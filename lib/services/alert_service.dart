import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// Centralized alert/automation engine for WattX.
/// Monitors: power overage, idle device auto-off, bill milestone, schedules.
class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  final DatabaseReference _alertsRef = FirebaseDatabase.instance.ref('Alerts');
  final DatabaseReference _controlRef =
      FirebaseDatabase.instance.ref('Devices/METER001/controls');
  final DatabaseReference _readingRef =
      FirebaseDatabase.instance.ref('EnergyReadings/live/METER001');

  // ── Config (low values for easy testing) ──────────────────────────────────
  static const double overagePowerThresholdKW = 0.5; // kW → alert if exceeded
  static const double billMilestoneRs = 10.0; // ₹ → alert every ₹10
  static const int idleAutoOffMinutes = 2; // mins until auto-off
  static const double costPerKwh = 6.50; // ₹ per kWh (KSEB basic)

  // ── Internal tracking ─────────────────────────────────────────────────────
  final Map<String, DateTime> _deviceOnSince = {};
  final Map<String, Timer> _idleTimers = {};
  double _lastBillMilestone = 0;
  double _accumulatedKwh = 0;
  DateTime? _sessionStart;

  StreamSubscription<DatabaseEvent>? _powerSub;
  StreamSubscription<DatabaseEvent>? _controlSub;
  final List<Timer> _scheduleTimers = [];

  bool _running = false;

  // ── Public API ────────────────────────────────────────────────────────────

  void start() {
    if (_running) return;
    _running = true;
    _sessionStart = DateTime.now();
    _monitorPower();
    _monitorDevices();
  }

  void stop() {
    _running = false;
    _powerSub?.cancel();
    _controlSub?.cancel();
    for (final t in _idleTimers.values) t.cancel();
    for (final t in _scheduleTimers) t.cancel();
    _idleTimers.clear();
    _scheduleTimers.clear();
  }

  /// Schedule a device to be turned OFF at [hour]:[minute] every day.
  void addSchedule({
    required String deviceKey,
    required int hour,
    required int minute,
    String label = '',
  }) {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (target.isBefore(now)) target = target.add(const Duration(days: 1));
    final delay = target.difference(now);

    final t = Timer(delay, () async {
      await _controlRef.child(deviceKey).update({'isOn': false});
      await _pushAlert(
        title: '⏰ Schedule Triggered',
        message: '$label turned OFF automatically by your schedule.',
        type: 'info',
      );
      // Re-schedule for next day
      addSchedule(
          deviceKey: deviceKey, hour: hour, minute: minute, label: label);
    });
    _scheduleTimers.add(t);
  }

  // ── Internal monitoring ───────────────────────────────────────────────────

  void _monitorPower() {
    bool _overageAlertSent = false;

    _powerSub = _readingRef.onValue.listen((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return;

      final power = (data['power'] as num?)?.toDouble() ?? 0.0;

      // Accumulate kWh for bill milestone
      final now = DateTime.now();
      if (_sessionStart != null) {
        final hours = now.difference(_sessionStart!).inSeconds / 3600.0;
        _accumulatedKwh = power * hours;
        final cost = _accumulatedKwh * costPerKwh;
        _checkBillMilestone(cost);
      }

      // Overage alert (debounce: only send once per surge)
      if (power > overagePowerThresholdKW && !_overageAlertSent) {
        _overageAlertSent = true;
        await _pushAlert(
          title: '⚡ Power Overage!',
          message:
              'Current usage is ${power.toStringAsFixed(2)} kW, exceeding your '
              '${overagePowerThresholdKW.toStringAsFixed(1)} kW threshold.',
          type: 'critical',
        );
      } else if (power <= overagePowerThresholdKW) {
        _overageAlertSent = false; // reset so it can fire again
      }
    });
  }

  void _monitorDevices() {
    _controlSub = _controlRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return;

      for (final entry in data.entries) {
        final key = entry.key as String;
        final state = entry.value;
        if (state is! Map) continue;
        final isOn = state['isOn'] == true;

        if (isOn) {
          // Start tracking when device was turned on
          _deviceOnSince.putIfAbsent(key, () => DateTime.now());
          // Set idle auto-off timer
          _idleTimers[key]?.cancel();
          _idleTimers[key] = Timer(
            Duration(minutes: idleAutoOffMinutes),
            () => _handleIdleAutoOff(key),
          );
        } else {
          // Device turned OFF — cancel timer and clear tracking
          _idleTimers[key]?.cancel();
          _idleTimers.remove(key);
          _deviceOnSince.remove(key);
        }
      }
    });
  }

  Future<void> _handleIdleAutoOff(String key) async {
    final sinceTime = _deviceOnSince[key];
    final label = _friendlyName(key);
    final minutes = sinceTime != null
        ? DateTime.now().difference(sinceTime).inMinutes
        : idleAutoOffMinutes;

    // Turn off in Firebase → mqtt_sync.py will relay to ESP32
    await _controlRef.child(key).update({'isOn': false});
    _deviceOnSince.remove(key);

    await _pushAlert(
      title: '💡 Auto-Off: $label',
      message: '$label has been ON for $minutes minute(s) with no change. '
          'It was turned OFF automatically to save energy.',
      type: 'warning',
    );
  }

  void _checkBillMilestone(double currentCostRs) async {
    final milestone =
        (currentCostRs / billMilestoneRs).floor() * billMilestoneRs;
    if (milestone > _lastBillMilestone && milestone > 0) {
      _lastBillMilestone = milestone;
      await _pushAlert(
        title: '💸 Bill Milestone Reached',
        message: 'Your estimated bill this session has crossed '
            '₹${milestone.toStringAsFixed(0)}. '
            'Total so far: ₹${currentCostRs.toStringAsFixed(2)}.',
        type: 'warning',
      );
    }
  }

  Future<void> _pushAlert({
    required String title,
    required String message,
    required String type,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ref = _alertsRef.child(uid).push();
    await ref.set({
      'title': title,
      'message': message,
      'type': type,
      'timestamp': ServerValue.timestamp,
      'isRead': false,
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _friendlyName(String key) {
    const map = {
      'LED 1': 'Light 1',
      'LED 2': 'Light 2',
      'LED 3': 'Light 3',
      'Motor 1': 'Fan 1',
      'Motor 2': 'Fan 2',
    };
    return map[key] ?? key;
  }
}

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

/// Result of the anomaly check — exposes the percentage difference and severity.
class AnomalyResult {
  final double currentPower; // live kW
  final double baselineAvg; // 7-day average kW
  final double percentDiff; // positive = higher, negative = lower
  final AnomalySeverity severity;

  const AnomalyResult({
    required this.currentPower,
    required this.baselineAvg,
    required this.percentDiff,
    required this.severity,
  });

  bool get isAnomaly => severity != AnomalySeverity.normal;

  String get label {
    final abs = percentDiff.abs().toStringAsFixed(0);
    if (percentDiff > 0) return '$abs% higher than usual';
    return '$abs% lower than usual';
  }

  String get emoji {
    switch (severity) {
      case AnomalySeverity.critical:
        return '🚨';
      case AnomalySeverity.high:
        return '⚠️';
      case AnomalySeverity.low:
        return '✅';
      case AnomalySeverity.normal:
        return '📊';
    }
  }
}

enum AnomalySeverity { normal, low, high, critical }

/// Watches live power vs stored 7-day average and emits [AnomalyResult] events.
class AnomalyService {
  static final AnomalyService _instance = AnomalyService._internal();
  factory AnomalyService() => _instance;
  AnomalyService._internal();

  static const String _meterId = 'METER001';

  // Thresholds (% above baseline to trigger each level)
  static const double _highThreshold = 30.0; // ≥30% → WARNING
  static const double _criticalThreshold = 60.0; // ≥60% → CRITICAL
  static const double _lowThreshold = -25.0; // ≤-25% → LOW (notably good)

  // How many live readings to keep in memory for a rolling average
  static const int _sampleWindow = 12; // ~2 minutes of readings

  final DatabaseReference _liveRef =
      FirebaseDatabase.instance.ref('EnergyReadings/live/$_meterId');
  final DatabaseReference _dailyRef =
      FirebaseDatabase.instance.ref('EnergyReadings/daily/$_meterId');
  final DatabaseReference _anomalyRef =
      FirebaseDatabase.instance.ref('EnergyReadings/anomaly/$_meterId');

  // Internal state
  final List<double> _recentSamples = [];
  StreamSubscription<DatabaseEvent>? _liveSub;

  // Public stream that the dashboard listens to
  final StreamController<AnomalyResult> _controller =
      StreamController<AnomalyResult>.broadcast();

  Stream<AnomalyResult> get stream => _controller.stream;

  // ── Public API ─────────────────────────────────────────────────────────────

  void start() {
    _liveSub?.cancel();
    _liveSub = _liveRef.onValue.listen(_onLiveReading);
  }

  void stop() {
    _liveSub?.cancel();
    _controller.close();
  }

  // ── Core logic ─────────────────────────────────────────────────────────────

  Future<void> _onLiveReading(DatabaseEvent event) async {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return;

    final power = (data['power'] as num?)?.toDouble() ?? 0.0;

    // Maintain a rolling window of recent samples
    _recentSamples.add(power);
    if (_recentSamples.length > _sampleWindow) _recentSamples.removeAt(0);

    // Current power = average of last N samples (smoothed)
    final currentAvg = _recentSamples.isEmpty
        ? power
        : _recentSamples.reduce((a, b) => a + b) / _recentSamples.length;

    // Read stored 7-day baseline from Firebase
    final baseline = await _fetchBaselineAvg();

    // Also write today's running average so Python/other days can read it
    await _writeTodayAvg(currentAvg);

    if (baseline <= 0) {
      // Not enough history yet — publish raw result with no anomaly
      _controller.add(AnomalyResult(
        currentPower: currentAvg,
        baselineAvg: 0,
        percentDiff: 0,
        severity: AnomalySeverity.normal,
      ));
      return;
    }

    final pct = ((currentAvg - baseline) / baseline) * 100;
    final severity = _classify(pct);

    final result = AnomalyResult(
      currentPower: currentAvg,
      baselineAvg: baseline,
      percentDiff: pct,
      severity: severity,
    );

    _controller.add(result);

    // Write anomaly state to Firebase for Python/other clients to read
    await _anomalyRef.set({
      'percentDiff': pct,
      'currentPower': currentAvg,
      'baselinePower': baseline,
      'severity': severity.name,
      'timestamp': ServerValue.timestamp,
    });
  }

  /// Reads the last 7 days of stored daily averages and returns the mean.
  Future<double> _fetchBaselineAvg() async {
    try {
      final snap = await _dailyRef.get();
      if (!snap.exists) return 0;
      final map = snap.value as Map<dynamic, dynamic>;

      final today = _todayKey();
      final values = map.entries
          .where((e) => e.key != today) // exclude today (in progress)
          .map((e) {
            final v = e.value;
            if (v is Map && v.containsKey('avgPower')) {
              return (v['avgPower'] as num).toDouble();
            }
            return 0.0;
          })
          .where((v) => v > 0)
          .toList();

      if (values.isEmpty) return 0;
      // Take up to the last 7 days
      final recent =
          values.length > 7 ? values.sublist(values.length - 7) : values;
      return recent.reduce((a, b) => a + b) / recent.length;
    } catch (_) {
      return 0;
    }
  }

  /// Writes/updates today's running average power to Firebase.
  Future<void> _writeTodayAvg(double avgPower) async {
    try {
      final key = _todayKey();
      final ref = _dailyRef.child(key);
      final snap = await ref.child('sampleCount').get();
      final count = (snap.value as num?)?.toInt() ?? 0;

      // Running average update: newAvg = (oldAvg * n + newVal) / (n+1)
      final snap2 = await ref.child('avgPower').get();
      final oldAvg = (snap2.value as num?)?.toDouble() ?? avgPower;
      final newAvg = (oldAvg * count + avgPower) / (count + 1);

      await ref.update({
        'avgPower': newAvg,
        'sampleCount': count + 1,
        'date': key,
        'lastUpdated': ServerValue.timestamp,
      });
    } catch (_) {}
  }

  AnomalySeverity _classify(double pct) {
    if (pct >= _criticalThreshold) return AnomalySeverity.critical;
    if (pct >= _highThreshold) return AnomalySeverity.high;
    if (pct <= _lowThreshold) return AnomalySeverity.low;
    return AnomalySeverity.normal;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

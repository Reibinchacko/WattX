import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'theme/app_theme.dart';
import 'schedules_screen.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final DatabaseReference _controlRef =
      FirebaseDatabase.instance.ref('Devices/METER001/controls');

  // Mutable lists so drag-to-reorder works
  List<_DeviceConfig> _lights = [
    const _DeviceConfig(
        key: 'LED 1', label: 'Light 1', location: 'Living Room'),
    const _DeviceConfig(key: 'LED 2', label: 'Light 2', location: 'Bedroom'),
    const _DeviceConfig(key: 'LED 3', label: 'Light 3', location: 'Kitchen'),
  ];

  List<_DeviceConfig> _fans = [
    const _DeviceConfig(
        key: 'Motor 1', label: 'Fan 1', location: 'Living Room'),
    const _DeviceConfig(key: 'Motor 2', label: 'Fan 2', location: 'Bedroom'),
  ];

  final Map<String, bool> _states = {
    'LED 1': false,
    'LED 2': false,
    'LED 3': false,
    'Motor 1': false,
    'Motor 2': false,
  };

  // Usage time: records when each device was switched ON
  final Map<String, DateTime> _onSince = {};

  bool _isLoading = true;
  late DatabaseReference _listener;
  Timer? _ticker; // refreshes all duration displays every second

  @override
  void initState() {
    super.initState();
    _listenToFirebase();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _listenToFirebase() {
    _listener = _controlRef;
    _listener.onValue.listen((event) {
      if (!mounted) return;
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      setState(() {
        _isLoading = false;
        if (data != null) {
          for (final key in _states.keys) {
            final deviceData = data[key];
            if (deviceData is Map && deviceData.containsKey('isOn')) {
              final newVal = deviceData['isOn'] == true;
              final wasOn = _states[key] ?? false;
              _states[key] = newVal;
              // Start/stop usage timer
              if (newVal && !wasOn) {
                _onSince[key] = DateTime.now();
              } else if (!newVal) {
                _onSince.remove(key);
              }
            }
          }
        }
      });
    }, onError: (e) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Future<void> _toggle(String key, bool value) async {
    HapticFeedback.lightImpact();
    setState(() {
      _states[key] = value;
      if (value) {
        _onSince[key] = DateTime.now();
      } else {
        _onSince.remove(key);
      }
    });
    await _controlRef.child(key).update({'isOn': value});
  }

  /// Turns ALL devices ON or OFF at once.
  Future<void> _setAll(bool value) async {
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    setState(() {
      for (final key in _states.keys) {
        _states[key] = value;
        if (value) {
          _onSince[key] ??= now;
        } else {
          _onSince.remove(key);
        }
      }
    });
    for (final key in _states.keys) {
      await _controlRef.child(key).update({'isOn': value});
    }
  }

  /// Returns a human-readable usage duration for a device.
  String _formatDuration(String key) {
    final since = _onSince[key];
    if (since == null) return 'Standby';
    final d = DateTime.now().difference(since);
    if (d.inHours > 0) {
      return 'ON · ${d.inHours}h ${d.inMinutes.remainder(60)}m';
    } else if (d.inMinutes > 0) {
      return 'ON · ${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    } else {
      return 'ON · ${d.inSeconds}s';
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allOn = _states.values.every((v) => v);
    final allOff = _states.values.every((v) => !v);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: _buildHeader(isDark, allOn, allOff),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            icon: Icons.light_rounded,
                            title: 'LIGHTS',
                            color: AppTheme.primaryGold,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildReorderableSection(
                            devices: _lights,
                            icon: Icons.light_rounded,
                            color: AppTheme.primaryGold,
                            isDark: isDark,
                            onReorder: (o, n) => setState(() {
                              if (n > o) n--;
                              _lights.insert(n, _lights.removeAt(o));
                            }),
                          ),
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                            icon: Icons.wind_power_rounded,
                            title: 'FANS',
                            color: Colors.blueAccent,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildReorderableSection(
                            devices: _fans,
                            icon: Icons.wind_power_rounded,
                            color: Colors.blueAccent,
                            isDark: isDark,
                            onReorder: (o, n) => setState(() {
                              if (n > o) n--;
                              _fans.insert(n, _fans.removeAt(o));
                            }),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool allOn, bool allOff) {
    final activeCount = _states.values.where((v) => v).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AUTOMATION',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? Colors.white38
                          : AppTheme.midnightCharcoal.withValues(alpha: 0.5),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Control Center',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.midnightCharcoal,
                    ),
                  ),
                ],
              ),
            ),
            // Schedules shortcut
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SchedulesScreen()),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm_rounded,
                        color: Colors.blueAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Schedules',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Active count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$activeCount / ${_states.length} ON',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── All ON / All OFF buttons ──────────────────────────────────────
        Row(
          children: [
            // ALL ON
            Expanded(
              child: GestureDetector(
                onTap: allOn ? null : () => _setAll(true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: allOn
                        ? Colors.green
                        : Colors.green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: allOn ? 0 : 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.power_settings_new_rounded,
                        size: 16,
                        color: allOn ? Colors.white : Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'All ON',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: allOn ? Colors.white : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ALL OFF
            Expanded(
              child: GestureDetector(
                onTap: allOff ? null : () => _setAll(false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: allOff
                        ? AppTheme.midnightCharcoal
                        : AppTheme.midnightCharcoal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.midnightCharcoal
                          .withValues(alpha: allOff ? 0 : 0.22),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.power_off_rounded,
                        size: 16,
                        color: allOff
                            ? Colors.white
                            : (isDark
                                ? Colors.white60
                                : AppTheme.midnightCharcoal),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'All OFF',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: allOff
                              ? Colors.white
                              : (isDark
                                  ? Colors.white60
                                  : AppTheme.midnightCharcoal),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildReorderableSection({
    required List<_DeviceConfig> devices,
    required IconData icon,
    required Color color,
    required bool isDark,
    required void Function(int, int) onReorder,
  }) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorder: onReorder,
      // Animated lift effect: scale up + gold shadow when dragging
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final t = Curves.easeInOut.transform(animation.value);
            return Transform.scale(
              scale: 1.0 + t * 0.04,
              child: Material(
                color: Colors.transparent,
                elevation: t * 22,
                borderRadius: BorderRadius.circular(24),
                shadowColor: color.withValues(alpha: 0.55),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      children: [
        for (int i = 0; i < devices.length; i++)
          // Wrap entire tile — hold anywhere to drag
          ReorderableDelayedDragStartListener(
            key: ValueKey(devices[i].key),
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildControlTile(
                config: devices[i],
                icon: icon,
                color: color,
                isDark: isDark,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildControlTile({
    required _DeviceConfig config,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final isOn = _states[config.key] ?? false;
    final duration = _formatDuration(config.key);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isOn ? AppTheme.premiumShadow : AppTheme.softShadow,
        border: isOn
            ? Border.all(color: color.withValues(alpha: 0.4), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          // Icon bubble
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOn
                  ? color.withValues(alpha: 0.18)
                  : color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isOn
                  ? [
                      BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 1)
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isOn ? color : color.withValues(alpha: 0.5),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.midnightCharcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  config.location,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white38
                        : AppTheme.midnightCharcoal.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                // ── Usage time counter ──────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    duration,
                    key: ValueKey(duration),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isOn
                          ? Colors.green
                          : (isDark ? Colors.white24 : Colors.black26),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Toggle switch
          Switch(
            value: isOn,
            onChanged: (val) => _toggle(config.key, val),
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.2),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.black.withValues(alpha: 0.07),
          ),
        ],
      ),
    );
  }
}

class _DeviceConfig {
  final String key;
  final String label;
  final String location;
  const _DeviceConfig({
    required this.key,
    required this.label,
    required this.location,
  });
}

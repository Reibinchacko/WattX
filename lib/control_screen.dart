import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'theme/app_theme.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final DatabaseReference _controlRef =
      FirebaseDatabase.instance.ref('Devices/METER001/controls');

  // Device keys must match mqtt_sync.py topic_map keys exactly
  final List<_DeviceConfig> _lights = [
    const _DeviceConfig(
        key: 'LED 1', label: 'Light 1', location: 'Living Room'),
    const _DeviceConfig(key: 'LED 2', label: 'Light 2', location: 'Bedroom'),
    const _DeviceConfig(key: 'LED 3', label: 'Light 3', location: 'Kitchen'),
  ];

  final List<_DeviceConfig> _fans = [
    const _DeviceConfig(
        key: 'Motor 1', label: 'Fan 1', location: 'Living Room'),
    const _DeviceConfig(key: 'Motor 2', label: 'Fan 2', location: 'Bedroom'),
  ];

  // Local state map: device key -> isOn
  final Map<String, bool> _states = {
    'LED 1': false,
    'LED 2': false,
    'LED 3': false,
    'Motor 1': false,
    'Motor 2': false,
  };

  bool _isLoading = true;
  late DatabaseReference _listener;

  @override
  void initState() {
    super.initState();
    _listenToFirebase();
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
              _states[key] = deviceData['isOn'] == true;
            }
          }
        }
      });
    }, onError: (e) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Future<void> _toggle(String key, bool value) async {
    setState(() => _states[key] = value);
    await _controlRef.child(key).update({'isOn': value});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isDark),
                    const SizedBox(height: 28),

                    // ── Lights ──
                    _buildSectionHeader(
                      icon: Icons.light_rounded,
                      title: 'LIGHTS',
                      color: AppTheme.primaryGold,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    ..._lights.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildControlTile(
                            config: d,
                            icon: Icons.light_rounded,
                            color: AppTheme.primaryGold,
                            isDark: isDark,
                          ),
                        )),

                    const SizedBox(height: 28),

                    // ── Fans ──
                    _buildSectionHeader(
                      icon: Icons.wind_power_rounded,
                      title: 'FANS',
                      color: Colors.blueAccent,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    ..._fans.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildControlTile(
                            config: d,
                            icon: Icons.wind_power_rounded,
                            color: Colors.blueAccent,
                            isDark: isDark,
                          ),
                        )),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final activeCount = _states.values.where((v) => v).length;
    return Row(
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

  Widget _buildControlTile({
    required _DeviceConfig config,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final isOn = _states[config.key] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isOn ? AppTheme.premiumShadow : AppTheme.softShadow,
        border: isOn
            ? Border.all(
                color: color.withValues(alpha: 0.4),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          // Icon with animated glow when ON
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(13),
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
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isOn ? color : color.withValues(alpha: 0.5),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    isOn ? '● Running' : '○ Standby',
                    key: ValueKey(isOn),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isOn ? Colors.green : Colors.black26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
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

// Simple config holder
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

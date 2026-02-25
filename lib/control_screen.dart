import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final Map<String, bool> _deviceStates = {
    'Living Room Lights': true,
    'Air Conditioner': false,
    'Smart TV': true,
    'Refrigerator': true,
    'Water Heater': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildCategoryTitle('SMART DEVICES'),
              const SizedBox(height: 16),
              ..._deviceStates.keys.map((device) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildControlTile(
                    icon: _getIconForDevice(device),
                    title: device,
                    isOn: _deviceStates[device]!,
                    color: _getColorForDevice(device),
                    onChanged: (val) =>
                        setState(() => _deviceStates[device] = val),
                  ),
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AUTOMATION',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness == Brightness.dark
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
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppTheme.midnightCharcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppTheme.midnightCharcoal.withValues(alpha: 0.4),
        letterSpacing: 1.0,
      ),
    );
  }

  IconData _getIconForDevice(String name) {
    if (name.contains('Light')) return Icons.light_rounded;
    if (name.contains('Air')) return Icons.ac_unit_rounded;
    if (name.contains('TV')) return Icons.tv_rounded;
    if (name.contains('Refrigerator')) return Icons.kitchen_rounded;
    if (name.contains('Water')) return Icons.water_drop_rounded;
    return Icons.settings_remote_rounded;
  }

  Color _getColorForDevice(String name) {
    if (name.contains('Light')) return AppTheme.primaryGold;
    if (name.contains('Air')) return Colors.blue;
    if (name.contains('TV')) return Colors.purple;
    if (name.contains('Refrigerator')) return Colors.green;
    if (name.contains('Water')) return Colors.orange;
    return AppTheme.midnightCharcoal;
  }

  Widget _buildControlTile({
    required IconData icon,
    required String title,
    required bool isOn,
    required Color color,
    required Function(bool) onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
        border: isOn
            ? Border.all(
                color: AppTheme.primaryGold.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppTheme.midnightCharcoal,
                  ),
                ),
                Text(
                  isOn ? 'Running' : 'Standby',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isOn ? Colors.green : Colors.black26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isOn,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryGold,
            activeTrackColor: AppTheme.primaryGold.withValues(alpha: 0.1),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
    );
  }
}

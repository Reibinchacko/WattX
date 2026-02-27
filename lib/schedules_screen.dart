import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'services/alert_service.dart';

/// A schedule entry held in memory (no persistence needed for demo).
class _ScheduleEntry {
  final String deviceKey;
  final String deviceLabel;
  final IconData icon;
  final Color color;
  final TimeOfDay time;

  _ScheduleEntry({
    required this.deviceKey,
    required this.deviceLabel,
    required this.icon,
    required this.color,
    required this.time,
  });
}

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  final List<_ScheduleEntry> _schedules = [];

  final List<Map<String, dynamic>> _deviceOptions = [
    {
      'key': 'LED 1',
      'label': 'Light 1',
      'icon': Icons.lightbulb_rounded,
      'color': const Color(0xFFFFD700)
    },
    {
      'key': 'LED 2',
      'label': 'Light 2',
      'icon': Icons.lightbulb_rounded,
      'color': const Color(0xFFFFD700)
    },
    {
      'key': 'LED 3',
      'label': 'Light 3',
      'icon': Icons.lightbulb_rounded,
      'color': const Color(0xFFFFD700)
    },
    {
      'key': 'Motor 1',
      'label': 'Fan 1',
      'icon': Icons.wind_power_rounded,
      'color': Colors.blueAccent
    },
    {
      'key': 'Motor 2',
      'label': 'Fan 2',
      'icon': Icons.wind_power_rounded,
      'color': Colors.blueAccent
    },
  ];

  String? _selectedKey;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 22, minute: 0);

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primaryGold),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _addSchedule() {
    if (_selectedKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a device first.')),
      );
      return;
    }
    final opt = _deviceOptions.firstWhere((d) => d['key'] == _selectedKey);

    final entry = _ScheduleEntry(
      deviceKey: _selectedKey!,
      deviceLabel: opt['label'] as String,
      icon: opt['icon'] as IconData,
      color: opt['color'] as Color,
      time: _selectedTime,
    );

    setState(() => _schedules.add(entry));

    // Register with AlertService
    AlertService().addSchedule(
      deviceKey: entry.deviceKey,
      hour: entry.time.hour,
      minute: entry.time.minute,
      label: entry.deviceLabel,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          '${entry.deviceLabel} will auto-off at ${entry.time.format(context)} daily.',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _removeSchedule(int index) {
    setState(() => _schedules.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildInfoBanner(isDark),
                    const SizedBox(height: 24),
                    _buildAddScheduleCard(isDark),
                    const SizedBox(height: 28),
                    _buildScheduleList(isDark),
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

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppTheme.softShadow,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? Colors.white70 : AppTheme.midnightCharcoal,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AUTOMATION',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryGold,
                  letterSpacing: 1.4,
                ),
              ),
              Text(
                'Schedules',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.midnightCharcoal,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_schedules.length} Active',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Colors.blueAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Schedules run while the app is open. '
              'Set a time and device to auto-turn it OFF daily.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddScheduleCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Schedule',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.midnightCharcoal,
            ),
          ),
          const SizedBox(height: 16),

          // Device Dropdown
          Text(
            'SELECT DEVICE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white38 : Colors.black38,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedKey,
                hint: Text(
                  'Choose a device…',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E2025) : Colors.white,
                items: _deviceOptions.map((d) {
                  return DropdownMenuItem<String>(
                    value: d['key'] as String,
                    child: Row(
                      children: [
                        Icon(d['icon'] as IconData,
                            color: d['color'] as Color, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          d['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : AppTheme.midnightCharcoal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedKey = v),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Time Picker Row
          Text(
            'AUTO-OFF TIME',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white38 : Colors.black38,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.primaryGold.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      color: AppTheme.primaryGold, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    _selectedTime.format(context),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Tap to change',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.primaryGold.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Add Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addSchedule,
              icon: const Icon(Icons.add_alarm_rounded, size: 20),
              label: Text(
                'Add Schedule',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: AppTheme.midnightCharcoal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(bool isDark) {
    if (_schedules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            children: [
              Icon(Icons.alarm_off_rounded,
                  size: 56, color: isDark ? Colors.white24 : Colors.black12),
              const SizedBox(height: 12),
              Text(
                'No schedules yet',
                style: GoogleFonts.inter(
                    fontSize: 15,
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Add one above to auto-turn off devices.',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? Colors.white24 : Colors.black26),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIVE SCHEDULES',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white38 : Colors.black38,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_schedules.length, (i) {
          final s = _schedules[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: s.color.withValues(alpha: 0.3), width: 1.2),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: s.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(s.icon, color: s.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.deviceLabel,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : AppTheme.midnightCharcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Auto-OFF at ${s.time.format(context)} daily',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '● Active',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _removeSchedule(i),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: Colors.red, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

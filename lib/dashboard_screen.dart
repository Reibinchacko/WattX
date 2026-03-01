import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'analytics_screen.dart';
import 'notifications_screen.dart';
import 'bill_savings_screen.dart';
import 'profile_screen.dart';
import 'control_screen.dart';
import 'services/alert_service.dart';
import 'theme/app_theme.dart';
import 'services/database_service.dart';
import 'services/anomaly_service.dart';
import 'models/reading_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;
  final DatabaseService _databaseService = DatabaseService();

  // Quick-control device states (mirrors ControlScreen Firebase path)
  final DatabaseReference _controlRef =
      FirebaseDatabase.instance.ref('Devices/METER001/controls');

  final List<Map<String, dynamic>> _quickDevices = [
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

  final Map<String, bool> _deviceStates = {
    'LED 1': false,
    'LED 2': false,
    'LED 3': false,
    'Motor 1': false,
    'Motor 2': false,
  };

  late DatabaseReference _deviceListener;

  // Anomaly detection
  AnomalyResult? _anomaly;
  StreamSubscription<AnomalyResult>? _anomalySub;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _listenToDevices();
    _anomalySub = AnomalyService().stream.listen((result) {
      if (mounted) setState(() => _anomaly = result);
    });
  }

  void _listenToDevices() {
    _deviceListener = _controlRef;
    _deviceListener.onValue.listen((event) {
      if (!mounted) return;
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      setState(() {
        if (data != null) {
          for (final key in _deviceStates.keys) {
            final deviceData = data[key];
            if (deviceData is Map && deviceData.containsKey('isOn')) {
              _deviceStates[key] = deviceData['isOn'] == true;
            }
          }
        }
      });
    });
  }

  Future<void> _quickToggle(String key) async {
    final newVal = !(_deviceStates[key] ?? false);
    HapticFeedback.lightImpact();
    setState(() => _deviceStates[key] = newVal);
    await _controlRef.child(key).update({'isOn': newVal});
  }

  @override
  void dispose() {
    _anomalySub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildDashboardView(),
          const AnalyticsScreen(),
          const BillSavingsScreen(),
          const ControlScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 70, // Slightly more compact nav
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1C1E) : AppTheme.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.grid_view_rounded, 0, 'Home'),
          _buildNavItem(Icons.show_chart_rounded, 1, 'Analytics'),
          _buildNavItem(Icons.receipt_long_outlined, 2, 'Billing'),
          _buildNavItem(Icons.tune_rounded, 3, 'Control'),
          _buildNavItem(Icons.person_outline_rounded, 4, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryGold.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppTheme.midnightCharcoal)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white24
                      : Colors.black26),
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppTheme.midnightCharcoal)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white24
                      : Colors.black26),
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildDashboardView() {
    final user = FirebaseAuth.instance.currentUser;
    const String meterId = 'METER001';

    return StreamBuilder<ReadingModel?>(
      stream: _databaseService.getLiveReading(meterId),
      builder: (context, snapshot) {
        ReadingModel? reading = snapshot.data;

        return Stack(
          children: [
            // Dark Header Section (More Compact - 0.22 instead of 0.35)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.22,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.midnightCharcoal,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryGold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_rounded,
                                  color: AppTheme.midnightCharcoal),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome Back',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    user?.displayName ?? 'Alex Morgan',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildCircleButton(
                              icon: Icons.notifications_none_rounded,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationsScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content Section (Moved Up)
            Positioned.fill(
              top: MediaQuery.of(context).size.height * 0.12,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  children: [
                    // Main Power Card
                    _buildMainPowerCard(reading),

                    const SizedBox(height: 12),

                    // Anomaly Banner (only shown when anomaly detected)
                    if (_anomaly != null) _buildAnomalyBanner(_anomaly!),
                    if (_anomaly != null) const SizedBox(height: 12),

                    // Quick Device Controls
                    _buildQuickDeviceStrip(),

                    const SizedBox(height: 20),

                    // Metrics Grid (More Compact Spacing)
                    _buildMetricsGrid(reading),

                    const SizedBox(height: 20),

                    // Daily Goal Card
                    _buildDailyGoalCard(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCircleButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildMainPowerCard(ReadingModel? reading) {
    // Determine status chip label + color from anomaly result
    final String statusLabel;
    final Color statusColor;
    switch (_anomaly?.severity) {
      case AnomalySeverity.critical:
        statusLabel = 'Critical';
        statusColor = Colors.red;
        break;
      case AnomalySeverity.high:
        statusLabel = 'High Usage';
        statusColor = Colors.orange;
        break;
      case AnomalySeverity.low:
        statusLabel = 'Efficient ✔';
        statusColor = Colors.green;
        break;
      default:
        statusLabel = 'Optimal';
        statusColor = AppTheme.midnightCharcoal;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LIVE POWER USAGE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.midnightCharcoal.withValues(alpha: 0.6),
                  letterSpacing: 1.0,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                reading?.power.toStringAsFixed(2) ?? '0.00',
                style: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.midnightCharcoal,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'kW',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.midnightCharcoal.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  (_anomaly?.percentDiff ?? 0) < 0
                      ? Icons.trending_down_rounded
                      : Icons.trending_up_rounded,
                  color: (_anomaly?.percentDiff ?? 0) < 0
                      ? Colors.green
                      : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _anomaly != null && _anomaly!.baselineAvg > 0
                      ? _anomaly!.label
                      : 'Building usage baseline…',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.midnightCharcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Animated anomaly banner shown below the power card when anomaly detected.
  Widget _buildAnomalyBanner(AnomalyResult anomaly) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bannerColor;
    final Color bgColor;
    final IconData bannerIcon;
    final String title;

    switch (anomaly.severity) {
      case AnomalySeverity.critical:
        bannerColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: isDark ? 0.18 : 0.08);
        bannerIcon = Icons.warning_amber_rounded;
        title = '🚨 Anomaly Detected!';
        break;
      case AnomalySeverity.high:
        bannerColor = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: isDark ? 0.18 : 0.08);
        bannerIcon = Icons.trending_up_rounded;
        title = '⚠️ High Usage Alert';
        break;
      case AnomalySeverity.low:
        bannerColor = Colors.green;
        bgColor = Colors.green.withValues(alpha: isDark ? 0.18 : 0.08);
        bannerIcon = Icons.eco_rounded;
        title = '✅ Great Efficiency!';
        break;
      default:
        return const SizedBox.shrink();
    }

    final absPct = anomaly.percentDiff.abs().toStringAsFixed(0);
    final baseKw = anomaly.baselineAvg.toStringAsFixed(2);
    final curKw = anomaly.currentPower.toStringAsFixed(2);
    final direction = anomaly.percentDiff > 0 ? 'above' : 'below';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: bannerColor.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: bannerColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(bannerIcon, color: bannerColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: bannerColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Usage is $absPct% $direction your 7-day average '
                  '($curKw kW now vs $baseKw kW avg)',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white70
                        : AppTheme.midnightCharcoal.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          // Percentage badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: bannerColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${anomaly.percentDiff > 0 ? '+' : ''}${anomaly.percentDiff.toStringAsFixed(0)}%',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: bannerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDeviceStrip() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Text(
                'QUICK CONTROLS',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? Colors.white38
                      : AppTheme.midnightCharcoal.withValues(alpha: 0.45),
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _deviceStates.values.any((v) => v)
                      ? Colors.greenAccent
                      : (isDark ? Colors.white24 : Colors.black12),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _quickDevices.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final device = _quickDevices[index];
              final key = device['key'] as String;
              final label = device['label'] as String;
              final icon = device['icon'] as IconData;
              final color = device['color'] as Color;
              final isOn = _deviceStates[key] ?? false;

              return _buildGlassPill(
                key: key,
                label: label,
                icon: icon,
                color: color,
                isOn: isOn,
                isDark: isDark,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Shows an inline bottom-sheet schedule picker for a quick-control device.
  void _showScheduleSheet({
    required String deviceKey,
    required String deviceLabel,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    TimeOfDay pickedTime = const TimeOfDay(hour: 22, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheet) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              24,
              20,
              24,
              MediaQuery.of(sheetCtx).viewInsets.bottom + 32,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1C1E) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sheet drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white24
                        : Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),

                // Device header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.85),
                            color.withValues(alpha: 0.50),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 12)
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Schedule',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white38
                                : AppTheme.midnightCharcoal
                                    .withValues(alpha: 0.45),
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          deviceLabel,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : AppTheme.midnightCharcoal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Time picker row
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: sheetCtx,
                      initialTime: pickedTime,
                      initialEntryMode: TimePickerEntryMode.input,
                      builder: (ctx, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                              primary: AppTheme.primaryGold),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setSheet(() => pickedTime = picked);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppTheme.primaryGold.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            color: AppTheme.primaryGold, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          pickedTime.format(sheetCtx),
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
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

                const SizedBox(height: 10),
                Text(
                  'Device will auto-OFF daily at this time.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),

                const SizedBox(height: 20),

                // Add button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AlertService().addSchedule(
                        deviceKey: deviceKey,
                        hour: pickedTime.hour,
                        minute: pickedTime.minute,
                        label: deviceLabel,
                      );
                      Navigator.pop(sheetCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Text(
                            '$deviceLabel auto-OFF at ${pickedTime.format(context)} ✅',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.alarm_add_rounded, size: 20),
                    label: Text(
                      'Set Auto-OFF Schedule',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: AppTheme.midnightCharcoal,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassPill({
    required String key,
    required String label,
    required IconData icon,
    required Color color,
    required bool isOn,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => _quickToggle(key),
      // Long-press → show inline schedule bottom-sheet for this device
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showScheduleSheet(
          deviceKey: key,
          deviceLabel: label,
          icon: icon,
          color: color,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        width: 148,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          // Frosted glass base
          color: isOn
              ? color.withValues(alpha: isDark ? 0.18 : 0.10)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.85)),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isOn
                ? color.withValues(alpha: isDark ? 0.6 : 0.45)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.06)),
            width: 1.4,
          ),
          boxShadow: isOn
              ? [
                  // Outer glow (device color)
                  BoxShadow(
                    color: color.withValues(alpha: 0.38),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                  // Inner soft glow
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon bubble with pulse ring
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulse ring (only when ON)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  width: isOn ? 44 : 36,
                  height: isOn ? 44 : 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: isOn
                          ? color.withValues(alpha: 0.30)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                // Icon circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isOn
                        ? LinearGradient(
                            colors: [
                              color.withValues(alpha: 0.90),
                              color.withValues(alpha: 0.55),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isOn
                        ? null
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : color.withValues(alpha: 0.10)),
                    boxShadow: isOn
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.55),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isOn
                        ? Colors.white
                        : color.withValues(alpha: isDark ? 0.50 : 0.55),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            // Label + status chip
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isOn
                          ? (isDark ? Colors.white : AppTheme.midnightCharcoal)
                          : (isDark
                              ? Colors.white54
                              : AppTheme.midnightCharcoal
                                  .withValues(alpha: 0.55)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: isOn
                          ? color.withValues(alpha: isDark ? 0.30 : 0.18)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.07)
                              : Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Text(
                      isOn ? 'ON' : 'OFF',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: isOn
                            ? (isDark ? color.withValues(alpha: 0.95) : color)
                            : (isDark ? Colors.white30 : Colors.black26),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(ReadingModel? reading) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4, // Shallower cards
      padding: EdgeInsets.zero,
      children: [
        _buildMetricCard(
            'Voltage',
            reading?.voltage.toStringAsFixed(1) ?? '0.0',
            'V',
            Icons.bolt_rounded),
        _buildMetricCard(
            'Current',
            reading?.current.toStringAsFixed(2) ?? '0.00',
            'A',
            Icons.electric_meter_rounded),
        _buildMetricCard('Frequency', '50.1', 'Hz', Icons.waves_rounded),
        _buildMetricCard('Power Factor', '0.98', 'φ', Icons.speed_rounded),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, String unit, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1C1E) : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.midnightCharcoal,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalCard() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Shallower
      decoration: BoxDecoration(
        color: AppTheme.midnightCharcoal,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch_rounded,
                  color: AppTheme.primaryGold, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Goal',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '78% of 15 kWh target',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '78%',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.78,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGold),
            ),
          ),
        ],
      ),
    );
  }
}

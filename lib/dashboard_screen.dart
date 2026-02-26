import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'analytics_screen.dart';
import 'notifications_screen.dart';
import 'bill_savings_screen.dart';
import 'profile_screen.dart';
import 'control_screen.dart';
import 'theme/app_theme.dart';
import 'services/database_service.dart';
import 'models/reading_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // Shorter padding
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.midnightCharcoal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Optimal',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.midnightCharcoal,
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
                  fontSize: 40, // Slightly smaller font
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
                const Icon(Icons.trending_down_rounded,
                    color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text(
                  '12% lower than yesterday',
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

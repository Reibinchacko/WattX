import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'theme/app_theme.dart';
import 'energy_report_screen.dart';
import 'profile_screen.dart';
import 'kseb_consumer_list_screen.dart';
import 'kseb_alerts_screen.dart';

class KsebOfficerDashboardScreen extends StatefulWidget {
  const KsebOfficerDashboardScreen({super.key});

  @override
  State<KsebOfficerDashboardScreen> createState() =>
      _KsebOfficerDashboardScreenState();
}

class _KsebOfficerDashboardScreenState
    extends State<KsebOfficerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F8),
      body: SafeArea(
        child: _buildBody(_selectedIndex),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody(int index) {
    if (index == 0) return _buildDashboardContent();
    if (index == 1) return const KsebConsumerListScreen();
    if (index == 2) return const EnergyReportContent();
    if (index == 3) return const KsebAlertsScreen();
    if (index == 4) return const ProfileScreen();
    return const SizedBox();
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          _buildConsumptionTrendsCard(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt_rounded,
                  color: AppTheme.primaryGold, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Officer Portal',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.midnightCharcoal,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => setState(() => _selectedIndex = 3),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                const Icon(Icons.notifications_rounded,
                    color: AppTheme.primaryGold, size: 24),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KSEB SMART METER SYSTEM',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF919EAB),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Welcome,\nOfficer',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.midnightCharcoal,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedIndex = 1),
          child: _buildStatCard(
            '120,500',
            'Total Consumers',
            Icons.people_alt_rounded,
            const Color(0xFFFFB300),
          ),
        ),
        _buildStatCard(
          '118,200',
          'Active Meters',
          Icons.speed_rounded,
          const Color(0xFFFFB300),
        ),
        GestureDetector(
          onTap: () => setState(() => _selectedIndex = 3),
          child: _buildStatCard(
            '45',
            'Active Alerts',
            Icons.notifications_rounded,
            const Color(0xFFFFE0B2),
            iconColor: const Color(0xFFFF8A00),
          ),
        ),
        _buildStatCard(
          '1,200',
          'High Usage',
          Icons.trending_up_rounded,
          const Color(0xFFFFB300),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color bg,
      {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF637381),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.midnightCharcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionTrendsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consumption Trend',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.midnightCharcoal,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Sun',
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat'
                        ];
                        if (value < 0 || value >= days.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            days[value.toInt()],
                            style: GoogleFonts.inter(
                              color: const Color(0xFF919EAB),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1.2),
                      FlSpot(1, 1.8),
                      FlSpot(2, 1.5),
                      FlSpot(3, 2.2),
                      FlSpot(4, 1.9),
                      FlSpot(5, 2.8),
                      FlSpot(6, 3.2),
                    ],
                    isCurved: true,
                    color: AppTheme.primaryGold,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGold.withValues(alpha: 0.3),
                          AppTheme.primaryGold.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, 'Home', 0),
          _buildNavItem(Icons.people_alt_rounded, 'Consumers', 1),
          _buildNavItem(Icons.bar_chart_rounded, 'Reports', 2),
          _buildNavItem(Icons.notifications_rounded, 'Alerts', 3,
              hasBadge: true),
          _buildNavItem(Icons.person_rounded, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,
      {bool hasBadge = false}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: 70,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Container(
                width: 30,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 16),
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.primaryGold
                      : const Color(0xFF919EAB),
                  size: 26,
                ),
                if (hasBadge && !isSelected)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color:
                    isSelected ? AppTheme.primaryGold : const Color(0xFF919EAB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'user_management_screen.dart';
import 'assign_officer_screen.dart';
import 'energy_report_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F8),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _buildBody(),
      ),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_selectedIndex == 1) {
      return AppBar(
        backgroundColor: const Color(0xFFF9F9F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => setState(() => _selectedIndex = 0),
        ),
        title: Text(
          'Energy Report',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.midnightCharcoal,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, color: Colors.black),
            onPressed: () {},
          ),
        ],
      );
    }
    if (_selectedIndex == 3) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => setState(() => _selectedIndex = 0),
        ),
        title: Text(
          'Assign KSEB Officer',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.midnightCharcoal,
          ),
        ),
        centerTitle: true,
      );
    }
    if (_selectedIndex == 2) {
      return AppBar(
        backgroundColor: const Color(0xFFF9F9F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => setState(() => _selectedIndex = 0),
        ),
        title: Text(
          'User Management',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.midnightCharcoal,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      );
    }
    return null;
  }

  Widget? _buildFAB() {
    if (_selectedIndex == 2) {
      return FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2EBD59),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      );
    }
    return null;
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSystemHealthCard(),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildEnergyConsumptionCard(),
              const SizedBox(height: 24),
              _buildServiceStatusSection(),
              const SizedBox(height: 20),
            ],
          ),
        );
      case 1:
        return const EnergyReportContent();
      case 2:
        return const UserManagementContent();
      case 3:
        return const AssignOfficerContent();
      case 4:
        return const ProfileContent();
      default:
        return Center(
          child: Text(
            'Coming Soon',
            style: GoogleFonts.inter(color: Colors.black26),
          ),
        );
    }
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Dashboard',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.midnightCharcoal,
              ),
            ),
            Text(
              'System Overview',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black38,
              ),
            ),
          ],
        ),
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    color: Colors.black),
              ),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5252),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemHealthCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined,
                color: Color(0xFF2EBD59), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Healthy',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.midnightCharcoal,
                  ),
                ),
                Text(
                  'All services operational',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.15,
      children: [
        _buildStatCard(
          '2,543',
          'Registered Users',
          Icons.people_outline,
          null,
          silhouetteIcon: Icons.people_outline,
        ),
        _buildStatCard(
          '1,890',
          'Active Meters',
          Icons.bolt_outlined,
          '+12%',
          silhouetteIcon: Icons.bolt_outlined,
        ),
        _buildStatCard(
          '14',
          'Active Alerts',
          Icons.warning_amber_rounded,
          null,
          iconColor: const Color(0xFFFF8A00),
          iconBgColor: const Color(0xFFFFF4E9),
          silhouetteIcon: Icons.priority_high_rounded,
        ),
        _buildStatCard(
          '54ms',
          'Avg Latency',
          Icons.dns_outlined,
          null,
          iconColor: const Color(0xFF4C84FF),
          iconBgColor: const Color(0xFFEFF4FF),
          silhouetteIcon: Icons.storage_rounded,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, String? trend,
      {Color? iconColor,
      Color? iconBgColor,
      required IconData silhouetteIcon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                silhouetteIcon,
                size: 80,
                color: Colors.black.withValues(alpha: 0.03),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconBgColor ??
                              Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon,
                            color: iconColor ?? Colors.black, size: 20),
                      ),
                      if (trend != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD7F5E0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            trend,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2EBD59),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.midnightCharcoal,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black38,
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

  Widget _buildEnergyConsumptionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Energy Consumption',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.midnightCharcoal,
                    ),
                  ),
                  Text(
                    'Daily Total across all meters',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'This Week',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '482.5',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.midnightCharcoal,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'MWh',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black26,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMiniBarChart(),
        ],
      ),
    );
  }

  Widget _buildMiniBarChart() {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final values = [0.25, 0.4, 0.3, 0.5, 0.9, 0.45, 0.35];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        return Column(
          children: [
            Container(
              height: 120,
              width: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  FractionallySizedBox(
                    heightFactor: values[index],
                    child: Container(
                      decoration: BoxDecoration(
                        color: index == 4
                            ? const Color(0xFFF0F210)
                            : const Color(0xFFF0F210).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[index],
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: index == 4 ? FontWeight.w800 : FontWeight.w500,
                color: index == 4 ? Colors.black : Colors.black26,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildServiceStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Status Indicators',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.midnightCharcoal,
          ),
        ),
        const SizedBox(height: 16),
        _buildServiceItem(
            'Meter Synchronization', 'Operational', const Color(0xFF2EBD59)),
        _buildServiceItem(
            'User Authentication', 'Operational', const Color(0xFF2EBD59)),
        _buildServiceItem(
            'Notification Delivery', 'Delayed', const Color(0xFFFF8A00)),
      ],
    );
  }

  Widget _buildServiceItem(String name, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.midnightCharcoal,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
              Icons.grid_view_rounded, 'Dashboard', _selectedIndex == 0, 0),
          _buildNavItem(
              Icons.assessment_rounded, 'Reports', _selectedIndex == 1, 1),
          _buildNavItem(
              Icons.people_alt_rounded, 'Users', _selectedIndex == 2, 2),
          _buildNavItem(Icons.tune_rounded, 'Control', _selectedIndex == 3, 3),
          _buildNavItem(
              Icons.person_outline_rounded, 'Profile', _selectedIndex == 4, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, int index,
      {bool hasNotification = false}) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFF0F210) : Colors.black26,
                size: 24,
              ),
              if (hasNotification)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 6,
                    height: 6,
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
              color: isSelected ? const Color(0xFFF0F210) : Colors.black26,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

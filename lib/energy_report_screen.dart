import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'theme/app_theme.dart';
import 'services/database_service.dart';
import 'models/user_model.dart';

class EnergyReportContent extends StatefulWidget {
  const EnergyReportContent({super.key});

  @override
  State<EnergyReportContent> createState() => _EnergyReportContentState();
}

class _EnergyReportContentState extends State<EnergyReportContent> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  String _searchQuery = '';
  String _selectedPeriod = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    _selectedPeriod =
        "${start.day.toString().padLeft(2, '0')}/${start.month}/${start.year} - ${end.day.toString().padLeft(2, '0')}/${end.month}/${end.year}";
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      children: [
        _buildPeriodSelector(),
        const SizedBox(height: 24),
        _buildConsumptionTrendsCard(),
        const SizedBox(height: 24),
        _buildSummaryCards(),
        const SizedBox(height: 32),
        _buildMeterBreakdownHeader(),
        const SizedBox(height: 16),
        _buildSearchBar(),
        const SizedBox(height: 16),
        StreamBuilder<List<UserModel>>(
          stream: _dbService.getAllUsersStream(),
          builder: (context, snapshot) {
            final users = snapshot.data ?? [];
            final filteredUsers =
                users.where((u) => u.role == 'user').where((u) {
              if (_searchQuery.isEmpty) return true;
              return u.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  u.email.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();
            return _buildMeterList(filteredUsers);
          },
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return GestureDetector(
      onTap: () => _selectDateRange(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_today_rounded,
                  color: Color(0xFF26A69A), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Period',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black26,
                    ),
                  ),
                  Text(
                    _selectedPeriod,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.midnightCharcoal,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.expand_more_rounded, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGold,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedPeriod =
            "${picked.start.day.toString().padLeft(2, '0')}/${picked.start.month}/${picked.start.year} - ${picked.end.day.toString().padLeft(2, '0')}/${picked.end.month}/${picked.end.year}";
      });
    }
  }

  Widget _buildConsumptionTrendsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consumption Trends',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.midnightCharcoal,
                    ),
                  ),
                  Text(
                    'Daily usage in kWh',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up,
                        color: Color(0xFF2EBD59), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '+12%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2EBD59),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          StreamBuilder<List<double>>(
            stream:
                _dbService.getAggregateHistoricalConsumptionStream('METER001'),
            builder: (context, snapshot) {
              final readings =
                  snapshot.data ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
              return SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                            if (value < 0 || value >= days.length)
                              return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[value.toInt()],
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.black12,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: readings
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value))
                            .toList(),
                        isCurved: true,
                        color: const Color(0xFF26A69A),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF26A69A).withValues(alpha: 0.15),
                              const Color(0xFF26A69A).withValues(alpha: 0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => Colors.white,
                        tooltipRoundedRadius: 12,
                        tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return StreamBuilder<double>(
      stream: _dbService.getSystemLivePowerStream(),
      builder: (context, snapshot) {
        final totalLive = snapshot.data ?? 0.0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSummaryCard(
                label: 'System Load',
                value: totalLive.toStringAsFixed(1),
                unit: 'kW',
                trend: '+ 5.2%',
                isPositive: true,
                icon: Icons.bolt_rounded,
                iconColor: const Color(0xFF4DB6AC),
                iconBg: const Color(0xFFE0F2F1),
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                label: 'Avg Daily',
                value: (totalLive * 24).toStringAsFixed(0),
                unit: 'kWh',
                trend: '+ 1.2%',
                isPositive: true,
                icon: Icons.calendar_view_day_rounded,
                iconColor: const Color(0xFF4C84FF),
                iconBg: const Color(0xFFEFF4FF),
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                label: 'Active Users',
                value: '128',
                unit: 'Users',
                trend: '+8%',
                isPositive: true,
                icon: Icons.people_rounded,
                iconColor: const Color(0xFFF0F210),
                iconBg: const Color(0xFFF9F9F8),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required String unit,
    required String trend,
    required bool isPositive,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.midnightCharcoal,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black26,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? const Color(0xFF2EBD59) : Colors.redAccent,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color:
                      isPositive ? const Color(0xFF2EBD59) : Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeterBreakdownHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Meter Breakdown',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.midnightCharcoal,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'View All',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4DB6AC),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by User or Meter ID...',
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black12,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.black12, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon:
                      const Icon(Icons.clear, color: Colors.black12, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildMeterList(List<UserModel> users) {
    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('No meters match your search',
                  style: GoogleFonts.inter(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    return Column(
      children: users.map((user) {
        return StreamBuilder<double>(
          stream: _dbService.getSystemLivePowerStream(),
          builder: (context, snapshot) {
            final consumption = snapshot.data ?? 0.0;
            return _buildMeterItem(
              name: user.name,
              meterId: 'METER #${user.uid.substring(0, 5).toUpperCase()}',
              consumption: (consumption / users.length).toStringAsFixed(1),
              status: consumption > 5 ? 'High' : 'Normal',
              statusColor: consumption > 5
                  ? const Color(0xFFFDD835)
                  : const Color(0xFF2EBD59),
              avatarUrl: user.profileImageUrl,
              initials: user.name.isNotEmpty ? user.name[0] : 'U',
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildMeterItem({
    required String name,
    required String meterId,
    required String consumption,
    required String status,
    required Color statusColor,
    String? avatarUrl,
    String? initials,
    Color? initialsColor,
    Color? initialsTextColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(avatarUrl, initials, initialsColor, initialsTextColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.midnightCharcoal,
                  ),
                ),
                Text(
                  meterId,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black26,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    consumption,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.midnightCharcoal,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      'kWh',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.black26,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
      String? url, String? initials, Color? bgColor, Color? textColor) {
    if (url != null && url.isNotEmpty) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          border: Border.all(color: const Color(0xFFF9F9F8), width: 2),
        ),
      );
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor ?? const Color(0xFFE0F2F1),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF9F9F8), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initials ?? 'U',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: textColor ?? const Color(0xFF26A69A),
        ),
      ),
    );
  }
}

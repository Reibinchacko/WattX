import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod =
      'Week'; // Changed default to Week to match one of the images

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSegmentedControl(),
              const SizedBox(height: 16),
              _buildPowerUsageCard(),
              const SizedBox(height: 16),
              _buildBreakdownCard(),
              const SizedBox(height: 16),
              _buildBottomMetrics(),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Color(0xFFFFB74D),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF757575),
                ),
              ),
              Text(
                'Usage Trends',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        // Calendar Button
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.calendar_today_outlined, size: 20),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl() {
    final periods = ['Day', 'Week', 'Month', 'Year'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFFEEFF41) : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    period,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isSelected ? Colors.black : const Color(0xFF757575),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPowerUsageCard() {
    String title = 'Power Usage';
    String value = '2.84';
    String unit = 'kW';
    String trend = '-12%';
    List<FlSpot> spots = const [
      FlSpot(0, 1),
      FlSpot(3, 1.5),
      FlSpot(6, 2.2),
      FlSpot(9, 2),
      FlSpot(12, 2.8),
      FlSpot(15, 2.1),
      FlSpot(18, 2),
      FlSpot(21, 2.5),
      FlSpot(24, 2.8),
    ];
    double maxX = 24;

    if (_selectedPeriod == 'Week') {
      title = 'Weekly Usage';
      value = '142.8';
      unit = 'kWh';
      trend = '-12%';
      spots = const [
        FlSpot(0, 1.2),
        FlSpot(1, 1.8),
        FlSpot(2, 1.7),
        FlSpot(3, 2.4),
        FlSpot(4, 1.5),
        FlSpot(5, 1.8),
        FlSpot(6, 2.5),
      ];
      maxX = 6;
    } else if (_selectedPeriod == 'Month') {
      title = 'Avg. Power Usage';
      value = '1.84';
      unit = 'kW';
      trend = '-4.2%';
      spots = const [
        FlSpot(0, 1.4),
        FlSpot(7, 1.8),
        FlSpot(14, 1.5),
        FlSpot(21, 1.9),
        FlSpot(28, 2.2),
      ];
      maxX = 28;
    } else if (_selectedPeriod == 'Year') {
      title = 'Total Usage';
      value = '12.8';
      unit = 'MWh';
      trend = '-4%';
      spots = const [
        FlSpot(0, 1.5),
        FlSpot(2, 2.2),
        FlSpot(4, 2.0),
        FlSpot(6, 2.6),
        FlSpot(8, 2.1),
        FlSpot(10, 2.8),
      ];
      maxX = 10;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF757575),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_down,
                        color: Color(0xFF4CAF50), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
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
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFEEEEEE),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style =
                            TextStyle(color: Color(0xFF9E9E9E), fontSize: 10);
                        if (_selectedPeriod == 'Day') {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('00:00', style: style);
                            case 6:
                              return const Text('06:00', style: style);
                            case 12:
                              return const Text('12:00', style: style);
                            case 18:
                              return const Text('18:00', style: style);
                            case 24:
                              return const Text('24:00', style: style);
                          }
                        } else if (_selectedPeriod == 'Week') {
                          final days = ['Mon', 'Wed', 'Fri', 'Sun'];
                          if (value % 2 == 0) {
                            return Text(days[(value / 2).toInt()],
                                style: style);
                          }
                        } else if (_selectedPeriod == 'Month') {
                          final dates = [
                            'Oct 1',
                            'Oct 8',
                            'Oct 15',
                            'Oct 22',
                            'Oct 29'
                          ];
                          if (value % 7 == 0) {
                            return Text(dates[(value / 7).toInt()],
                                style: style);
                          }
                        } else if (_selectedPeriod == 'Year') {
                          final months = [
                            'Jan',
                            'Mar',
                            'May',
                            'Jul',
                            'Sep',
                            'Nov'
                          ];
                          if (value % 2 == 0) {
                            return Text(months[(value / 2).toInt()],
                                style: style);
                          }
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFFEEFF41),
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEEFF41).withOpacity(0.3),
                          const Color(0xFFEEFF41).withOpacity(0.0),
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

  Widget _buildBreakdownCard() {
    String title = 'Daily Consumption';
    String subtitle = 'Last 7 Days';
    int count = 7;
    List<String> labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    List<double> values = [5, 7, 10, 6, 4, 8, 3];
    int activeIndex = 2;

    if (_selectedPeriod == 'Week') {
      title = 'Breakdown';
      subtitle = 'This Week';
      labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      values = [4, 6, 3, 9, 5, 2, 2];
      activeIndex = 3;
    } else if (_selectedPeriod == 'Month') {
      title = 'Daily Consumption';
      subtitle = 'October 2023';
      count = 30;
      labels = List.generate(30, (i) => (i + 1).toString());
      values = List.generate(30, (i) => (5 + (i % 5)).toDouble());
      values[16] = 10; // Highlight one
      activeIndex = 16;
    } else if (_selectedPeriod == 'Year') {
      title = 'Monthly Consumption';
      subtitle = 'Year 2024';
      count = 12;
      labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
      values = [5, 6, 5, 7, 8, 9, 11, 10, 8, 6, 5, 6];
      activeIndex = 6;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
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
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xFF757575),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.more_horiz, color: Color(0xFF9E9E9E)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style =
                            TextStyle(color: Color(0xFF9E9E9E), fontSize: 10);
                        if (value >= 0 && value < count) {
                          bool isSelected = value == activeIndex;
                          String text = labels[value.toInt()];
                          // For month, only show 1, 5, 10, 15, 20, 25, 30
                          if (_selectedPeriod == 'Month') {
                            int day = value.toInt() + 1;
                            if (day != 1 && day % 5 != 0 && day != 30) {
                              return const Text('');
                            }
                          }
                          return Text(
                            text,
                            style: style.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.black
                                  : const Color(0xFF9E9E9E),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(count, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        color: i == activeIndex
                            ? const Color(0xFFEEFF41)
                            : const Color(0xFFE0E0E0),
                        width: _selectedPeriod == 'Month' ? 6 : 18,
                        borderRadius: BorderRadius.circular(10),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: values.reduce((a, b) => a > b ? a : b) + 2,
                          color: const Color(0xFFF5F5F5),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomMetrics() {
    String peakValue = '4.2';
    String peakSubtitle = 'Today at 18:00';
    String costValue = '₹12.50';
    String costSubtitle = 'Daily Average';

    if (_selectedPeriod == 'Week') {
      peakValue = '4.2';
      peakSubtitle = 'Thu at 19:30';
      costValue = '₹34.50';
      costSubtitle = 'This Week';
    } else if (_selectedPeriod == 'Month') {
      peakValue = '5.8';
      peakSubtitle = 'Oct 12 at 18:00';
      costValue = '₹145.20';
      costSubtitle = 'Month to date';
    } else if (_selectedPeriod == 'Year') {
      peakValue = '5.8';
      peakSubtitle = 'July 15 at 14:00';
      costValue = '₹1,840';
      costSubtitle = 'Yearly Total';
    }

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: 'PEAK LOAD',
            value: peakValue,
            unit: 'kW',
            subtitle: peakSubtitle,
            icon: Icons.bolt,
            iconColor: const Color(0xFFFF9800),
            bgColor: const Color(0xFFFFF7EC),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            label: 'EST. COST',
            value: costValue,
            unit: '',
            subtitle: costSubtitle,
            icon: Icons.account_balance_wallet_outlined,
            iconColor: const Color(0xFF2196F3),
            bgColor: const Color(0xFFF0F7FF),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String unit,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }
}

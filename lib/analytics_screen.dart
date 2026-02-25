import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Week';

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
              _buildSegmentedControl(),
              const SizedBox(height: 32),
              _buildPowerUsageCard(),
              const SizedBox(height: 24),
              _buildBreakdownCard(),
              const SizedBox(height: 24),
              _buildBottomMetrics(),
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
          'ANALYTICS',
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
          'Usage Trends',
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

  Widget _buildSegmentedControl() {
    final periods = ['Day', 'Week', 'Month', 'Year'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.midnightCharcoal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.midnightCharcoal
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    period,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.midnightCharcoal.withValues(alpha: 0.5),
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
      trend = '-8%';
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
      title = 'Avg. Power';
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.midnightCharcoal.withValues(alpha: 0.4),
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trend,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.green,
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
                value,
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
                  unit,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.midnightCharcoal.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.midnightCharcoal.withValues(alpha: 0.05),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _getIntervalForPeriod(),
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _getLabelForValue(value),
                            style: GoogleFonts.inter(
                              color: AppTheme.midnightCharcoal
                                  .withValues(alpha: 0.4),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.inter(
                            color: AppTheme.midnightCharcoal
                                .withValues(alpha: 0.3),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => AppTheme.midnightCharcoal,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final flSpot = barSpot;
                        return LineTooltipItem(
                          '${flSpot.y} $unit',
                          GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryGold,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGold.withValues(alpha: 0.2),
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

  double _getIntervalForPeriod() {
    switch (_selectedPeriod) {
      case 'Day':
        return 6;
      case 'Week':
        return 1;
      case 'Month':
        return 7;
      case 'Year':
        return 2;
      default:
        return 1;
    }
  }

  String _getLabelForValue(double value) {
    if (_selectedPeriod == 'Day') {
      int hour = value.toInt();
      if (hour == 0) return '12AM';
      if (hour == 12) return '12PM';
      if (hour == 24) return '12AM';
      return hour > 12 ? '${hour - 12}PM' : '${hour}AM';
    } else if (_selectedPeriod == 'Week') {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      if (value < 0 || value >= days.length) return '';
      return days[value.toInt()];
    } else if (_selectedPeriod == 'Month') {
      int day = value.toInt() + 1;
      return '$day';
    } else if (_selectedPeriod == 'Year') {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      if (value < 0 || value >= months.length) return '';
      return months[value.toInt()];
    }
    return '';
  }

  Widget _buildBreakdownCard() {
    String title = 'Daily Usage';
    int count = 7;
    List<double> values = [5, 7, 10, 6, 4, 8, 3];
    int activeIndex = 2;

    if (_selectedPeriod == 'Week') {
      values = [4, 6, 3, 9, 5, 2, 2];
      activeIndex = 3;
    } else if (_selectedPeriod == 'Month') {
      count = 30;
      values = List.generate(30, (i) => (5 + (i % 5)).toDouble());
      activeIndex = 16;
    } else if (_selectedPeriod == 'Year') {
      count = 12;
      values = [5, 6, 5, 7, 8, 9, 11, 10, 8, 6, 5, 6];
      activeIndex = 6;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.midnightCharcoal.withValues(alpha: 0.4),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= count) {
                          return const SizedBox.shrink();
                        }

                        String text = '';
                        if (_selectedPeriod == 'Week') {
                          const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          text = days[index % 7];
                        } else if (_selectedPeriod == 'Year') {
                          const months = [
                            'J',
                            'F',
                            'M',
                            'A',
                            'M',
                            'J',
                            'J',
                            'A',
                            'S',
                            'O',
                            'N',
                            'D'
                          ];
                          text = months[index % 12];
                        } else {
                          if (index % 5 != 0) return const SizedBox.shrink();
                          text = '${index + 1}';
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            text,
                            style: GoogleFonts.inter(
                              color: AppTheme.midnightCharcoal
                                  .withValues(alpha: 0.4),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppTheme.midnightCharcoal,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toString(),
                        GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: List.generate(count, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        color: i == activeIndex
                            ? AppTheme.primaryGold
                            : AppTheme.midnightCharcoal.withValues(alpha: 0.05),
                        width: _selectedPeriod == 'Month' ? 6 : 14,
                        borderRadius: BorderRadius.circular(4),
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
    return Row(
      children: [
        Expanded(
          child: _buildMetricMiniCard(
              'Peak Load', '4.2', 'kW', Icons.bolt_rounded),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricMiniCard(
              'Est. Bill', '₹240', '', Icons.receipt_long_rounded),
        ),
      ],
    );
  }

  Widget _buildMetricMiniCard(
      String label, String value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 20),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.midnightCharcoal.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.midnightCharcoal,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.midnightCharcoal.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

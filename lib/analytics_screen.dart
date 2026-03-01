import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'theme/app_theme.dart';
import 'models/reading_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Day';

  // Live reading stream (for Day view — recent readings from Firebase)
  final _liveRef =
      FirebaseDatabase.instance.ref('EnergyReadings/live/METER001');
  final _recentRef = FirebaseDatabase.instance
      .ref('EnergyReadings/historical/METER001/recent');

  // Accumulated in-memory readings for live Day chart
  final List<ReadingModel> _liveReadings = [];
  StreamSubscription? _liveSubscription;

  // Historical readings per period
  final Map<String, List<ReadingModel>> _historicalCache = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _subscribeToLive();
    _loadHistorical();
  }

  /// Subscribes to the recent node which the IoT device keeps updated.
  void _subscribeToLive() {
    // Safety timeout — always stop spinner after 3s regardless of Firebase
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    });

    _liveSubscription = _recentRef.onValue.listen((event) {
      if (!mounted) return;
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null || data.isEmpty) {
        // /recent node is empty — try the single live reading instead
        _liveRef.get().then((snap) {
          if (!mounted) return;
          final d = snap.value as Map<dynamic, dynamic>?;
          setState(() {
            if (d != null) {
              _liveReadings
                ..clear()
                ..add(ReadingModel.fromMap(d));
            }
            // Whether we got data or not, stop loading so fallback shows
            _isLoading = false;
          });
        }).catchError((_) {
          if (mounted) setState(() => _isLoading = false);
        });
        return;
      }

      final readings = data.values
          .map((v) => ReadingModel.fromMap(v as Map<dynamic, dynamic>))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (mounted) {
        setState(() {
          _liveReadings
            ..clear()
            ..addAll(readings);
          _isLoading = false;
        });
      }
    }, onError: (_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  /// Loads historical data for Week / Month / Year from Firebase once per period.
  Future<void> _loadHistorical() async {
    for (final period in ['weekly', 'monthly', 'yearly']) {
      try {
        final snap = await FirebaseDatabase.instance
            .ref('EnergyReadings/historical/METER001/$period')
            .get();
        if (snap.exists && snap.value is Map) {
          final data = snap.value as Map<dynamic, dynamic>;
          final readings = data.values
              .map((v) => ReadingModel.fromMap(v as Map<dynamic, dynamic>))
              .toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
          if (mounted) {
            setState(() => _historicalCache[period] = readings);
          }
        }
      } catch (_) {
        // Historical path doesn't exist yet — keep empty
      }
    }
  }

  @override
  void dispose() {
    _liveSubscription?.cancel();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Data helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns chart spots from real Firebase readings for the selected period.
  /// Falls back to sensible static shape if Firebase has no data yet.
  List<FlSpot> _getSpotsForPeriod() {
    switch (_selectedPeriod) {
      case 'Day':
        if (_liveReadings.isEmpty) return _fallbackSpots('Day');
        return _readingsToSpots(_liveReadings, 'Day');
      case 'Week':
        final data = _historicalCache['weekly'] ?? [];
        if (data.isEmpty) return _fallbackSpots('Week');
        return _readingsToSpots(data, 'Week');
      case 'Month':
        final data = _historicalCache['monthly'] ?? [];
        if (data.isEmpty) return _fallbackSpots('Month');
        return _readingsToSpots(data, 'Month');
      case 'Year':
        final data = _historicalCache['yearly'] ?? [];
        if (data.isEmpty) return _fallbackSpots('Year');
        return _readingsToSpots(data, 'Year');
      default:
        return _fallbackSpots(_selectedPeriod);
    }
  }

  /// Converts a reading list into FlSpots with x mapped to the period axis.
  List<FlSpot> _readingsToSpots(List<ReadingModel> readings, String period) {
    if (readings.isEmpty) return [];
    final spots = <FlSpot>[];
    for (int i = 0; i < readings.length; i++) {
      double x;
      final r = readings[i];
      switch (period) {
        case 'Day':
          x = r.timestamp.hour + r.timestamp.minute / 60.0;
          break;
        case 'Week':
          x = r.timestamp.weekday.toDouble() - 1; // 0=Mon … 6=Sun
          break;
        case 'Month':
          x = r.timestamp.day.toDouble() - 1;
          break;
        case 'Year':
          x = r.timestamp.month.toDouble() - 1;
          break;
        default:
          x = i.toDouble();
      }
      spots.add(FlSpot(x, double.parse(r.power.toStringAsFixed(2))));
    }
    return spots;
  }

  /// Static fallback data (used if Firebase has no readings yet).
  List<FlSpot> _fallbackSpots(String period) {
    switch (period) {
      case 'Day':
        return const [
          FlSpot(0, 1.0),
          FlSpot(3, 1.5),
          FlSpot(6, 2.2),
          FlSpot(9, 2.0),
          FlSpot(12, 2.8),
          FlSpot(15, 2.1),
          FlSpot(18, 2.0),
          FlSpot(21, 2.5),
          FlSpot(23, 2.8),
        ];
      case 'Week':
        return const [
          FlSpot(0, 1.2),
          FlSpot(1, 1.8),
          FlSpot(2, 1.7),
          FlSpot(3, 2.4),
          FlSpot(4, 1.5),
          FlSpot(5, 1.8),
          FlSpot(6, 2.5),
        ];
      case 'Month':
        return const [
          FlSpot(0, 1.4),
          FlSpot(7, 1.8),
          FlSpot(14, 1.5),
          FlSpot(21, 1.9),
          FlSpot(28, 2.2),
        ];
      case 'Year':
        return const [
          FlSpot(0, 1.5),
          FlSpot(2, 2.2),
          FlSpot(4, 2.0),
          FlSpot(6, 2.6),
          FlSpot(8, 2.1),
          FlSpot(10, 2.8),
        ];
      default:
        return [];
    }
  }

  double _maxXForPeriod() {
    switch (_selectedPeriod) {
      case 'Day':
        return 23;
      case 'Week':
        return 6;
      case 'Month':
        return 28;
      case 'Year':
        return 11;
      default:
        return 6;
    }
  }

  /// Current/total value shown in the large number above the chart.
  String _summaryValue() {
    final spots = _getSpotsForPeriod();
    if (spots.isEmpty) return '--';
    switch (_selectedPeriod) {
      case 'Day':
        // Latest reading
        return spots.last.y.toStringAsFixed(2);
      case 'Week':
      case 'Month':
        // Sum (kWh)
        final sum = spots.fold(0.0, (a, s) => a + s.y);
        return sum.toStringAsFixed(1);
      case 'Year':
        // Sum in MWh
        final sum = spots.fold(0.0, (a, s) => a + s.y) / 1000;
        return sum.toStringAsFixed(2);
      default:
        return '--';
    }
  }

  String _summaryUnit() {
    switch (_selectedPeriod) {
      case 'Day':
        return 'kW';
      case 'Week':
        return 'kWh';
      case 'Month':
        return 'kWh';
      case 'Year':
        return 'MWh';
      default:
        return 'kW';
    }
  }

  String _summaryTitle() {
    switch (_selectedPeriod) {
      case 'Day':
        return 'Current Power';
      case 'Week':
        return 'Weekly Usage';
      case 'Month':
        return 'Monthly Usage';
      case 'Year':
        return 'Total Usage';
      default:
        return 'Power Usage';
    }
  }

  double _peakLoad() {
    final spots = _getSpotsForPeriod();
    if (spots.isEmpty) return 0;
    return spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
  }

  double _estBill() {
    final spots = _getSpotsForPeriod();
    if (spots.isEmpty) return 0;
    // Simple estimate: units * ₹7/kWh
    final units = spots.fold(0.0, (a, s) => a + s.y);
    return units * 7;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 24),
              _buildSegmentedControl(isDark),
              const SizedBox(height: 24),
              _buildPowerUsageCard(isDark),
              const SizedBox(height: 24),
              _buildBreakdownCard(isDark),
              const SizedBox(height: 24),
              _buildBottomMetrics(isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final isLive = _selectedPeriod == 'Day';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ANALYTICS',
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
                'Usage Trends',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.midnightCharcoal,
                ),
              ),
            ],
          ),
        ),
        // Live indicator badge (only for Day view)
        if (isLive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.green,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSegmentedControl(bool isDark) {
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

  Widget _buildPowerUsageCard(bool isDark) {
    final spots = _getSpotsForPeriod();
    final value = _summaryValue();
    final unit = _summaryUnit();
    final title = _summaryTitle();
    final isLive = _selectedPeriod == 'Day';

    // Compute trend vs previous (simple: first vs last)
    String trend = '--';
    bool trendUp = false;
    if (spots.length >= 2) {
      final diff = ((spots.last.y - spots.first.y) / spots.first.y * 100);
      trendUp = diff > 0;
      trend = '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)}%';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppTheme.surfaceWhite,
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
                  color: isDark
                      ? Colors.white38
                      : AppTheme.midnightCharcoal.withValues(alpha: 0.4),
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                children: [
                  // Live Firebase badge
                  if (isLive && !_isLoading)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⚡ Firebase',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  // Trend badge
                  if (trend != '--')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: trendUp
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        trend,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: trendUp ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Large value
          _isLoading
              ? const LinearProgressIndicator(
                  color: AppTheme.primaryGold,
                  backgroundColor: Colors.transparent)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color:
                            isDark ? Colors.white : AppTheme.midnightCharcoal,
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
                          color: isDark
                              ? Colors.white38
                              : AppTheme.midnightCharcoal
                                  .withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Data source label
                    Text(
                      spots == _fallbackSpots(_selectedPeriod)
                          ? 'Sample data'
                          : '${spots.length} readings',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 28),
          // ── Line Chart ────────────────────────────────────────────────
          if (_isLoading)
            const SizedBox(
              height: 180,
              child: Center(
                child: CircularProgressIndicator(
                    color: AppTheme.primaryGold, strokeWidth: 2),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: _maxXForPeriod(),
                  minY: 0,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: (isDark ? Colors.white : AppTheme.midnightCharcoal)
                          .withValues(alpha: 0.05),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
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
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _getLabelForValue(value),
                            style: GoogleFonts.inter(
                              color: isDark
                                  ? Colors.white38
                                  : AppTheme.midnightCharcoal
                                      .withValues(alpha: 0.4),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
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
                              color: isDark
                                  ? Colors.white24
                                  : AppTheme.midnightCharcoal
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
                      getTooltipColor: (_) => isDark
                          ? const Color(0xFF1E2026)
                          : AppTheme.midnightCharcoal,
                      tooltipRoundedRadius: 10,
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      getTooltipItems: (spots) => spots.map((s) {
                        final label = _getLabelForValue(s.x);
                        return LineTooltipItem(
                          '${label.isNotEmpty ? '$label\n' : ''}${s.y.toStringAsFixed(2)} $unit',
                          GoogleFonts.inter(
                            color: AppTheme.primaryGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                    handleBuiltInTouches: true,
                    getTouchedSpotIndicator: (data, indices) => indices
                        .map((_) => TouchedSpotIndicatorData(
                              FlLine(
                                color:
                                    AppTheme.primaryGold.withValues(alpha: 0.4),
                                strokeWidth: 1.5,
                                dashArray: [4, 4],
                              ),
                              FlDotData(
                                show: true,
                                getDotPainter: (_, __, ___, ____) =>
                                    FlDotCirclePainter(
                                  radius: 5,
                                  color: AppTheme.primaryGold,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots.isEmpty
                          ? _fallbackSpots(_selectedPeriod)
                          : spots,
                      isCurved: true,
                      color: AppTheme.primaryGold,
                      barWidth: 3.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGold.withValues(alpha: 0.22),
                            AppTheme.primaryGold.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
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
      final h = value.toInt();
      if (h == 0) return '12AM';
      if (h == 12) return '12PM';
      if (h == 23) return '11PM';
      return h > 12 ? '${h - 12}PM' : '${h}AM';
    } else if (_selectedPeriod == 'Week') {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final i = value.toInt();
      return (i >= 0 && i < days.length) ? days[i] : '';
    } else if (_selectedPeriod == 'Month') {
      return '${value.toInt() + 1}';
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
      final i = value.toInt();
      return (i >= 0 && i < months.length) ? months[i] : '';
    }
    return '';
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Breakdown bar chart
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildBreakdownCard(bool isDark) {
    String title = 'Daily Breakdown';
    List<double> values;
    int count;

    switch (_selectedPeriod) {
      case 'Day':
        // Use real readings for today
        if (_liveReadings.isNotEmpty) {
          // Group by hour and average
          final Map<int, List<double>> byHour = {};
          for (final r in _liveReadings) {
            byHour.putIfAbsent(r.timestamp.hour, () => []).add(r.power);
          }
          count = 24;
          values = List.generate(24, (h) {
            final bucket = byHour[h];
            if (bucket == null || bucket.isEmpty) return 0;
            return bucket.reduce((a, b) => a + b) / bucket.length;
          });
        } else {
          count = 7;
          values = [5, 7, 10, 6, 4, 8, 3];
        }
        break;
      case 'Week':
        title = 'Daily Usage (kWh)';
        final weekData = _historicalCache['weekly'] ?? [];
        if (weekData.isNotEmpty) {
          count = 7;
          final Map<int, List<double>> byDay = {};
          for (final r in weekData) {
            final d = r.timestamp.weekday - 1;
            byDay.putIfAbsent(d, () => []).add(r.power);
          }
          values = List.generate(
              7, (i) => byDay[i]?.fold<double>(0.0, (a, b) => a + b) ?? 0.0);
        } else {
          count = 7;
          values = [4, 6, 3, 9, 5, 2, 2];
        }
        break;
      case 'Month':
        title = 'Daily Usage (kWh)';
        count = 30;
        values = List.generate(
            30,
            (i) => _historicalCache['monthly'] != null
                ? 0.0
                : (5 + (i % 5)).toDouble());
        break;
      case 'Year':
        title = 'Monthly Usage (kWh)';
        count = 12;
        values = _historicalCache['yearly'] != null &&
                _historicalCache['yearly']!.isNotEmpty
            ? List.generate(12, (m) {
                final data = _historicalCache['yearly']!;
                final bucket = data.where((r) => r.timestamp.month - 1 == m);
                return bucket.isEmpty
                    ? 0.0
                    : bucket.fold(0.0, (a, r) => a + r.power);
              })
            : [5, 6, 5, 7, 8, 9, 11, 10, 8, 6, 5, 6];
        break;
      default:
        count = 7;
        values = [5, 7, 10, 6, 4, 8, 3];
    }

    final maxY = values.isEmpty ? 12.0 : values.reduce((a, b) => a > b ? a : b);
    final activeIndex = values.isEmpty ? 0 : values.indexOf(maxY.toDouble());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppTheme.surfaceWhite,
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
              color: isDark
                  ? Colors.white38
                  : AppTheme.midnightCharcoal.withValues(alpha: 0.4),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                maxY: maxY + 2,
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
                        final index = value.toInt();
                        if (index < 0 || index >= count) {
                          return const SizedBox.shrink();
                        }
                        String text = '';
                        if (_selectedPeriod == 'Day') {
                          if (index % 6 != 0) return const SizedBox.shrink();
                          text = _getLabelForValue(index.toDouble());
                        } else if (_selectedPeriod == 'Week') {
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
                              color: isDark
                                  ? Colors.white38
                                  : AppTheme.midnightCharcoal
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
                    getTooltipColor: (_) => isDark
                        ? const Color(0xFF1E2026)
                        : AppTheme.midnightCharcoal,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)} kW',
                        GoogleFonts.inter(
                          color: AppTheme.primaryGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: List.generate(count, (i) {
                  final y = (i < values.length) ? values[i] : 0.0;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: y,
                        color: i == activeIndex
                            ? AppTheme.primaryGold
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : AppTheme.midnightCharcoal
                                    .withValues(alpha: 0.05)),
                        width: _selectedPeriod == 'Month' ||
                                _selectedPeriod == 'Day'
                            ? 6
                            : 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Bottom metric cards
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildBottomMetrics(bool isDark) {
    final peak = _peakLoad();
    final bill = _estBill();
    return Row(
      children: [
        Expanded(
          child: _buildMetricMiniCard(
            isDark: isDark,
            label: 'Peak Load',
            value: peak > 0 ? peak.toStringAsFixed(1) : '4.2',
            unit: 'kW',
            icon: Icons.bolt_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricMiniCard(
            isDark: isDark,
            label: 'Est. Bill',
            value: bill > 0 ? '₹${bill.toStringAsFixed(0)}' : '₹240',
            unit: '',
            icon: Icons.receipt_long_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricMiniCard({
    required bool isDark,
    required String label,
    required String value,
    required String unit,
    required IconData icon,
  }) {
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
          Icon(icon, color: AppTheme.primaryGold, size: 20),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white38
                  : AppTheme.midnightCharcoal.withValues(alpha: 0.4),
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
                  color: isDark ? Colors.white : AppTheme.midnightCharcoal,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white24
                      : AppTheme.midnightCharcoal.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

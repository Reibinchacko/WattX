import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'services/database_service.dart';
import 'models/alert_model.dart';

class KsebAlertsScreen extends StatefulWidget {
  const KsebAlertsScreen({super.key});

  @override
  State<KsebAlertsScreen> createState() => _KsebAlertsScreenState();
}

class _KsebAlertsScreenState extends State<KsebAlertsScreen> {
  final DatabaseService _dbService = DatabaseService();
  String _selectedFilter = 'All Alerts';

  List<AlertModel> _filterAlerts(List<AlertModel> alerts) {
    if (_selectedFilter == 'All Alerts') return alerts;
    return alerts
        .where((alert) =>
            alert.type.toUpperCase() == _selectedFilter.toUpperCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F8),
      body: SafeArea(
        child: StreamBuilder<List<AlertModel>>(
          stream: _dbService.getAlertsStream(),
          builder: (context, snapshot) {
            final allAlerts = snapshot.data ?? [];
            final filtered = _filterAlerts(allAlerts);
            final criticalCount =
                allAlerts.where((a) => a.type == 'CRITICAL').length;
            final resolvedCount =
                allAlerts.where((a) => a.status == 'RESOLVED').length;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildFilterChips(),
                  const SizedBox(height: 24),
                  _buildSummaryCards(
                      criticalCount: criticalCount,
                      resolvedCount: resolvedCount),
                  const SizedBox(height: 32),
                  _buildSectionTitle('TODAY', '${filtered.length} Alerts'),
                  const SizedBox(height: 16),
                  if (filtered.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text('No alerts found',
                            style: GoogleFonts.inter(color: Colors.grey)),
                      ),
                    )
                  else
                    ...filtered.map((alert) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildAlertCard(
                            type: alert.type,
                            title: alert.title,
                            name: 'Meter #${alert.meterId}',
                            consumerId: alert.meterId,
                            location: 'Zone 4',
                            time:
                                '${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')}',
                            status: alert.status,
                            icon: _getAlertIcon(alert.type),
                            color: _getAlertColor(alert.type),
                          ),
                        )),
                  const SizedBox(height: 32),
                  _buildSectionTitle('HISTORY', ''),
                  const SizedBox(height: 16),
                  _buildResolvedCard(
                    title: 'System Initialized',
                    name: 'Admin',
                    time: 'Recent',
                    icon: Icons.info_outline_rounded,
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'End of list',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black26,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: const Icon(Icons.arrow_back,
                  color: AppTheme.midnightCharcoal),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alerts & Faults',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.midnightCharcoal,
                  ),
                ),
                Text(
                  'Zone 4 • Trivandrum North',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.tune_rounded,
              color: AppTheme.primaryGold, size: 20),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All Alerts', 'color': Colors.transparent},
      {'label': 'Critical', 'color': const Color(0xFFD32F2F)},
      {'label': 'Warning', 'color': const Color(0xFFFFB300)},
      {'label': 'Tamper', 'color': const Color(0xFFEAA900)},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['label'];
          final dotColor = f['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () =>
                  setState(() => _selectedFilter = f['label'] as String),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryGold : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    if (dotColor != Colors.transparent) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      f['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.midnightCharcoal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards({int criticalCount = 0, int resolvedCount = 0}) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: -10,
                  child: Icon(Icons.flash_on_rounded,
                      color: Colors.white.withValues(alpha: 0.2), size: 80),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Critical Faults',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          criticalCount.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.midnightCharcoal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'Active',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
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
                      'Resolved',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black38,
                      ),
                    ),
                    const Icon(Icons.check_circle,
                        color: Color(0xFF2EBD59), size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      resolvedCount.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.midnightCharcoal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'Total',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black26,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String badge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.midnightCharcoal,
            letterSpacing: 1.0,
          ),
        ),
        if (badge.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFEAA900),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAlertCard({
    required String type,
    required String title,
    required String name,
    required String consumerId,
    required String location,
    required String time,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, color: color, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                type,
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              time,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.midnightCharcoal,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: status == 'NEW'
                                        ? const Color(0xFFFFB300)
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  status,
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
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
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.midnightCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '#',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.primaryGold,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Consumer $consumerId',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('•',
                            style: GoogleFonts.inter(color: Colors.black12)),
                        const SizedBox(width: 8),
                        Text(
                          location,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResolvedCard({
    required String title,
    required String name,
    required String time,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black26, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF454F5B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Color(0xFF2EBD59), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'RESOLVED',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2EBD59),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.black26,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAlertIcon(String type) {
    switch (type.toUpperCase()) {
      case 'CRITICAL':
        return Icons.flash_on_rounded;
      case 'WARNING':
        return Icons.warning_amber_rounded;
      case 'TAMPER':
        return Icons.lock_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getAlertColor(String type) {
    switch (type.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFFD32F2F);
      case 'WARNING':
        return const Color(0xFFFF8A00);
      case 'TAMPER':
        return const Color(0xFFEAA900);
      default:
        return Colors.blue;
    }
  }
}

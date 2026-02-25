import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';

class KsebAlertsScreen extends StatefulWidget {
  const KsebAlertsScreen({super.key});

  @override
  State<KsebAlertsScreen> createState() => _KsebAlertsScreenState();
}

class _KsebAlertsScreenState extends State<KsebAlertsScreen> {
  String _selectedFilter = 'All Alerts';

  final List<Map<String, dynamic>> _alerts = [
    {
      'type': 'CRITICAL',
      'title': 'Phase Failure',
      'name': 'Ramesh Kumar',
      'consumerId': '12345',
      'location': 'Sec B, Pallimukku',
      'time': '10:42 AM',
      'status': 'NEW',
      'icon': Icons.flash_on_rounded,
      'color': const Color(0xFFD32F2F),
    },
    {
      'type': 'WARNING',
      'title': 'Overload Detected',
      'name': 'Anjali Menon',
      'consumerId': '67890',
      'location': 'Sec A, Kowdiar',
      'time': '09:15 AM',
      'status': 'NEW',
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFFFF8A00),
    },
    {
      'type': 'TAMPER',
      'title': 'Cover Open Attempt',
      'name': 'Govt. High School',
      'consumerId': '99100',
      'location': 'Sec C, Peroorkada',
      'time': '08:30 AM',
      'status': 'VIEWED',
      'icon': Icons.lock_outline_rounded,
      'color': const Color(0xFFEAA900),
    },
  ];

  List<Map<String, dynamic>> get _filteredAlerts {
    if (_selectedFilter == 'All Alerts') return _alerts;
    return _alerts
        .where((alert) =>
            alert['type'].toString().toUpperCase() ==
            _selectedFilter.toUpperCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAlerts;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildFilterChips(),
              const SizedBox(height: 24),
              _buildSummaryCards(),
              const SizedBox(height: 32),
              _buildSectionTitle('TODAY', '${filtered.length} New'),
              const SizedBox(height: 16),
              ...filtered.map((alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildAlertCard(
                      type: alert['type'],
                      title: alert['title'],
                      name: alert['name'],
                      consumerId: alert['consumerId'],
                      location: alert['location'],
                      time: alert['time'],
                      status: alert['status'],
                      icon: alert['icon'],
                      color: alert['color'],
                    ),
                  )),
              const SizedBox(height: 32),
              _buildSectionTitle('YESTERDAY', ''),
              const SizedBox(height: 16),
              _buildResolvedCard(
                title: 'Outage Reported',
                name: 'Sandeep Varma',
                time: 'Yesterday, 4:15 PM',
                icon: Icons.power_off_rounded,
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
      {'label': 'Review', 'color': Colors.transparent},
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

  Widget _buildSummaryCards() {
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
                    Text('Active Faults',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('12',
                            style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.midnightCharcoal)),
                        const SizedBox(width: 8),
                        Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('Requires Action',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black45))),
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
                color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Resolved',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black38)),
                      const Icon(Icons.check_circle,
                          color: Color(0xFF2EBD59), size: 16)
                    ]),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('45',
                        style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.midnightCharcoal)),
                    const SizedBox(width: 8),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('Today',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black26))),
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
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.midnightCharcoal,
                letterSpacing: 1.0)),
        if (badge.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(8)),
            child: Text(badge,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFEAA900))),
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
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
                width: 4,
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20)))),
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
                                    borderRadius: BorderRadius.circular(10)),
                                child: Icon(icon, color: color, size: 18)),
                            const SizedBox(width: 12),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text(type,
                                    style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: color,
                                        letterSpacing: 0.5))),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(time,
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.midnightCharcoal)),
                            Row(children: [
                              Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      color: status == 'NEW'
                                          ? const Color(0xFFFFB300)
                                          : Colors.grey,
                                      shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text(status,
                                  style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black26))
                            ]),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(title,
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.midnightCharcoal)),
                    const SizedBox(height: 2),
                    Text(name,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('#',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.primaryGold,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(width: 4),
                        Text('Consumer $consumerId',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.black38,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Text('•',
                            style: GoogleFonts.inter(color: Colors.black12)),
                        const SizedBox(width: 8),
                        Text(location,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.black38,
                                fontWeight: FontWeight.w500)),
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
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey[100], shape: BoxShape.circle),
              child: Icon(icon, color: Colors.black26, size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF454F5B))),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6)),
                        child: Row(children: [
                          const Icon(Icons.check_circle,
                              color: Color(0xFF2EBD59), size: 12),
                          const SizedBox(width: 4),
                          Text('RESOLVED',
                              style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2EBD59)))
                        ]))
                  ],
                ),
                Text(name,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black38,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(time,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.black26,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

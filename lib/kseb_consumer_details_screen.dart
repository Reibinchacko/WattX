import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'theme/app_theme.dart';
import 'services/database_service.dart';
import 'models/bill_model.dart';

class KsebConsumerDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> consumer;
  final DatabaseService _dbService = DatabaseService();

  KsebConsumerDetailsScreen({super.key, required this.consumer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F8),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildQuickStats(),
            const SizedBox(height: 32),
            _buildUsageChartCard(),
            const SizedBox(height: 32),
            _buildDetailsSection(),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTheme.midnightCharcoal, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Consumer Profile',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppTheme.midnightCharcoal,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon:
              const Icon(Icons.edit_outlined, color: AppTheme.midnightCharcoal),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    Color statusColor = _getStatusColor(consumer['status']);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          _buildAvatarLarge(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  consumer['name'],
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.midnightCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Consumer ${consumer['consumerId']}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        consumer['status'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarLarge() {
    if (consumer['type'] == 'apartment') {
      return Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFFE0F2F1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.apartment_rounded,
            color: Color(0xFF00695C), size: 40),
      );
    } else if (consumer['type'] == 'business') {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.business_rounded, color: Colors.grey, size: 40),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFFFECB3),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          consumer['name'][0],
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6D4C41),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
            child:
                _buildStatItem('Daily Avg', '4.2', 'kWh', Icons.bolt_rounded)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatItem(
                'Balance', '₹1,240', '', Icons.account_balance_wallet_rounded)),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 24),
          const SizedBox(height: 16),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black38,
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
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black26,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
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
                'CONSUMPTION TREND',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black26,
                  letterSpacing: 1.0,
                ),
              ),
              const Icon(Icons.more_horiz_rounded, color: Colors.black26),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 4),
                      FlSpot(2, 3.5),
                      FlSpot(3, 5),
                      FlSpot(4, 4),
                      FlSpot(5, 6),
                      FlSpot(6, 5.5),
                    ],
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

  Widget _buildDetailsSection() {
    return Column(
      children: [
        _buildDetailRow('Meter ID', consumer['meterId'], Icons.bolt_rounded),
        const SizedBox(height: 12),
        _buildDetailRow('Connection Type', 'Single Phase', Icons.cable_rounded),
        const SizedBox(height: 12),
        _buildDetailRow('Tariff Plan', 'Domestic - LT1', Icons.receipt_rounded),
        const SizedBox(height: 12),
        _buildDetailRow(
            'Last Reading', 'Jan 10, 2026', Icons.event_available_rounded),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.midnightCharcoal, size: 18),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black38,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.midnightCharcoal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _showBillingHistory(context),
          style: AppTheme.primaryButtonStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(AppTheme.primaryGold),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_rounded, size: 20),
              SizedBox(width: 12),
              Text('View Billing History'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => _showCutConnectionDialog(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(color: AppTheme.primaryGold, width: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            foregroundColor: AppTheme.primaryGold,
          ),
          child: Text(
            'Cut Connection',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  void _showBillingHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Billing History',
                style: GoogleFonts.inter(
                    fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<List<BillModel>>(
                stream: _dbService.getBills(consumer['uid'] ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final bills = snapshot.data ?? [];
                  if (bills.isEmpty) {
                    return const Center(
                        child: Text('No billing history found.'));
                  }
                  return ListView.separated(
                    itemCount: bills.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final bill = bills[index];
                      return ListTile(
                        title: Text('Bill for ${bill.billingMonth}'),
                        subtitle:
                            Text('Amount: ₹${bill.amount.toStringAsFixed(2)}'),
                        trailing: Text(
                          bill.status.toUpperCase(),
                          style: TextStyle(
                            color: bill.status == 'paid'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCutConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Disconnection',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to cut the power connection for ${consumer['name']}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Disconnect'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return const Color(0xFF2EBD59);
      case 'PENDING':
        return const Color(0xFFFF8A00);
      case 'DISC.':
      case 'DISCONNECTED':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }
}

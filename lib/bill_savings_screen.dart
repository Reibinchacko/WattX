import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notifications_screen.dart';
import 'theme/app_theme.dart';
import 'services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/bill_model.dart';

class BillSavingsScreen extends StatefulWidget {
  const BillSavingsScreen({super.key});

  @override
  State<BillSavingsScreen> createState() => _BillSavingsScreenState();
}

class _BillSavingsScreenState extends State<BillSavingsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: StreamBuilder<List<BillModel>>(
          stream: _databaseService.getBills(_uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final bills = snapshot.data ?? [];
            var latestBill = bills.isNotEmpty
                ? bills.reduce((a, b) =>
                    a.id.compareTo(b.id) > 0 ? a : b) // Simple logic for latest
                : null;

            // If no bill exists, create a dummy one for display
            latestBill ??= BillModel(
              id: 'dummy_bill',
              amount: 786.00,
              dueDate: DateTime.now().add(const Duration(days: 5)),
              billingMonth: 'January 2026',
              unitsConsumed: 142,
              status: 'unpaid',
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildMainBillingCard(latestBill),
                  const SizedBox(height: 32),
                  _buildBreakdownSection(latestBill),
                  const SizedBox(height: 32),
                  _buildSmartSavingsSection(),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FINANCIALS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.midnightCharcoal.withValues(alpha: 0.5),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bill & Savings',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppTheme.midnightCharcoal,
              ),
            ),
            _buildCircleButton(
              icon: Icons.notifications_none_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.midnightCharcoal.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.midnightCharcoal, size: 22),
      ),
    );
  }

  Widget _buildMainBillingCard(BillModel bill) {
    const currency = '₹';
    final daysToDue = bill.dueDate.difference(DateTime.now()).inDays;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.midnightCharcoal,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.midnightCharcoal.withValues(alpha: 0.2),
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
                bill.billingMonth.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white54,
                  letterSpacing: 1.2,
                ),
              ),
              if (bill.status == 'unpaid')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    daysToDue > 0 ? 'Due in $daysToDue days' : 'Overdue',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'PAID',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '$currency${bill.amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNITS USED',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white38,
                          fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${bill.unitsConsumed} kWh',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              if (bill.status == 'unpaid')
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () =>
                        _showPaymentSuccessDialog(context, bill.amount),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: AppTheme.midnightCharcoal,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'PAY NOW',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccessDialog(BuildContext context, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.green, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Done!',
              style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.midnightCharcoal),
            ),
            const SizedBox(height: 12),
            Text(
              'Your transaction of ₹${amount.toStringAsFixed(2)} has been completed successfully.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14, color: Colors.black45, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: AppTheme.primaryButtonStyle,
                child: const Text('Back to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownSection(BillModel bill) {
    const rate = 8.5; // Matches DatabaseService logic
    final usageCharge = bill.unitsConsumed * rate;
    const fixedCharge = 50.0;
    final taxes = bill.amount - usageCharge - fixedCharge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BILL BREAKDOWN',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.midnightCharcoal.withValues(alpha: 0.5),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              _buildBreakdownItem(
                  'Usage Charges',
                  '${bill.unitsConsumed} kWh × ₹$rate',
                  '₹${usageCharge.toStringAsFixed(2)}',
                  Icons.bolt_rounded,
                  Colors.blue),
              const Divider(height: 48, color: Colors.black12),
              _buildBreakdownItem(
                  'Service Fee',
                  'Fixed monthly rate',
                  '₹${fixedCharge.toStringAsFixed(2)}',
                  Icons.settings_input_component_rounded,
                  Colors.purple),
              const Divider(height: 48, color: Colors.black12),
              _buildBreakdownItem(
                  'Local Taxes',
                  'State & Gov Levies',
                  '₹${taxes.toStringAsFixed(2)}',
                  Icons.receipt_long_rounded,
                  Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownItem(String title, String subtitle, String amount,
      IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.midnightCharcoal)),
              Text(subtitle,
                  style:
                      GoogleFonts.inter(fontSize: 12, color: Colors.black38)),
            ],
          ),
        ),
        Text(amount,
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.midnightCharcoal)),
      ],
    );
  }

  Widget _buildSmartSavingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SMART SAVINGS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white38
                : AppTheme.midnightCharcoal.withValues(alpha: 0.5),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _buildSavingsCard('Phantom Power', 'Discard unused apps...',
                  'SAVE ₹120/mo', Icons.electric_bolt_rounded, Colors.green),
              const SizedBox(width: 16),
              _buildSavingsCard('AC Schedule', 'Optimize thermostatic...',
                  'SAVE ₹450/mo', Icons.ac_unit_rounded, AppTheme.primaryGold),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsCard(
      String title, String desc, String impact, IconData icon, Color color) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  impact,
                  style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w800, color: color),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.midnightCharcoal)),
          const SizedBox(height: 4),
          Text(desc,
              style: GoogleFonts.inter(
                  fontSize: 12, color: Colors.black38, height: 1.4)),
        ],
      ),
    );
  }
}

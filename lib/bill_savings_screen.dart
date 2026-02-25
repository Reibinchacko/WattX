import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notifications_screen.dart';
import 'theme/app_theme.dart';

class BillSavingsScreen extends StatefulWidget {
  const BillSavingsScreen({super.key});

  @override
  State<BillSavingsScreen> createState() => _BillSavingsScreenState();
}

class _BillSavingsScreenState extends State<BillSavingsScreen> {
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
              _buildMainBillingCard(),
              const SizedBox(height: 32),
              _buildBreakdownSection(),
              const SizedBox(height: 32),
              _buildSmartSavingsSection(),
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

  Widget _buildMainBillingCard() {
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
                'OCTOBER 2023',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white54,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Due in 5 days',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '₹842.50',
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
                    Text('EST. TOTAL',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white38,
                            fontWeight: FontWeight.w800)),
                    Text('₹1,240',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: AppTheme.midnightCharcoal,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('PAY NOW',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownSection() {
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
              boxShadow: AppTheme.softShadow),
          child: Column(
            children: [
              _buildBreakdownItem('Usage Charges', '412 kWh × ₹0.14', '₹576.80',
                  Icons.bolt_rounded, Colors.blue),
              const Divider(height: 48, color: Colors.black12),
              _buildBreakdownItem('Service Fee', 'Fixed daily rate', '₹150.00',
                  Icons.settings_input_component_rounded, Colors.purple),
              const Divider(height: 48, color: Colors.black12),
              _buildBreakdownItem('Local Taxes', 'State & Gov Levies',
                  '₹115.70', Icons.receipt_long_rounded, Colors.orange),
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
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24)),
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
          boxShadow: AppTheme.softShadow),
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
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(impact,
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: color))),
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

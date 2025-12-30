import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notifications_screen.dart';

class BillSavingsScreen extends StatefulWidget {
  const BillSavingsScreen({super.key});

  @override
  State<BillSavingsScreen> createState() => _BillSavingsScreenState();
}

class _BillSavingsScreenState extends State<BillSavingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildMainBillingCard(),
            const SizedBox(height: 12),
            _buildBreakdownSection(),
            const SizedBox(height: 16),
            _buildSmartSavingsSection(),
            const SizedBox(height: 16),
            _buildBillingHistorySection(),
            const SizedBox(height: 100), // Spacing for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
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
                'Financials',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF757575),
                ),
              ),
              Text(
                'Bill & Savings',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.black,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainBillingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
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
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: Color(0xFF757575)),
                  const SizedBox(width: 8),
                  Text(
                    'Oct 1 - Oct 31',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Due in 5 days',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Total Amount',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹84',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  height: 1.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '.50',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                'Projected: ₹110.00',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF757575),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.7,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEEFF41),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget: ₹125.00',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
              ElevatedButton(
                onPressed: () => _showPaymentSuccessDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEFF41),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'PAY NOW',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: Color(0xFF4CAF50), size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Successful!',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your payment of ₹84.50 has been processed successfully.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              Text(
                'Breakdown',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              InkWell(
                onTap: () => _showPaymentSuccessDialog(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEFF41),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PAY NOW',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildBreakdownItem(
            icon: Icons.bolt,
            iconColor: const Color(0xFF2196F3),
            bgColor: const Color(0xFFE3F2FD),
            title: 'Usage Charges',
            subtitle: '412 kWh × ₹0.14',
            amount: '₹57.68',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          _buildBreakdownItem(
            icon: Icons.card_giftcard,
            iconColor: const Color(0xFF9C27B0),
            bgColor: const Color(0xFFF3E5F5),
            title: 'Service Fee',
            subtitle: 'Fixed daily rate',
            amount: '₹15.00',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          _buildBreakdownItem(
            icon: Icons.receipt,
            iconColor: const Color(0xFF757575),
            bgColor: const Color(0xFFF5F5F5),
            title: 'Taxes & Levies',
            subtitle: 'State & Local',
            amount: '₹11.82',
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSmartSavingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Savings',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSavingsCard(
                icon: Icons.savings_outlined,
                iconColor: const Color(0xFF4CAF50),
                bgColor: const Color(0xFFE8F5E9),
                title: 'Phantom Power',
                description: 'Unplug unused devices to save on standby...',
                impact: '+₹12/mo',
              ),
              const SizedBox(width: 16),
              _buildSavingsCard(
                icon: Icons.lightbulb_outline,
                iconColor: const Color(0xFFFF9800),
                bgColor: const Color(0xFFFFF3E0),
                title: 'AC Schedule',
                description: 'Optimizing your thermostat can cut...',
                impact: 'High Impact',
                isYellow: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String description,
    required String impact,
    bool isYellow = false,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isYellow ? const Color(0xFFFEF9E7) : const Color(0xFFF1FDF6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isYellow ? const Color(0xFFFCF3CF) : const Color(0xFFD4EFDF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  impact,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF757575),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Billing History',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Full billing history coming soon')),
                );
              },
              child: Text(
                'See All',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(
                      0xFFE5BB00), // Adjusted to be visible on background
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildHistoryCard(
                month: 'September',
                amount: '₹92.40',
                status: 'Paid',
              ),
              const SizedBox(width: 16),
              _buildHistoryCard(
                month: 'August',
                amount: '₹145.20',
                status: 'Paid',
              ),
              const SizedBox(width: 16),
              _buildHistoryCard(
                month: 'July',
                amount: '₹132.00',
                status: 'Paid',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard({
    required String month,
    required String amount,
    required String status,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            month,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.check_circle,
                  color: Color(0xFF4CAF50), size: 16),
              const SizedBox(width: 4),
              Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

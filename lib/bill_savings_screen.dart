import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'notifications_screen.dart';
import 'theme/app_theme.dart';

class BillSavingsScreen extends StatefulWidget {
  const BillSavingsScreen({super.key});

  @override
  State<BillSavingsScreen> createState() => _BillSavingsScreenState();
}

class _BillSavingsScreenState extends State<BillSavingsScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  // Bill amount in paise (₹842.50 = 84250 paise)
  static const int _billAmountPaise = 84250;
  static const String _billDisplay = '₹842.50';

  // ─── Razorpay TEST KEY ─────────────────────────────────────────────────────
  // Replace with your actual key from https://dashboard.razorpay.com
  static const String _razorpayTestKey = 'rzp_test_SKniOJcdMAcaIL';
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _openRazorpay() {
    final options = {
      'key': _razorpayTestKey,
      'amount': _billAmountPaise, // in paise
      'name': 'WattX Energy',
      'description': 'Electricity Bill – October 2023',
      'prefill': {
        'contact': '9999999999',
        'email': 'user@wattx.in',
      },
      'theme': {
        'color': '#C9A84C', // AppTheme gold
      },
      'notes': {
        'meter_id': 'METER001',
        'bill_month': 'October 2023',
      },
    };

    try {
      setState(() => _isProcessing = true);
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      _showResultDialog(
        success: false,
        title: 'Could not open payment',
        message: e.toString(),
      );
    }
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessing = false);
    _showResultDialog(
      success: true,
      title: 'Payment Successful! 🎉',
      message:
          'Your electricity bill has been paid.\n\nPayment ID: ${response.paymentId}',
    );
  }

  void _onPaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    _showResultDialog(
      success: false,
      title: 'Payment Failed',
      message: response.message ?? 'Something went wrong. Please try again.',
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet selected: ${response.walletName}'),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showResultDialog({
    required bool success,
    required String title,
    required String message,
  }) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppTheme.surfaceWhite,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: success
                    ? Colors.green.withValues(alpha: 0.12)
                    : AppTheme.errorRed.withValues(alpha: 0.12),
              ),
              child: Icon(
                success ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 40,
                color: success ? Colors.green : AppTheme.errorRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.midnightCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      success ? Colors.green : AppTheme.primaryGold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  success ? 'Done' : 'Try Again',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            _billDisplay,
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
              // ── PAY NOW button ─────────────────────────────────────
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _openRazorpay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: AppTheme.midnightCharcoal,
                    disabledBackgroundColor:
                        AppTheme.primaryGold.withValues(alpha: 0.5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.midnightCharcoal,
                          ),
                        )
                      : Text('PAY NOW',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
              // ──────────────────────────────────────────────────────
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

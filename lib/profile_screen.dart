import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildProfileSection(user),
              const SizedBox(height: 32),
              _buildMeterDetailsCard(),
              const SizedBox(height: 24),
              _buildAppInfoCard(),
              const SizedBox(height: 32),
              _buildLogOutButton(),
              const SizedBox(height: 12),
              _buildVersionInfo(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACCOUNT',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.midnightCharcoal.withOpacity(0.5),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'My Profile',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.midnightCharcoal,
              ),
            ),
          ],
        ),
        _buildCircleButton(
          icon: Icons.settings_outlined,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings coming soon')),
            );
          },
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
          color: AppTheme.midnightCharcoal.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.midnightCharcoal, size: 22),
      ),
    );
  }

  Widget _buildProfileSection(User? user) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryGold, width: 2),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryGold.withOpacity(0.1),
                child: Text(
                  (user?.displayName ?? 'A')[0].toUpperCase(),
                  style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.midnightCharcoal),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_rounded,
                    size: 16, color: AppTheme.midnightCharcoal),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          user?.displayName ?? 'Alex Morgan',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.midnightCharcoal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? 'alex.morgan@email.com',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.midnightCharcoal.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildMeterDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded,
                  color: AppTheme.primaryGold, size: 24),
              const SizedBox(width: 12),
              Text(
                'Meter Details',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.midnightCharcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Smart Meter ID', 'SN-MTR-849201', showCopy: true),
          const SizedBox(height: 20),
          _buildInfoRow('Service Address', '123 Maple Avenue, SF'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Signal Status',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black38)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.green),
                      const SizedBox(width: 8),
                      Text('Excellent',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.green)),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.midnightCharcoal.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'v2.4.0',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.midnightCharcoal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool showCopy = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.black38)),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.midnightCharcoal)),
          ],
        ),
        if (showCopy)
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Copied')));
            },
            icon: Icon(Icons.copy_all_rounded,
                size: 20, color: AppTheme.midnightCharcoal.withOpacity(0.3)),
          ),
      ],
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.electric_bolt_rounded,
                    color: AppTheme.primaryGold),
              ),
              const SizedBox(width: 16),
              Text(
                'WattX App',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.midnightCharcoal),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Smart energy monitoring and optimization platform for modern sustainable living.',
            style: GoogleFonts.inter(
                fontSize: 12, color: Colors.black45, height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink('Privacy'),
              _buildDot(),
              _buildFooterLink('Terms'),
              _buildDot(),
              _buildFooterLink('Support'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.midnightCharcoal));
  }

  Widget _buildDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 4,
      height: 4,
      decoration: BoxDecoration(
          color: AppTheme.midnightCharcoal.withOpacity(0.1),
          shape: BoxShape.circle),
    );
  }

  Widget _buildLogOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _showLogOutDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.1),
          foregroundColor: Colors.red,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 20),
            const SizedBox(width: 12),
            Text('LOG OUT',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  void _showLogOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text('Log Out',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Log Out',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      'v2.4.0 (892)',
      style: GoogleFonts.inter(
          fontSize: 11, color: Colors.black26, fontWeight: FontWeight.w600),
    );
  }
}

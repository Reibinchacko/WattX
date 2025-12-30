import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // We'll build our own header
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildProfileSection(),
            const SizedBox(height: 20),
            _buildMeterDetailsCard(),
            const SizedBox(height: 12),
            _buildAppInfoCard(),
            const SizedBox(height: 20),
            _buildLogOutButton(),
            const SizedBox(height: 12),
            _buildVersionInfo(),
            const SizedBox(height: 100), // Spacing for bottom nav
          ],
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
              'Account',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF757575),
              ),
            ),
            Text(
              'My Profile',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings are currently locked')),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.settings_outlined, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFEB3B), width: 3),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFFFD54F),
                child: ClipOval(
                  child: Image.network(
                    'https://ui-avatars.com/api/?name=Alex+Morgan&background=FFD54F&color=000&size=120',
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Profile editing coming soon!')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEB3B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Alex Morgan',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'alex.morgan@email.com',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, size: 8, color: Color(0xFF4CAF50)),
              const SizedBox(width: 8),
              Text(
                'Active User',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeterDetailsCard() {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEB3B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt, size: 16, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Text(
                'Meter Details',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Smart Meter ID', 'SN - 849201 - XJ', showCopy: true),
          const SizedBox(height: 16),
          _buildInfoRow('Service Address', '123 Maple Avenue, Apt 4B'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connection Status',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.circle,
                          size: 8, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 8),
                      Text(
                        'Signal Strong',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Firmware v2.1',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF757575),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool showCopy = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            if (showCopy)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.copy_rounded,
                    size: 18, color: Color(0xFFBDBDBD)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF9E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.energy_savings_leaf,
                    color: Color(0xFFF57C00)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WattX App',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Monitor energy consumption in real-time, optimize savings, and reduce your carbon footprint with smart analytics.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF757575),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink('Terms'),
              _buildDot(),
              _buildFooterLink('Privacy'),
              _buildDot(),
              _buildFooterLink('Help'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {
        _showInfoDialog(text);
      },
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  void _showInfoDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('Information about $title will be displayed here soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          color: Color(0xFFE0E0E0),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildLogOutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          _showLogOutDialog();
        },
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFFFF1F1),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded,
                color: Color(0xFFE53935), size: 20),
            const SizedBox(width: 8),
            Text(
              'Log Out',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE53935),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      'Version 2.4.0 (Build 892)',
      style: GoogleFonts.inter(
        fontSize: 12,
        color: const Color(0xFFBDBDBD),
      ),
    );
  }
}

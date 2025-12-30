import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Control Center',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your smart devices',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 32),
              _buildControlTile(
                icon: Icons.lightbulb_outline,
                title: 'Living Room Lights',
                isOn: true,
                color: const Color(0xFFFFEB3B),
              ),
              const SizedBox(height: 16),
              _buildControlTile(
                icon: Icons.ac_unit,
                title: 'Air Conditioner',
                isOn: false,
                color: const Color(0xFF2196F3),
              ),
              const SizedBox(height: 16),
              _buildControlTile(
                icon: Icons.tv,
                title: 'Smart TV',
                isOn: true,
                color: const Color(0xFF9C27B0),
              ),
              const SizedBox(height: 16),
              _buildControlTile(
                icon: Icons.kitchen,
                title: 'Refrigerator',
                isOn: true,
                color: const Color(0xFF4CAF50),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlTile({
    required IconData icon,
    required String title,
    required bool isOn,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          Switch(
            value: isOn,
            onChanged: (value) {},
            activeColor: const Color(0xFFEEFF41),
            activeTrackColor: Colors.black.withOpacity(0.1),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
    );
  }
}

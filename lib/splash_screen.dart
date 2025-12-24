import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Added if (mounted) check for lint fix
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFF00), // Vivid Yellow from image
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Circular Logo
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1A1A1A), // Dark/Black circle
                ),
                child: const Icon(
                  Icons.bolt,
                  color: Color(0xFFFFFF00), // Matching yellow bolt
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Title
            Text(
              'WattX',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 40, // Increased size for shorter text
                fontWeight: FontWeight.w800,
                color: Colors.black,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle
            Text(
              'POWER MANAGEMENT',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black.withAlpha((0.7 * 255).toInt()),
                letterSpacing: 2.0,
              ),
            ),
            const Spacer(flex: 3),
            // Loading Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.black.withAlpha((0.1 * 255).toInt()),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Version
            Text(
              'v1.0.4',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.black.withAlpha((0.6 * 255).toInt()),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

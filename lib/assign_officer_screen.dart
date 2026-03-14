import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'services/database_service.dart';
import 'models/user_model.dart';

class AssignOfficerContent extends StatefulWidget {
  const AssignOfficerContent({super.key});

  @override
  State<AssignOfficerContent> createState() => _AssignOfficerContentState();
}

class _AssignOfficerContentState extends State<AssignOfficerContent> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        _buildFormCard(),
        const SizedBox(height: 32),
        _buildAllOfficersHeader(),
        _buildOfficersList(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Officer Email Address',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.midnightCharcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter officer email (e.g. name@ks...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black26,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(Icons.alternate_email_rounded,
                    color: Colors.black26, size: 20),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF0F210),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Assign Officer',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.midnightCharcoal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: AppTheme.midnightCharcoal, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Need to create a new officer account?',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllOfficersHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Text(
            'All Assigned Officers',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.midnightCharcoal,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black26, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon:
                const Icon(Icons.tune_rounded, color: Colors.black26, size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOfficersList() {
    return StreamBuilder<List<UserModel>>(
      stream: DatabaseService().getUsersByRole('officer'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading officers'));
        }
        final officersList = snapshot.data ?? [];
        if (officersList.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                'No officers found.',
                style: GoogleFonts.inter(color: Colors.black38),
              ),
            ),
          );
        }

        final bgColors = [
          const Color(0xFFEFF4FF),
          const Color(0xFFF6EFFF),
          const Color(0xFFFFF4E9),
          const Color(0xFFE0F7F6),
        ];
        final textColors = [
          const Color(0xFF4C84FF),
          const Color(0xFFA14CFF),
          const Color(0xFFFF8A00),
          const Color(0xFF26A69A),
        ];

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: officersList.length,
          itemBuilder: (context, index) {
            final officer = officersList[index];
            final name = officer.name.isNotEmpty ? officer.name : 'O';
            final initials = name.length > 1 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
            final email = officer.email;
            
            final bgColor = bgColors[index % bgColors.length];
            final textColor = textColors[index % textColors.length];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.midnightCharcoal,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.grid_view_rounded,
                                size: 12, color: Colors.black26),
                            const SizedBox(width: 4),
                            Text(
                              'KSEB Officer',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.black26,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.black12),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

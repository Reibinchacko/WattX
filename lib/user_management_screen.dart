import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';

class UserManagementContent extends StatefulWidget {
  const UserManagementContent({super.key});

  @override
  State<UserManagementContent> createState() => _UserManagementContentState();
}

class _UserManagementContentState extends State<UserManagementContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchAndFilter(),
              const SizedBox(height: 24),
              _buildSectionHeader(),
            ],
          ),
        ),
        Expanded(
          child: _buildUserList(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search user...',
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black26,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.black26, size: 20),
          suffixIcon:
              const Icon(Icons.tune_rounded, color: Colors.black26, size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Text(
          'Total Users',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.midnightCharcoal,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F210).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '128',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.midnightCharcoal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserList() {
    final users = [
      {
        'name': 'Arun Varma',
        'id': '#449201',
        'status': 'Active',
        'email': 'arun.v@gmail.com'
      },
      {
        'name': 'Meera Nair',
        'id': '#883109',
        'status': 'Inactive',
        'email': 'meera.n@gmail.com'
      },
      {
        'name': 'Rahul Das',
        'id': '#112004',
        'status': 'Active',
        'email': 'rahul.d@gmail.com'
      },
      {
        'name': 'Sita Pillai',
        'id': '#223405',
        'status': 'Active',
        'email': 'sita.p@gmail.com'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isActive = user['status'] == 'Active';
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        AppTheme.primaryGold.withValues(alpha: 0.1),
                    child: Text(
                      user['name']![0],
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.midnightCharcoal,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF2EBD59) : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name']!,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.midnightCharcoal,
                      ),
                    ),
                    Text(
                      'Meter ${user['id']}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black26,
                        fontWeight: FontWeight.w500,
                      ),
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
  }
}

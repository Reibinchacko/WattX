import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'services/database_service.dart';
import 'models/user_model.dart';
import 'kseb_consumer_details_screen.dart';

class KsebConsumerListScreen extends StatefulWidget {
  const KsebConsumerListScreen({super.key});

  @override
  State<KsebConsumerListScreen> createState() => _KsebConsumerListScreenState();
}

class _KsebConsumerListScreenState extends State<KsebConsumerListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _db = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Add User / Officer Bottom Sheet ──────────────────────────────────────────

  void _showAddDialog(String role) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final meterCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    bool obscure = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: role == 'officer'
                                ? Colors.blueAccent.withValues(alpha: 0.12)
                                : AppTheme.primaryGold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            role == 'officer'
                                ? Icons.badge_rounded
                                : Icons.person_add_rounded,
                            color: role == 'officer'
                                ? Colors.blueAccent
                                : AppTheme.primaryGold,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          role == 'officer'
                              ? 'Add New Officer'
                              : 'Add New Consumer',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.midnightCharcoal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Fields
                    _sheetField(
                      label: 'Full Name *',
                      controller: nameCtrl,
                      hint: 'e.g. Priya Nair',
                      icon: Icons.person_outline_rounded,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _sheetField(
                      label: 'Email Address *',
                      controller: emailCtrl,
                      hint: 'e.g. priya@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final re = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!re.hasMatch(v)) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Password
                    Text(
                      'Password *',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.midnightCharcoal.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: passCtrl,
                      obscureText: obscure,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 6) return 'Min 6 characters';
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Min 6 characters',
                        prefixIcon:
                            const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: Colors.black38,
                          ),
                          onPressed: () =>
                              setSheetState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sheetField(
                      label: 'Phone Number',
                      controller: phoneCtrl,
                      hint: '+91 98765 43210',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _sheetField(
                      label: 'Address',
                      controller: addressCtrl,
                      hint: 'e.g. Kowdiar, Trivandrum',
                      icon: Icons.location_on_outlined,
                    ),
                    if (role == 'user') ...[
                      const SizedBox(height: 16),
                      _sheetField(
                        label: 'Meter ID (optional)',
                        controller: meterCtrl,
                        hint: 'e.g. METER002',
                        icon: Icons.bolt_outlined,
                      ),
                    ],
                    const SizedBox(height: 28),

                    // Submit
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: role == 'officer'
                              ? Colors.blueAccent
                              : AppTheme.primaryGold,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setSheetState(() => isLoading = true);
                                HapticFeedback.mediumImpact();
                                try {
                                  await _db.createUserByAdmin(
                                    name: nameCtrl.text.trim(),
                                    email: emailCtrl.text.trim(),
                                    password: passCtrl.text.trim(),
                                    role: role,
                                    phone: phoneCtrl.text.trim().isEmpty
                                        ? null
                                        : phoneCtrl.text.trim(),
                                    address: addressCtrl.text.trim().isEmpty
                                        ? null
                                        : addressCtrl.text.trim(),
                                    meterId: meterCtrl.text.trim().isEmpty
                                        ? null
                                        : meterCtrl.text.trim(),
                                  );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${role == "officer" ? "Officer" : "Consumer"} "${nameCtrl.text.trim()}" added!',
                                        ),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setSheetState(() => isLoading = false);
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text(e
                                            .toString()
                                            .replaceAll('Exception: ', '')),
                                        backgroundColor: AppTheme.errorRed,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    role == 'officer'
                                        ? Icons.badge_rounded
                                        : Icons.person_add_rounded,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(role == 'officer'
                                      ? 'Add Officer'
                                      : 'Add Consumer'),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sheetField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.midnightCharcoal.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
          ),
        ),
      ],
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: _buildHeader(),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _buildSearchBar(),
            ),
            // Tab bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _buildTabBar(),
            ),
            const SizedBox(height: 12),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUserList('user'),
                  _buildUserList('officer'),
                ],
              ),
            ),
          ],
        ),
        // FAB
        Positioned(
          bottom: 24,
          right: 24,
          child: _buildFab(),
        ),
      ],
    );
  }

  Widget _buildFab() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final isOfficerTab = _tabController.index == 1;
        return FloatingActionButton.extended(
          onPressed: () => _showAddDialog(isOfficerTab ? 'officer' : 'user'),
          backgroundColor:
              isOfficerTab ? Colors.blueAccent : AppTheme.primaryGold,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Icon(
            isOfficerTab ? Icons.badge_rounded : Icons.person_add_rounded,
            size: 20,
          ),
          label: Text(
            isOfficerTab ? 'Add Officer' : 'Add Consumer',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        );
      },
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
              'User Management',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.midnightCharcoal,
              ),
            ),
            Text(
              'Live from Firebase',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        // Live user count badge
        StreamBuilder<List<UserModel>>(
          stream: _db.getAllUsers(),
          builder: (context, snap) {
            final count = snap.data?.length ?? 0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count Total',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGold,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search name or email...',
          hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(Icons.clear, color: Colors.grey),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        labelStyle:
            GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.midnightCharcoal,
        indicator: BoxDecoration(
          color: AppTheme.primaryGold,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: '👤  Consumers'),
          Tab(text: '🛡️  Officers'),
        ],
        onTap: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildUserList(String role) {
    return StreamBuilder<List<UserModel>>(
      stream: _db.getUsersByRole(role),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: GoogleFonts.inter(color: AppTheme.errorRed)),
          );
        }

        var users = snapshot.data ?? [];

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          users = users
              .where((u) =>
                  u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  u.email.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
        }

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  role == 'officer'
                      ? Icons.badge_outlined
                      : Icons.person_search_rounded,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No results for "$_searchQuery"'
                      : 'No ${role == "officer" ? "officers" : "consumers"} yet',
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to add one',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey[400]),
                  ),
                ]
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 100),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildUserCard(users[index], role),
        );
      },
    );
  }

  Widget _buildUserCard(UserModel user, String role) {
    final isOfficer = role == 'officer';
    final color = isOfficer ? Colors.blueAccent : AppTheme.primaryGold;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () {
        // Pass real user data to details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KsebConsumerDetailsScreen(consumer: {
              'name': user.name,
              'consumerId': '#${user.uid.substring(0, 6).toUpperCase()}',
              'meterId': 'SM-${user.uid.substring(0, 6).toUpperCase()}',
              'location': user.address ?? 'Not set',
              'status': user.isActive ? 'ACTIVE' : 'DISC.',
              'type': isOfficer ? 'business' : 'individual',
              'email': user.email,
              'phone': user.phoneNumber ?? 'Not set',
              'role': user.role,
              'uid': user.uid,
            }),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.midnightCharcoal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Active status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: user.isActive
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: user.isActive
                                          ? Colors.green
                                          : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.isActive ? 'ACTIVE' : 'INACTIVE',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: user.isActive
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user.email,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user.phoneNumber != null &&
                            user.phoneNumber!.isNotEmpty)
                          Text(
                            user.phoneNumber!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.black38,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black26),
                ],
              ),
            ),
            // Bottom row: UID + toggle
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.04),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.fingerprint_rounded, size: 14, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'UID: ${user.uid}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color.withValues(alpha: 0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Active toggle
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      await _db.setUserActive(user.uid, !user.isActive);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.isActive
                            ? Colors.red.withValues(alpha: 0.08)
                            : Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user.isActive ? 'Deactivate' : 'Activate',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: user.isActive ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

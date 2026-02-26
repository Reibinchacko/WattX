import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'services/database_service.dart';
import 'models/user_model.dart';
import 'register_complaint_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1012) : AppTheme.backgroundLight,
      body: const ProfileContent(),
    );
  }
}

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  bool _pushNotifications = true;
  bool _shareUsageData = true;
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return StreamBuilder<UserModel?>(
      stream: _databaseService.getUserProfile(firebaseUser?.uid ?? ''),
      builder: (context, snapshot) {
        final userData = snapshot.data;

        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 32),
                _buildProfileSection(firebaseUser, userData, isDark),
                const SizedBox(height: 32),
                _buildAccountDetails(firebaseUser, userData, isDark),
                const SizedBox(height: 32),
                _buildAppPreferences(themeProvider, isDark),
                const SizedBox(height: 32),
                _buildPrivacySettings(isDark),
                const SizedBox(height: 32),
                _buildSupportSection(isDark),
                const SizedBox(height: 32),
                _buildLogOutButton(isDark),
                const SizedBox(height: 12),
                _buildVersionInfo(isDark),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        'Settings',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppTheme.midnightCharcoal,
        ),
      ),
    );
  }

  Widget _buildProfileSection(
      User? firebaseUser, UserModel? userData, bool isDark) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryGold, width: 2),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor:
                    isDark ? const Color(0xFF1A1C1E) : AppTheme.backgroundLight,
                backgroundImage: (userData?.profileImageUrl != null)
                    ? NetworkImage(userData!.profileImageUrl!)
                    : (firebaseUser?.photoURL != null
                        ? NetworkImage(firebaseUser!.photoURL!)
                        : null),
                child: (userData?.profileImageUrl == null &&
                        firebaseUser?.photoURL == null)
                    ? Text(
                        (userData?.name ?? firebaseUser?.displayName ?? 'J')[0]
                            .toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : AppTheme.midnightCharcoal,
                        ),
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          userData?.name ?? firebaseUser?.displayName ?? 'Jane Doe',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppTheme.midnightCharcoal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${userData?.role.toUpperCase() ?? 'USER'} • ${userData?.address ?? 'Location not set'}',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark
                ? Colors.white54
                : AppTheme.midnightCharcoal.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDetails(
      User? firebaseUser, UserModel? userData, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ACCOUNT DETAILS', isDark),
        const SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.business_center_outlined,
          title: 'Full Name',
          subtitle: userData?.name ?? firebaseUser?.displayName ?? 'Jane Doe',
          onTap: () => _showChangeNameDialog(userData),
          showTrailing: true,
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _buildSettingsItem(
          icon: Icons.email_outlined,
          title: 'Email',
          subtitle:
              userData?.email ?? firebaseUser?.email ?? 'jane@example.com',
          onTap: () => _showChangeEmailDialog(),
          showTrailing: true,
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _buildSettingsItem(
          icon: Icons.lock_outline_rounded,
          title: 'Change Password',
          onTap: () => _showChangePasswordDialog(),
          showTrailing: true,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildAppPreferences(ThemeProvider themeProvider, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('APP PREFERENCES', isDark),
        const SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.notifications_outlined,
          title: 'Push Notifications',
          trailing: Switch(
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
            activeThumbColor: AppTheme.primaryGold,
            activeTrackColor: AppTheme.primaryGold.withValues(alpha: 0.5),
          ),
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _buildSettingsItem(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode',
          trailing: Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            activeThumbColor: AppTheme.primaryGold,
            activeTrackColor: AppTheme.primaryGold.withValues(alpha: 0.5),
          ),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildPrivacySettings(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('PRIVACY SETTINGS', isDark),
        const SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.bar_chart_rounded,
          title: 'Share Usage Data',
          subtitle: 'Help improve service accuracy',
          trailing: Switch(
            value: _shareUsageData,
            onChanged: (value) {
              setState(() {
                _shareUsageData = value;
              });
            },
            activeThumbColor: AppTheme.primaryGold,
            activeTrackColor: AppTheme.primaryGold.withValues(alpha: 0.5),
          ),
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _buildSettingsItem(
          icon: Icons.shield_outlined,
          title: 'Privacy Policy',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Privacy Policy coming soon')),
            );
          },
          showTrailing: true,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSupportSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('SUPPORT & HELP', isDark),
        const SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.error_outline_rounded,
          title: 'Register Complaint',
          subtitle: 'Report issues or suggest improvements',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterComplaintScreen(),
              ),
            );
          },
          showTrailing: true,
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _buildSettingsItem(
          icon: Icons.help_outline_rounded,
          title: 'Help Center',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help Center coming soon')),
            );
          },
          showTrailing: true,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: isDark
            ? Colors.white38
            : AppTheme.midnightCharcoal.withValues(alpha: 0.4),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    bool showTrailing = false,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppTheme.midnightCharcoal.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDark ? Colors.white70 : AppTheme.midnightCharcoal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.midnightCharcoal,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white54
                            : AppTheme.midnightCharcoal.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (showTrailing)
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? Colors.white30
                    : AppTheme.midnightCharcoal.withValues(alpha: 0.3),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(
        height: 1,
        thickness: 1,
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppTheme.midnightCharcoal.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildLogOutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => _showLogOutDialog(isDark),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : AppTheme.midnightCharcoal,
          side: const BorderSide(color: AppTheme.primaryGold, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 20),
            const SizedBox(width: 10),
            Text(
              'Log Out',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeNameDialog(UserModel? userData) {
    final nameController = TextEditingController(
      text: userData?.name ??
          FirebaseAuth.instance.currentUser?.displayName ??
          '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1C1E)
            : AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Change Name',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your full name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;

              try {
                await FirebaseAuth.instance.currentUser
                    ?.updateDisplayName(newName);
                if (userData != null) {
                  final updatedUser = UserModel(
                    uid: userData.uid,
                    name: newName,
                    email: userData.email,
                    role: userData.role,
                    phoneNumber: userData.phoneNumber,
                    address: userData.address,
                    budgetLimit: userData.budgetLimit,
                    isActive: userData.isActive,
                    createdAt: userData.createdAt,
                  );
                  await _databaseService.updateUserProfile(updatedUser);
                }
                await FirebaseAuth.instance.currentUser?.reload();
                if (!context.mounted) return;
                setState(() {});
                Navigator.pop(context);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: AppTheme.primaryGold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1C1E)
            : AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Change Email',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'New Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final newEmail = emailController.text.trim();
              final password = passwordController.text;
              if (newEmail.isEmpty || password.isEmpty) return;

              try {
                final user = FirebaseAuth.instance.currentUser;
                final credential = EmailAuthProvider.credential(
                  email: user!.email!,
                  password: password,
                );
                await user.reauthenticateWithCredential(credential);
                await user.verifyBeforeUpdateEmail(newEmail);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification email sent')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: Text('Update',
                style: GoogleFonts.inter(
                    color: AppTheme.primaryGold, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1C1E)
            : AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Change Password',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final currentPassword = currentPasswordController.text;
              final newPassword = newPasswordController.text;
              if (currentPassword.isEmpty || newPassword.isEmpty) return;

              try {
                final user = FirebaseAuth.instance.currentUser;
                final credential = EmailAuthProvider.credential(
                  email: user!.email!,
                  password: currentPassword,
                );
                await user.reauthenticateWithCredential(credential);
                await user.updatePassword(newPassword);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password updated')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: Text('Update',
                style: GoogleFonts.inter(
                    color: AppTheme.primaryGold, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showLogOutDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF1A1C1E) : AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Log Out',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text('Log Out',
                style: GoogleFonts.inter(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(bool isDark) {
    return Text(
      'Version 2.4.0 • Build 132',
      style: GoogleFonts.inter(
        fontSize: 12,
        color: isDark
            ? Colors.white24
            : AppTheme.midnightCharcoal.withValues(alpha: 0.3),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

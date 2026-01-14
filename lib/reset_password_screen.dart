import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _newPasswordError;
  String? _confirmPasswordError;

  void _validateForm() {
    setState(() {
      _newPasswordError = _validatePassword(_newPasswordController.text);
      _confirmPasswordError =
          _validateConfirmPassword(_confirmPasswordController.text);
      _isFormValid = _newPasswordError == null && _confirmPasswordError == null;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < 8) return 'Min 8 chars';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value != _newPasswordController.text) return 'Mismatch';
    return null;
  }

  void _resetPassword() {
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFF9D0),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 40,
                color: Color(0xFFFFEB3B),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Password Reset!',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your password has been successfully reset. Login to continue.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context)
                    .popUntil((route) => route.isFirst); // Back to Login (root)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEB3B),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Back to Login',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).toInt()),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: !isVisible,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFFBDBDBD),
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: errorText != null
                    ? const Color(0xFFFFB300)
                    : const Color(0xFF9E9E9E),
                size: 20,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFFFFB300), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            errorText,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFFB300),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      isVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF9E9E9E),
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  ),
                ],
              ),
              errorStyle: const TextStyle(fontSize: 0, height: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: errorText != null
                    ? const BorderSide(color: Color(0xFF212121), width: 1.2)
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                    color: errorText != null
                        ? const Color(0xFF212121)
                        : Colors.black12,
                    width: 1.5),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              if (label == 'New Password' && value.length < 8) {
                return 'Min 8 chars';
              }
              if (label == 'Confirm Password' &&
                  value != _newPasswordController.text) {
                return 'Mismatch';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'New Password',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // Icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFF9D0),
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFEB3B),
                        ),
                        child: const Icon(
                          Icons.lock_reset,
                          size: 40,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Set New Password',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  'Must be at least 8 characters.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(height: 48),

                // New Password
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  isVisible: _isNewPasswordVisible,
                  errorText: _newPasswordError,
                  onToggleVisibility: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Confirm Password
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  isVisible: _isConfirmPasswordVisible,
                  errorText: _confirmPasswordError,
                  onToggleVisibility: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),

                const SizedBox(height: 48),

                // Reset Password Button
                ElevatedButton(
                  onPressed: _isFormValid ? _resetPassword : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid
                        ? const Color(0xFFFFEB3B)
                        : const Color(0xFFE0E0E0),
                    foregroundColor:
                        _isFormValid ? Colors.black : const Color(0xFF9E9E9E),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Reset Password',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

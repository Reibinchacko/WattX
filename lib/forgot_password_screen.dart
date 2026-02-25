import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isFormValid = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _emailController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _validateEmail(_emailController.text) == null;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) return 'Invalid Email';
    return null;
  }

  Future<void> forgotPassword(String email) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFEB3B))),
      );

      await _authService.resetPassword(email);

      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFFFFF9D0)),
                  child: const Icon(Icons.check_circle,
                      size: 40, color: Color(0xFFFFEB3B)),
                ),
                const SizedBox(height: 24),
                Text('Reset Link Sent!',
                    style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
                const SizedBox(height: 12),
                Text(
                    'Check your email for instructions to reset your password.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: const Color(0xFF9E9E9E))),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEB3B),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('OK',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    }
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
        title: Text('Forgot Password',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  _buildIconHeader(),
                  const SizedBox(height: 48),
                  _buildTitleAndSubtitle(),
                  const SizedBox(height: 48),
                  _buildEmailField(),
                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
                  _buildLoginLink(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconHeader() {
    return Center(
      child: Container(
        width: 140,
        height: 140,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: Color(0xFFFFF9D0)),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                  angle: -0.5,
                  child:
                      const Icon(Icons.refresh, size: 60, color: Colors.black)),
              const Positioned(
                  right: 45,
                  top: 45,
                  child: Icon(Icons.lock, size: 35, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    return Column(
      children: [
        Text('Forgot Password?',
            style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black)),
        const SizedBox(height: 16),
        Text(
            "Don't worry, it happens. Please enter the\nemail associated with your account.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 14, color: const Color(0xFF9E9E9E), height: 1.5)),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email Address',
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ]),
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: GoogleFonts.inter(color: const Color(0xFFBDBDBD)),
              prefixIcon: const Icon(Icons.email_outlined,
                  color: Color(0xFF9E9E9E), size: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            validator: _validateEmail,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isFormValid
          ? () => forgotPassword(_emailController.text.trim())
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isFormValid ? const Color(0xFFFFEB3B) : const Color(0xFFE0E0E0),
        foregroundColor: _isFormValid ? Colors.black : const Color(0xFF9E9E9E),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text('Forgot Password',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Wrap(
        children: [
          Text('Remembered it? ',
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF9E9E9E))),
          GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text('Log in',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      decoration: TextDecoration.underline))),
        ],
      ),
    );
  }
}

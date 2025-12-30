import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isFormValid = false;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  void _validateForm() {
    setState(() {
      _nameError = _validateName(_nameController.text);
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError =
          _validateConfirmPassword(_confirmPasswordController.text);
      _isFormValid = _nameError == null &&
          _emailError == null &&
          _passwordError == null &&
          _confirmPasswordError == null;
    });
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) return 'Invalid Email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < 6) return 'Min 6 chars';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value != _passwordController.text) return 'Mismatch';
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
        );

        // Sign out after signup as requested to force manual login
        await _authService.signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully! Please log in.'),
              backgroundColor: Colors.green,
            ),
          );
          // Explicitly go to login page and clear stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Account',
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Name Field
                  Text(
                    'Full Name',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      controller: _nameController,
                      style: GoogleFonts.inter(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Enter Full Name',
                        hintStyle:
                            GoogleFonts.inter(color: const Color(0xFFBDBDBD)),
                        prefixIcon: Icon(Icons.person_outline,
                            color: _nameError != null
                                ? const Color(0xFFE53935)
                                : const Color(0xFF9E9E9E),
                            size: 20),
                        suffixIcon: _nameError != null
                            ? Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Color(0xFFE53935), size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      _nameError!,
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFE53935),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : null,
                        errorStyle: const TextStyle(fontSize: 0, height: 0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: _nameError != null
                              ? const BorderSide(
                                  color: Color(0xFFE53935), width: 1)
                              : BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                              color: _nameError != null
                                  ? const Color(0xFFE53935)
                                  : Colors.black12,
                              width: 1.5),
                        ),
                        filled: true,
                        fillColor: _nameError != null
                            ? const Color(0xFFFFF1F1)
                            : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                      validator: _validateName,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Email Field
                  Text(
                    'Email Address',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Enter Email',
                        hintStyle:
                            GoogleFonts.inter(color: const Color(0xFFBDBDBD)),
                        prefixIcon: Icon(Icons.email_outlined,
                            color: _emailError != null
                                ? const Color(0xFFE53935)
                                : const Color(0xFF9E9E9E),
                            size: 20),
                        suffixIcon: _emailError != null
                            ? Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Color(0xFFE53935), size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      _emailError!,
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFE53935),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : null,
                        errorStyle: const TextStyle(fontSize: 0, height: 0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: _emailError != null
                              ? const BorderSide(
                                  color: Color(0xFFE53935), width: 1)
                              : BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                              color: _emailError != null
                                  ? const Color(0xFFE53935)
                                  : Colors.black12,
                              width: 1.5),
                        ),
                        filled: true,
                        fillColor: _emailError != null
                            ? const Color(0xFFFFF1F1)
                            : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                      validator: _validateEmail,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  Text(
                    'Password',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: GoogleFonts.inter(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Enter Password',
                        hintStyle:
                            GoogleFonts.inter(color: const Color(0xFFBDBDBD)),
                        prefixIcon: Icon(Icons.lock_outline,
                            color: _passwordError != null
                                ? const Color(0xFFE53935)
                                : const Color(0xFF9E9E9E),
                            size: 20),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_passwordError != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Color(0xFFE53935), size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      _passwordError!,
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFE53935),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF9E9E9E),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ],
                        ),
                        errorStyle: const TextStyle(fontSize: 0, height: 0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: _passwordError != null
                              ? const BorderSide(
                                  color: Color(0xFFE53935), width: 1)
                              : BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                              color: _passwordError != null
                                  ? const Color(0xFFE53935)
                                  : Colors.black12,
                              width: 1.5),
                        ),
                        filled: true,
                        fillColor: _passwordError != null
                            ? const Color(0xFFFFF1F1)
                            : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                      validator: _validatePassword,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Confirm Password Field
                  Text(
                    'Confirm Password',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      style: GoogleFonts.inter(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Re-enter Password',
                        hintStyle:
                            GoogleFonts.inter(color: const Color(0xFFBDBDBD)),
                        prefixIcon: Icon(Icons.lock_outline,
                            color: _confirmPasswordError != null
                                ? const Color(0xFFE53935)
                                : const Color(0xFF9E9E9E),
                            size: 20),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_confirmPasswordError != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Color(0xFFE53935), size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      _confirmPasswordError!,
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFE53935),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF9E9E9E),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ],
                        ),
                        errorStyle: const TextStyle(fontSize: 0, height: 0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: _confirmPasswordError != null
                              ? const BorderSide(
                                  color: Color(0xFFE53935), width: 1)
                              : BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                              color: _confirmPasswordError != null
                                  ? const Color(0xFFE53935)
                                  : Colors.black12,
                              width: 1.5),
                        ),
                        filled: true,
                        fillColor: _confirmPasswordError != null
                            ? const Color(0xFFFFF1F1)
                            : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                      validator: _validateConfirmPassword,
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading || !_isFormValid ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid
                            ? const Color(0xFFFFEB3B)
                            : const Color(0xFFE0E0E0),
                        foregroundColor: _isFormValid
                            ? Colors.black
                            : const Color(0xFF9E9E9E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sign Up',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Log In Link
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            'Log In',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

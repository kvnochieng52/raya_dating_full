import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../router/app_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

enum _Step { requestCode, resetPassword }

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _Step _step = _Step.requestCode;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final message = await AuthService.requestPasswordReset(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _step = _Step.resetPassword);
      _showSnack(message);
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final message = await AuthService.requestPasswordReset(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      _showSnack(message);
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReset() async {
    if (!_resetFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final message = await AuthService.resetPassword(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );
      if (!mounted) return;
      _showSnack(message);
      context.go(AppRoutes.login);
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red.shade600 : AppTheme.primaryColor,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryColor),
          onPressed: () {
            if (_step == _Step.resetPassword) {
              setState(() => _step = _Step.requestCode);
              return;
            }
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.login);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largeSpacing,
          ),
          child: _step == _Step.requestCode
              ? _buildRequestStep()
              : _buildResetStep(),
        ),
      ),
    );
  }

  Widget _buildHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.smallSpacing),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppConstants.largeSpacing),
      ],
    );
  }

  Widget _buildRequestStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(
            title: 'Forgot your password?',
            subtitle:
                'Enter the email you used to sign up and we will send you a 6-digit code to reset your password.',
          ),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.largeSpacing),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Send reset code',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          Center(
            child: TextButton(
              onPressed: _isLoading ? null : () => context.go(AppRoutes.login),
              child: Text(
                'Back to sign in',
                style: GoogleFonts.poppins(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetStep() {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(
            title: 'Enter reset code',
            subtitle:
                'We sent a 6-digit code to ${_emailController.text.trim()}. Enter it below along with your new password. The code expires in 15 minutes.',
          ),
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: const InputDecoration(
              labelText: '6-digit code',
              prefixIcon: Icon(Icons.pin_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().length != 6) {
                return 'Enter the 6-digit code from your email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'New password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () => setState(
                    () => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter a new password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmVisible,
            decoration: InputDecoration(
              labelText: 'Confirm new password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_isConfirmVisible
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () =>
                    setState(() => _isConfirmVisible = !_isConfirmVisible),
              ),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.largeSpacing),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitReset,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Reset password',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          Center(
            child: TextButton(
              onPressed: _isLoading ? null : _resendCode,
              child: Text(
                "Didn't get the code? Resend",
                style: GoogleFonts.poppins(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

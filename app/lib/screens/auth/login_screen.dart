import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../router/app_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/animated_logo.dart';
// ignore: unused_import
import '../../widgets/social_auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isEmailLogin = true; // Toggle between email and phone

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.welcome);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppConstants.largeSpacing),

              // Logo and Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Column(
                    children: [
                      const StaticLogo(size: 80),
                      const SizedBox(height: AppConstants.mediumSpacing),
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallSpacing),
                      Text(
                        'Sign in to continue your journey',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.xLargeSpacing),

              // Login type toggle — removed; email-only login.
              // SlideTransition(
              //   position: _slideAnimation,
              //   child: FadeTransition(
              //     opacity: _fadeAnimation,
              //     child: _buildLoginTypeToggle(),
              //   ),
              // ),
              // const SizedBox(height: AppConstants.largeSpacing),

              // Form
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email address',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Please enter your email';
                            if (!v.contains('@')) return 'Please enter a valid email';
                            return null;
                          },
                        ),

                        const SizedBox(height: AppConstants.mediumSpacing),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppTheme.primaryColor,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppConstants.smallSpacing),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => context.push(AppRoutes.forgotPassword),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppConstants.largeSpacing),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Sign In',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // "or continue with" divider + Google/Apple social buttons —
              // temporarily disabled.
              // const SizedBox(height: AppConstants.xLargeSpacing),
              // SlideTransition(
              //   position: _slideAnimation,
              //   child: FadeTransition(
              //     opacity: _fadeAnimation,
              //     child: Row(
              //       children: [
              //         const Expanded(child: Divider()),
              //         Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 16),
              //           child: Text(
              //             'or continue with',
              //             style: GoogleFonts.poppins(
              //               fontSize: 14,
              //               color: Colors.grey[600],
              //             ),
              //           ),
              //         ),
              //         const Expanded(child: Divider()),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: AppConstants.largeSpacing),
              // SlideTransition(
              //   position: _slideAnimation,
              //   child: FadeTransition(
              //     opacity: _fadeAnimation,
              //     child: Column(
              //       children: [
              //         SocialAuthButton(
              //           icon: Icons.g_mobiledata,
              //           text: 'Continue with Google',
              //           onPressed: _handleGoogleLogin,
              //           backgroundColor: Colors.white,
              //           textColor: Colors.black87,
              //           borderColor: Colors.grey[300],
              //         ),
              //         const SizedBox(height: AppConstants.mediumSpacing),
              //         SocialAuthButton(
              //           icon: Icons.apple,
              //           text: 'Continue with Apple',
              //           onPressed: _handleAppleLogin,
              //           backgroundColor: Colors.black,
              //           textColor: Colors.white,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              const SizedBox(height: AppConstants.xLargeSpacing),

              // Sign Up Link
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.signup),
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.largeSpacing),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildLoginTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isEmailLogin = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isEmailLogin ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Email',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _isEmailLogin ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isEmailLogin = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isEmailLogin ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Phone',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: !_isEmailLogin ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      _showSnack('Login successful!', Colors.green);

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      context.go(AppRoutes.dashboard);
    } on AuthException catch (e) {
      _showSnack(e.message, Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ignore: unused_element
  void _handleGoogleLogin() async {
    // TODO: Implement Google login
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Google login successful!',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
  }

  // ignore: unused_element
  void _handleAppleLogin() async {
    // TODO: Implement Apple login
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Apple login successful!',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
  }
}
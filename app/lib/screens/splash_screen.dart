import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../router/app_router.dart';
import '../services/auth_state.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _animationController.forward();

    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;
    final target = AuthState.instance.isAuthenticated
        ? AppRoutes.dashboard
        : AppRoutes.welcome;
    context.go(target);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            // Background Image - heavenly sunrise / golden light
            Container(
              width: size.width,
              height: size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1080&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Gradient Overlay — deep plum → medium plum → dusty rose.
            Container(
              width: size.width,
              height: size.height,
              decoration: const BoxDecoration(
                gradient: AppTheme.splashGradient,
              ),
            ),

            // Content
            SizedBox(
              width: size.width,
              height: size.height,
              child: SafeArea(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo
                          Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Opacity(
                              opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      AppTheme.accentColor,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.4),
                                      blurRadius: 30,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  size: 70,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // App Name
                          Opacity(
                            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                            child: Text(
                              AppConstants.appName,
                              style: GoogleFonts.poppins(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Tagline
                          Opacity(
                            opacity: (_fadeAnimation.value * 0.9).clamp(0.0, 1.0),
                            child: Text(
                              'Where Faith Meets Love',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                                color: AppTheme.accentColor,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Scripture verse
                          Opacity(
                            opacity: (_fadeAnimation.value * 0.8).clamp(0.0, 1.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                '"He who finds a wife finds a good thing\nand obtains favour from the Lord."\n— Proverbs 18:22',
                                style: GoogleFonts.lora(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.75),
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          const SizedBox(height: 80),

                          // Loading indicator
                          Opacity(
                            opacity: (_fadeAnimation.value * 0.8).clamp(0.0, 1.0),
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.goldColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Loading text
                          Opacity(
                            opacity: (_fadeAnimation.value * 0.7).clamp(0.0, 1.0),
                            child: Text(
                              'Preparing your journey...',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

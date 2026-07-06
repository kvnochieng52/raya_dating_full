import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedLogo extends StatefulWidget {
  final double size;
  final Color? color;

  const AnimatedLogo({
    super.key,
    this.size = 80,
    this.color,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color ?? Colors.white,
                  widget.color?.withOpacity(0.8) ?? Colors.white.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.color ?? Colors.white).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.favorite,
              size: widget.size * 0.5,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class StaticLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const StaticLogo({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color ?? AppTheme.primaryColor,
            (color ?? AppTheme.primaryColor).withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (color ?? AppTheme.primaryColor).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.favorite,
        size: size * 0.5,
        color: Colors.white,
      ),
    );
  }
}
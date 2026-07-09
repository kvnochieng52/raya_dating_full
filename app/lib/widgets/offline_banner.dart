import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/connectivity_service.dart';
import '../theme/app_theme.dart';

class OfflineBanner extends StatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  bool _wasOffline = false;
  bool _showRestoredBanner = false;
  Timer? _restoredTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    ConnectivityService.instance.addListener(_onConnectivityChanged);

    if (!ConnectivityService.instance.isOnline) {
      _controller.value = 1.0;
      _wasOffline = true;
    }
  }

  void _onConnectivityChanged() {
    final online = ConnectivityService.instance.isOnline;
    if (!online) {
      _restoredTimer?.cancel();
      setState(() {
        _showRestoredBanner = false;
        _wasOffline = true;
      });
      _controller.forward();
    } else if (_wasOffline) {
      _controller.reverse().then((_) {
        if (!mounted) return;
        setState(() => _showRestoredBanner = true);
        _restoredTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showRestoredBanner = false);
        });
        _wasOffline = false;
      });
    }
  }

  @override
  void dispose() {
    ConnectivityService.instance.removeListener(_onConnectivityChanged);
    _restoredTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Offline banner
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _slide,
            child: _OfflineStrip(),
          ),
        ),

        // "Back online" confirmation banner
        if (_showRestoredBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _RestoredStrip(),
          ),
      ],
    );
  }
}

class _OfflineStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: const Color(0xFF323232),
      padding: EdgeInsets.only(
        top: topPadding + 8,
        bottom: 10,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No internet connection. Some features may not work.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestoredStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: AppTheme.primaryColor,
      padding: EdgeInsets.only(
        top: topPadding + 8,
        bottom: 10,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text(
            'Back online',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

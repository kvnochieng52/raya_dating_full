import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/status_indicator.dart';
import '../services/privacy_service.dart';

class SwipeCard extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSuperLike;
  final VoidCallback? onTap;
  final VoidCallback? onChat;
  final bool isTop;

  const SwipeCard({
    super.key,
    required this.profile,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSuperLike,
    this.onTap,
    this.onChat,
    this.isTop = false,
  });

  @override
  State<SwipeCard> createState() => SwipeCardState();
}

class SwipeCardState extends State<SwipeCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isBeingRemoved = false;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // If card is being removed, make it invisible to prevent glitches
    if (_isBeingRemoved) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value * size.width + _dragOffset,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildCard(size),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(Size size) {
    return GestureDetector(
      onPanStart: widget.isTop ? _onPanStart : null,
      onPanUpdate: widget.isTop ? _onPanUpdate : null,
      onPanEnd: widget.isTop ? _onPanEnd : null,
      onTap: widget.onTap ?? _nextPhoto,
      child: Container(
        width: size.width * 0.9,
        height: size.height * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity( 0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Photo
              _buildPhotoView(),

              // Photo indicators
              if (widget.profile.photos.length > 1)
                _buildPhotoIndicators(),

              // Gradient overlay
              _buildGradientOverlay(),

              // Profile info
              _buildProfileInfo(),

              // Action indicators
              if (_isDragging) _buildActionIndicators(),

              // Verification badge
              if (widget.profile.isVerified)
                _buildVerificationBadge(),

              // Online status
              _buildOnlineStatus(),

              // Chat shortcut (top-right)
              if (widget.onChat != null) _buildChatButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatButton() {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
    return Positioned(
      bottom: 20,
      right: 20,
      child: Material(
        color: Colors.white.withOpacity(0.92),
        shape: shape,
        elevation: 2,
        child: InkWell(
          customBorder: shape,
          onTap: widget.onChat,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Chat',
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoView() {
    return PageView.builder(
      itemCount: widget.profile.photos.length,
      onPageChanged: (index) {
        setState(() => _currentPhotoIndex = index);
      },
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: widget.profile.photos[index],
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.person,
              size: 100,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoIndicators() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Row(
        children: List.generate(
          widget.profile.photos.length,
          (index) => Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index == _currentPhotoIndex
                    ? Colors.white
                    : Colors.white.withOpacity( 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity( 0.7),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Positioned(
      bottom: 140,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.profile.displayName}, ${widget.profile.age}',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (widget.profile.isVerified)
                const Icon(
                  Icons.verified,
                  color: Colors.blue,
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.profile.occupation,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity( 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.profile.bio,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity( 0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.profile.interests.take(3).map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity( 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity( 0.3)),
                ),
                child: Text(
                  interest,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIndicators() {
    final opacity = (_dragOffset.dx.abs() / 100).clamp(0.0, 1.0);

    return Stack(
      children: [
        // Like indicator
        if (_dragOffset.dx > 0)
          Positioned(
            top: 100,
            left: 20,
            child: Transform.rotate(
              angle: -0.3,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'LIKE',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Pass indicator
        if (_dragOffset.dx < 0)
          Positioned(
            top: 100,
            right: 20,
            child: Transform.rotate(
              angle: 0.3,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PASS',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerificationBadge() {
    return const Positioned(
      top: 20,
      right: 20,
      child: Icon(
        Icons.verified,
        color: Colors.blue,
        size: 32,
      ),
    );
  }

  Widget _buildOnlineStatus() {
    return Positioned(
      top: 60,
      right: 20,
      child: OnlineStatusIndicator(
        status: widget.profile.isOnline ? OnlineStatus.online : OnlineStatus.offline,
        size: 16,
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _isDragging = false);

    const swipeThreshold = 100.0;

    if (_dragOffset.dx > swipeThreshold) {
      // Swipe right - like
      _animateAndCallback(() => widget.onSwipeRight?.call());
    } else if (_dragOffset.dx < -swipeThreshold) {
      // Swipe left - pass
      _animateAndCallback(() => widget.onSwipeLeft?.call());
    } else if (_dragOffset.dy < -swipeThreshold) {
      // Swipe up - super like
      superLike();
    } else {
      // Return to center
      setState(() => _dragOffset = Offset.zero);
    }
  }

  void _animateAndCallback(VoidCallback callback) {
    setState(() => _isBeingRemoved = true);
    _animationController.forward().then((_) {
      // Call the callback to remove the card from the parent's list
      callback();
    });
  }

  void _nextPhoto() {
    if (widget.profile.photos.length > 1) {
      setState(() {
        _currentPhotoIndex = (_currentPhotoIndex + 1) % widget.profile.photos.length;
      });
    }
  }

  // Public methods for programmatic swiping
  void swipeLeft() {
    _animateAndCallback(() => widget.onSwipeLeft?.call());
  }

  void swipeRight() {
    _animateAndCallback(() => widget.onSwipeRight?.call());
  }

  void superLike() {
    // Add a small shake animation for super like
    _shakeController.forward().then((_) {
      _shakeController.reverse().then((_) {
        setState(() => _isBeingRemoved = true);
        widget.onSuperLike?.call();
      });
    });
  }
}
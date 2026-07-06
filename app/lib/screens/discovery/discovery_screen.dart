import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/match_summary.dart';
import '../../models/user_model.dart';
import '../../router/app_router.dart';
import '../../services/auth_state.dart';
import '../../services/discovery_service.dart';
import '../../services/matching_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../chat/chat_thread_screen.dart';
import '../../widgets/swipe_card.dart';
import '../../widgets/animated_logo.dart';
import 'filters_screen.dart';
import 'likes_screen.dart';
import '../matching/match_request_screen.dart';
import '../therapy/therapy_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => DiscoveryScreenState();
}

class DiscoveryScreenState extends State<DiscoveryScreen>
    with TickerProviderStateMixin {
  /// Forces a re-fetch of the discovery feed. Called from outside (e.g. when
  /// the user taps the Discover bottom-nav tab).
  void refresh() => _loadProfiles();

  late AnimationController _buttonAnimationController;
  late AnimationController _matchAnimationController;

  List<UserProfile> _profiles = [];
  List<GlobalKey<SwipeCardState>> _cardKeys = [];
  FilterCriteria _filters = FilterCriteria();
  bool _isLoading = true;
  final MatchingService _matchingService = MatchingService();
  Map<String, MatchSummary> _matchesByUserId = {};

  @override
  void initState() {
    super.initState();

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _matchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadProfiles();
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    _matchAnimationController.dispose();
    super.dispose();
  }

  void _loadProfiles() async {
    setState(() => _isLoading = true);

    // Fetch in parallel — matches map drives the chat icon's behavior.
    final results = await Future.wait([
      MatchingService.getDiscoveryProfiles(filters: _filters),
      DiscoveryService.fetchMatchesByPartnerId().catchError(
        (_) => <String, MatchSummary>{},
      ),
    ]);
    if (!mounted) return;

    final profiles = results[0] as List<UserProfile>;
    final matches = results[1] as Map<String, MatchSummary>;
    final cardKeys = List.generate(
      profiles.length,
      (index) => GlobalKey<SwipeCardState>(),
    );

    setState(() {
      _profiles = profiles;
      _cardKeys = cardKeys;
      _matchesByUserId = matches;
      _isLoading = false;
    });
  }

  /// Tap-handler for the chat icon on a swipe card. If we've already matched
  /// with this profile, jump to the thread; otherwise nudge the user to swipe
  /// right first.
  void _openChatFor(UserProfile profile) {
    final match = _matchesByUserId[profile.id];
    if (match != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatThreadScreen(match: match)),
      );
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Like ${profile.displayName} back to start chatting.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Re-render whenever the user's completed_step changes so the
    // "finish your profile" banner appears/disappears live.
    return AnimatedBuilder(
      animation: AuthState.instance,
      builder: (context, _) {
        final showBanner = !AuthState.instance.isProfileComplete;
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(),
          body: Column(
            children: [
              if (showBanner) _buildProfileBanner(),
              Expanded(
                child: _isLoading ? _buildLoadingView() : _buildDiscoveryView(),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomActions(),
        );
      },
    );
  }

  Widget _buildProfileBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Finish your profile to start matching and chatting.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => context.push(AppRoutes.profileSetup),
            child: Text(
              'Finish',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileIncompleteToast() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Finish your profile to start matching.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'FINISH',
          textColor: Colors.white,
          onPressed: () => context.push(AppRoutes.profileSetup),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          const StaticLogo(size: 32),
          const SizedBox(width: 12),
          Text(
            AppConstants.appName,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune_outlined, color: AppTheme.primaryColor),
          onPressed: _openFilters,
        ),
        // Mental health / therapy shortcut — temporarily hidden.
        // IconButton(
        //   icon: const Icon(Icons.psychology_outlined, color: AppTheme.primaryColor),
        //   onPressed: _openSupport,
        // ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: AppTheme.primaryColor),
          onPressed: _openLikes,
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          SizedBox(height: 16),
          Text('Finding amazing people nearby...'),
        ],
      ),
    );
  }

  Widget _buildDiscoveryView() {
    if (_profiles.isEmpty) {
      return _buildEmptyView();
    }

    return Column(
      children: [
        // Want to be matched banner
        _buildMatchingBanner(),

        // Main swipe area
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cards stack - first card is on top visually
              for (int i = _profiles.length - 1; i >= 0; i--)
                Positioned(
                  top: 8 + i * 10,
                  child: Builder(builder: (_) {
                    // In browse-only mode, suppress gesture callbacks so
                    // the card never animates off-screen on a blocked swipe.
                    final canSwipe = AuthState.instance.isProfileComplete;
                    return SwipeCard(
                      key: _cardKeys[i],
                      profile: _profiles[i],
                      isTop: i == 0,
                      onSwipeLeft: (i == 0 && canSwipe)
                          ? () => _handleSwipe(0, SwipeAction.pass)
                          : null,
                      onSwipeRight: (i == 0 && canSwipe)
                          ? () => _handleSwipe(0, SwipeAction.like)
                          : null,
                      onSuperLike: (i == 0 && canSwipe)
                          ? () => _handleSwipe(0, SwipeAction.superLike)
                          : null,
                      onTap: i == 0
                          ? (canSwipe
                              ? () => _showProfileDetails(_profiles[i])
                              : _showProfileIncompleteToast)
                          : null,
                      onChat: i == 0
                          ? () => _openChatFor(_profiles[i])
                          : null,
                    );
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No more profiles',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your filters or check back later for new people.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _openFilters,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'Adjust Filters',
                style: GoogleFonts.poppins(
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

  Widget _buildMatchingBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const MatchRequestScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Icon Section
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // Text Section
            Expanded(
              child: Text(
                '✨ Want to be matched? Let our team find your perfect match!',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 8),

            // Arrow
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    if (_profiles.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.chevron_left,
              color: Colors.grey,
              onPressed: _profiles.length > 1 ? _showPreviousProfile : () {},
              size: 44,
            ),
            _buildActionButton(
              icon: Icons.close,
              color: Colors.red,
              onPressed: () => _programmaticSwipe(SwipeAction.pass),
              size: 60,
            ),
            _buildActionButton(
              icon: Icons.favorite,
              color: Colors.green,
              onPressed: () => _programmaticSwipe(SwipeAction.like),
              size: 60,
            ),
            _buildActionButton(
              icon: Icons.chevron_right,
              color: Colors.grey,
              onPressed: _profiles.length > 1 ? _showNextProfile : () {},
              size: 44,
            ),
          ],
        ),
      ),
    );
  }

  /// Rotates the card stack: bring the bottom card to the top.
  void _showPreviousProfile() {
    if (_profiles.length < 2) return;
    setState(() {
      _profiles.insert(0, _profiles.removeLast());
      _cardKeys.insert(0, _cardKeys.removeLast());
    });
  }

  /// Rotates the card stack: send the top card to the bottom (no swipe
  /// recorded — just a peek at the next one).
  void _showNextProfile() {
    if (_profiles.length < 2) return;
    setState(() {
      _profiles.add(_profiles.removeAt(0));
      _cardKeys.add(_cardKeys.removeAt(0));
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 50,
  }) {
    return AnimatedBuilder(
      animation: _buttonAnimationController,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => _buttonAnimationController.forward(),
          onTapUp: (_) => _buttonAnimationController.reverse(),
          onTapCancel: () => _buttonAnimationController.reverse(),
          onTap: onPressed,
          child: Transform.scale(
            scale: 1.0 - (_buttonAnimationController.value * 0.1),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: color, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity( 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: size * 0.4,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSwipe(int index, SwipeAction action) async {
    if (index >= _profiles.length) return;

    // Browse-only mode for users who haven't finished their profile.
    if (!AuthState.instance.isProfileComplete) {
      _showProfileIncompleteToast();
      return;
    }

    final profile = _profiles[index];

    bool isMatch = false;
    try {
      isMatch = await _matchingService.handleSwipe(profile.id, action);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Swipe failed: $e')),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _profiles.removeAt(index);
      _cardKeys.removeAt(index);
    });

    print('After removal, profiles left: ${_profiles.length}');
    if (_profiles.isNotEmpty) {
      print('New top profile: ${_profiles.first.name}'); // Changed to first since first is now top
    }

    if (isMatch && action != SwipeAction.pass && mounted) {
      _showMatchDialog(profile);
    }

    // Load more profiles if running low
    if (_profiles.length <= 2) {
      _loadMoreProfiles();
    }
  }

  void _programmaticSwipe(SwipeAction action) {
    if (_profiles.isEmpty) return;

    // Same gate as _handleSwipe — keep the card from animating off-screen
    // with no feedback when the user can't actually swipe yet.
    if (!AuthState.instance.isProfileComplete) {
      _showProfileIncompleteToast();
      return;
    }

    final topCardKey = _cardKeys.first; // First card is now on top
    final topCardState = topCardKey.currentState;

    if (topCardState != null) {
      // Trigger the visual animation which will call the callback
      switch (action) {
        case SwipeAction.like:
          topCardState.swipeRight();
          break;
        case SwipeAction.pass:
          topCardState.swipeLeft();
          break;
        case SwipeAction.superLike:
          topCardState.superLike();
          break;
      }
    }
  }

  void _loadMoreProfiles() async {
    final newProfiles = await MatchingService.getDiscoveryProfiles(filters: _filters);
    if (!mounted) return;
    final newCardKeys = List.generate(
      newProfiles.length,
      (index) => GlobalKey<SwipeCardState>(),
    );

    setState(() {
      _profiles.addAll(newProfiles);
      _cardKeys.addAll(newCardKeys);
    });
  }

  void _showMatchDialog(UserProfile profile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MatchDialog(
        profile: profile,
        onKeepSwiping: () => Navigator.pop(context),
        onSendMessage: () {
          Navigator.pop(context);
          // TODO: Navigate to chat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Chat feature will be implemented with APIs',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  void _openFilters() async {
    final result = await Navigator.push<FilterCriteria>(
      context,
      MaterialPageRoute(
        builder: (context) => FiltersScreen(currentFilters: _filters),
      ),
    );

    if (result != null) {
      setState(() => _filters = result);
      _loadProfiles();
    }
  }

  void _openLikes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LikesScreen(),
      ),
    );
  }

  // ignore: unused_element
  void _openSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TherapyScreen(),
      ),
    );
  }

  void _showProfileDetails(UserProfile user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProfileDetailsSheet(user),
    );
  }

  Widget _buildProfileDetailsSheet(UserProfile user) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photos
                      SizedBox(
                        height: 400,
                        child: PageView.builder(
                          itemCount: user.photos.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: user.photos[index],
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
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Name and age
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${user.displayName}, ${user.age}',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceColor,
                              ),
                            ),
                          ),
                          if (user.isVerified)
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 28,
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Occupation
                      Text(
                        user.occupation,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bio
                      Text(
                        user.bio,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppTheme.onSurfaceColor,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Interests
                      if (user.interests.isNotEmpty) ...[
                        Text(
                          'Interests',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.interests.map((interest) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity( 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.primaryColor.withOpacity( 0.3)),
                              ),
                              child: Text(
                                interest,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _handleSwipe(0, SwipeAction.pass);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                foregroundColor: Colors.grey[700],
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Pass',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _handleSwipe(0, SwipeAction.superLike);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Super Like',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _handleSwipe(0, SwipeAction.like);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Like',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Match Dialog Widget
class MatchDialog extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onKeepSwiping;
  final VoidCallback onSendMessage;

  const MatchDialog({
    super.key,
    required this.profile,
    required this.onKeepSwiping,
    required this.onSendMessage,
  });

  @override
  State<MatchDialog> createState() => _MatchDialogState();
}

class _MatchDialogState extends State<MatchDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity( 0.8),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.all(40),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "It's a Match!",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'You and ${widget.profile.displayName} liked each other',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.network(
                              widget.profile.photos.first,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Icon(
                            Icons.favorite,
                            color: AppTheme.primaryColor,
                            size: 40,
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: widget.onKeepSwiping,
                              child: Text(
                                'Keep Swiping',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: widget.onSendMessage,
                              child: Text(
                                'Send Message',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
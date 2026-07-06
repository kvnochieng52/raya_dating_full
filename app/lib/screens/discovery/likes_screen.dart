import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/match_summary.dart';
import '../../models/user_model.dart';
import '../../services/discovery_service.dart';
import '../../services/matching_service.dart';
import '../../services/privacy_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_indicator.dart';
import '../chat/chat_thread_screen.dart';

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final MatchingService _matchingService = MatchingService();
  Map<String, MatchSummary> _matchesByUserId = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    try {
      final map = await DiscoveryService.fetchMatchesByPartnerId();
      if (!mounted) return;
      setState(() => _matchesByUserId = map);
    } catch (_) {
      // Silent — chat icon will just nudge the user to like/match first.
    }
  }

  Widget _buildChatShortcut(UserProfile user, {required bool isWhoLikedYou}) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));
    return Material(
      color: Colors.white.withOpacity(0.95),
      shape: shape,
      elevation: 2,
      child: InkWell(
        customBorder: shape,
        onTap: () => _openChatOrNudge(
          user,
          unmatched: isWhoLikedYou
              ? 'Like ${user.displayName} back to start chatting.'
              : 'Waiting for ${user.displayName} to like you back.',
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 14,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                'Chat',
                style: GoogleFonts.poppins(
                  color: AppTheme.primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openChatOrNudge(UserProfile user, {required String unmatched}) {
    final match = _matchesByUserId[user.id];
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
        content: Text(unmatched, style: GoogleFonts.poppins()),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Only show back-arrow when the screen was pushed onto the stack
        // (e.g. opened from the Discovery heart icon). When mounted as a
        // bottom-nav tab, there's nowhere to go back to.
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: false,
        title: Text(
          'Likes',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: AppTheme.primaryColor,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          tabs: const [
            Tab(text: 'People You Liked'),
            Tab(text: 'Who Liked You'),
            Tab(text: 'Matches'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPeopleYouLikedTab(),
          _buildWhoLikedYouTab(),
          const _MatchesTab(),
        ],
      ),
    );
  }

  Widget _buildWhoLikedYouTab() {
    return FutureBuilder<List<UserProfile>>(
      future: _matchingService.getWhoLikedYou(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading likes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          );
        }

        final likedByUsers = snapshot.data ?? [];

        if (likedByUsers.isEmpty) {
          return _buildEmptyState(
            'No one has liked you yet',
            'Keep swiping to find your matches!',
            Icons.favorite_border,
          );
        }

        return _buildUserGrid(likedByUsers, isWhoLikedYou: true);
      },
    );
  }

  Widget _buildPeopleYouLikedTab() {
    return FutureBuilder<List<UserProfile>>(
      future: _matchingService.getPeopleYouLiked(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading your likes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          );
        }

        final likedUsers = snapshot.data ?? [];

        if (likedUsers.isEmpty) {
          return _buildEmptyState(
            'You haven\'t liked anyone yet',
            'Start swiping to find people you like!',
            Icons.thumb_up_outlined,
          );
        }

        return _buildUserGrid(likedUsers, isWhoLikedYou: false);
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserGrid(List<UserProfile> users, {required bool isWhoLikedYou}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user, isWhoLikedYou: isWhoLikedYou);
        },
      ),
    );
  }

  Widget _buildUserCard(UserProfile user, {required bool isWhoLikedYou}) {
    return GestureDetector(
      onTap: () => _showUserDetails(user, isWhoLikedYou: isWhoLikedYou),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity( 0.1),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Photo
              CachedNetworkImage(
                imageUrl: user.photos.first,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
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
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
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
              ),

              // User info
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${user.displayName}, ${user.age}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isVerified)
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 16,
                          ),
                      ],
                    ),
                    if (user.occupation.isNotEmpty)
                      Text(
                        user.occupation,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity( 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Online status
              Positioned(
                top: 8,
                right: 8,
                child: OnlineStatusIndicator(
                  status: user.isOnline ? OnlineStatus.online : OnlineStatus.offline,
                  size: 12,
                ),
              ),

              // Chat shortcut
              Positioned(
                bottom: 8,
                right: 8,
                child: _buildChatShortcut(user, isWhoLikedYou: isWhoLikedYou),
              ),

              // Match indicator for "Who Liked You"
              if (isWhoLikedYou)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Likes You',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserDetails(UserProfile user, {required bool isWhoLikedYou}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildUserDetailsSheet(user, isWhoLikedYou: isWhoLikedYou),
    );
  }

  Widget _buildUserDetailsSheet(UserProfile user, {required bool isWhoLikedYou}) {
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
                      if (isWhoLikedYou)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _handlePass(user);
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
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _handleLike(user);
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
                                  'Like Back',
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

  void _handleLike(UserProfile user) {
    _matchingService.handleSwipe(user.id, SwipeAction.like);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You liked ${user.displayName}!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {});
  }

  void _handlePass(UserProfile user) {
    _matchingService.handleSwipe(user.id, SwipeAction.pass);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You passed on ${user.displayName}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.grey[600],
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {});
  }
}

/// Mutual matches — pulled in via DiscoveryService.fetchMatchSummaries() and
/// rendered as a photo grid. Tapping a tile opens the chat thread.
class _MatchesTab extends StatefulWidget {
  const _MatchesTab();

  @override
  State<_MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<_MatchesTab>
    with AutomaticKeepAliveClientMixin {
  late Future<List<MatchSummary>> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _future = DiscoveryService.fetchMatchSummaries();
  }

  Future<void> _refresh() async {
    final fresh = DiscoveryService.fetchMatchSummaries();
    setState(() {
      _future = fresh;
    });
    await fresh;
  }

  void _openThread(MatchSummary match) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatThreadScreen(match: match)),
    );
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppTheme.primaryColor,
      child: FutureBuilder<List<MatchSummary>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            );
          }
          if (snap.hasError) {
            return _scrollableMessage(
              icon: Icons.error_outline,
              title: 'Could not load matches',
              subtitle: '${snap.error}',
            );
          }
          final matches = snap.data ?? const [];
          if (matches.isEmpty) {
            return _scrollableMessage(
              icon: Icons.favorite_border,
              title: 'No matches yet',
              subtitle: 'When you and someone like each other, you\'ll see them here.',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: matches.length,
            itemBuilder: (context, i) => _MatchCard(
              match: matches[i],
              onTap: () => _openThread(matches[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _scrollableMessage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Icon(icon, size: 72, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, required this.onTap});

  final MatchSummary match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photo = match.partner.photos.isNotEmpty ? match.partner.photos.first : null;
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      color: Colors.grey[100],
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photo != null)
              CachedNetworkImage(
                imageUrl: photo,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[200]),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.person, size: 60),
              )
            else
              const Center(child: Icon(Icons.person, size: 60, color: Colors.grey)),
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            match.partner.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (match.partner.age > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '${match.partner.age}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        match.hasMessages
                            ? match.lastMessage!.body
                            : 'Say hi 👋',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                          fontStyle: match.hasMessages ? null : FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
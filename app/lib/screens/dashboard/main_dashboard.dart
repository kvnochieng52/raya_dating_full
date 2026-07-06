import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/match_summary.dart';
import '../../router/app_router.dart';
import '../../services/auth_service.dart';
import '../../services/discovery_service.dart';
import '../../services/privacy_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/status_indicator.dart';
import '../chat/chat_thread_screen.dart';
import '../discovery/discovery_screen.dart';
import '../discovery/likes_screen.dart';
import '../matching/match_request_screen.dart';
import '../profile/photo_upload_screen.dart';
import '../settings/privacy_settings_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedIndex = 0;
  final GlobalKey<DiscoveryScreenState> _discoveryKey = GlobalKey<DiscoveryScreenState>();

  List<Widget> get _screens => [
    DiscoveryScreen(key: _discoveryKey),
    const LikesScreen(),
    const ChatScreen(),
    ProfileScreen(onNavigateToChat: () => setState(() => _selectedIndex = 2)),
  ];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
    // Tapping Discover always refreshes the feed (whether re-selecting it or
    // returning from another tab) so the user can pull in newly-seeded
    // profiles or new candidates without restarting the app.
    if (index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _discoveryKey.currentState?.refresh();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
    return Scaffold(
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.explore_outlined, Icons.explore, 'Discover', 0),
              _buildNavItem(Icons.favorite_border, Icons.favorite, 'Matches', 1),
              _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 'Chat', 2),
              _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildNavItem(IconData inactiveIcon, IconData activeIcon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screens

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  late Future<List<MatchSummary>> _future;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Matches',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
      body: RefreshIndicator(
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
              return _MatchesEmpty(
                icon: Icons.error_outline,
                title: 'Could not load matches',
                subtitle: '${snap.error}',
              );
            }
            final matches = snap.data ?? const [];
            if (matches.isEmpty) {
              return const _MatchesEmpty(
                icon: Icons.favorite_border,
                title: 'No matches yet',
                subtitle: 'Start swiping to find your matches!',
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
              itemBuilder: (context, i) => _MatchTile(
                match: matches[i],
                onTap: () => _openThread(matches[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.match, required this.onTap});

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
                errorWidget: (_, __, ___) => const Icon(Icons.person, size: 60),
              )
            else
              const Center(child: Icon(Icons.person, size: 60, color: Colors.grey)),
            if (match.hasUnread)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  constraints: const BoxConstraints(minWidth: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    match.unreadCount > 99 ? '99+' : '${match.unreadCount}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
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
                    if (match.hasMessages)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          match.lastMessage!.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Say hi 👋',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
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

class _MatchesEmpty extends StatelessWidget {
  const _MatchesEmpty({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Need scroll physics so RefreshIndicator works even when "empty".
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Icon(icon, size: 80, color: Colors.grey[400]),
        const SizedBox(height: AppConstants.largeSpacing),
        Text(title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            )),
        const SizedBox(height: AppConstants.smallSpacing),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<List<MatchSummary>> _future;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
      body: RefreshIndicator(
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
              return _MatchesEmpty(
                icon: Icons.error_outline,
                title: 'Could not load conversations',
                subtitle: '${snap.error}',
              );
            }
            final matches = snap.data ?? const [];
            if (matches.isEmpty) {
              return const _MatchesEmpty(
                icon: Icons.chat_bubble_outline,
                title: 'No conversations yet',
                subtitle: 'Match with someone to start chatting!',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: matches.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, i) => _ConversationTile(
                match: matches[i],
                onTap: () => _openThread(matches[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.match, required this.onTap});

  final MatchSummary match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photo = match.partner.photos.isNotEmpty ? match.partner.photos.first : null;
    final last = match.lastMessage;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
        backgroundImage: photo != null ? CachedNetworkImageProvider(photo) : null,
        child: photo == null
            ? Text(
                match.partner.displayName.isNotEmpty
                    ? match.partner.displayName[0].toUpperCase()
                    : '?',
                style: GoogleFonts.poppins(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
      title: Text(
        match.partner.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      subtitle: last == null
          ? Text(
              'Say hi 👋',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            )
          : Text(
              last.isMine ? 'You: ${last.body}' : last.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: match.hasUnread ? Colors.black87 : Colors.grey[700],
                fontWeight: match.hasUnread ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _relativeTime(match.lastActivityAt),
            style: GoogleFonts.poppins(
              color: match.hasUnread ? AppTheme.primaryColor : Colors.grey[500],
              fontSize: 11,
              fontWeight: match.hasUnread ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (match.hasUnread) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              constraints: const BoxConstraints(minWidth: 20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                match.unreadCount > 99 ? '99+' : '${match.unreadCount}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    final local = dt.toLocal();
    return '${local.month}/${local.day}';
  }
}

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onNavigateToChat;

  const ProfileScreen({super.key, this.onNavigateToChat});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  VisibilityMode _visibilityMode = VisibilityMode.public;
  OnlineStatus _onlineStatus = OnlineStatus.online;
  bool _showOnlineStatus = true;
  bool _showLastSeen = true;
  DateTime? _lastSeen;

  // Profile header
  String? _avatarUrl;
  String? _displayName;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
    _loadProfileHeader();
  }

  Future<void> _loadProfileHeader() async {
    try {
      final cached = await AuthService.getCachedUser();
      if (mounted && cached != null) {
        setState(() => _displayName = cached['name'] as String?);
      }
      final response = await ProfileService.getProfile();
      final profile = response['profile'] as Map<String, dynamic>?;
      if (profile == null || !mounted) return;

      // Prefer nickname; fall back to user's name.
      final nickname = (profile['nickname'] as String?)?.trim();
      String? avatar;
      final photos = (profile['photos'] as List?) ?? const [];
      for (final p in photos) {
        if (p is Map<String, dynamic> && (p['is_main'] == true)) {
          avatar = p['url'] as String?;
          break;
        }
      }
      avatar ??= photos.isNotEmpty
          ? (photos.first as Map<String, dynamic>)['url'] as String?
          : null;

      setState(() {
        _avatarUrl = avatar;
        if (nickname != null && nickname.isNotEmpty) {
          _displayName = nickname;
        }
      });
    } catch (_) {
      // Silent — header just falls back to the logo placeholder.
    }
  }

  void _loadPrivacySettings() async {
    final visibility = await PrivacyService.getVisibilityMode();
    final onlineStatus = await PrivacyService.getOnlineStatus();
    final showOnlineStatus = await PrivacyService.getShowOnlineStatus();
    final showLastSeen = await PrivacyService.getShowLastSeen();
    final lastSeen = await PrivacyService.getLastSeen();

    setState(() {
      _visibilityMode = visibility;
      _onlineStatus = onlineStatus;
      _showOnlineStatus = showOnlineStatus;
      _showLastSeen = showLastSeen;
      _lastSeen = lastSeen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white24,
                        backgroundImage: _avatarUrl != null
                            ? CachedNetworkImageProvider(_avatarUrl!)
                            : null,
                        child: _avatarUrl == null
                            ? const Icon(Icons.person,
                                size: 56, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: OnlineStatusIndicator(
                          status: _onlineStatus,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _displayName ?? 'Your Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  VisibilityModeIndicator(
                    mode: _visibilityMode,
                    showText: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status Section
            _buildStatusSection(),

            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(),

            const SizedBox(height: 24),

            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(Icons.logout, size: 20),
        label: Text(
          'Log out',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Log out?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'You\'ll need to sign in again to use the app.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey[700])),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await AuthService.logout();
              // Router redirect fires automatically via AuthState refresh.
            },
            child: Text(
              'Log out',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy & Status',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ProfileStatusWidget(
            onlineStatus: _onlineStatus,
            visibilityMode: _visibilityMode,
            lastSeen: _lastSeen,
            showOnlineStatus: _showOnlineStatus,
            showLastSeen: _showLastSeen,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacySettingsScreen(),
                  ),
                ).then((_) => _loadPrivacySettings());
              },
              child: Text(
                'Manage Privacy Settings',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionButton(
            Icons.edit_outlined,
            'Edit Profile',
            'Update your photos and information',
            () => context.push(AppRoutes.profileSetup),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            Icons.photo_library_outlined,
            'Manage Photos',
            'Add or remove your profile photos',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PhotoUploadScreen(standalone: true),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            Icons.chat_bubble_outline,
            'Messages & Chats',
            'View your conversations and matches',
            () {
              // Switch to the Chat tab using callback
              widget.onNavigateToChat?.call();
            },
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            Icons.favorite_border,
            'Want to be matched?',
            'Let our team find the perfect match for you',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MatchRequestScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../services/privacy_service.dart';
import '../../widgets/status_indicator.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  VisibilityMode _currentVisibilityMode = VisibilityMode.public;
  OnlineStatus _currentOnlineStatus = OnlineStatus.online;
  bool _showOnlineStatus = true;
  bool _showLastSeen = true;
  DateTime? _lastSeen;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final visibility = await PrivacyService.getVisibilityMode();
    final onlineStatus = await PrivacyService.getOnlineStatus();
    final showOnlineStatus = await PrivacyService.getShowOnlineStatus();
    final showLastSeen = await PrivacyService.getShowLastSeen();
    final lastSeen = await PrivacyService.getLastSeen();

    setState(() {
      _currentVisibilityMode = visibility;
      _currentOnlineStatus = onlineStatus;
      _showOnlineStatus = showOnlineStatus;
      _showLastSeen = showLastSeen;
      _lastSeen = lastSeen;
    });
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Settings',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status Preview
            _buildStatusPreview(),

            const SizedBox(height: AppConstants.xLargeSpacing),

            // Visibility Mode Section
            _buildVisibilitySection(),

            const SizedBox(height: AppConstants.xLargeSpacing),

            // Online Status Section
            _buildOnlineStatusSection(),

            const SizedBox(height: AppConstants.xLargeSpacing),

            // Privacy Options Section
            _buildPrivacyOptionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity( 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity( 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Profile Status',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ProfileStatusWidget(
            onlineStatus: _currentOnlineStatus,
            visibilityMode: _currentVisibilityMode,
            lastSeen: _lastSeen,
            showOnlineStatus: _showOnlineStatus,
            showLastSeen: _showLastSeen,
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Visibility',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Control who can see your profile in discovery',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        ...VisibilityMode.values.map((mode) => _buildVisibilityOption(mode)),
      ],
    );
  }

  Widget _buildVisibilityOption(VisibilityMode mode) {
    final isSelected = _currentVisibilityMode == mode;

    return GestureDetector(
      onTap: () => _updateVisibilityMode(mode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity( 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            VisibilityModeIndicator(mode: mode, showText: false),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PrivacyService.getVisibilityModeTitle(mode),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.onSurfaceColor,
                    ),
                  ),
                  Text(
                    PrivacyService.getVisibilityModeDescription(mode),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Online Status',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set your availability status',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        ...OnlineStatus.values.map((status) => _buildOnlineStatusOption(status)),
      ],
    );
  }

  Widget _buildOnlineStatusOption(OnlineStatus status) {
    final isSelected = _currentOnlineStatus == status;

    return GestureDetector(
      onTap: () => _updateOnlineStatus(status),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity( 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            OnlineStatusIndicator(status: status, size: 16),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                PrivacyService.getOnlineStatusDescription(status),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.onSurfaceColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Options',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Control what others can see about your activity',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        _buildPrivacyToggle(
          'Show Online Status',
          'Others can see when you\'re online',
          _showOnlineStatus,
          (value) => _updateShowOnlineStatus(value),
        ),
        const SizedBox(height: 12),
        _buildPrivacyToggle(
          'Show Last Seen',
          'Others can see when you were last online',
          _showLastSeen,
          (value) => _updateShowLastSeen(value),
        ),
      ],
    );
  }

  Widget _buildPrivacyToggle(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
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
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  void _updateVisibilityMode(VisibilityMode mode) async {
    setState(() => _currentVisibilityMode = mode);
    await PrivacyService.setVisibilityMode(mode);
    _showFeedback('Visibility mode updated');
  }

  void _updateOnlineStatus(OnlineStatus status) async {
    setState(() => _currentOnlineStatus = status);
    await PrivacyService.setOnlineStatus(status);

    if (status == OnlineStatus.offline) {
      final lastSeen = await PrivacyService.getLastSeen();
      setState(() => _lastSeen = lastSeen);
    }

    _showFeedback('Online status updated');
  }

  void _updateShowOnlineStatus(bool show) async {
    setState(() => _showOnlineStatus = show);
    await PrivacyService.setShowOnlineStatus(show);
    _showFeedback(show ? 'Online status is now visible' : 'Online status is now hidden');
  }

  void _updateShowLastSeen(bool show) async {
    setState(() => _showLastSeen = show);
    await PrivacyService.setShowLastSeen(show);
    _showFeedback(show ? 'Last seen is now visible' : 'Last seen is now hidden');
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

class TherapyScreen extends StatefulWidget {
  const TherapyScreen({super.key});

  @override
  State<TherapyScreen> createState() => _TherapyScreenState();
}

class _TherapyScreenState extends State<TherapyScreen> {
  final _ventController = TextEditingController();
  bool _isAnonymous = true;

  @override
  void dispose() {
    _ventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wellness Support',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.05),
              Colors.white,
              AppTheme.accentColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You\'re not alone',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Safe space for support & connection',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.xLargeSpacing),

              // Quick Vent Section
              _buildSection(
                title: '💭 Quick Vent',
                description: 'Share what\'s on your mind anonymously',
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: _ventController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'What\'s weighing on your heart today? Share freely...',
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _isAnonymous,
                          onChanged: (value) => setState(() => _isAnonymous = value!),
                          activeColor: AppTheme.primaryColor,
                        ),
                        Text(
                          'Post anonymously',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _submitVent,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            'Share',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.largeSpacing),

              // Professional Support
              _buildSection(
                title: '🎯 Professional Support',
                description: 'Connect with licensed therapists',
                child: Column(
                  children: [
                    _buildSupportOption(
                      icon: Icons.video_call,
                      title: 'Video Therapy Session',
                      subtitle: 'Book a 1-on-1 session with a licensed therapist',
                      color: Colors.blue,
                      onTap: () => _showTherapistBooking(),
                    ),
                    const SizedBox(height: 12),
                    _buildSupportOption(
                      icon: Icons.chat,
                      title: 'Text Therapy',
                      subtitle: 'Message-based therapy at your own pace',
                      color: Colors.green,
                      onTap: () => _showTextTherapy(),
                    ),
                    const SizedBox(height: 12),
                    _buildSupportOption(
                      icon: Icons.phone,
                      title: 'Crisis Hotline',
                      subtitle: '24/7 immediate support when you need it most',
                      color: Colors.red,
                      onTap: () => _showCrisisSupport(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.largeSpacing),

              // Community Support
              _buildSection(
                title: '👥 Community Support',
                description: 'Connect with others who understand',
                child: Column(
                  children: [
                    _buildSupportOption(
                      icon: Icons.group,
                      title: 'Support Groups',
                      subtitle: 'Join guided group sessions on various topics',
                      color: AppTheme.primaryColor,
                      onTap: () => _showSupportGroups(),
                    ),
                    const SizedBox(height: 12),
                    _buildSupportOption(
                      icon: Icons.forum,
                      title: 'Anonymous Forum',
                      subtitle: 'Share experiences and get peer support',
                      color: Colors.purple,
                      onTap: () => _showAnonymousForum(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.largeSpacing),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'If you\'re experiencing a mental health emergency, please contact emergency services immediately or call the National Suicide Prevention Lifeline at 988.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
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

  void _submitVent() {
    if (_ventController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please write something to share',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Submit the vent
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(
              'Shared',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Your thoughts have been shared anonymously. Thank you for being brave and reaching out.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _ventController.clear();
            },
            child: Text(
              'Okay',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTherapistBooking() {
    _showComingSoon('Video Therapy Session booking');
  }

  void _showTextTherapy() {
    _showComingSoon('Text Therapy');
  }

  void _showCrisisSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Crisis Support',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'National Suicide Prevention Lifeline:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            Text('988', style: GoogleFonts.poppins(fontSize: 18, color: Colors.red)),
            const SizedBox(height: 12),
            Text(
              'Crisis Text Line:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            Text('Text HOME to 741741', style: GoogleFonts.poppins()),
            const SizedBox(height: 12),
            Text(
              'Emergency Services: 911',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportGroups() {
    _showComingSoon('Support Groups');
  }

  void _showAnonymousForum() {
    _showComingSoon('Anonymous Forum');
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature will be available soon. We\'re working hard to bring you the best support experience.',
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
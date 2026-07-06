import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../router/app_router.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/progress_indicator.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _codeController = TextEditingController();

  // Email state
  bool _emailVerified = false;
  bool _codeSent = false;
  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  String? _userEmail;

  // Selfie state
  File? _selfiePhoto;         // newly-picked, not yet replaced on server
  String? _existingSelfieUrl; // already uploaded to backend
  bool _isLoadingSelfie = false;

  bool get _selfieUploaded => _selfiePhoto != null || _existingSelfieUrl != null;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
    _prefillFromExisting();
  }

  Future<void> _prefillFromExisting() async {
    try {
      final user = await AuthService.getCachedUser();
      if (mounted && user != null) {
        setState(() => _userEmail = user['email'] as String?);
      }

      final response = await ProfileService.getProfile();
      final profile = response['profile'] as Map<String, dynamic>?;
      if (profile == null || !mounted) return;
      setState(() {
        _emailVerified = profile['email_verified'] == true;
        _existingSelfieUrl = profile['selfie_url'] as String?;
      });
    } catch (_) {
      // Silent — user can still verify from scratch.
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _codeController.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verification',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const CustomProgressIndicator(currentStep: 5, totalSteps: 5),
            const SizedBox(height: AppConstants.largeSpacing),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verify your identity',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallSpacing),
                        Text(
                          'Verify at least one method to continue.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: AppConstants.xLargeSpacing),

                        _buildEmailCard(),
                        const SizedBox(height: AppConstants.mediumSpacing),
                        _buildSelfieCard(),

                        const SizedBox(height: AppConstants.xLargeSpacing),
                        _buildInfoBox(),
                        const SizedBox(height: AppConstants.xLargeSpacing * 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canContinue() ? _handleContinue : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        backgroundColor:
                            _canContinue() ? null : Colors.grey[300],
                      ),
                      child: Text(
                        'Complete Setup',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallSpacing),
                  TextButton(
                    onPressed: _handleSkip,
                    child: Text(
                      'Skip for now',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────── Email ───────────────────

  Widget _buildEmailCard() {
    final email = _userEmail ?? 'your email';
    return _VerificationCard(
      icon: Icons.email_outlined,
      title: 'Email Verification',
      subtitle: _emailVerified
          ? 'Verified ✓'
          : 'We\'ll send a 6-digit code to $email',
      isVerified: _emailVerified,
      child: _emailVerified
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_codeSent) ...[
                  ElevatedButton(
                    onPressed: _isSendingCode ? null : _requestCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isSendingCode
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Send Code',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ] else ...[
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '••••••',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 24,
                        letterSpacing: 8,
                        color: Colors.grey[300],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _isVerifyingCode ? null : _verifyEnteredCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: _isVerifyingCode
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Verify Code',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _isSendingCode ? null : _requestCode,
                        child: Text(
                          'Resend',
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  Future<void> _requestCode() async {
    setState(() => _isSendingCode = true);
    try {
      await ProfileService.requestEmailCode();
      if (!mounted) return;
      setState(() {
        _codeSent = true;
        _codeController.clear();
      });
      _showSuccessMessage('Code sent — check your email.');
    } on AuthException catch (e) {
      _showErrorMessage(e.message);
    } finally {
      if (mounted) setState(() => _isSendingCode = false);
    }
  }

  Future<void> _verifyEnteredCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      _showErrorMessage('Enter the 6-digit code we sent you.');
      return;
    }
    setState(() => _isVerifyingCode = true);
    try {
      await ProfileService.verifyEmail(code);
      if (!mounted) return;
      setState(() {
        _emailVerified = true;
        _codeSent = false;
        _codeController.clear();
      });
      _showSuccessMessage('Email verified!');
    } on AuthException catch (e) {
      _showErrorMessage(e.fieldErrors?.values.firstOrNull?.firstOrNull ?? e.message);
    } finally {
      if (mounted) setState(() => _isVerifyingCode = false);
    }
  }

  // ─────────────────── Selfie ───────────────────

  Widget _buildSelfieCard() {
    return _VerificationCard(
      icon: Icons.camera_alt_outlined,
      title: 'Photo Verification',
      subtitle: _selfieUploaded
          ? 'Selfie on file ✓'
          : 'Take a selfie so we can match it to your photos',
      isVerified: _selfieUploaded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selfieUploaded) ...[
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: _selfiePhoto != null
                      ? Image.file(_selfiePhoto!, fit: BoxFit.cover)
                      : CachedNetworkImage(
                          imageUrl: _existingSelfieUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.grey[200]),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.person, size: 60),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          ElevatedButton.icon(
            onPressed: _isLoadingSelfie ? null : _takeSelfie,
            icon: _isLoadingSelfie
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(_selfieUploaded ? Icons.refresh : Icons.camera_alt),
            label: Text(
              _isLoadingSelfie
                  ? 'Uploading…'
                  : (_selfieUploaded ? 'Retake Selfie' : 'Take Selfie'),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _takeSelfie() async {
    setState(() => _isLoadingSelfie = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
        preferredCameraDevice: CameraDevice.front,
      );
      if (image == null) {
        if (mounted) setState(() => _isLoadingSelfie = false);
        return;
      }
      final file = File(image.path);
      await ProfileService.uploadSelfie(file);
      if (!mounted) return;
      setState(() {
        _selfiePhoto = file;
        // The freshly-uploaded file is the source of truth now; the URL
        // accessor on the next prefill will hold a new path anyway.
        _existingSelfieUrl = null;
      });
      _showSuccessMessage('Selfie uploaded successfully!');
    } on AuthException catch (e) {
      _showErrorMessage(e.message);
    } catch (_) {
      _showErrorMessage('Failed to take selfie. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoadingSelfie = false);
    }
  }

  // ─────────────────── Footer ───────────────────

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your verification information is encrypted and used only to keep Raya safe and authentic.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canContinue() => _emailVerified || _selfieUploaded;

  Future<void> _handleContinue() async {
    if (!_canContinue()) return;
    try {
      await ProfileService.updateProfile(const {}, step: 5);
    } on AuthException catch (e) {
      _showErrorMessage(e.message);
      return;
    }
    if (!mounted) return;
    context.go(AppRoutes.locationPermission);
  }

  void _handleSkip() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Skip Verification?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'You can verify your account later in settings. Verified profiles get more matches and trust.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Go Back',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.locationPermission);
            },
            child: Text(
              'Skip',
              style: GoogleFonts.poppins(color: AppTheme.primaryColor),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isVerified,
    this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isVerified;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? Colors.green[200]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isVerified
                      ? Colors.green[100]
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isVerified ? Icons.check : icon,
                  color:
                      isVerified ? Colors.green[600] : AppTheme.primaryColor,
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
              if (isVerified)
                Icon(Icons.check_circle, color: Colors.green[600], size: 24),
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: 16),
            child!,
          ],
        ],
      ),
    );
  }
}

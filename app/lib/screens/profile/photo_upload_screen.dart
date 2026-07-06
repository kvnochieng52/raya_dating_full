import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/progress_indicator.dart';
import 'interests_screen.dart';

class PhotoUploadScreen extends StatefulWidget {
  /// When true, the screen is being used as a standalone "manage photos"
  /// editor (from the Profile tab). Continue saves and pops back instead of
  /// advancing to the next onboarding step.
  final bool standalone;

  const PhotoUploadScreen({super.key, this.standalone = false});

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ImagePicker _picker = ImagePicker();
  // Newly-picked local files per slot. Takes priority over any existing
  // server-side photo at the same position.
  List<File?> _photos = List.filled(AppConstants.maxPhotos, null);
  // Photos already uploaded to the backend, keyed by position.
  List<Map<String, dynamic>?> _existingPhotos =
      List.filled(AppConstants.maxPhotos, null);

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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _prefillFromExisting();
  }

  Future<void> _prefillFromExisting() async {
    try {
      final response = await ProfileService.getProfile();
      final profile = response['profile'] as Map<String, dynamic>?;
      if (profile == null || !mounted) return;
      final photos = (profile['photos'] as List?) ?? const [];
      final slots = List<Map<String, dynamic>?>.filled(
        AppConstants.maxPhotos,
        null,
      );
      for (final raw in photos) {
        if (raw is! Map<String, dynamic>) continue;
        final position = raw['position'] as int?;
        if (position == null || position < 0 || position >= slots.length) {
          continue;
        }
        slots[position] = raw;
      }
      setState(() => _existingPhotos = slots);
    } catch (_) {
      // Silent — user can still upload from scratch.
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          'Add Photos',
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
            // Progress Indicator
            const CustomProgressIndicator(currentStep: 3, totalSteps: 5),

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
                          'Show your best self',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),

                        const SizedBox(height: AppConstants.smallSpacing),

                        Text(
                          'Add at least 2 photos to continue. The first photo will be your main profile picture.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: AppConstants.xLargeSpacing),

                        // Photo Tips
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity( 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.accentColor.withOpacity( 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.tips_and_updates_outlined,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Photo Tips',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTip('Use high-quality, recent photos'),
                              _buildTip('Show your face clearly in the first photo'),
                              _buildTip('Include photos of your hobbies and interests'),
                              _buildTip('Smile! It makes you more approachable'),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppConstants.xLargeSpacing),

                        // Photo Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: AppConstants.maxPhotos,
                          itemBuilder: (context, index) {
                            return _buildPhotoSlot(index);
                          },
                        ),

                        const SizedBox(height: AppConstants.xLargeSpacing),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_canContinue() && !_isSubmitting) ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: _canContinue() ? null : Colors.grey[300],
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Continue',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlot(int index) {
    final photo = _photos[index];
    final existing = _existingPhotos[index];
    final hasContent = photo != null || existing != null;
    final isMainPhoto = index == 0;

    return GestureDetector(
      onTap: () => _showPhotoOptions(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: isMainPhoto
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            // Photo or placeholder. Newly-picked File takes priority over an
            // existing server photo at the same position.
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: photo != null
                  ? Image.file(
                      photo,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : existing != null
                      ? CachedNetworkImage(
                          imageUrl: existing['url'] as String,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.grey[200]),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isMainPhoto ? 'Main Photo' : 'Add Photo',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
            ),

            // Main photo indicator
            if (isMainPhoto && hasContent)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'MAIN',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Remove button
            if (hasContent)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _removePhoto(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity( 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Photo',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildPhotoOption(
                        Icons.camera_alt_outlined,
                        'Camera',
                        () => _pickImage(ImageSource.camera, index),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPhotoOption(
                        Icons.photo_library_outlined,
                        'Gallery',
                        () => _pickImage(ImageSource.gallery, index),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity( 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, int index) async {
    Navigator.pop(context); // Close bottom sheet

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _photos[index] = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to pick image',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _removePhoto(int index) async {
    final existing = _existingPhotos[index];
    // Optimistically clear locally so the UI feels snappy; if the server
    // delete fails we silently swallow (user can retry).
    setState(() {
      _photos[index] = null;
      _existingPhotos[index] = null;
    });
    if (existing != null) {
      try {
        await ProfileService.deletePhoto(existing['id'] as int);
      } catch (_) {
        // Ignore — slot is already cleared locally.
      }
    }
  }

  bool _canContinue() {
    var filled = 0;
    for (var i = 0; i < AppConstants.maxPhotos; i++) {
      if (_photos[i] != null || _existingPhotos[i] != null) filled++;
    }
    return filled >= 2;
  }

  bool _isSubmitting = false;

  void _handleContinue() async {
    if (!_canContinue() || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      // Only upload newly-picked files. Existing photos at the same position
      // stay as they are; if the user picked a replacement, our backend upsert
      // (by position) handles the swap.
      for (int i = 0; i < _photos.length; i++) {
        final file = _photos[i];
        if (file == null) continue;
        await ProfileService.uploadPhoto(
          file,
          position: i,
          isMain: i == 0,
        );
      }
      await ProfileService.updateProfile(const {}, step: 3);

      if (!mounted) return;

      // When opened from "Manage Photos" on the Profile tab, save & return.
      if (widget.standalone) {
        Navigator.pop(context, true);
        return;
      }

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const InterestsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      );
    } on AuthException catch (e) {
      _showError(e.fieldErrors?.values.firstOrNull?.firstOrNull ?? e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
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
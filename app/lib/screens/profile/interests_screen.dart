import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/progress_indicator.dart';
import 'verification_screen.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<String> _selectedInterests = [];
  String? _selectedShowMe;
  RangeValues _ageRange = const RangeValues(22, 35);
  String? _selectedAdminContact;
  final _adminTimeController = TextEditingController();
  final _adminNumberController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _partnerDetailsController = TextEditingController();

  final List<String> _showMeOptions = [
    'Men',
    'Women',
    'Everyone',
  ];

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

      final ageMin = (profile['age_min'] as int?)?.toDouble();
      final ageMax = (profile['age_max'] as int?)?.toDouble();
      final adminConsent = profile['admin_contact_consent'];

      setState(() {
        final raw = profile['interests'];
        if (raw is List) {
          _selectedInterests = raw.map((e) => e.toString()).toList();
        }
        _selectedShowMe = profile['show_me'] as String?;
        if (ageMin != null && ageMax != null && ageMax >= ageMin) {
          _ageRange = RangeValues(ageMin, ageMax);
        }
        if (adminConsent != null) {
          _selectedAdminContact = adminConsent == true ? 'Yes' : 'No';
        }
        _adminTimeController.text =
            (profile['admin_contact_time'] as String?) ?? '';
        _adminNumberController.text =
            (profile['admin_contact_phone'] as String?) ?? '';
        _adminEmailController.text =
            (profile['admin_contact_email'] as String?) ?? '';
        _partnerDetailsController.text =
            (profile['partner_details'] as String?) ?? '';
      });
    } catch (_) {
      // Silent.
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _adminTimeController.dispose();
    _adminNumberController.dispose();
    _adminEmailController.dispose();
    _partnerDetailsController.dispose();
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
          'Interests & Preferences',
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
            const CustomProgressIndicator(currentStep: 4, totalSteps: 5),

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
                          'Your interests and preferences',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),

                        const SizedBox(height: AppConstants.smallSpacing),

                        Text(
                          'Help us find people who share your interests and match your preferences.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: AppConstants.xLargeSpacing),

                        // Interests Section
                        _buildSectionTitle('Your Interests'),
                        Text(
                          'Select at least 3 interests',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInterestsSection(),

                        const SizedBox(height: AppConstants.xLargeSpacing),

                        // Show Me Section
                        _buildSectionTitle('Show Me'),
                        _buildShowMeSelection(),

                        const SizedBox(height: AppConstants.xLargeSpacing),

                        // Age Range Section
                        _buildSectionTitle('Age Range'),
                        _buildAgeRangeSlider(),

                        const SizedBox(height: AppConstants.xLargeSpacing),

                        // Admin Contact
                        _buildSectionTitle('Can our Administrator contact you\nto help find what you\'re looking for?'),
                        _buildYesNoRow(
                          selected: _selectedAdminContact,
                          onTap: (val) => setState(() {
                            _selectedAdminContact = val;
                            if (val == 'No') {
                              _adminTimeController.clear();
                              _adminNumberController.clear();
                              _adminEmailController.clear();
                            }
                          }),
                        ),
                        if (_selectedAdminContact == 'Yes') ...[
                          const SizedBox(height: AppConstants.mediumSpacing),
                          _buildContactField(
                            controller: _adminTimeController,
                            hint: 'Best time to contact you (e.g. 9am – 5pm)',
                            icon: Icons.access_time_outlined,
                          ),
                          const SizedBox(height: AppConstants.smallSpacing),
                          _buildContactField(
                            controller: _adminNumberController,
                            hint: 'Phone number',
                            icon: Icons.phone_outlined,
                            inputType: TextInputType.phone,
                          ),
                          const SizedBox(height: AppConstants.smallSpacing),
                          _buildContactField(
                            controller: _adminEmailController,
                            hint: 'Email address',
                            icon: Icons.email_outlined,
                            inputType: TextInputType.emailAddress,
                          ),
                        ],

                        const SizedBox(height: AppConstants.xLargeSpacing),

                        // Partner Details
                        _buildSectionTitle('Details of the Person You Are Looking For'),
                        TextField(
                          controller: _partnerDetailsController,
                          maxLines: 5,
                          maxLength: 500,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Describe your ideal partner — values, character, faith, lifestyle...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            counterStyle: const TextStyle(color: Colors.grey),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),

                        const SizedBox(height: AppConstants.xLargeSpacing * 2),
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
                  onPressed: _isSubmitting ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.onSurfaceColor,
        ),
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AppConstants.interestCategories.map((category) {
        return _buildInterestCategory(category);
      }).toList(),
    );
  }

  Widget _buildInterestCategory(String category) {
    final categoryInterests = AppConstants.interests[category] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            category,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categoryInterests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return GestureDetector(
              onTap: () => _toggleInterest(interest),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  interest,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.onSurfaceColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildShowMeSelection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _showMeOptions.map((option) {
        final isSelected = _selectedShowMe == option;
        return GestureDetector(
          onTap: () => setState(() => _selectedShowMe = option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              ),
            ),
            child: Text(
              option,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.onSurfaceColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAgeRangeSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_ageRange.start.round()} years',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              '${_ageRange.end.round()} years',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _ageRange,
          min: 18,
          max: 100,
          divisions: 82,
          labels: RangeLabels(
            _ageRange.start.round().toString(),
            _ageRange.end.round().toString(),
          ),
          activeColor: AppTheme.primaryColor,
          inactiveColor: Colors.grey[300],
          onChanged: (RangeValues values) {
            setState(() {
              _ageRange = values;
            });
          },
        ),
      ],
    );
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  String? _validate() {
    if (_selectedInterests.length < 3) {
      return 'Please select at least 3 interests so we can find your best matches.';
    }
    if (_selectedShowMe == null) {
      return 'Please choose who you\'d like to be shown — Men, Women, or Everyone.';
    }
    if (_selectedAdminContact == null) {
      return 'Please answer whether our administrator can contact you.';
    }
    return null;
  }

  Widget _buildYesNoRow({
    required String? selected,
    required ValueChanged<String> onTap,
  }) {
    return Row(
      children: ['Yes', 'No'].asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selected == option;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(option),
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 6,
                right: index == 1 ? 0 : 6,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                ),
              ),
              child: Text(
                option,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.onSurfaceColor,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: GoogleFonts.poppins(fontSize: 15),
    );
  }

  bool _isSubmitting = false;

  void _handleContinue() async {
    if (_isSubmitting) return;
    final error = _validate();
    if (error != null) {
      _showError(error);
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      final wantsContact = _selectedAdminContact == 'Yes';

      await ProfileService.updateProfile(
        {
          'interests': _selectedInterests,
          'show_me': _selectedShowMe,
          'age_min': _ageRange.start.round(),
          'age_max': _ageRange.end.round(),
          'admin_contact_consent': wantsContact,
          if (wantsContact) ...{
            'admin_contact_time': _adminTimeController.text.trim(),
            'admin_contact_phone': _adminNumberController.text.trim(),
            'admin_contact_email': _adminEmailController.text.trim(),
          },
          if (_partnerDetailsController.text.trim().isNotEmpty)
            'partner_details': _partnerDetailsController.text.trim(),
        },
        step: 4,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const VerificationScreen(),
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
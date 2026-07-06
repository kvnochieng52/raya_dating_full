import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/progress_indicator.dart';
import 'photo_upload_screen.dart';

class EducationOccupationScreen extends StatefulWidget {
  const EducationOccupationScreen({super.key});

  @override
  State<EducationOccupationScreen> createState() =>
      _EducationOccupationScreenState();
}

class _EducationOccupationScreenState extends State<EducationOccupationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedEducation;
  String? _selectedOccupation;
  String? _selectedReligion;
  String? _selectedDenomination;
  String? _selectedRelocate;
  String? _selectedCountry;
  String? _selectedKingdomPurpose;
  String? _selectedRelationshipGoal;
  String? _selectedHasKids;
  String? _selectedFinancialStatus;
  final _countyStateController = TextEditingController();
  final _kidsCountController = TextEditingController();

  final List<String> _countries = [
    'Afghanistan', 'Albania', 'Algeria', 'Angola', 'Argentina', 'Australia',
    'Austria', 'Bangladesh', 'Belgium', 'Bolivia', 'Brazil', 'Cameroon',
    'Canada', 'Chile', 'China', 'Colombia', 'Congo', 'Croatia', 'Cuba',
    'Czech Republic', 'Denmark', 'Ecuador', 'Egypt', 'Ethiopia', 'Finland',
    'France', 'Germany', 'Ghana', 'Greece', 'Guatemala', 'Haiti', 'Honduras',
    'Hungary', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel',
    'Italy', 'Jamaica', 'Japan', 'Jordan', 'Kenya', 'Lebanon', 'Libya',
    'Malaysia', 'Mali', 'Mexico', 'Morocco', 'Mozambique', 'Myanmar',
    'Nepal', 'Netherlands', 'New Zealand', 'Nicaragua', 'Nigeria', 'Norway',
    'Pakistan', 'Panama', 'Paraguay', 'Peru', 'Philippines', 'Poland',
    'Portugal', 'Romania', 'Russia', 'Rwanda', 'Saudi Arabia', 'Senegal',
    'Sierra Leone', 'Somalia', 'South Africa', 'South Korea', 'Spain',
    'Sri Lanka', 'Sudan', 'Sweden', 'Switzerland', 'Syria', 'Tanzania',
    'Thailand', 'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Uganda',
    'Ukraine', 'United Arab Emirates', 'United Kingdom', 'United States',
    'Uruguay', 'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe',
  ];

  final List<String> _denominations = [
    'Baptist',
    'Catholic',
    'Pentecostal',
    'Methodist',
    'Anglican / Episcopal',
    'Presbyterian',
    'Lutheran',
    'Seventh-day Adventist',
    'Charismatic',
    'Non-denominational',
    'Orthodox',
    'Other',
  ];

  final List<String> _educationLevels = [
    'High School',
    'Some College',
    'Undergraduate Degree',
    'Graduate Degree',
    'PhD/Doctoral',
    'Trade School',
    'Other',
  ];

  final List<String> _occupations = [
    'Student',
    'Technology',
    'Healthcare',
    'Education',
    'Finance',
    'Arts & Entertainment',
    'Business',
    'Engineering',
    'Legal',
    'Marketing',
    'Sales',
    'Other',
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

      String? yesNo(dynamic v) =>
          v == null ? null : (v == true ? 'Yes' : 'No');

      setState(() {
        _selectedKingdomPurpose = profile['kingdom_purpose'] as String?;
        _selectedRelationshipGoal = profile['relationship_goal'] as String?;
        _selectedReligion = yesNo(profile['is_believer']);
        _selectedDenomination = profile['denomination'] as String?;
        _selectedHasKids = yesNo(profile['has_kids']);
        final kidsCount = profile['kids_count'];
        if (kidsCount != null) {
          _kidsCountController.text = kidsCount.toString();
        }
        _selectedEducation = profile['education_level'] as String?;
        _selectedOccupation = profile['occupation'] as String?;
        _selectedFinancialStatus = profile['financial_status'] as String?;
        _selectedCountry = profile['country'] as String?;
        _countyStateController.text = (profile['county_state'] as String?) ?? '';
        _selectedRelocate = yesNo(profile['willing_to_relocate']);
      });
    } catch (_) {
      // Silent.
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _countyStateController.dispose();
    _kidsCountController.dispose();
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
          'Faith & Background',
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
            const CustomProgressIndicator(currentStep: 2, totalSteps: 5),

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
                          'Faith & Background',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),

                        const SizedBox(height: AppConstants.smallSpacing),

                        Text(
                          'Tell us about your purpose, faith, and life story',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: AppConstants.largeSpacing),

                        // ── Why Are You Here ──
                        _buildGroupHeader('Why Are You Here?'),
                        _buildKingdomPurposeCards(),
                        if (_selectedKingdomPurpose == 'Dating') ...[
                          const SizedBox(height: AppConstants.mediumSpacing),
                          _buildSectionTitle('What are you looking for?'),
                          _buildDropdown(
                            value: _selectedRelationshipGoal,
                            items: AppConstants.relationshipGoals,
                            hint: 'Select what you\'re looking for',
                            icon: Icons.favorite_outline,
                            onChanged: (val) => setState(() => _selectedRelationshipGoal = val),
                          ),
                        ],

                        const SizedBox(height: AppConstants.largeSpacing),

                        // ── Faith ──
                        _buildGroupHeader('Your Faith'),
                        _buildSectionTitle('Are you a Believer?'),
                        _buildYesNoSelector(
                          selected: _selectedReligion,
                          onTap: (val) => setState(() {
                            _selectedReligion = val;
                            if (val == 'No') _selectedDenomination = null;
                          }),
                        ),
                        if (_selectedReligion == 'Yes') ...[
                          const SizedBox(height: AppConstants.mediumSpacing),
                          _buildSectionTitle('Denomination'),
                          _buildDropdown(
                            value: _selectedDenomination,
                            items: _denominations,
                            hint: 'Select your denomination',
                            icon: Icons.church_outlined,
                            onChanged: (val) =>
                                setState(() => _selectedDenomination = val),
                          ),
                        ],

                        const SizedBox(height: AppConstants.largeSpacing),

                        // ── Family ──
                        _buildGroupHeader('Your Family'),
                        _buildSectionTitle('Do you have Kids?'),
                        _buildYesNoSelector(
                          selected: _selectedHasKids,
                          onTap: (val) => setState(() {
                            _selectedHasKids = val;
                            if (val == 'No') _kidsCountController.clear();
                          }),
                        ),
                        if (_selectedHasKids == 'Yes') ...[
                          const SizedBox(height: AppConstants.mediumSpacing),
                          TextField(
                            controller: _kidsCountController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'How many?',
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              prefixIcon: const Icon(Icons.child_care, color: AppTheme.primaryColor),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: GoogleFonts.poppins(),
                          ),
                        ],

                        const SizedBox(height: AppConstants.largeSpacing),

                        // ── Career & Finances ──
                        _buildGroupHeader('Career & Finances'),
                        _buildSectionTitle('Education'),
                        _buildDropdown(
                          value: _selectedEducation,
                          items: _educationLevels,
                          hint: 'Select your education level',
                          icon: Icons.school_outlined,
                          onChanged: (value) =>
                              setState(() => _selectedEducation = value),
                        ),
                        const SizedBox(height: AppConstants.mediumSpacing),
                        _buildSectionTitle('Occupation'),
                        _buildDropdown(
                          value: _selectedOccupation,
                          items: _occupations,
                          hint: 'Select your field',
                          icon: Icons.work_outline,
                          onChanged: (value) =>
                              setState(() => _selectedOccupation = value),
                        ),
                        const SizedBox(height: AppConstants.mediumSpacing),
                        _buildSectionTitle('Financial Status'),
                        _buildDropdown(
                          value: _selectedFinancialStatus,
                          items: const [
                            'Student', 'Just starting out', 'Financially stable',
                            'Doing well', 'Prefer not to say',
                          ],
                          hint: 'Select your financial status',
                          icon: Icons.account_balance_wallet_outlined,
                          onChanged: (val) => setState(() => _selectedFinancialStatus = val),
                        ),

                        const SizedBox(height: AppConstants.largeSpacing),

                        // ── Location ──
                        _buildGroupHeader('Your Location'),
                        _buildSectionTitle('Country'),
                        _buildDropdown(
                          value: _selectedCountry,
                          items: _countries,
                          hint: 'Select your country',
                          icon: Icons.public_outlined,
                          onChanged: (val) =>
                              setState(() => _selectedCountry = val),
                        ),
                        const SizedBox(height: AppConstants.mediumSpacing),
                        _buildSectionTitle('County / State'),
                        _buildTextField(
                          controller: _countyStateController,
                          hint: 'Enter your county or state',
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: AppConstants.mediumSpacing),
                        _buildSectionTitle('Willing to Relocate?'),
                        _buildYesNoSelector(
                          selected: _selectedRelocate,
                          onTap: (val) =>
                              setState(() => _selectedRelocate = val),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.onSurfaceColor,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(
                  hint,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                isExpanded: true,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: GoogleFonts.poppins(fontSize: 16)),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canContinue() {
    if (_selectedKingdomPurpose == null) return false;
    if (_selectedKingdomPurpose == 'Dating' && _selectedRelationshipGoal == null) return false;
    if (_selectedReligion == null) return false;
    if (_selectedReligion == 'Yes' && _selectedDenomination == null) return false;
    if (_selectedHasKids == null) return false;
    if (_selectedHasKids == 'Yes' && _kidsCountController.text.trim().isEmpty) return false;
    if (_selectedEducation == null || _selectedOccupation == null) return false;
    if (_selectedFinancialStatus == null) return false;
    if (_selectedCountry == null) return false;
    if (_countyStateController.text.trim().isEmpty) return false;
    if (_selectedRelocate == null) return false;
    return true;
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppTheme.primaryColor.withOpacity(0.3))),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: AppTheme.primaryColor.withOpacity(0.3))),
        ],
      ),
    );
  }

  Widget _buildKingdomPurposeCards() {
    const purposes = ['Counseling', 'Dating', 'Friendship'];
    return Row(
      children: purposes.asMap().entries.map((entry) {
        final index = entry.key;
        final purpose = entry.value;
        final isSelected = _selectedKingdomPurpose == purpose;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedKingdomPurpose = purpose),
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 5,
                right: index == purposes.length - 1 ? 0 : 5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    purpose == 'Counseling'
                        ? Icons.volunteer_activism
                        : purpose == 'Dating'
                            ? Icons.favorite_outline
                            : Icons.people_outline,
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    purpose,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.onSurfaceColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildYesNoSelector({
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                option,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.onSurfaceColor,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: GoogleFonts.poppins(fontSize: 16),
    );
  }

  bool _isSubmitting = false;

  void _handleContinue() async {
    if (!_canContinue() || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final isDating = _selectedKingdomPurpose == 'Dating';
      final isBeliever = _selectedReligion == 'Yes';
      final hasKids = _selectedHasKids == 'Yes';

      await ProfileService.updateProfile(
        {
          'kingdom_purpose': _selectedKingdomPurpose,
          if (isDating) 'relationship_goal': _selectedRelationshipGoal,
          'is_believer': isBeliever,
          if (isBeliever) 'denomination': _selectedDenomination,
          'has_kids': hasKids,
          if (hasKids)
            'kids_count': int.tryParse(_kidsCountController.text.trim()),
          'education_level': _selectedEducation,
          'occupation': _selectedOccupation,
          'financial_status': _selectedFinancialStatus,
          'country': _selectedCountry,
          'county_state': _countyStateController.text.trim(),
          'willing_to_relocate': _selectedRelocate == 'Yes',
        },
        step: 2,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PhotoUploadScreen(),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/progress_indicator.dart';
import 'education_occupation_screen.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedBodyType;

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
      setState(() {
        _nicknameController.text = (profile['nickname'] as String?) ?? '';
        _bioController.text = (profile['bio'] as String?) ?? '';
        final birth = profile['birth_date'] as String?;
        if (birth != null && birth.isNotEmpty) {
          _selectedDate = DateTime.tryParse(birth);
        }
        _selectedGender = profile['gender'] as String?;
        _selectedMaritalStatus = profile['marital_status'] as String?;
        _selectedBodyType = profile['body_type'] as String?;
      });
    } catch (_) {
      // Silent — user can still fill the form from scratch.
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nicknameController.dispose();
    _bioController.dispose();
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
          'Basic Information',
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
            const CustomProgressIndicator(currentStep: 1, totalSteps: 5),

            const SizedBox(height: AppConstants.largeSpacing),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tell us about yourself',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),

                          const SizedBox(height: AppConstants.smallSpacing),

                          Text(
                            'Quick basics — this will only take a moment',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),

                          const SizedBox(height: AppConstants.xLargeSpacing),

                          // Nickname
                          _buildSectionTitle('Preferred Name'),
                          TextFormField(
                            controller: _nicknameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'What should we call you?',
                              prefixIcon: Icon(
                                Icons.tag,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a preferred name';
                              }
                              if (value.trim().length < 2) {
                                return 'Preferred name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppConstants.largeSpacing),

                          // Birth Date
                          _buildSectionTitle('Birth Date'),
                          GestureDetector(
                            onTap: _selectDate,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: _selectedDate == null
                                    ? Border.all(color: Colors.red.withOpacity(0.3))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _selectedDate != null
                                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                        : 'Select your birth date',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: _selectedDate != null
                                          ? AppTheme.onSurfaceColor
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppConstants.largeSpacing),

                          // Gender
                          _buildSectionTitle('Gender'),
                          _buildDropdown(
                            value: _selectedGender,
                            items: AppConstants.genderOptions,
                            hint: 'Select your gender',
                            icon: Icons.person_outline,
                            onChanged: (val) => setState(() => _selectedGender = val),
                          ),

                          const SizedBox(height: AppConstants.largeSpacing),

                          // Marital Status
                          _buildSectionTitle('Marital Status'),
                          _buildChipRow(
                            options: ['Single', 'Divorced', 'Widowed'],
                            selected: _selectedMaritalStatus,
                            onTap: (val) => setState(() => _selectedMaritalStatus = val),
                          ),

                          const SizedBox(height: AppConstants.largeSpacing),

                          // Body Type
                          _buildSectionTitle('Body Type'),
                          _buildDropdown(
                            value: _selectedBodyType,
                            items: const [
                              'Slim', 'Athletic', 'Average', 'Curvy',
                              'Thick', 'Fit', 'Muscular', 'Plus-size', 'Petite',
                            ],
                            hint: 'Select your body type',
                            icon: Icons.accessibility_new_outlined,
                            onChanged: (val) => setState(() => _selectedBodyType = val),
                          ),

                          const SizedBox(height: AppConstants.largeSpacing),

                          // Bio
                          _buildSectionTitle('About You (Optional)'),
                          TextFormField(
                            controller: _bioController,
                            maxLines: 4,
                            maxLength: AppConstants.maxBioLength,
                            decoration: const InputDecoration(
                              hintText: 'Tell us a bit about yourself, your interests, what makes you unique...',
                              counterStyle: TextStyle(color: Colors.grey),
                            ),
                            style: GoogleFonts.poppins(),
                          ),

                          const SizedBox(height: AppConstants.xLargeSpacing * 2),
                        ],
                      ),
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
                hint: Text(hint, style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[600])),
                icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                isExpanded: true,
                items: items.map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: GoogleFonts.poppins(fontSize: 15)),
                )).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
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

  bool _canContinue() {
    return _selectedDate != null &&
        _selectedGender != null &&
        _selectedMaritalStatus != null &&
        _selectedBodyType != null;
  }

  Widget _buildChipRow({
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onTap,
  }) {
    return Row(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selected == option;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(option),
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 5,
                right: index == options.length - 1 ? 0 : 5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                ),
              ),
              child: Text(
                option,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
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

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool _isSubmitting = false;

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _handleContinue() async {
    if (!_canContinue() || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await ProfileService.updateProfile(
        {
          'nickname': _nicknameController.text.trim(),
          'birth_date': _isoDate(_selectedDate!),
          'gender': _selectedGender,
          'marital_status': _selectedMaritalStatus,
          'body_type': _selectedBodyType,
          if (_bioController.text.trim().isNotEmpty)
            'bio': _bioController.text.trim(),
        },
        step: 1,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const EducationOccupationScreen(),
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
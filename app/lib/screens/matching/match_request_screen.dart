import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../../services/match_request_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

class MatchRequestScreen extends StatefulWidget {
  const MatchRequestScreen({super.key});

  @override
  State<MatchRequestScreen> createState() => _MatchRequestScreenState();
}

class _MatchRequestScreenState extends State<MatchRequestScreen> {
  static const List<String> _genders = ['Man', 'Woman', 'Prefer not to say'];
  static const List<String> _bodyTypes = [
    'Slim', 'Athletic', 'Average', 'Curvy', 'Thick',
    'Fit', 'Muscular', 'Plus-size', 'Petite',
  ];

  final _formKey = GlobalKey<FormState>();
  final _religionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _lookingForController = TextEditingController();

  String? _selectedGender;
  String? _selectedBodyType;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _prefillFromExisting();
  }

  Future<void> _prefillFromExisting() async {
    // Email from cached user; gender/body_type/religion from their profile
    // if they have one. Saves typing for existing users.
    try {
      final user = await AuthService.getCachedUser();
      if (mounted && user != null) {
        _emailController.text = (user['email'] as String?) ?? '';
      }
      final response = await ProfileService.getProfile();
      final profile = response['profile'] as Map<String, dynamic>?;
      if (profile == null || !mounted) return;
      setState(() {
        _selectedGender = profile['gender'] as String?;
        _selectedBodyType = profile['body_type'] as String?;
        final denomination = profile['denomination'] as String?;
        if (denomination != null && denomination.isNotEmpty) {
          _religionController.text = denomination;
        } else if (profile['is_believer'] == true) {
          _religionController.text = 'Christian';
        }
      });
    } catch (_) {
      // Silent — user can fill the form from scratch.
    }
  }

  @override
  void dispose() {
    _religionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _lookingForController.dispose();
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
          'Request a Match',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell us a bit about you',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Our team will use this to hand-pick a match for you and get in touch.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: AppConstants.xLargeSpacing),

                _label('Your Gender'),
                _genderChips(),
                const SizedBox(height: AppConstants.largeSpacing),

                _label('Body Type'),
                _bodyTypeDropdown(),
                const SizedBox(height: AppConstants.largeSpacing),

                _label('Religion / Denomination'),
                _textField(
                  controller: _religionController,
                  hint: 'e.g. Christian, Catholic, Pentecostal',
                  icon: Icons.church_outlined,
                  validator: _required('Please enter your religion'),
                ),
                const SizedBox(height: AppConstants.largeSpacing),

                _label('Your Phone Number'),
                _textField(
                  controller: _phoneController,
                  hint: '+254 712 345 678',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.length < 7) return 'Enter a valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.largeSpacing),

                _label('Your Email'),
                _textField(
                  controller: _emailController,
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Please enter your email';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.largeSpacing),

                _label('Details of the Person You\'re Looking For'),
                TextFormField(
                  controller: _lookingForController,
                  minLines: 4,
                  maxLines: 8,
                  maxLength: 2000,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText:
                        'Tell us about the person you hope to meet — values, faith, lifestyle, what matters to you in a partner…',
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
                    contentPadding: const EdgeInsets.all(14),
                    counterStyle: const TextStyle(color: Colors.grey),
                  ),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.length < 10) {
                      return 'Tell us a little more (at least 10 characters)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppConstants.xLargeSpacing),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Submit Request',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppConstants.smallSpacing),
                Center(
                  child: Text(
                    'Our team typically responds within 24-48 hours.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── helpers ─────────────────────────────────────────

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceColor,
          ),
        ),
      );

  Widget _genderChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _genders.map((g) {
        final selected = _selectedGender == g;
        return GestureDetector(
          onTap: () => setState(() => _selectedGender = g),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primaryColor : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppTheme.primaryColor : Colors.grey.shade300,
              ),
            ),
            child: Text(
              g,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppTheme.onSurfaceColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _bodyTypeDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.accessibility_new_outlined,
              color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBodyType,
                isExpanded: true,
                hint: Text(
                  'Select body type',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.grey[600]),
                ),
                icon: const Icon(Icons.arrow_drop_down,
                    color: AppTheme.primaryColor),
                items: _bodyTypes
                    .map((b) => DropdownMenuItem(
                          value: b,
                          child: Text(b,
                              style: GoogleFonts.poppins(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBodyType = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: GoogleFonts.poppins(fontSize: 15),
    );
  }

  String? Function(String?) _required(String message) {
    return (v) {
      if ((v?.trim() ?? '').isEmpty) return message;
      return null;
    };
  }

  Future<void> _submit() async {
    if (_selectedGender == null) {
      _showError('Please select your gender.');
      return;
    }
    if (_selectedBodyType == null) {
      _showError('Please select your body type.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await MatchRequestService.submit(
        gender: _selectedGender!,
        bodyType: _selectedBodyType!,
        religion: _religionController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        lookingForDetails: _lookingForController.text.trim(),
      );
      if (!mounted) return;
      _showSuccessDialog();
    } on AuthException catch (e) {
      _showError(
        e.fieldErrors?.values.firstOrNull?.firstOrNull ?? e.message,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(
              'Request Submitted',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Thanks! Our matchmaking team will review your details and reach out within 24-48 hours.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);          // close dialog
              Navigator.pop(context);      // leave the form screen
            },
            child: Text(
              'Got it',
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

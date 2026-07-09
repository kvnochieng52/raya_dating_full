import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/api_config.dart';
import 'package:http/http.dart' as http;

class CounsellingScreen extends StatefulWidget {
  final bool isPublic;
  const CounsellingScreen({super.key, this.isPublic = false});

  @override
  State<CounsellingScreen> createState() => _CounsellingScreenState();
}

class _CounsellingScreenState extends State<CounsellingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _counselorGender;
  final List<String> _communicationModes = [];
  String? _budgetRange;
  String? _counsellingType;
  String? _sessionFormat;
  String? _preferredDays;
  String? _preferredTime;
  String? _urgency;
  bool _submitting = false;
  bool _submitted = false;

  static const _genders = ['Male', 'Female', 'No preference'];
  static const _commModes = ['Call', 'Text', 'Email', 'Video Call'];
  static const _budgets = [
    'Under KES 500',
    'KES 500 – 1,500',
    'KES 1,500 – 3,000',
    'KES 3,000 – 6,000',
    'Above KES 6,000',
    'Free / Volunteer only',
  ];
  static const _types = [
    'Relationship',
    'Pre-marital',
    'Marriage',
    'Personal',
    'Grief',
    'Anxiety',
    'Other',
  ];
  static const _formats = ['Online', 'In-person', 'Either'];
  static const _days = ['Weekdays', 'Weekends', 'Flexible'];
  static const _times = ['Morning', 'Afternoon', 'Evening', 'Flexible'];
  static const _urgencies = ['This week', 'Within a month', 'No rush'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        title: Text(
          'Need Counselling?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppTheme.primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: _submitted ? _buildSuccess() : _buildForm(),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  size: 60, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 28),
            Text(
              'Request Received!',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Thank you for reaching out. Our team will contact you shortly through your preferred channel.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"Cast all your anxiety on Him because He cares for you."\n— 1 Peter 5:7',
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.grey[500],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                child: Text('Back to App',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image with text overlay
            SizedBox(
              width: double.infinity,
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/couseling.jpg',
                    fit: BoxFit.cover,
                  ),
                  // dark gradient overlay for readability
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x22000000),
                          Color(0xCC000000),
                        ],
                      ),
                    ),
                  ),
                  // Text overlay
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'You Are Not Alone',
                          style: GoogleFonts.lora(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Confidential, faith-based support for your journey.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

            // Section 1: Counselor preference
            _sectionTitle('Counselor Preference', Icons.person_outline),
            _chipGroup(
              options: _genders,
              selected: _counselorGender != null ? [_counselorGender!] : [],
              onTap: (v) => setState(() => _counselorGender = v),
              single: true,
              validator: _counselorGender == null
                  ? 'Please select your counselor preference'
                  : null,
            ),

            const SizedBox(height: 24),

            // Section 2: Contact details
            _sectionTitle('Your Contact Details', Icons.contact_phone_outlined),
            if (widget.isPublic) ...[
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: _inputDecoration('Your full name', Icons.person_outline),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: _inputDecoration('Phone number', Icons.phone_outlined),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration:
                  _inputDecoration('Email address', Icons.email_outlined),
              validator: (v) {
                if ((v == null || v.trim().isEmpty) &&
                    _phoneController.text.trim().isEmpty) {
                  return 'Please provide at least a phone or email';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Section 3: Communication modes
            _sectionTitle(
                'How Should We Reach You?', Icons.chat_bubble_outline),
            _chipGroup(
              options: _commModes,
              selected: _communicationModes,
              onTap: (v) => setState(() {
                _communicationModes.contains(v)
                    ? _communicationModes.remove(v)
                    : _communicationModes.add(v);
              }),
              single: false,
              validator: _communicationModes.isEmpty
                  ? 'Select at least one mode'
                  : null,
            ),

            const SizedBox(height: 24),

            // Section 4: Counselling type
            _sectionTitle('Area of Support', Icons.favorite_border),
            _chipGroup(
              options: _types,
              selected: _counsellingType != null ? [_counsellingType!] : [],
              onTap: (v) => setState(() => _counsellingType = v),
              single: true,
              validator:
                  _counsellingType == null ? 'Please choose an area' : null,
            ),

            const SizedBox(height: 24),

            // Section 5: Budget
            _sectionTitle('Budget per Session', Icons.wallet_outlined),
            _chipGroup(
              options: _budgets,
              selected: _budgetRange != null ? [_budgetRange!] : [],
              onTap: (v) => setState(() => _budgetRange = v),
              single: true,
              validator: _budgetRange == null ? 'Please select a budget' : null,
            ),

            const SizedBox(height: 24),

            // Section 6: Session format
            _sectionTitle('Session Format', Icons.videocam_outlined),
            _chipGroup(
              options: _formats,
              selected: _sessionFormat != null ? [_sessionFormat!] : [],
              onTap: (v) => setState(() => _sessionFormat = v),
              single: true,
              validator:
                  _sessionFormat == null ? 'Please choose a format' : null,
            ),

            const SizedBox(height: 24),

            // Section 7: Preferred days & time
            _sectionTitle('Preferred Schedule', Icons.schedule_outlined),
            Row(
              children: [
                Expanded(
                  child: _dropdownField(
                    label: 'Days',
                    value: _preferredDays,
                    items: _days,
                    onChanged: (v) => setState(() => _preferredDays = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdownField(
                    label: 'Time',
                    value: _preferredTime,
                    items: _times,
                    onChanged: (v) => setState(() => _preferredTime = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section 8: Urgency
            _sectionTitle('How Soon Do You Need Help?', Icons.timer_outlined),
            _chipGroup(
              options: _urgencies,
              selected: _urgency != null ? [_urgency!] : [],
              onTap: (v) => setState(() => _urgency = v),
              single: true,
              validator: _urgency == null ? 'Please select urgency' : null,
            ),

            const SizedBox(height: 24),

            // Section 9: Description
            _sectionTitle('Tell Us More (Optional)', Icons.edit_note_outlined),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 800,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    'Briefly describe what you are going through. This helps us match you with the right counsellor.',
                hintStyle:
                    GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                counterStyle: const TextStyle(color: Colors.grey),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              '🔒 All information is kept strictly confidential.',
              style:
                  GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Submit Request',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
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

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipGroup({
    required List<String> options,
    required List<String> selected,
    required Function(String) onTap,
    required bool single,
    String? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selected.contains(opt);
            return GestureDetector(
              onTap: () => onTap(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  opt,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected ? Colors.white : AppTheme.onSurfaceColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (validator != null) ...[
          const SizedBox(height: 6),
          Text(
            validator,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.red[600]),
          ),
        ],
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.onSurfaceColor),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
      prefixIcon: Icon(icon, size: 20, color: AppTheme.primaryColor),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  String? _validate() {
    if (_counselorGender == null) return 'Please select counselor preference.';
    if (_phoneController.text.trim().isEmpty &&
        _emailController.text.trim().isEmpty) {
      return 'Please provide a phone number or email.';
    }
    if (_communicationModes.isEmpty) {
      return 'Please select how we should reach you.';
    }
    if (widget.isPublic && _nameController.text.trim().isEmpty) {
      return 'Please enter your full name.';
    }
    if (_counsellingType == null) return 'Please choose an area of support.';
    if (_budgetRange == null) return 'Please select your budget.';
    if (_sessionFormat == null) return 'Please choose a session format.';
    if (_urgency == null) return 'Please indicate how soon you need help.';
    return null;
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }

    setState(() => _submitting = true);

    try {
      final isPublic = widget.isPublic;
      final token = isPublic ? null : await AuthService.getToken();
      final endpoint = isPublic
          ? '${ApiConfig.baseUrl}/counselling/public'
          : '${ApiConfig.baseUrl}/counselling';

      final payload = {
        if (isPublic) 'requester_name': _nameController.text.trim(),
        'counselor_gender': _counselorGender,
        'contact_phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'contact_email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'communication_modes': _communicationModes,
        'budget_range': _budgetRange,
        'counselling_type': _counsellingType,
        'session_format': _sessionFormat,
        'preferred_days': _preferredDays,
        'preferred_time': _preferredTime,
        'urgency': _urgency,
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      };

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .post(Uri.parse(endpoint), headers: headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 201) {
        setState(() => _submitted = true);
      } else {
        final body = jsonDecode(response.body);
        _showSnack(body['message'] ?? 'Something went wrong.', isError: true);
      }
    } catch (_) {
      _showSnack('Could not reach the server. Check your connection.',
          isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: isError ? Colors.red[700] : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

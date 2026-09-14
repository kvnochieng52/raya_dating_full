import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../models/user_model.dart';

class FiltersScreen extends StatefulWidget {
  final FilterCriteria currentFilters;

  const FiltersScreen({
    super.key,
    required this.currentFilters,
  });

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  late RangeValues _ageRange;
  late List<String> _selectedGenders;
  late List<String> _selectedInterests;
  late bool _onlineOnly;
  late bool _verifiedOnly;

  @override
  void initState() {
    super.initState();
    _ageRange = RangeValues(
      widget.currentFilters.minAge.toDouble(),
      widget.currentFilters.maxAge.toDouble(),
    );
    _selectedGenders = List.from(widget.currentFilters.genders);
    _selectedInterests = List.from(widget.currentFilters.interests);
    _onlineOnly = widget.currentFilters.onlineOnly;
    _verifiedOnly = widget.currentFilters.verifiedOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Discovery Filters',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: Text(
              'Reset',
              style: GoogleFonts.poppins(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAgeRangeSection(),
            const SizedBox(height: AppConstants.xLargeSpacing),
            _buildGenderSection(),
            const SizedBox(height: AppConstants.xLargeSpacing),
            _buildInterestsSection(),
            const SizedBox(height: AppConstants.xLargeSpacing),
            _buildPreferencesSection(),
            const SizedBox(height: AppConstants.xLargeSpacing * 2),
          ],
        ),
      ),
      bottomNavigationBar: _buildApplyButton(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.onSurfaceColor,
        ),
      ),
    );
  }

  Widget _buildAgeRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Age Range'),
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
            setState(() => _ageRange = values);
          },
        ),
      ],
    );
  }

  Widget _buildGenderSection() {
    final genders = ['Man', 'Woman', 'Non-binary'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Show Me'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: genders.map((gender) {
            final isSelected = _selectedGenders.contains(gender);
            return GestureDetector(
              onTap: () => _toggleGender(gender),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  gender,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.onSurfaceColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Interests'),
        Text(
          'Find people with similar interests',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        ...AppConstants.interestCategories.map((category) {
          return _buildInterestCategory(category);
        }),
      ],
    );
  }

  Widget _buildInterestCategory(String category) {
    final categoryInterests = AppConstants.interests[category] ?? [];

    return ExpansionTile(
      title: Text(
        category,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.onSurfaceColor,
        ),
      ),
      iconColor: AppTheme.primaryColor,
      collapsedIconColor: AppTheme.primaryColor,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categoryInterests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return GestureDetector(
                onTap: () => _toggleInterest(interest),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    interest,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.onSurfaceColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Preferences'),
        _buildPreferenceToggle(
          'Online Only',
          'Show only people who are currently online',
          _onlineOnly,
          (value) => setState(() => _onlineOnly = value),
        ),
        const SizedBox(height: 16),
        _buildPreferenceToggle(
          'Verified Profiles Only',
          'Show only verified profiles',
          _verifiedOnly,
          (value) => setState(() => _verifiedOnly = value),
        ),
      ],
    );
  }

  Widget _buildPreferenceToggle(
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

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Apply Filters',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleGender(String gender) {
    setState(() {
      if (_selectedGenders.contains(gender)) {
        _selectedGenders.remove(gender);
      } else {
        _selectedGenders.add(gender);
      }
    });
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

  void _resetFilters() {
    setState(() {
      _ageRange = const RangeValues(18, 100);
      _selectedGenders.clear();
      _selectedInterests.clear();
      _onlineOnly = false;
      _verifiedOnly = false;
    });
  }

  void _applyFilters() {
    final filters = FilterCriteria(
      minAge: _ageRange.start.round(),
      maxAge: _ageRange.end.round(),
      genders: _selectedGenders,
      interests: _selectedInterests,
      onlineOnly: _onlineOnly,
      verifiedOnly: _verifiedOnly,
    );

    Navigator.pop(context, filters);
  }
}
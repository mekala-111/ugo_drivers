import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/utils/input_validators.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uber-style Address & Emergency Contact step.
/// Optional fields - user can skip, but validated if provided.
class AddressDetailsWidget extends StatefulWidget {
  const AddressDetailsWidget({
    super.key,
    this.mobile,
    this.firstname,
    this.lastname,
    this.email,
    this.referalcode,
    this.vehicletype,
  });

  final int? mobile;
  final String? firstname;
  final String? lastname;
  final String? email;
  final String? referalcode;
  final String? vehicletype;

  static String routeName = 'address_details';
  static String routePath = '/addressDetails';

  @override
  State<AddressDetailsWidget> createState() => _AddressDetailsWidgetState();
}

class _AddressDetailsWidgetState extends State<AddressDetailsWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;

  @override
  void initState() {
    super.initState();
    // Mark current step for resume functionality
    FFAppState().registrationStep = 2;
    _dobController = TextEditingController(text: FFAppState().dateOfBirth);
    _addressController = TextEditingController(text: FFAppState().address);
    _cityController = TextEditingController(text: FFAppState().city);
    _stateController = TextEditingController(text: FFAppState().state);
    _postalController = TextEditingController(text: FFAppState().postalCode);
    _emergencyNameController = TextEditingController(text: FFAppState().emergencyContactName);
    _emergencyPhoneController = TextEditingController(text: FFAppState().emergencyContactPhone);

    _dobController.addListener(() {
      FFAppState().dateOfBirth = _dobController.text.trim();
    });
    _addressController.addListener(() {
      FFAppState().address = _addressController.text.trim();
    });
    _cityController.addListener(() {
      FFAppState().city = _cityController.text.trim();
    });
    _stateController.addListener(() {
      FFAppState().state = _stateController.text.trim();
    });
    _postalController.addListener(() {
      FFAppState().postalCode = _postalController.text.trim();
    });
    _emergencyNameController.addListener(() {
      FFAppState().emergencyContactName = _emergencyNameController.text.trim();
    });
    _emergencyPhoneController.addListener(() {
      FFAppState().emergencyContactPhone = _emergencyPhoneController.text.trim();
    });
  }

  @override
  void dispose() {
    _dobController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? hint,
    String? Function(String?)? validator,
    bool isSmall = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isSmall ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
            filled: true,
            fillColor: AppColors.backgroundCard,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandPrimary = AppColors.primary;

    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isSmall = width < 360;
    final isTablet = width >= 600;
    final horizontalPadding = isTablet ? 32.0 : (isSmall ? 16.0 : 24.0);
    final titleSize = isTablet ? 22.0 : (isSmall ? 18.0 : 20.0);
    final headingSize = isTablet ? 20.0 : (isSmall ? 16.0 : 18.0);
    final buttonHeight = isSmall ? 48.0 : 56.0;
    final fieldSpacing = isSmall ? 16.0 : 20.0;
    final sectionSpacing = isSmall ? 24.0 : 28.0;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundAlt,
        appBar: AppBar(
          backgroundColor: brandPrimary,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              final mobile = widget.mobile ?? FFAppState().mobileNo;
              context.goNamed(
                FirstdetailsWidget.routeName,
                queryParameters: {
                  'mobile': serializeParam(mobile, ParamType.int),
                }.withoutNulls,
              );
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText('ad0001'),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: titleSize,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(horizontalPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FFLocalizations.of(context).getText('ad0002'),
                  style: GoogleFonts.inter(
                    fontSize: isSmall ? 13 : 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: sectionSpacing),
                _buildField(
                  label: FFLocalizations.of(context).getText('ad0003'),
                  controller: _dobController,
                  icon: Icons.calendar_today,
                  hint: FFLocalizations.of(context).getText('ad0004'),
                  validator: (v) => v != null && v.isNotEmpty
                      ? InputValidators.dateOfBirthError(v)
                      : null,
                  isSmall: isSmall,
                ),
                SizedBox(height: fieldSpacing),
                _buildField(
                  label: FFLocalizations.of(context).getText('ad0005'),
                  controller: _addressController,
                  icon: Icons.location_on_outlined,
                  hint: FFLocalizations.of(context).getText('ad0006'),
                  isSmall: isSmall,
                ),
                SizedBox(height: fieldSpacing),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isStacked = constraints.maxWidth < 380;
                    if (isStacked) {
                      return Column(
                        children: [
                          _buildField(
                            label: FFLocalizations.of(context).getText('ad0007'),
                            controller: _cityController,
                            icon: Icons.location_city,
                            hint: FFLocalizations.of(context).getText('ad0007'),
                            isSmall: isSmall,
                          ),
                          SizedBox(height: fieldSpacing),
                          _buildField(
                            label: FFLocalizations.of(context).getText('ad0008'),
                            controller: _stateController,
                            icon: Icons.map_outlined,
                            hint: FFLocalizations.of(context).getText('ad0008'),
                            isSmall: isSmall,
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            label: FFLocalizations.of(context).getText('ad0007'),
                            controller: _cityController,
                            icon: Icons.location_city,
                            hint: FFLocalizations.of(context).getText('ad0007'),
                            isSmall: isSmall,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildField(
                            label: FFLocalizations.of(context).getText('ad0008'),
                            controller: _stateController,
                            icon: Icons.map_outlined,
                            hint: FFLocalizations.of(context).getText('ad0008'),
                            isSmall: isSmall,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: fieldSpacing),
                _buildField(
                  label: FFLocalizations.of(context).getText('ad0009'),
                  controller: _postalController,
                  icon: Icons.pin_drop,
                  keyboardType: TextInputType.number,
                  hint: FFLocalizations.of(context).getText('ad0010'),
                  isSmall: isSmall,
                ),
                SizedBox(height: sectionSpacing),
                Text(
                  FFLocalizations.of(context).getText('ad0011'),
                  style: GoogleFonts.inter(
                    fontSize: headingSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: FFLocalizations.of(context).getText('ad0012'),
                  controller: _emergencyNameController,
                  icon: Icons.person_outline,
                  hint: FFLocalizations.of(context).getText('ad0012'),
                  isSmall: isSmall,
                ),
                SizedBox(height: fieldSpacing),
                _buildField(
                  label: FFLocalizations.of(context).getText('ad0013'),
                  controller: _emergencyPhoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  hint: FFLocalizations.of(context).getText('ad0014'),
                  validator: (v) => v != null && v.isNotEmpty
                      ? InputValidators.phoneError(v)
                      : null,
                  isSmall: isSmall,
                ),
                SizedBox(height: sectionSpacing),
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveAndContinue();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      FFLocalizations.of(context).getText('ad0015'),
                      style: GoogleFonts.interTight(
                        fontSize: isSmall ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _saveAndContinue,
                    child: Text(
                      FFLocalizations.of(context).getText('ad0016'),
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: isSmall ? 12 : 14,
                      ),
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

  void _saveAndContinue() {
    FFAppState().dateOfBirth = _dobController.text.trim();
    FFAppState().address = _addressController.text.trim();
    FFAppState().city = _cityController.text.trim();
    FFAppState().state = _stateController.text.trim();
    FFAppState().postalCode = _postalController.text.trim();
    FFAppState().emergencyContactName = _emergencyNameController.text.trim();
    FFAppState().emergencyContactPhone = _emergencyPhoneController.text.trim();
    
    // Update registration step (for resume functionality)
    FFAppState().registrationStep = 2;
    
    context.pushNamed(
      ChooseVehicleWidget.routeName,
      queryParameters: {
        if (widget.mobile != null) 'mobile': serializeParam(widget.mobile, ParamType.int),
        if (widget.firstname != null) 'firstname': serializeParam(widget.firstname, ParamType.String),
        if (widget.lastname != null) 'lastname': serializeParam(widget.lastname, ParamType.String),
        if (widget.email != null) 'email': serializeParam(widget.email, ParamType.String),
        if (widget.referalcode != null) 'referalcode': serializeParam(widget.referalcode, ParamType.String),
      }.withoutNulls,
    );
  }
}

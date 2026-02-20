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
    _dobController = TextEditingController(text: FFAppState().dateOfBirth);
    _addressController = TextEditingController(text: FFAppState().address);
    _cityController = TextEditingController(text: FFAppState().city);
    _stateController = TextEditingController(text: FFAppState().state);
    _postalController = TextEditingController(text: FFAppState().postalCode);
    _emergencyNameController = TextEditingController(text: FFAppState().emergencyContactName);
    _emergencyPhoneController = TextEditingController(text: FFAppState().emergencyContactPhone);
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundAlt,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Address & Emergency',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optional - Add for faster KYC verification',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                _buildField(
                  label: 'Date of Birth',
                  controller: _dobController,
                  icon: Icons.calendar_today,
                  hint: 'YYYY-MM-DD or DD/MM/YYYY',
                  validator: (v) => v != null && v.isNotEmpty
                      ? InputValidators.dateOfBirthError(v)
                      : null,
                ),
                const SizedBox(height: 20),
                _buildField(
                  label: 'Address',
                  controller: _addressController,
                  icon: Icons.location_on_outlined,
                  hint: 'Street, area',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: 'City',
                        controller: _cityController,
                        icon: Icons.location_city,
                        hint: 'City',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildField(
                        label: 'State',
                        controller: _stateController,
                        icon: Icons.map_outlined,
                        hint: 'State',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildField(
                  label: 'Postal Code',
                  controller: _postalController,
                  icon: Icons.pin_drop,
                  keyboardType: TextInputType.number,
                  hint: 'e.g. 500001',
                ),
                const SizedBox(height: 28),
                Text(
                  'Emergency Contact',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Contact Name',
                  controller: _emergencyNameController,
                  icon: Icons.person_outline,
                  hint: 'Name',
                ),
                const SizedBox(height: 20),
                _buildField(
                  label: 'Contact Phone',
                  controller: _emergencyPhoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  hint: '10-digit number',
                  validator: (v) => v != null && v.isNotEmpty
                      ? InputValidators.phoneError(v)
                      : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
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
                      'Continue',
                      style: GoogleFonts.interTight(
                        fontSize: 18,
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
                      'Skip for now',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 14,
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

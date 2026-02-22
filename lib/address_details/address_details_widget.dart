import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/utils/input_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ==========================================
// 1. REUSABLE VIBRANT INPUT WIDGET
// ==========================================
class UgoTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const UgoTextField({
    Key? key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
          labelStyle: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w600),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[200]!, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
            borderRadius: BorderRadius.circular(16),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 2.5),
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        validator: validator,
      ),
    );
  }
}

// ==========================================
// 2. MODULAR FORM WIDGET (CAN BE USED IN MODALS OR PAGES)
// ==========================================
class AddressEmergencyForm extends StatefulWidget {
  final Function() onContinue;
  final Function() onSkip;

  const AddressEmergencyForm({
    Key? key,
    required this.onContinue,
    required this.onSkip,
  }) : super(key: key);

  @override
  State<AddressEmergencyForm> createState() => AddressEmergencyFormState();
}

class AddressEmergencyFormState extends State<AddressEmergencyForm> {
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

  bool validateAndSave() {
    if (_formKey.currentState!.validate()) {
      FFAppState().dateOfBirth = _dobController.text.trim();
      FFAppState().address = _addressController.text.trim();
      FFAppState().city = _cityController.text.trim();
      FFAppState().state = _stateController.text.trim();
      FFAppState().postalCode = _postalController.text.trim();
      FFAppState().emergencyContactName = _emergencyNameController.text.trim();
      FFAppState().emergencyContactPhone = _emergencyPhoneController.text.trim();
      return true;
    }
    return false;
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.15),
            radius: 24,
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.interTight(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Personal Details Section ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSectionHeader(
                  'Personal Info',
                  'For faster KYC verification',
                  Icons.person_pin_circle,
                ),
                UgoTextField(
                  label: 'Date of Birth',
                  hint: 'YYYY-MM-DD',
                  icon: Icons.calendar_month_rounded,
                  controller: _dobController,
                  validator: (v) => v != null && v.isNotEmpty ? InputValidators.dateOfBirthError(v) : null,
                ),
                UgoTextField(
                  label: 'Home Address',
                  hint: 'Street, area, building',
                  icon: Icons.home_rounded,
                  controller: _addressController,
                ),
                Row(
                  children: [
                    Expanded(
                      child: UgoTextField(
                        label: 'City',
                        hint: 'e.g. Mumbai',
                        icon: Icons.location_city_rounded,
                        controller: _cityController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: UgoTextField(
                        label: 'State',
                        hint: 'e.g. MH',
                        icon: Icons.map_rounded,
                        controller: _stateController,
                      ),
                    ),
                  ],
                ),
                UgoTextField(
                  label: 'Postal Code',
                  hint: '6-digit PIN',
                  icon: Icons.pin_drop_rounded,
                  controller: _postalController,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Emergency Contact Section ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSectionHeader(
                  'Emergency Contact',
                  'Who to call in an emergency',
                  Icons.health_and_safety_rounded,
                ),
                UgoTextField(
                  label: 'Contact Name',
                  hint: 'Family member or friend',
                  icon: Icons.badge_rounded,
                  controller: _emergencyNameController,
                ),
                UgoTextField(
                  label: 'Phone Number',
                  hint: '10-digit mobile number',
                  icon: Icons.phone_in_talk_rounded,
                  controller: _emergencyPhoneController,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v != null && v.isNotEmpty ? InputValidators.phoneError(v) : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. MAIN PAGE SCAFFOLD
// ==========================================
class AddressDetailsWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Create a GlobalKey to access the form state
    final GlobalKey<AddressEmergencyFormState> formKey = GlobalKey<AddressEmergencyFormState>();

    void proceedToNextStep() {
      context.pushNamed(
        ChooseVehicleWidget.routeName,
        queryParameters: {
          if (mobile != null) 'mobile': serializeParam(mobile, ParamType.int),
          if (firstname != null) 'firstname': serializeParam(firstname, ParamType.String),
          if (lastname != null) 'lastname': serializeParam(lastname, ParamType.String),
          if (email != null) 'email': serializeParam(email, ParamType.String),
          if (referalcode != null) 'referalcode': serializeParam(referalcode, ParamType.String),
        }.withoutNulls,
      );
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundAlt ?? const Color(0xFFF5F7FA), // Soft background makes white cards pop
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Step 2 of 3', // Driver friendly progress indicator
            style: GoogleFonts.interTight(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 120),
          child: AddressEmergencyForm(
            key: formKey,
            onContinue: proceedToNextStep,
            onSkip: proceedToNextStep,
          ),
        ),
        // STICKY BOTTOM BAR: Driver friendly, button is always accessible
        bottomSheet: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validateAndSave() == true) {
                      proceedToNextStep();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Save & Continue',
                    style: GoogleFonts.interTight(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white, // Ensure high contrast
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: proceedToNextStep,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'I\'ll do this later',
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/backend/api_requests/api_calls.dart';
import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_util.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> driverData;

  const EditProfileScreen({super.key, required this.driverData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();

  FFUploadedFile? profileImage;
  bool saving = false;

  static const Color brandPrimary = AppColors.primary;

  @override
  void initState() {
    super.initState();

    firstNameCtrl.text = widget.driverData['first_name'] ?? '';
    lastNameCtrl.text = widget.driverData['last_name'] ?? '';
  }

  Future pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    profileImage = FFUploadedFile(
      name: picked.name,
      bytes: bytes,
    );

    setState(() {});
  }

  Future saveProfile() async {
    if (firstNameCtrl.text.trim().isEmpty ||
        lastNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First & Last name required')),
      );
      return;
    }

    setState(() => saving = true);

    await UpdateDriverCall.call(
      token: FFAppState().accessToken,
      id: FFAppState().driverid,
      firstName: firstNameCtrl.text.trim(),
      lastName: lastNameCtrl.text.trim(),
      profileimage: profileImage,
    );

    setState(() => saving = false);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: brandPrimary,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  const SizedBox(height: 10),

            // PROFILE IMAGE
            GestureDetector(
              onTap: pickImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
  radius: 55,
  backgroundColor: brandPrimary.withValues(alpha: 0.1),
  backgroundImage: profileImage != null
      ? MemoryImage(profileImage!.bytes!)
      : (widget.driverData['profile_image'] != null &&
              widget.driverData['profile_image'].toString().isNotEmpty
          ? NetworkImage(
              "https://ugo-api.icacorp.org/${widget.driverData['profile_image']}",
            )
          : null) as ImageProvider?,
  child: profileImage == null &&
          (widget.driverData['profile_image'] == null ||
              widget.driverData['profile_image'].toString().isEmpty)
      ? const Icon(Icons.camera_alt,
          size: 30, color: brandPrimary)
      : null,
),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: brandPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit,
                          size: 16, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // FIRST NAME
            TextField(
  controller: firstNameCtrl,
  decoration: InputDecoration(
    labelText: 'First Name',
    prefixIcon: const Icon(Icons.person_outline),
    filled: true,
    fillColor: Colors.white,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: brandPrimary, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
  ),
),


            const SizedBox(height: 16),

            // LAST NAME
            TextField(
  controller: lastNameCtrl,
  decoration: InputDecoration(
    labelText: 'Last Name',
    prefixIcon: const Icon(Icons.person_outline),
    filled: true,
    fillColor: Colors.white,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: brandPrimary, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
  ),
),


            const SizedBox(height: 24),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saving ? null : saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

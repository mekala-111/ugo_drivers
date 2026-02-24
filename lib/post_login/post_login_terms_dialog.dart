import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/constants/app_colors.dart';

/// Rapido-style: UGO TAXI Terms of Service modal shown after login.
/// "Don't forget to pay attention to your surroundings and always obey the law."
class PostLoginTermsDialog extends StatelessWidget {
  const PostLoginTermsDialog({
    super.key,
    required this.onGotIt,
  });

  final VoidCallback onGotIt;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'UGO TAXI Terms of Service',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Don\'t forget to pay attention to your surroundings and always obey the law.',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black87,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onGotIt();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: Text(
                  'GOT IT',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

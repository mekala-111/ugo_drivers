import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ugo_driver/backend/api_requests/api_calls.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/models/payment_mode.dart';
import 'package:ugo_driver/constants/responsive.dart';
import '../home/ride_request_model.dart';

class ReviewScreen extends StatefulWidget {
  final RideRequest ride;
  final VoidCallback onSubmit;
  final VoidCallback onClose;
  final bool isCashPayment;

  const ReviewScreen({
    super.key,
    required this.ride,
    required this.onSubmit,
    required this.onClose,
    this.isCashPayment = false,
  });

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _starRating = 0;
  bool _isSubmitting = false;
  final List<String> _selectedTagKeys = [];

  // Figma tags matching screenshot + Rapido style
  static const List<String> _reviewTagKeys = [
    'drv_review_friendly',
    'drv_review_safe',
    'drv_review_worst',
    'drv_review_fast',
    'drv_review_affordable',
  ];

  String get _fareAmount =>
      '₹${(widget.ride.finalFare ?? widget.ride.estimatedFare)?.toStringAsFixed(2) ?? '0.00'}';

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (_starRating <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final token = FFAppState().accessToken;
    final driverId = FFAppState().driverid;
    if (token.isEmpty || driverId <= 0) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
      return;
    }

    final comment = _selectedTagKeys
        .map((k) => FFLocalizations.of(context).getText(k))
        .where((s) => s.isNotEmpty)
        .join(', ');

    try {
      final res = await RateRideCall.call(
        token: token,
        rideId: widget.ride.id,
        userId: widget.ride.userId,
        driverId: driverId,
        rating: _starRating,
        comment: comment.isNotEmpty ? comment : null,
      );

      if (!mounted) return;

      final ok = res.succeeded && (RateRideCall.success(res.jsonBody) ?? false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              RateRideCall.message(res.jsonBody) ??
                  'Thank you! Rating submitted.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onSubmit();
      } else {
        final msg =
            RateRideCall.message(res.jsonBody) ?? 'Failed to submit rating';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not submit rating: ${e.toString()}'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFB), // Subtle off-white background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          FFLocalizations.of(context).getText('drv_ride_completed'),
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: widget.onClose,
            child: Text(
              FFLocalizations.of(context).getText('drv_skip'),
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Rider Info Card
              _buildRiderCard(),
              const SizedBox(height: 32),

              // Review Section
              Text(
                FFLocalizations.of(context).getText('drv_review'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildStarRating(),

              const SizedBox(height: 32),
              // Optional Comments
              Text(
                FFLocalizations.of(context).getText('drv_optional_comments'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildReviewTags(),

              const SizedBox(height: 40),
              // Fare Display
              _buildFareCard(),

              const SizedBox(height: 40),
              // Submit Button
              _buildSubmitButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiderCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.primary, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FFLocalizations.of(context).getText('drv_passenger'),
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.ride.fullName.isNotEmpty
                      ? widget.ride.fullName.toUpperCase()
                      : 'PASSENGER',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${FFLocalizations.of(context).getText('drv_rating_label')} : ',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      '5.0', // Standard or fetch if available
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (widget.ride.vehicleType != null)
                  Row(
                    children: [
                      Text(
                        '${FFLocalizations.of(context).getText('drv_vehicle_label')} : ',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        widget.ride.vehicleType!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final isSelected = index < _starRating;
        return InkWell(
          onTap: () => setState(() => _starRating = index + 1),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isSelected ? AppColors.primary : Colors.grey[300],
              size: 52,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildReviewTags() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _reviewTagKeys.map((key) {
        final label = FFLocalizations.of(context).getText(key);
        final isSelected = _selectedTagKeys.contains(key);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedTagKeys.remove(key);
              } else {
                _selectedTagKeys.add(key);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey[200]!,
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.black54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFareCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FFLocalizations.of(context).getText('drv_total_fare'),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.ride.paymentMode.isCash
                            ? Colors.green.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: widget.ride.paymentMode.isCash
                                ? Colors.green.shade200
                                : Colors.blue.shade200),
                      ),
                      child: Text(
                        widget.ride.rawPaymentMode.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: widget.ride.paymentMode.isCash
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      _fareAmount,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey[400]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                FFLocalizations.of(context).getText('drv_submit'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

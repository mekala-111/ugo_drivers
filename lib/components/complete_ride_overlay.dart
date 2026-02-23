import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/constants/responsive.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import 'package:ugo_driver/components/rich_address_from_lat_lng.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home/ride_request_model.dart';

// --- Wrapper Widget ---
class RideCompleteOverlay extends StatelessWidget {
  final RideRequest ride;
  final VoidCallback? onSwipe;
  final bool isLoading;

  const RideCompleteOverlay({
    super.key,
    required this.ride,
    this.onSwipe,
    this.isLoading = false,
  });

  // ✅ Universal Map Launcher
  Future<void> _launchMap(double? lat, double? lng) async {
    if (lat == null || lng == null || (lat == 0.0 && lng == 0.0)) {
      debugPrint('❌ Error: Invalid Coordinates ($lat, $lng)');
      return;
    }

    final Uri googleMapsUrl = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final Uri browserUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else if (await canLaunchUrl(browserUrl)) {
        await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('❌ Could not launch maps url');
      }
    } catch (e) {
      debugPrint('❌ Map Launch Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Align bottom center forces this entire block to snap to the bottom of the screen
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false, // Ensures it doesn't add padding to the top, only respects bottom notches
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ✅ Floating "Drop" Navigation Button
            Padding(
              padding: EdgeInsets.only(
                right: Responsive.horizontalPadding(context),
                bottom: Responsive.verticalSpacing(context),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _launchMap(ride.dropLat, ride.dropLng),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    height: Responsive.buttonHeight(context, base: 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary, // Orange
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            Icons.navigation,
                            color: Colors.black,
                            size: Responsive.iconSize(context, base: 20)
                        ),
                        const SizedBox(width: 8),
                        Text(
                          FFLocalizations.of(context).getText('drv_drop'),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.fontSize(context, 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ✅ The Main Card
            CompleteRideCard(
              ride: ride,
              onSwipe: onSwipe,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

// --- The Card Widget ---
class CompleteRideCard extends StatelessWidget {
  final RideRequest ride;
  final VoidCallback? onSwipe;
  final bool isLoading;

  const CompleteRideCard({
    super.key,
    required this.ride,
    this.onSwipe,
    this.isLoading = false,
  });

  static const Color ugoOrange = AppColors.primary;
  static const Color ugoGreen = AppColors.success;
  static const Color ugoRed = AppColors.error;

  // ✅ Logic to Make Phone Call
  Future<void> _makePhoneCall(BuildContext context) async {
    final phoneNumber = ride.mobileNumber ?? '';

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FFLocalizations.of(context).getText('ride0007'))),
      );
      return;
    }

    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(FFLocalizations.of(context).getText('drv_dialer_fail'))),
        );
      }
    } catch (e) {
      debugPrint('Phone call error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar (Green for 'Go to Drop Location' banner)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: ugoGreen, // Green background to match Figma
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Text(
              FFLocalizations.of(context).getText('drv_go_to_drop'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.0),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.horizontalPadding(context) + 4,
              20,
              Responsive.horizontalPadding(context) + 4,
              24,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN: Passenger Name & Address
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.firstName ?? FFLocalizations.of(context).getText('drv_passenger'),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Drop Icon Box (White with Red Border)
                              Container(
                                width: Responsive.buttonHeight(context, base: 46),
                                height: Responsive.buttonHeight(context, base: 46),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: ugoRed, width: 1.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.location_on,
                                        color: ugoRed,
                                        size: Responsive.iconSize(context, base: 22)),
                                    Text(
                                      FFLocalizations.of(context).getText('drv_drop'),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),

                              // ✅ Address text
                              Expanded(
                                child: RichAddressFromLatLng(
                                  lat: ride.dropLat,
                                  lng: ride.dropLng,
                                  fallbackAddress: ride.dropAddress,
                                  fallbackLabel: FFLocalizations.of(context).getText('drv_drop_location'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // RIGHT COLUMN: Call Button
                    Column(
                      children: [
                        _buildSquareIconBtn(
                          context,
                          Icon(Icons.call, color: Colors.black, size: Responsive.iconSize(context, base: 24)),
                              () => _makePhoneCall(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Swipe to Complete Button (Red)
                isLoading
                    ? Container(
                  height: Responsive.buttonHeight(context, base: 55),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(color: ugoRed),
                )
                    : SlideToAction(
                    text: FFLocalizations.of(context).getText('drv_complete_ride'),
                    outerColor: ugoRed,
                    onSubmitted: onSwipe ?? () {},
                    height: Responsive.buttonHeight(context, base: 55)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareIconBtn(BuildContext context, Widget iconWidget, VoidCallback onTap) {
    final sz = Responsive.buttonHeight(context, base: 48);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: sz,
        height: sz,
        decoration: BoxDecoration(
            color: const Color(0xFFE2E2E2),
            borderRadius: BorderRadius.circular(10)),
        child: Center(child: iconWidget),
      ),
    );
  }
}

// --- Custom Swipe Button  ---
class SlideToAction extends StatefulWidget {
  final String text;
  final Color outerColor;
  final VoidCallback onSubmitted;
  final double height;

  const SlideToAction({
    super.key,
    required this.text,
    required this.outerColor,
    required this.onSubmitted,
    this.height = 55.0,
  });

  @override
  _SlideToActionState createState() => _SlideToActionState();
}

class _SlideToActionState extends State<SlideToAction> {
  double _position = 0.0;
  double _maxWidth = 0.0;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _maxWidth = constraints.maxWidth;
        double sliderSize = widget.height - 8;

        return Container(
          height: widget.height,
          width: _maxWidth,
          decoration: BoxDecoration(
            color: widget.outerColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0),
                ),
              ),
              Positioned(
                left: _position + 4,
                top: 4,
                bottom: 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_submitted) return;
                    setState(() {
                      _position += details.delta.dx;
                      if (_position < 0) _position = 0;
                      if (_position > _maxWidth - widget.height) {
                        _position = _maxWidth - widget.height;
                      }
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_submitted) return;
                    if (_position > (_maxWidth - widget.height) * 0.7) {
                      setState(() {
                        _position = _maxWidth - widget.height;
                        _submitted = true;
                      });
                      widget.onSubmitted();
                    } else {
                      setState(() {
                        _position = 0;
                      });
                    }
                  },
                  child: Container(
                    width: sliderSize,
                    height: sliderSize,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 3,
                              offset: Offset(1, 1))
                        ]),
                    child: Icon(Icons.arrow_forward,
                        color: widget.outerColor, size: 24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
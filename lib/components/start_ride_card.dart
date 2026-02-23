import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/constants/responsive.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ugo_driver/components/rich_address_from_lat_lng.dart';
import '../home/ride_request_model.dart';
import '../models/ride_status.dart';

// --- Main Wrapper Widget ---
class RideBottomOverlay extends StatelessWidget {
  final RideRequest ride;
  final String formattedWaitTime;
  final VoidCallback onSwipe;
  final VoidCallback onCancel;
  final VoidCallback onCall;

  const RideBottomOverlay({
    super.key,
    required this.ride,
    required this.formattedWaitTime,
    required this.onSwipe,
    required this.onCancel,
    required this.onCall,
  });

  // ✅ Helper to launch Google Maps Navigation
  Future<void> _launchMap(double? lat, double? lng) async {
    if (lat == null || lng == null) {
      debugPrint('❌ Coordinates are null');
      return;
    }

    final Uri googleMapsUrl = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final Uri fallbackUrl =
    Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('❌ Could not launch map: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ✅ Navigation Button - Pickup when arrived, Drop when started
        Padding(
          padding: EdgeInsets.only(
            right: Responsive.horizontalPadding(context),
            bottom: Responsive.verticalSpacing(context),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final isStarted = ride.status == RideStatus.started ||
                    ride.status == RideStatus.onTrip;
                _launchMap(
                  isStarted ? ride.dropLat : ride.pickupLat,
                  isStarted ? ride.dropLng : ride.pickupLng,
                );
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: Responsive.buttonHeight(context, base: 48),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.horizontalPadding(context) + 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary, // Orange Color
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.navigation,
                        color: Colors.black,
                        size: Responsive.iconSize(context, base: 20)),
                    const SizedBox(width: 8),
                    Text(
                      (ride.status == RideStatus.started ||
                          ride.status == RideStatus.onTrip)
                          ? FFLocalizations.of(context)
                          .getText('drv_nav_to_drop') // Assuming this translates to "Drop"
                          : FFLocalizations.of(context)
                          .getText('drv_nav_to_pickup'),
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
        Material(
          type: MaterialType.transparency,
          child: StartRideCard(
            ride: ride,
            formattedWaitTime: formattedWaitTime,
            onSwipe: onSwipe,
            onCancel: onCancel,
            onCall: onCall,
          ),
        ),
      ],
    );
  }
}

// --- The Bottom Card ---
class StartRideCard extends StatelessWidget {
  final RideRequest ride;
  final String formattedWaitTime;
  final VoidCallback onSwipe;
  final VoidCallback onCancel;
  final VoidCallback onCall;

  const StartRideCard({
    super.key,
    required this.ride,
    required this.formattedWaitTime,
    required this.onSwipe,
    required this.onCancel,
    required this.onCall,
  });

  // --- Colors ---
  static const Color ugoOrange = AppColors.primary;
  static const Color ugoGreen = AppColors.success;
  static const Color ugoRed = AppColors.error;

  @override
  Widget build(BuildContext context) {
    bool isStarted = ride.status == RideStatus.started;

    String btnText = isStarted
        ? FFLocalizations.of(context).getText('drv_complete_ride')
        : FFLocalizations.of(context).getText('drv_start_ride');
    Color btnColor = isStarted ? ugoRed : ugoGreen;

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
          // Green Header Bar (Waiting Time)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: ugoGreen,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Text(
              "${FFLocalizations.of(context).getText('drv_waiting_time')} : $formattedWaitTime",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
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
                // --- FIGMA LEFT/RIGHT SPLIT LAYOUT ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN: Name and Address Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.firstName ??
                                FFLocalizations.of(context)
                                    .getText('drv_passenger'),
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
                              // Pickup/Drop Box
                              Container(
                                width: Responsive.buttonHeight(context, base: 46),
                                height: Responsive.buttonHeight(context, base: 46),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: isStarted ? ugoRed : ugoGreen, width: 1.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.location_on,
                                        color: isStarted ? ugoRed : ugoGreen,
                                        size: Responsive.iconSize(context, base: 22)),
                                    Text(
                                      isStarted
                                          ? FFLocalizations.of(context).getText('drv_drop')
                                          : FFLocalizations.of(context).getText('drv_pickup'),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Address text
                              Expanded(
                                child: RichAddressFromLatLng(
                                  lat: isStarted ? ride.dropLat : ride.pickupLat,
                                  lng: isStarted ? ride.dropLng : ride.pickupLng,
                                  fallbackAddress:
                                  isStarted ? ride.dropAddress : ride.pickupAddress,
                                  fallbackLabel: FFLocalizations.of(context)
                                      .getText('drv_unknown_location'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // RIGHT COLUMN: Vertically Stacked Action Buttons
                    Column(
                      children: [
                        _buildSquareIconBtn(
                          context,
                          Icon(Icons.call, color: Colors.black, size: Responsive.iconSize(context, base: 24)),
                          onCall,
                        ),
                        SizedBox(height: Responsive.verticalSpacing(context)),
                        _buildSquareIconBtn(
                          context,
                          Container(
                            width: Responsive.iconSize(context, base: 24),
                            height: Responsive.iconSize(context, base: 24),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: Responsive.iconSize(context, base: 16)),
                          ),
                          onCancel,
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 24),

                // Bottom Slider Button
                SlideToAction(
                  text: btnText,
                  outerColor: btnColor,
                  onSubmitted: onSwipe,
                  height: Responsive.buttonHeight(context, base: 55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareIconBtn(
      BuildContext context, Widget iconWidget, VoidCallback onPressed) {
    final sz = Responsive.buttonHeight(context, base: 48);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: sz,
        height: sz,
        decoration: BoxDecoration(
            color: const Color(0xFFE2E2E2), // Matching the light gray box from Figma
            borderRadius: BorderRadius.circular(10)),
        child: Center(child: iconWidget),
      ),
    );
  }
}

// --- Custom Swipe Button Implementation ---
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
                    child: Icon(
                      Icons.arrow_forward,
                      color: widget.outerColor,
                      size: 24,
                    ),
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
import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/constants/responsive.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import 'package:url_launcher/url_launcher.dart';

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
    // Stack ensures the floating button sits on top of the map layer visually,
    // but here we use a Column to stack it vertically *above* the card.
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end, // Align button to right
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
                final isStarted = ride.status == RideStatus.started || ride.status == RideStatus.onTrip;
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
                  color: AppColors.primary,
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
                    Icon(Icons.navigation, color: Colors.black, size: Responsive.iconSize(context, base: 20)),
                    const SizedBox(width: 8),
                    Text(
                      (ride.status == RideStatus.started || ride.status == RideStatus.onTrip)
                          ? FFLocalizations.of(context).getText('drv_nav_to_drop')
                          : FFLocalizations.of(context).getText('drv_nav_to_pickup'),
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
    // ride.status is now an enum
    bool isStarted = ride.status == RideStatus.started;

    // Button Logic
    String btnText = isStarted ? FFLocalizations.of(context).getText('drv_complete_ride') : FFLocalizations.of(context).getText('drv_start_ride');
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
              16,
              Responsive.horizontalPadding(context) + 4,
              24,
            ),
            child: Column(
              children: [
                // Top Row: User Name & Action Buttons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        ride.firstName ?? FFLocalizations.of(context).getText('drv_passenger'),
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        _buildSquareIconBtn(context, Icons.call, Colors.black,
                            Colors.grey[200]!, onCall),
                        SizedBox(width: Responsive.verticalSpacing(context)),
                        _buildSquareIconBtn(context,
                            Icons.close, Colors.white, ugoRed, onCancel),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // Middle Row: Location Box & Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pickup/Drop Box
                    Container(
                      width: Responsive.buttonHeight(context, base: 50),
                      height: Responsive.buttonHeight(context, base: 50),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isStarted ? ugoRed : ugoGreen, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on,
                              color: isStarted ? ugoRed : ugoGreen,
                              size: Responsive.iconSize(context, base: 20)),
                          Text(
                            isStarted ? FFLocalizations.of(context).getText('drv_drop') : FFLocalizations.of(context).getText('drv_pickup'),
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Rich Address
                    Expanded(
                      child: _buildRichAddress(
                          isStarted ? ride.dropAddress : ride.pickupAddress),
                    ),
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

  Widget _buildRichAddress(String rawAddress) {
    String pincode = '';
    String locality = '';
    String rest = rawAddress;

    final pinMatch = RegExp(r'\b\d{6}\b').firstMatch(rawAddress);
    if (pinMatch != null) {
      pincode = pinMatch.group(0)!;
      rest = rawAddress.replaceAll(pincode, '').trim();
      if (rest.startsWith(',')) rest = rest.substring(1).trim();
      if (rest.endsWith(',')) rest = rest.substring(0, rest.length - 1).trim();
    }

    List<String> parts = rest.split(',');
    if (parts.isNotEmpty) {
      locality = parts[0].trim();
      if (parts.length > 1) {
        rest = parts.sublist(1).join(', ').trim();
      } else {
        rest = '';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pincode.isNotEmpty)
          Text(pincode,
              style: const TextStyle(
                  color: ugoOrange, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 4),
        RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style:
                const TextStyle(fontSize: 14, color: Colors.black, height: 1.3),
            children: [
              TextSpan(
                  text: '$locality, ',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: rest, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSquareIconBtn(BuildContext context,
      IconData icon, Color iconColor, Color bgColor, VoidCallback onPressed) {
    final sz = Responsive.buttonHeight(context, base: 48);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: sz,
        height: sz,
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor, size: Responsive.iconSize(context, base: 24)),
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

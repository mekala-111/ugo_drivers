import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/constants/responsive.dart';
import '../home/ride_request_model.dart';
import '../models/ride_status.dart';

// --- Wrapper Widget ---
class RidePickupOverlay extends StatelessWidget {
  final RideRequest ride;
  final String formattedWaitTime;
  final VoidCallback onSwipe;
  final VoidCallback? onCancel;

  const RidePickupOverlay({
    super.key,
    required this.ride,
    required this.formattedWaitTime,
    required this.onSwipe,
    this.onCancel,
  });

  Future<void> _launchMap(double? lat, double? lng) async {
    if (lat == null || lng == null || (lat == 0.0 && lng == 0.0)) {
      debugPrint('❌ Error: Invalid Coordinates ($lat, $lng)');
      return;
    }
    final Uri googleMapsUrl = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final Uri browserUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

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
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Floating "Pickup" Navigation Button
            LayoutBuilder(
              builder: (context, _) {
                final btnH = Responsive.buttonHeight(context, base: 48);
                return Padding(
                  padding: EdgeInsets.only(
                    right: Responsive.horizontalPadding(context),
                    bottom: Responsive.verticalSpacing(context),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _launchMap(ride.pickupLat, ride.pickupLng);
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        height: btnH,
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
                            Icon(Icons.navigation, color: Colors.white, size: Responsive.iconSize(context, base: 20)),
                            const SizedBox(width: 8),
                            Text(
                              FFLocalizations.of(context).getText('drv_navigate'),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.fontSize(context, 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // The Main Card
            ActiveRideCard(
              ride: ride,
              formattedWaitTime: formattedWaitTime,
              onSwipe: onSwipe,
              onCancel: onCancel,
            ),
          ],
        ),
      ],
    );
  }
}

// --- The Card Widget ---
class ActiveRideCard extends StatelessWidget {
  final RideRequest ride;
  final String formattedWaitTime;
  final VoidCallback onSwipe;
  final VoidCallback? onCancel;

  const ActiveRideCard({
    super.key,
    required this.ride,
    required this.formattedWaitTime,
    required this.onSwipe,
    this.onCancel,
  });

  static const Color ugoOrange = AppColors.primary;
  static const Color ugoGreen = AppColors.success;
  static const Color ugoRed = AppColors.error;

  @override
  Widget build(BuildContext context) {
    // ride.status is now a RideStatus enum
    bool isArrived = ride.status == RideStatus.arrived;
    bool isStarted = ride.status == RideStatus.started;

    String headerText = FFLocalizations.of(context).getText('drv_go_to_pickup');
    Color headerColor = ugoGreen;
    String btnText = FFLocalizations.of(context).getText('drv_arrived');
    Color btnColor = ugoGreen;
    bool showPickupBox = true;

    if (isArrived) {
      headerText = "${FFLocalizations.of(context).getText('drv_waiting_time')} : $formattedWaitTime";
      btnText = FFLocalizations.of(context).getText('drv_start_ride');
    } else if (isStarted) {
      headerText = FFLocalizations.of(context).getText('drv_go_to_drop');
      btnText = FFLocalizations.of(context).getText('drv_complete_ride');
      btnColor = ugoRed;
      headerColor = ugoRed; // Change header color for Drop
      showPickupBox = false;
    }

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
          // Header Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Text(
              headerText,
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
              Responsive.horizontalPadding(context),
              16,
              Responsive.horizontalPadding(context),
              24,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.firstName ?? FFLocalizations.of(context).getText('drv_passenger'),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon Box
                              Container(
                                width: Responsive.buttonHeight(context, base: 50),
                                height: Responsive.buttonHeight(context, base: 50),
                                decoration: BoxDecoration(
                                  color: (showPickupBox ? ugoGreen : ugoRed)
                                      .withValues(alpha:0.1),
                                  border: Border.all(
                                      color: showPickupBox ? ugoGreen : ugoRed,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.location_on,
                                        color:
                                            showPickupBox ? ugoGreen : ugoRed,
                                        size: Responsive.iconSize(context, base: 24)),
                                    Text(
                                      showPickupBox ? FFLocalizations.of(context).getText('drv_pickup') : FFLocalizations.of(context).getText('drv_drop'),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Rich Address Display
                              Expanded(
                                child: _buildRichAddress(context, showPickupBox
                                    ? ride.pickupAddress
                                    : ride.dropAddress),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        _buildSquareIconBtn(context, Icons.call, Colors.green, () {
                          launchUrl(
                              Uri.parse("tel:${ride.mobileNumber ?? ''}"));
                        }),
                        SizedBox(height: Responsive.verticalSpacing(context)),
                        _buildSquareIconBtn(context, Icons.close, ugoRed, onCancel ?? () {}),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 24),
                // Swipe Button
                SlideToAction(
                    text: btnText,
                    outerColor: btnColor,
                    onSubmitted: onSwipe,
                    height: Responsive.buttonHeight(context, base: 55)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ RAPIDO-STYLE ADDRESS HIGHLIGHTING
  Widget _buildRichAddress(BuildContext context, String rawAddress) {
    String pincode = '';
    String locality = '';
    String fullAddressWithoutPin = rawAddress;

    // 1. Extract Pincode (Matches 6 digits like 500081 or 500 081)
    final pinMatch = RegExp(r'\b\d{3}\s?\d{3}\b').firstMatch(rawAddress);

    if (pinMatch != null) {
      pincode = pinMatch.group(0)!;
      // Remove pincode from address string to avoid duplication
      fullAddressWithoutPin = rawAddress
          .replaceAll(pincode, '')
          .replaceAll(RegExp(r',+\s*$'), '')
          .trim();
    }

    // 2. Extract Locality (First part of the address)
    List<String> parts = fullAddressWithoutPin.split(',');
    if (parts.isNotEmpty) {
      locality = parts[0].trim();
      // If the first part is just a house number, maybe take the second part too
      if (locality.length < 5 && parts.length > 1) {
        locality = '$locality, ${parts[1].trim()}';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 1. Pincode Badge (Top)
        if (pincode.isNotEmpty)
          Text(
            pincode,
            style: const TextStyle(
                color: ugoOrange,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5),
          ),

        // 🔹 2. Area Name (Large & Bold)
        Text(
          locality.isNotEmpty ? locality : FFLocalizations.of(context).getText('drv_unknown_location'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 16, // Large size like Rapido
              fontWeight: FontWeight.w800, // Extra Bold
              color: Colors.black87,
              height: 1.2),
        ),

        const SizedBox(height: 4),

        // 🔹 3. Full Address (Small & Grey)
        Text(
          fullAddressWithoutPin,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.3),
        ),
      ],
    );
  }

  Widget _buildSquareIconBtn(BuildContext context, IconData icon, Color color, VoidCallback onTap) {
    final sz = Responsive.buttonHeight(context, base: 48);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: sz,
        height: sz,
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12)),
        child: Icon(icon, color: color, size: Responsive.iconSize(context, base: 24)),
      ),
    );
  }
}

// --- Custom Swipe Button ---
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

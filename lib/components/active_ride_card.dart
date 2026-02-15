import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home/ride_request_model.dart'; // Ensure this points to the file with the CORRECT RideRequest model

// --- Wrapper Widget ---
class RidePickupOverlay extends StatelessWidget {
  final RideRequest ride;
  final String formattedWaitTime;
  final VoidCallback onSwipe;

  const RidePickupOverlay({
    Key? key,
    required this.ride,
    required this.formattedWaitTime,
    required this.onSwipe,
  }) : super(key: key);

  // ✅ FIXED: Robust Map Launcher
  Future<void> _launchMap(double? lat, double? lng) async {
    // 1. Check for Null OR Zero coordinates
    if (lat == null || lng == null || (lat == 0.0 && lng == 0.0)) {
      debugPrint("❌ Error: Invalid Coordinates ($lat, $lng)");
      return;
    }

    // 2. Universal Google Maps URL (Works on Android & iOS)
    // api=1 ensures it triggers the navigation intent correctly
    final Uri googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving"
    );

    try {
      // 3. Try launching external application (Maps App)
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("❌ Could not launch maps url");
      }
    } catch (e) {
      debugPrint("❌ Map Launch Error: $e");
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
            Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
              child: InkWell(
                onTap: () {
                  // ✅ Uses the FIXED map launcher
                  print("📍 Navigating to: ${ride.pickupLat}, ${ride.pickupLng}");
                  _launchMap(ride.pickupLat, ride.pickupLng);
                },
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7B10), // ugoOrange
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.navigation, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "PICK UP",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // The Main Card
            ActiveRideCard(
              ride: ride,
              formattedWaitTime: formattedWaitTime,
              onSwipe: onSwipe,
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

  const ActiveRideCard({
    Key? key,
    required this.ride,
    required this.formattedWaitTime,
    required this.onSwipe,
  }) : super(key: key);

  static const Color ugoOrange = Color(0xFFFF7B10);
  static const Color ugoGreen = Color(0xFF4CAF50);
  static const Color ugoRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    String status = ride.status.toLowerCase();
    bool isArrived = status == 'arrived';
    bool isStarted = status == 'started';

    String headerText = "GO TO PICKUP";
    Color headerColor = ugoGreen;
    String btnText = "ARRIVED";
    Color btnColor = ugoGreen;
    bool showPickupBox = true;

    if (isArrived) {
      headerText = "Waiting Time : $formattedWaitTime";
      btnText = "START RIDE";
    } else if (isStarted) {
      headerText = "GO TO DROP";
      btnText = "COMPLETE RIDE";
      btnColor = ugoRed;
      showPickupBox = false;
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16)
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
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
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16)
              ),
            ),
            child: Text(
              headerText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                            // ✅ Fix: use firstName property from the FIXED model
                            "${ride.firstName ?? 'Passenger'}",
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon Box
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: showPickupBox ? ugoGreen : ugoRed,
                                      width: 1
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        Icons.location_on,
                                        color: showPickupBox ? ugoGreen : ugoRed,
                                        size: 24
                                    ),
                                    Text(
                                      showPickupBox ? "Pickup" : "Drop",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Address
                              Expanded(
                                child: _buildRichAddress(
                                    showPickupBox ? ride.pickupAddress : ride.dropAddress
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        _buildSquareIconBtn(Icons.call, Colors.green, () {
                          // Add call logic here if needed
                        }),
                        const SizedBox(height: 16),
                        _buildSquareIconBtn(Icons.close, ugoRed, () {}),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 24),
                // Swipe Button
                SlideToAction(
                    text: btnText,
                    outerColor: btnColor,
                    onSubmitted: onSwipe
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Better Pincode Regex & String Parsing
  Widget _buildRichAddress(String rawAddress) {
    String pincode = "";
    String locality = "";
    String rest = rawAddress;

    // 1. Matches 6 digits (e.g. 500081) OR 6 digits with space (e.g. 500 081)
    final pinMatch = RegExp(r'\b\d{3}\s?\d{3}\b').firstMatch(rawAddress);

    if (pinMatch != null) {
      pincode = pinMatch.group(0)!;
      // Remove pincode from address
      rest = rawAddress.replaceAll(pincode, '').trim();
    }

    // 2. Clean up dangling commas
    rest = rest.replaceAll(RegExp(r'^,+|,+$'), '').trim();

    List<String> parts = rest.split(',');
    if (parts.isNotEmpty) {
      locality = parts[0].trim();
      if (parts.length > 1) {
        rest = parts.sublist(1).join(', ').trim();
      } else {
        rest = "";
      }
    }

    // 3. Fallback: If locality is empty, use raw text
    if (locality.isEmpty && rest.isEmpty) {
      rest = rawAddress;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Only show Pincode row if we found one
        if (pincode.isNotEmpty)
          Text(
              pincode,
              style: const TextStyle(color: ugoOrange, fontWeight: FontWeight.bold, fontSize: 15)
          ),
        const SizedBox(height: 2),
        RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black, height: 1.3),
            children: [
              TextSpan(text: "$locality${locality.isNotEmpty ? ', ' : ''}", style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: rest, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSquareIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

// --- Custom Swipe Button (Unchanged) ---
class SlideToAction extends StatefulWidget {
  final String text;
  final Color outerColor;
  final VoidCallback onSubmitted;
  final double height;

  const SlideToAction({
    Key? key,
    required this.text,
    required this.outerColor,
    required this.onSubmitted,
    this.height = 55.0,
  }) : super(key: key);

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
                      letterSpacing: 1.0
                  ),
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
                          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1,1))
                        ]
                    ),
                    child: Icon(Icons.arrow_forward, color: widget.outerColor, size: 24),
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
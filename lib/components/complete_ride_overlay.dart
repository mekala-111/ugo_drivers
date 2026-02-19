import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home/ride_request_model.dart';

// --- Wrapper Widget ---
class RideCompleteOverlay extends StatelessWidget {
  final RideRequest ride;
  final VoidCallback onSwipe;

  const RideCompleteOverlay({
    Key? key,
    required this.ride,
    required this.onSwipe,
  }) : super(key: key);

  // ✅ Universal Map Launcher
  Future<void> _launchMap(double? lat, double? lng) async {
    if (lat == null || lng == null || (lat == 0.0 && lng == 0.0)) {
      debugPrint("❌ Error: Invalid Coordinates ($lat, $lng)");
      return;
    }

    final Uri googleMapsUrl = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    // fallback browser URL uses proper google maps query parameters
    final Uri browserUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else if (await canLaunchUrl(browserUrl)) {
        await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
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
            // ✅ Floating "Drop" Navigation Button
            Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
              child: InkWell(
                onTap: () => _launchMap(ride.dropLat, ride.dropLng),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7B10), // ugoOrange
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
                    children: const [
                      Icon(Icons.navigation, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "DROP",
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

            // ✅ The Main Card
            CompleteRideCard(
              ride: ride,
              onSwipe: onSwipe,
            ),
          ],
        ),
      ],
    );
  }
}

// --- The Card Widget ---
class CompleteRideCard extends StatelessWidget {
  final RideRequest ride;
  final VoidCallback onSwipe;

  const CompleteRideCard({
    Key? key,
    required this.ride,
    required this.onSwipe,
  }) : super(key: key);

  static const Color ugoOrange = Color(0xFFFF7B10);
  static const Color ugoGreen = Color(0xFF4CAF50);
  static const Color ugoRed = Color(0xFFE53935);

  // ✅ Logic to Make Phone Call
  Future<void> _makePhoneCall(BuildContext context) async {
    final phoneNumber = ride.mobileNumber ?? '';

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available.')),
      );
      return;
    }

    final Uri phoneUri = Uri.parse("tel:$phoneNumber");
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer.')),
        );
      }
    } catch (e) {
      debugPrint("Phone call error: $e");
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
          // Header Bar (Red for Drop/Complete phase)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: ugoRed,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: const Text(
              "GO TO DROP",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.0),
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
                          // Passenger Name
                          Text(
                            ride.firstName ?? 'Passenger',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Drop Icon Box (Red Theme)
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: ugoRed.withValues(alpha:0.1),
                                  border: Border.all(color: ugoRed, width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: ugoRed, size: 24),
                                    Text(
                                      "Drop",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),

                              // ✅ Rich Address with Pincode Badge
                              Expanded(
                                child: _buildRichAddress(ride.dropAddress),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ✅ Call Button
                    _buildSquareIconBtn(Icons.call, Colors.green,
                        () => _makePhoneCall(context)),
                  ],
                ),
                const SizedBox(height: 24),

                // Swipe to Complete
                SlideToAction(
                    text: "COMPLETE RIDE",
                    outerColor: ugoRed,
                    onSubmitted: onSwipe),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ UGO-STYLE ADDRESS PARSER
  Widget _buildRichAddress(String rawAddress) {
    String pincode = "";
    String locality = "";
    String fullAddressWithoutPin = rawAddress;

    // 1. Extract Pincode
    final pinMatch = RegExp(r'\b\d{6}\b').firstMatch(rawAddress);
    if (pinMatch != null) {
      pincode = pinMatch.group(0)!;
      fullAddressWithoutPin = rawAddress
          .replaceAll(pincode, '')
          .replaceAll(RegExp(r',+\s*$'), '')
          .trim();
    }

    // 2. Extract Locality (Bold Area Name)
    List<String> parts = fullAddressWithoutPin.split(',');
    if (parts.isNotEmpty) {
      locality = parts[0].trim();
      // Handle short house numbers by appending street name
      if (locality.length < 5 && parts.length > 1) {
        locality = "$locality, ${parts[1].trim()}";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Pincode Badge
        if (pincode.isNotEmpty)
          Text(
            "$pincode",
            style: const TextStyle(
                color: ugoOrange,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5),
          ),

        // 🔹 Bold Area Name
        Text(
          locality.isNotEmpty ? locality : "Drop Location",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              height: 1.2),
        ),

        const SizedBox(height: 4),

        // 🔹 Full Address
        Text(
          fullAddressWithoutPin,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.3),
        ),
      ],
    );
  }

  Widget _buildSquareIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12)),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}

// --- Custom Swipe Button (Kept same as provided) ---
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

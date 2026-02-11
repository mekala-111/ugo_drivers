import 'package:flutter/material.dart';
import '../home/home_model.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Wrapper Widget ---
class RideCompleteOverlay extends StatelessWidget {
  final RideRequest ride;
  final VoidCallback onSwipe;

  const RideCompleteOverlay({
    Key? key,
    required this.ride,
    required this.onSwipe,
  }) : super(key: key);

  // ✅ Helper to launch Google Maps for Drop Location
  Future<void> _launchMap(double? lat, double? lng) async {
    if (lat == null || lng == null) {
      debugPrint("❌ Coordinates are null");
      return;
    }

    final Uri googleMapsUrl = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    final Uri fallbackUrl = Uri.parse("http://googleusercontent.com/maps.google.com/?q=$lat,$lng");

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("❌ Could not launch map: $e");
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
            // ✅ Floating "Drop" Navigation Button (Orange)
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
                      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.navigation, color: Colors.black, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Drop",
                        style: TextStyle(
                          color: Colors.black,
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

  // --- Colors ---
  static const Color ugoOrange = Color(0xFFFF7B10);
  static const Color ugoGreen = Color(0xFF4CAF50);
  static const Color ugoRed = Color(0xFFE53935);

  // --- Actions ---
  void _makePhoneCall(BuildContext context) async {
    // Prefer mobile_number, fallback to passengerPhone if available
    final phoneNumber = ride.userIdName ?? ''; // Check your model for the correct phone field

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available.')),
      );
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw 'Could not launch $phoneUri';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not make the call.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            decoration: const BoxDecoration(
              color: ugoGreen,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16)
              ),
            ),
            child: const Text(
              "Go To Drop Location",
              textAlign: TextAlign.center,
              style: TextStyle(
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
                // Top Row: Name & Call Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        ride.first_name ?? 'Passenger', // ✅ Dynamic Name
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Call Button
                    InkWell(
                      onTap: () => _makePhoneCall(context),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.call, color: Colors.black, size: 28),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Address Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drop Location Box
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: ugoRed, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, color: ugoRed, size: 24),
                          Text(
                            "Drop",
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
                      child: _buildRichAddress(ride.dropAddress),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // RED Complete Ride Button
                SlideToAction(
                    text: "COMPLETE RIDE",
                    outerColor: ugoRed,
                    onSubmitted: onSwipe
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichAddress(String rawAddress) {
    String pincode = "";
    String locality = "";
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
        rest = "";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pincode.isNotEmpty)
          Text(pincode, style: const TextStyle(color: ugoOrange, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black, height: 1.3),
            children: [
              TextSpan(text: "$locality, ", style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: rest, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ],
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
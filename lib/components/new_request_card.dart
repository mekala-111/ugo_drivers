import 'package:flutter/material.dart';
import '../home/ride_request_model.dart';

class NewRequestCard extends StatelessWidget {
  final RideRequest ride;
  final int remainingTime;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const NewRequestCard({
    Key? key,
    required this.ride,
    required this.remainingTime,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  // --- Colors ---
  static const Color ugoOrange = Color(0xFFFF7B10);
  static const Color ugoGreen = Color(0xFF4CAF50);
  static const Color ugoRed = Color(0xFFE53935);
  static const Color ugoBlue = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
        ],
        border: Border.all(color: ugoOrange, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
                color: ugoGreen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("NEW REQUEST",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text("${remainingTime}s",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDistanceInfo("Pickup Distance", "0.31Km"),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(height: 1, color: Colors.grey[300]),
                          const Icon(Icons.arrow_forward, size: 16),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 25.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[400]!)),
                              child: Column(children: [
                                Text("Fare",
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 10)),
                                Text("₹${ride.estimatedFare?.toInt() ?? 80}",
                                    style: const TextStyle(
                                        color: ugoBlue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDistanceInfo(
                        "Drop Distance", "${ride.distance ?? 4}Km",
                        alignRight: true),
                  ],
                ),
                const SizedBox(height: 20),
                _buildAddressRow(
                    color: ugoRed,
                    label: "Drop",
                    code: "506000",
                    address: ride.dropAddress),
                const SizedBox(height: 12),
                _buildAddressRow(
                    color: ugoGreen,
                    label: "Pickup",
                    code: "508001",
                    address: ride.pickupAddress),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildButton("DECLINE", ugoRed, onDecline)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildButton("ACCEPT", ugoGreen, onAccept)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceInfo(String label, String value,
      {bool alignRight = false}) {
    return Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: ugoBlue, fontSize: 20, fontWeight: FontWeight.bold))
        ]);
  }

  Widget _buildAddressRow(
      {required Color color,
      required String label,
      required String code,
      required String address}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.5))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.location_on, color: color, size: 20),
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.grey))
          ])),
      const SizedBox(width: 12),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(code,
            style: const TextStyle(
                color: ugoOrange, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[700], fontSize: 13))
      ])),
    ]);
  }

  Widget _buildButton(String text, Color bg, VoidCallback onTap) {
    return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)));
  }
}

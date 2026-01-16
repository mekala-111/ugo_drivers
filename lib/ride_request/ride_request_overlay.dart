import 'package:flutter/material.dart';
import './ride_request_model.dart'; // Ensure this points to your model file
import 'package:dio/dio.dart';

class RideRequestOverlay extends StatefulWidget {
  const RideRequestOverlay({Key? key}) : super(key: key);

  @override
  RideRequestOverlayState createState() => RideRequestOverlayState();
}

// ⚠️ Note: This class is public (no underscore) so we can access it via GlobalKey
class RideRequestOverlayState extends State<RideRequestOverlay> {
  final List<RideRequest> _activeRequests = [];
  final Set<int> _seenRideIds = {};

  @override
  void initState() {
    super.initState();
    // Simulation code removed. This is now ready for real Socket data.
  }

  // 🔓 PUBLIC METHOD: Call this from your Home Screen socket listener
  void handleNewRide(Map<String, dynamic> rawData) {
    print("🔎 DEBUG: processing ride data: $rawData");
    try {
      final newRide = RideRequest.fromJson(rawData);

      // 1. Deduplication Check
      if (_seenRideIds.contains(newRide.id)) return;

      // 2. Add to State
      if (mounted) {
        setState(() {
          _seenRideIds.add(newRide.id);
          _activeRequests.add(newRide);
        });
        print("   🚀 Card added to UI. Total cards: ${_activeRequests.length}");
      }
    } catch (e) {
      print("❌ Error parsing ride request: $e");
    }
  }

  void _removeRide(int index) {
    setState(() {
      _activeRequests.removeAt(index);
    });
  }

  // Helper to calculate "5 min ago"
  String _getTimeAgo(DateTime? time) {
    if (time == null) return "Just now";
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return "Just now";
    return "${diff.inMinutes} min ago";
  }

  @override
  Widget build(BuildContext context) {
    // Hide completely if no requests
    if (_activeRequests.isEmpty) return SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 10,
      right: 10,
      child: SizedBox(
        height: 220,
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.95),
          itemCount: _activeRequests.length,
          itemBuilder: (context, index) {
            return _buildDetailedCard(_activeRequests[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildDetailedCard(RideRequest ride, int index) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ROW 1: FARE, DISTANCE, TIME ---
            Row(
              children: [
                // FARE BADGE
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    ride.estimatedFare != null
                        ? "₹${ride.estimatedFare!.toStringAsFixed(0)}"
                        : "₹ --",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        fontSize: 16),
                  ),
                ),
                SizedBox(width: 8),
                // DISTANCE
                Icon(Icons.directions_car, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  ride.distance != null ? "${ride.distance} km" : "-- km",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                // TIME AGO
                Icon(Icons.access_time, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  _getTimeAgo(ride.createdAt),
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),

            Divider(height: 20),

            // --- ROW 2: PICKUP ---
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 12),
                      Container(
                          height: 20, width: 2, color: Colors.grey.shade300),
                    ],
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.pickupAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            // --- ROW 3: DROPOFF ---
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.red, size: 14),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.dropAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            // --- ROW 4: METADATA ---
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "User ID: ${ride.userId}  •  Ride ID: ${ride.id}",
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ),

            // --- ROW 5: BUTTONS ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _removeRide(index),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade200),
                      padding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    child: Text("Ignore"),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // 1. Define the endpoint
                        // ⚠️ Ensure the URL structure matches your backend route exactly
                        final String url =
                            "https://ugotaxi.icacorp.org/api/rides/rides/${ride.id}/accept";

                        print("🚕 Attempting to accept ride: $url");
                        const String token =
                            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwibW9iaWxlX251bWJlciI6IjEiLCJyb2xlIjoiZHJpdmVyIiwiaWF0IjoxNzY3MTkxOTAyLCJleHAiOjE3Njc3OTY3MDJ9.WGBEt-CeyRdXNFcr-vicBZ0qADs3UEWFjP4AdPfVB_8";
                        // 2. Make the POST request
                        final dio = Dio();
                        final response = await dio.post(
                          url,
                          data: {"driver_id": 1}, // Send driver_id in body
                          options: Options(
                            headers: {
                              // If you need the token here, add it:
                              // "Authorization": "Bearer $YOUR_DRIVER_TOKEN",
                              "Authorization": "Bearer $token",
                              "Content-Type": "application/json",
                            },
                          ),
                        );

                        // 3. Handle Success
                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          print("✅ Ride Accepted Successfully!");

                          // Remove from the list immediately for UI responsiveness
                          _removeRide(index);

                          // Optional: Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Ride Accepted! Navigating to pickup...")),
                          );
                        }
                      } catch (e) {
                        // 4. Handle Errors
                        print("❌ Failed to accept ride: $e");

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Failed to accept ride. It might be taken."),
                            backgroundColor: Colors.red,
                          ),
                        );

                        // Optional: If the ride is already taken, you might want to remove it anyway
                        if (e is DioException &&
                            e.response?.statusCode == 409) {
                          _removeRide(index);
                        }
                      }
                    },
                    child: const Text("Accept"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

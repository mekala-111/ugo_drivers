import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LastOrderWidget extends StatefulWidget {
  const LastOrderWidget({super.key});

  @override
  State<LastOrderWidget> createState() => _LastOrderWidgetState();
}

class _LastOrderWidgetState extends State<LastOrderWidget> {
  bool loading = true;
  Map? lastRide;

  static const brandOrange = Color(0xFFFF7B10);

  @override
  void initState() {
    super.initState();
    fetchLastRide();
  }

  Future fetchLastRide() async {
    final res = await DriverRideHistoryCall.call(
      token: FFAppState().accessToken,
      id: FFAppState().driverid,
    );

    if (res.succeeded) {
      final rides = DriverRideHistoryCall.rides(res.jsonBody);

      if (rides.isNotEmpty) {
        setState(() {
          lastRide = rides.first; // newest
          loading = false;
        });
      } else {
        loading = false;
      }
    } else {
      loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandOrange,
        title: const Text("Last Order"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : lastRide == null
              ? const Center(child: Text("No orders yet"))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("₹${lastRide!['amount']}",
                              style: GoogleFonts.inter(
                                  fontSize: 36,
                                  color: brandOrange,
                                  fontWeight: FontWeight.bold)),

                          const SizedBox(height: 20),

                          _row(Icons.location_on,
                              lastRide!['from'], Colors.orange),

                          const SizedBox(height: 10),

                          _row(Icons.flag, lastRide!['to'], Colors.green),

                          const Divider(height: 30),

                          Text(
                              "Date: ${lastRide!['date']?.toString().substring(0, 10) ?? ''}",
                              style: GoogleFonts.inter(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _row(IconData icon, String? text, Color c) {
    return Row(
      children: [
        Icon(icon, color: c),
        const SizedBox(width: 8),
        Expanded(child: Text(text ?? '')),
      ],
    );
  }
}

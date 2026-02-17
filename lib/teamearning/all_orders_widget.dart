import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  bool loading = true;
  List rides = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future fetchOrders() async {
    final res = await DriverRideHistoryCall.call(
      token: FFAppState().accessToken,
      id: FFAppState().driverid,
    );

    if (res.succeeded) {
      setState(() {
        rides = DriverRideHistoryCall.rides(res.jsonBody);
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFFFF7B10);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: brand,
        title: const Text("All Orders"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rides.isEmpty
              ? const Center(child: Text("No rides found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rides.length,
                  itemBuilder: (context, i) {
                    final r = rides[i];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: brand),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    r['from'] ?? '',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                const Icon(Icons.flag,
                                    color: Colors.green),
                                const SizedBox(width: 6),
                                Expanded(child: Text(r['to'] ?? '')),
                              ],
                            ),

                            const Divider(height: 20),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "₹${r['amount']}",
                                  style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: brand),
                                ),
                                Text(
                                  r['date']?.toString().substring(0, 10) ??
                                      '',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Custom Staggered Animation Widget ---
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedListItem({super.key, required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100).clamp(0, 500)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)), // Slides up smoothly
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class LastOrderWidget extends StatefulWidget {
  const LastOrderWidget({super.key});

  static const String routeName = 'LastOrder';
  static const String routePath = '/lastOrder';

  @override
  State<LastOrderWidget> createState() => _LastOrderWidgetState();
}

class _LastOrderWidgetState extends State<LastOrderWidget> {
  bool loading = true;
  Map? lastRide;
  String? loadError;

  @override
  void initState() {
    super.initState();
    fetchLastRide();
  }

  /// Prefer full ride history first — it includes pickup/drop. Weekly earnings
  /// only expose amount + payment; use as fallback when history is empty.
  Future<void> fetchLastRide() async {
    final token = FFAppState().accessToken;
    final driverId = FFAppState().driverid;
    if (token.isEmpty || driverId <= 0) {
      if (mounted) {
        setState(() {
          loading = false;
          loadError = 'Sign in again to see your last trip.';
        });
      }
      return;
    }

    if (mounted) setState(() => loadError = null);

    var rides = <dynamic>[];
    var historyOk = false;
    var earningsOk = false;

    final historyRes = await DriverRideHistoryCall.call(
      token: token,
      id: driverId,
    );
    historyOk = historyRes.succeeded;
    if (historyOk) {
      var fromRides = DriverRideHistoryCall.completedRides(historyRes.jsonBody);
      if (fromRides.isEmpty) {
        fromRides = DriverRideHistoryCall.completedOrders(historyRes.jsonBody);
      }
      if (fromRides.isEmpty) {
        fromRides = DriverRideHistoryCall.rides(historyRes.jsonBody);
      }
      rides = _onlyCompleted(fromRides);
    }

    if (rides.isEmpty) {
      final earningsRes = await DriverEarningsCall.call(
        token: token,
        driverId: driverId,
        period: 'weekly',
      );
      earningsOk = earningsRes.succeeded;
      if (earningsOk) {
        final list = DriverEarningsCall.rides(earningsRes.jsonBody);
        if (list != null && list.isNotEmpty) {
          rides = List<dynamic>.from(list);
        }
      }
    } else {
      earningsOk = true;
    }

    if (!mounted) return;

    if (rides.isNotEmpty) {
      rides = List<dynamic>.from(rides);
      rides.sort((a, b) {
        final aVal = _sortKeyForRide(a);
        final bVal = _sortKeyForRide(b);
        return bVal.compareTo(aVal);
      });
      setState(() {
        lastRide = rides.first is Map
            ? Map<String, dynamic>.from(rides.first as Map)
            : null;
        loading = false;
        loadError = null;
      });
    } else {
      setState(() {
        lastRide = null;
        loading = false;
        loadError = (!historyOk && !earningsOk)
            ? 'Could not load trips. Pull to try again.'
            : null;
      });
    }
  }

  static List<dynamic> _onlyCompleted(List<dynamic> raw) {
    final out = <dynamic>[];
    for (final r in raw) {
      if (r is! Map) continue;
      final st = (r['status'] ?? r['ride_status'] ?? r['rideStatus'])
          ?.toString()
          .toLowerCase();
      if (st == null || st.isEmpty || st == 'completed') {
        out.add(r);
      }
    }
    return out.isEmpty ? raw : out;
  }

  static String _sortKeyForRide(dynamic ride) {
    if (ride is! Map) return '';
    final raw = ride['ride_end_time'] ??
        ride['completedAt'] ??
        ride['completed_at'] ??
        ride['createdAt'] ??
        ride['created_at'] ??
        ride['date'];
    return raw?.toString() ?? '';
  }

  static dynamic _fareRaw(Map<dynamic, dynamic> m) =>
      m['final_fare'] ?? m['estimated_fare'] ?? m['fare'] ?? m['amount'];

  static String _fareRupee(Map<dynamic, dynamic> m) {
    final v = _fareRaw(m);
    if (v == null) return '0';
    if (v is num) {
      if (v == v.roundToDouble()) return v.round().toString();
      return v.toStringAsFixed(2);
    }
    return v.toString();
  }

  static dynamic _completedAtRaw(Map<dynamic, dynamic> m) =>
      m['ride_end_time'] ??
      m['completedAt'] ??
      m['completed_at'] ??
      m['createdAt'] ??
      m['created_at'] ??
      m['date'];

  static String _paymentKey(Map<dynamic, dynamic> m) =>
      (m['paymentMethod'] ?? m['payment_method'] ?? '')
          .toString()
          .toLowerCase()
          .trim();

  static String _paymentLabel(Map<dynamic, dynamic> m) {
    switch (_paymentKey(m)) {
      case 'cash':
        return 'Cash';
      case 'online':
        return 'Online pay';
      case 'wallet':
        return 'Wallet';
      default:
        final p = _paymentKey(m);
        if (p.isEmpty) return 'Payment';
        return '${p[0].toUpperCase()}${p.length > 1 ? p.substring(1) : ''}';
    }
  }

  static String _fareReceivedLine(Map<dynamic, dynamic> m) {
    final amt = _fareRupee(m);
    switch (_paymentKey(m)) {
      case 'cash':
        return '₹$amt — cash trip. You collected this fare.';
      case 'online':
        return '₹$amt — rider paid online.';
      case 'wallet':
        return '₹$amt — paid from rider wallet.';
      default:
        return '₹$amt recorded for this trip.';
    }
  }

  static String _durationDistanceLine(Map<dynamic, dynamic> m) {
    final dist = m['distanceKm'] ?? m['distance'] ?? m['distance_km'];
    String distPart = '—';
    if (dist != null && dist.toString().trim().isNotEmpty) {
      final d = dist.toString().trim();
      distPart = d.toLowerCase().contains('km') ? d : '$d km';
    }
    final dur =
        m['duration'] ?? m['durationMinutes'] ?? m['actual_duration_minutes'];
    String durPart = '—';
    if (dur != null && dur.toString().trim().isNotEmpty) {
      final s = dur.toString().trim();
      durPart = s.toLowerCase().contains('min') ? s : '$s min';
    }
    return '$distPart • $durPart';
  }

  static bool _hasRouteDetails(Map<dynamic, dynamic> m) {
    String? s(dynamic x) => x?.toString().trim();
    return (s(m['pickupAddress'] ??
                    m['pickup_address'] ??
                    m['pickup_location_address'] ??
                    m['from'])
                ?.isNotEmpty ??
            false) ||
        (s(m['dropAddress'] ??
                    m['drop_address'] ??
                    m['drop_location_address'] ??
                    m['to'])
                ?.isNotEmpty ??
            false);
  }

  @override
  Widget build(BuildContext context) {
    String dateStr = 'Unknown Date';
    String timeStr = '';
    final dateVal = lastRide != null ? _completedAtRaw(lastRide!) : null;
    if (dateVal != null) {
      try {
        final dt = DateTime.parse(dateVal.toString());
        dateStr = DateFormat('MMM d, yyyy').format(dt);
        timeStr = DateFormat('h:mm a').format(dt);
      } catch (e) {
        dateStr = dateVal.toString();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Soft off-white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        ),
        title: Column(
          children: [
            Text(
              'Last trip',
              style: GoogleFonts.interTight(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (timeStr.isNotEmpty)
              Text(
                '$dateStr • $timeStr',
                style: GoogleFonts.inter(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryLightBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.headset_mic_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Help',
                    style: GoogleFonts.inter(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          )
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: fetchLastRide,
              child: lastRide == null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.25,
                        ),
                        Icon(Icons.local_taxi_rounded,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              loadError ??
                                  'No completed trips yet. Finish a ride to see it here.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (loadError == null)
                          Center(
                            child: Text(
                              'Pull down to refresh',
                              style: GoogleFonts.inter(
                                  color: Colors.grey.shade400, fontSize: 13),
                            ),
                          ),
                      ],
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Order ID & Status Header
                          AnimatedListItem(
                            index: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Trip #${lastRide!['rideId'] ?? lastRide!['ride_id'] ?? lastRide!['orderId'] ?? lastRide!['id'] ?? '—'}',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.success
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Completed',
                                    style: GoogleFonts.interTight(
                                        fontSize: 13,
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 2. Beautiful Earnings Card
                          AnimatedListItem(
                              index: 1, child: _buildEarningsCard()),
                          const SizedBox(height: 16),

                          // 3. Premium Route Info Card
                          AnimatedListItem(
                              index: 2, child: _buildRouteInfoCard()),
                          const SizedBox(height: 16),

                          // 4. Clean Payment Info
                          AnimatedListItem(
                            index: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4))
                                ],
                              ),
                              child: Theme(
                                data: Theme.of(context)
                                    .copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  iconColor: AppColors.primary,
                                  collapsedIconColor: Colors.grey.shade400,
                                  title: Text('Payment info',
                                      style: GoogleFonts.interTight(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  initiallyExpanded: true,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Trip fare',
                                                  style: GoogleFonts.inter(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              Text(
                                                '₹${_fareRupee(lastRide!)}',
                                                style: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: AppColors.success),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Payment type',
                                                  style: GoogleFonts.inter(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              Text(
                                                _paymentLabel(lastRide!),
                                                style: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                    color: Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
    );
  }

  // --- WIDGETS ---

  Widget _buildEarningsCard() {
    final payKey = _paymentKey(lastRide!);
    final (IconData payIcon, Color payColor) = switch (payKey) {
      'cash' => (Icons.payments_rounded, Colors.green.shade700),
      'online' => (Icons.credit_card_rounded, Colors.indigo.shade700),
      'wallet' => (Icons.account_balance_wallet_rounded, Colors.deepPurple),
      _ => (Icons.receipt_long_rounded, Colors.blue.shade700),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF4E6), Color(0xFFFFE0B2)], // Warm peach gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.orange.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What you earned',
              style: GoogleFonts.inter(
                  color: Colors.orange.shade800,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${_fareRupee(lastRide!)}',
                    style: GoogleFonts.interTight(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        letterSpacing: -1),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      _durationDistanceLine(lastRide!),
                      style: GoogleFonts.inter(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: payColor.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(payIcon, color: payColor, size: 22),
                      const SizedBox(height: 2),
                      Text(
                        _paymentLabel(lastRide!),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.interTight(
                            color: payColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            height: 1.1),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 20, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _fareReceivedLine(lastRide!),
                    style: GoogleFonts.inter(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRouteInfoCard() {
    final r = lastRide!;
    if (!_hasRouteDetails(r)) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded,
                color: Colors.grey.shade600, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pickup and drop addresses are not included in this summary. Open trip history for full route details.',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.35,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    String pickup = r['pickupAddress'] ??
        r['pickup_address'] ??
        r['pickup_location_address'] ??
        r['from'] ??
        'Pickup not recorded';
    String drop = r['dropAddress'] ??
        r['drop_address'] ??
        r['drop_location_address'] ??
        r['to'] ??
        'Drop not recorded';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trip Route',
              style: GoogleFonts.interTight(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 24),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Beautiful Timeline
                Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.primary, width: 3)),
                    ),
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.success, width: 3)),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Addresses
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pickup',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(pickup,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4)),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Drop-off',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(drop,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4)),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

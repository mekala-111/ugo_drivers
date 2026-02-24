import '/constants/app_colors.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/api_requests/api_calls.dart' show DriverRideHistoryCall;
import '/index.dart';
import '/repositories/driver_repository.dart';
import 'history_model.dart';
import '../models/ride_history_item.dart';
export 'history_model.dart';

// --- Custom Animation Widget ---
class FadeInAndSlide extends StatelessWidget {
  final Widget child;
  final int index;

  const FadeInAndSlide({super.key, required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      // Stagger the animation based on the list index
      duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 600)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)), // Slides up 50px
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

/// Past Booking History List
class HistoryWidget extends StatefulWidget {
  const HistoryWidget({super.key});

  static String routeName = 'History';
  static String routePath = '/history';

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  late HistoryModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  String? _error;
  List<dynamic> _rides = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HistoryModel());
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await DriverRepository.instance.getRideHistory(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );
      if (res.succeeded) {
        final data = DriverRideHistoryCall.rides(res.jsonBody);
        final parsed = data
            .whereType<Map<String, dynamic>>()
            .map((m) => RideHistoryItem.fromJson(m))
            .toList();
        setState(() {
          _rides = parsed;
        });
      } else {
        setState(() {
          _error = 'Failed to load history';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF5F7FA), // Soft light background
        appBar: AppBar(
          backgroundColor: AppColors.primary, // Vibrant Ugo Orange
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Row(
            children: [
              FlutterFlowIconButton(
                borderRadius: 20.0,
                buttonSize: 40.0,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24.0,
                ),
                onPressed: () async => context.safePop(),
              ),
              const SizedBox(width: 8),
              Text(
                FFLocalizations.of(context).getText('b5u7cma8' /* History */),
                style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Top Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    FFLocalizations.of(context).getText('c0vu40lh'), // e.g., "Past Bookings"
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: _loadHistory,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.refresh, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _error != null
                  ? _buildErrorState()
                  : _rides.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                onRefresh: _loadHistory,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  itemCount: _rides.length,
                  itemBuilder: (context, index) {
                    final ride = _rides[index] as RideHistoryItem;
                    return FadeInAndSlide(
                      index: index,
                      child: _HistoryRideCard(
                        ride: ride,
                        onViewPressed: () {
                          context.pushNamed(RideOverviewWidget.routeName);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  FFLocalizations.of(context).getText('hist0001'),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            _error!,
            style: GoogleFonts.inter(color: Colors.grey.shade800),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHistory,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Try Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _HistoryRideCard extends StatelessWidget {
  const _HistoryRideCard({
    required this.ride,
    this.onViewPressed,
  });

  final RideHistoryItem ride;
  final VoidCallback? onViewPressed;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(ride.date);
    final pickup = ride.pickupAddress.isNotEmpty ? ride.pickupAddress : 'Unknown Location';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Date & Fare
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '₹${ride.fare.toStringAsFixed(2)}',
                  style: GoogleFonts.interTight(
                    color: AppColors.success, // Vibrant Green
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),

            // Row 2: Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline Dot
                Column(
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Address Text
                Expanded(
                  child: Text(
                    pickup,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.black87,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Row 3: Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Optional Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Completed',
                    style: GoogleFonts.inter(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // View Details Button
                InkWell(
                  onTap: onViewPressed ?? () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightBg, // Soft orange background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      FFLocalizations.of(context).getText('8rlnckeh'), // 'View Details'
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '/backend/api_requests/api_calls.dart'
    show DriverAppHistoryCall, DriverRideHistoryCall;
import '/index.dart';
import '/models/driver_history_dto.dart';
import 'history_model.dart';
export 'history_model.dart';

/// Trip history — uses privacy-safe `/api/drivers/app/history` (no rider phone).
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
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _loadingMore = false;
  String? _error;
  final List<DriverHistoryDto> _items = [];
  int _page = 1;
  bool _hasMore = true;
  int _totalCount = 0;
  bool _usedLegacyApi = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HistoryModel());
    _scrollController.addListener(_onScroll);
    _loadHistory(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _isLoading) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 280) {
      _loadMore();
    }
  }

  List<DriverHistoryDto> _mapLegacyRides(List<dynamic> raw) {
    final out = <DriverHistoryDto>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      out.add(
        DriverHistoryDto.fromJson({
          'ride_id': m['rideId'] ?? m['ride_id'] ?? m['id'],
          'ride_type': m['ride_type'] ?? m['rideType'] ?? 'ride',
          'rider_name': 'Rider',
          'pickup_area': m['from'] ??
              m['pickup_location_address'] ??
              m['pickup_address'] ??
              '',
          'drop_area':
              m['to'] ?? m['drop_location_address'] ?? m['drop_address'] ?? '',
          'fare': m['amount'] ?? m['fare'] ?? 0,
          'payment_method': m['payment_method'] ?? m['paymentMode'],
          'status': (m['status'] ?? 'completed').toString().toLowerCase(),
          'trip_date': m['date'] ??
              m['ride_end_time'] ??
              m['completedAt'] ??
              m['created_at'],
          'distance_km': m['ride_distance_km'] ?? m['distance_km'],
          'duration_minutes': m['actual_duration_minutes'] ?? m['durationMinutes'],
          'duration_label': m['duration']?.toString(),
        }),
      );
    }
    return out;
  }

  Future<void> _loadHistory({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _page = 1;
        _hasMore = true;
        _items.clear();
        _usedLegacyApi = false;
      });
    }

    final token = FFAppState().accessToken;
    if (token.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Please sign in again.';
        });
      }
      return;
    }

    try {
      final res = await DriverAppHistoryCall.call(
        token: token,
        page: 1,
        pageSize: 20,
      );

      if (res.succeeded) {
        final list = DriverAppHistoryCall.items(res.jsonBody);
        final parsed = list
            .whereType<Map>()
            .map((m) => DriverHistoryDto.fromJson(Map<String, dynamic>.from(m)))
            .toList();
        if (mounted) {
          setState(() {
            _items
              ..clear()
              ..addAll(parsed);
            _totalCount = DriverAppHistoryCall.totalCount(res.jsonBody) ?? parsed.length;
            _hasMore = DriverAppHistoryCall.hasMore(res.jsonBody);
            _page = 1;
            _error = null;
            _isLoading = false;
          });
        }
        return;
      }

      // Fallback when new endpoints are not deployed yet
      final legacy = await DriverRideHistoryCall.call(
        token: token,
        id: FFAppState().driverid,
      );
      if (legacy.succeeded) {
        final raw = DriverRideHistoryCall.rides(legacy.jsonBody);
        final parsed = _mapLegacyRides(raw);
        if (mounted) {
          setState(() {
            _items
              ..clear()
              ..addAll(parsed);
            _totalCount = parsed.length;
            _hasMore = false;
            _usedLegacyApi = true;
            _page = 1;
            _error = null;
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _error = 'Could not load trip history';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_usedLegacyApi || !_hasMore || _loadingMore) return;
    final token = FFAppState().accessToken;
    if (token.isEmpty) return;

    setState(() => _loadingMore = true);
    try {
      final next = _page + 1;
      final res = await DriverAppHistoryCall.call(
        token: token,
        page: next,
        pageSize: 20,
      );
      if (res.succeeded && mounted) {
        final list = DriverAppHistoryCall.items(res.jsonBody);
        final parsed = list
            .whereType<Map>()
            .map((m) => DriverHistoryDto.fromJson(Map<String, dynamic>.from(m)))
            .toList();
        setState(() {
          _items.addAll(parsed);
          _page = next;
          _hasMore = DriverAppHistoryCall.hasMore(res.jsonBody);
          _totalCount =
              DriverAppHistoryCall.totalCount(res.jsonBody) ?? _items.length;
        });
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Row(
            children: [
              FlutterFlowIconButton(
                borderRadius: 20.0,
                buttonSize: 48.0,
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                onPressed: () async => context.safePop(),
              ),
              const SizedBox(width: 4),
              Text(
                FFLocalizations.of(context).getText('b5u7cma8' /* History */),
                style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your trips',
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLoading
                        ? 'Loading…'
                        : _totalCount > 0
                            ? '$_totalCount trips on record'
                            : 'No trips yet',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_usedLegacyApi) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Update the app server for full privacy mode & pagination.',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => _loadHistory(reset: true),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          ...List.generate(5, (_) => _shimmerCard()),
        ],
      );
    }
    if (_error != null && _items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
          Icon(Icons.error_outline, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: FilledButton(
              onPressed: () => _loadHistory(reset: true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              child: const Text('Try again'),
            ),
          ),
        ],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.22),
          Icon(Icons.route_rounded, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Center(
            child: Text(
              FFLocalizations.of(context).getText('hist0001'),
              style: GoogleFonts.inter(
                fontSize: 17,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _CaptainHistoryCard(
            trip: _items[index],
            onOpen: () {
              context.pushNamed(
                RideOverviewWidget.routeName,
                queryParameters: {
                  'rideId': _items[index].rideId.toString(),
                  'hideRiderContact': 'true',
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _shimmerCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 168,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _CaptainHistoryCard extends StatelessWidget {
  const _CaptainHistoryCard({
    required this.trip,
    required this.onOpen,
  });

  final DriverHistoryDto trip;
  final VoidCallback onOpen;

  static Color _statusColor(String s) {
    if (s == 'cancelled') return const Color(0xFFE53935);
    if (s == 'completed') return const Color(0xFF2E7D32);
    return Colors.blueGrey;
  }

  static Color _payColor(String? p) {
    final x = (p ?? '').toLowerCase();
    if (x == 'cash') return const Color(0xFFEF6C00);
    if (x == 'online') return const Color(0xFF2E7D32);
    if (x == 'wallet') return const Color(0xFF6A1B9A);
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    final dt = trip.tripDate;
    final dateStr =
        DateFormat('EEE, MMM d • h:mm a').format(dt);
    final statusColor = _statusColor(trip.status);
    final payColor = _payColor(trip.paymentMethod);
    final payLabel = (trip.paymentMethod ?? '—').toUpperCase();

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${trip.fare.toStringAsFixed(trip.fare == trip.fare.roundToDouble() ? 0 : 2)}',
                          style: GoogleFonts.interTight(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                            height: 1.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          trip.status,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: payColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          payLabel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: payColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.two_wheeler_rounded,
                      size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    (trip.rideType ?? 'Trip').toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  if (trip.distanceKm != null)
                    Text(
                      '${trip.distanceKm!.toStringAsFixed(1)} km',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  if (trip.durationLabel != null ||
                      trip.durationMinutes != null) ...[
                    Text(
                      ' • ',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    Text(
                      trip.durationLabel ??
                          '${trip.durationMinutes} min',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              _dotLine(Icons.circle, AppColors.primary, (trip.pickupArea ?? 'Pickup').trim().isEmpty ? 'Pickup' : trip.pickupArea!),
              const SizedBox(height: 10),
              _dotLine(Icons.flag_rounded, const Color(0xFF2E7D32), (trip.dropArea ?? 'Drop').trim().isEmpty ? 'Drop' : trip.dropArea!),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline_rounded,
                      size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      trip.riderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    'Details',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.primary, size: 22),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dotLine(IconData icon, Color c, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

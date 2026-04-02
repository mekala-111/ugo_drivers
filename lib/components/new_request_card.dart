import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/constants/responsive.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import 'package:ugo_driver/models/payment_mode.dart';
import 'package:ugo_driver/services/location_geocode_service.dart';
import 'package:ugo_driver/services/route_distance_service.dart';
import '../home/ride_request_model.dart';

class NewRequestCard extends StatefulWidget {
  final RideRequest ride;
  final int remainingTime;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final LatLng? driverLocation;
  final bool isLoading;

  const NewRequestCard({
    super.key,
    required this.ride,
    required this.remainingTime,
    this.onAccept,
    this.onDecline,
    this.driverLocation,
    this.isLoading = false,
  });

  // --- Colors ---
  static const Color ugoOrange = AppColors.primary;
  static const Color ugoGreen = AppColors.success;
  static const Color ugoRed = AppColors.error;
  static const Color ugoBlue = AppColors.infoDark;

  /// Compute pickup distance from driver to pickup (km).
  static double? _pickupDistanceKm(LatLng? driver, RideRequest ride) {
    if (driver == null || ride.pickupLat == 0 || ride.pickupLng == 0) {
      return null;
    }
    final m = Geolocator.distanceBetween(
      driver.latitude,
      driver.longitude,
      ride.pickupLat,
      ride.pickupLng,
    );
    return m / 1000;
  }

  /// Compute drop distance from pickup to drop (km).
  static double? _dropDistanceKm(RideRequest ride) {
    if (ride.pickupLat == 0 ||
        ride.pickupLng == 0 ||
        ride.dropLat == 0 ||
        ride.dropLng == 0) {
      return null;
    }
    final m = Geolocator.distanceBetween(
      ride.pickupLat,
      ride.pickupLng,
      ride.dropLat,
      ride.dropLng,
    );
    return m / 1000;
  }

  static String _formatDistance(double? km) {
    if (km == null) {
      return '--';
    }
    final normalizedKm = km > 0 && km < 0.1 ? 0.1 : km;
    return '${normalizedKm.toStringAsFixed(1)}Km';
  }

  @override
  State<NewRequestCard> createState() => _NewRequestCardState();
}

class _NewRequestCardState extends State<NewRequestCard> {
  int? _distancesRideId;
  LatLng? _driverSnapForRoadKm;
  Future<double?>? _pickupRoadFuture;
  Future<double?>? _dropRoadFuture;

  void _syncRoadDistanceFutures() {
    final ride = widget.ride;
    if (_distancesRideId != ride.id) {
      _distancesRideId = ride.id;
      _driverSnapForRoadKm = null;
      _pickupRoadFuture = null;
      _dropRoadFuture = null;
    }
    if (_driverSnapForRoadKm == null && widget.driverLocation != null) {
      _driverSnapForRoadKm = widget.driverLocation;
    }
    if (_pickupRoadFuture == null &&
        _driverSnapForRoadKm != null &&
        ride.pickupLat != 0 &&
        ride.pickupLng != 0) {
      final d = _driverSnapForRoadKm!;
      _pickupRoadFuture = RouteDistanceService().getDrivingDistanceKm(
        originLat: d.latitude,
        originLng: d.longitude,
        destLat: ride.pickupLat,
        destLng: ride.pickupLng,
      );
    }
    if (_dropRoadFuture == null &&
        ride.pickupLat != 0 &&
        ride.pickupLng != 0 &&
        ride.dropLat != 0 &&
        ride.dropLng != 0) {
      _dropRoadFuture = RouteDistanceService().getDrivingDistanceKm(
        originLat: ride.pickupLat,
        originLng: ride.pickupLng,
        destLat: ride.dropLat,
        destLng: ride.dropLng,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncRoadDistanceFutures();
    final ride = widget.ride;
    final margin =
        Responsive.value(context, small: 8.0, medium: 10.0, large: 12.0);
    final pad = Responsive.horizontalPadding(context);
    final isNarrow = MediaQuery.sizeOf(context).width < 360;
    final isPro = ride.bookingMode == 'pro';

    final gapSm = MediaQuery.sizeOf(context).height * 0.012;
    final gapMd = MediaQuery.sizeOf(context).height * 0.018;

    // Rapido-style: last 10s of the 30s offer window feels urgent.
    final urgent = widget.remainingTime <= 10 && widget.remainingTime > 0;
    final headerBg = urgent
        ? const Color(0xFFE53935)
        : (isPro ? const Color(0xFFE3CA43) : const Color(0xFF4CAF50));
    final headerFg =
        urgent ? Colors.white : (isPro ? Colors.black : Colors.white);

    final header = Container(
      padding: EdgeInsets.symmetric(
          horizontal: pad, vertical: Responsive.verticalSpacing(context)),
      decoration: BoxDecoration(
          color: headerBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              urgent
                  ? (isPro ? 'PRO — HURRY' : 'EXPIRING SOON')
                  : (isPro ? 'NEW PRO REQUEST' : 'NEW REQUEST'),
              style: TextStyle(
                  color: headerFg,
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.fontSize(context, 16))),
          Text('${widget.remainingTime}s',
              style: TextStyle(
                  color: headerFg,
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.fontSize(context, 16))),
        ],
      ),
    );

    final middle = Padding(
      padding: EdgeInsets.all(pad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isNarrow)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPickupDistanceInfo(
                      context,
                      FFLocalizations.of(context)
                          .getText('drv_pickup_distance'),
                      ride,
                    ),
                    _buildDropDistanceInfo(
                      context,
                      FFLocalizations.of(context).getText('drv_drop_distance'),
                      ride,
                    ),
                  ],
                ),
                SizedBox(height: gapSm),
                _buildFareBox(context),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPickupDistanceInfo(
                  context,
                  FFLocalizations.of(context).getText('drv_pickup_distance'),
                  ride,
                ),
                Expanded(child: _buildFareBox(context)),
                _buildDropDistanceInfo(
                  context,
                  FFLocalizations.of(context).getText('drv_drop_distance'),
                  ride,
                ),
              ],
            ),
          SizedBox(height: gapMd),
          _AddressRowFromLatLng(
            lat: ride.dropLat,
            lng: ride.dropLng,
            address: ride.dropAddress,
            color: NewRequestCard.ugoRed,
            label: FFLocalizations.of(context).getText('drv_drop'),
          ),
          SizedBox(height: Responsive.verticalSpacing(context)),
          _AddressRowFromLatLng(
            lat: ride.pickupLat,
            lng: ride.pickupLng,
            address: ride.pickupAddress,
            color: NewRequestCard.ugoGreen,
            label: FFLocalizations.of(context).getText('drv_pickup'),
          ),
        ],
      ),
    );

    final actions = Padding(
      padding: EdgeInsets.fromLTRB(pad, 0, pad, pad),
      child: Row(
        children: [
          Expanded(
              child: _buildButton(
                  context,
                  FFLocalizations.of(context)
                      .getText('drv_decline')
                      .toUpperCase(),
                  const Color(0xFFF7220F),
                  widget.isLoading ? null : widget.onDecline,
                  isPro: false)),
          SizedBox(width: MediaQuery.sizeOf(context).width * 0.04),
          Expanded(
              child: widget.isLoading
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(
                            MediaQuery.sizeOf(context).width * 0.03),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.06,
                          height: MediaQuery.sizeOf(context).width * 0.06,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isPro
                                ? const Color(0xFFE3CA43)
                                : const Color(0xFF3C9A40),
                          ),
                        ),
                      ),
                    )
                  : _buildButton(
                      context,
                      FFLocalizations.of(context)
                          .getText('drv_accept')
                          .toUpperCase(),
                      isPro ? const Color(0xFFE3CA43) : const Color(0xFF3C9A40),
                      widget.onAccept,
                      isPro: isPro)),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final bounded = h.isFinite && h < double.infinity;

        return Container(
          margin: EdgeInsets.all(margin),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
            ],
            border: Border.all(
                color:
                    isPro ? const Color(0xFFE3CA43) : NewRequestCard.ugoOrange,
                width: 2),
          ),
          child: bounded
              ? Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        child: middle,
                      ),
                    ),
                    actions,
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    middle,
                    actions,
                  ],
                ),
        );
      },
    );
  }

  Widget _buildDistanceInfo(BuildContext context, String label, String value,
      {bool alignRight = false}) {
    return Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: Responsive.fontSize(context, 12))),
          Text(value,
              style: TextStyle(
                  color: NewRequestCard.ugoBlue,
                  fontSize: Responsive.fontSize(context, 20),
                  fontWeight: FontWeight.bold))
        ]);
  }

  Widget _buildFareBox(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(height: 1, color: Colors.grey[300]),
        const Icon(Icons.arrow_forward, size: 16),
        Padding(
          padding: EdgeInsets.only(
            bottom:
                (MediaQuery.sizeOf(context).height * 0.015).clamp(6.0, 16.0),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width * 0.03,
              vertical: MediaQuery.sizeOf(context).height * 0.01,
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!)),
            child: Column(children: [
              Text(FFLocalizations.of(context).getText('ride0006'),
                  style: TextStyle(color: Colors.grey[400], fontSize: 10)),
              Text('₹${widget.ride.estimatedFare?.toInt() ?? 80}',
                  style: const TextStyle(
                      color: NewRequestCard.ugoBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.ride.paymentMode.isCash
                      ? Colors.green.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: widget.ride.paymentMode.isCash
                        ? Colors.green.shade200
                        : Colors.blue.shade200,
                  ),
                ),
                child: Text(
                  widget.ride.rawPaymentMode.toUpperCase(),
                  style: TextStyle(
                    color: widget.ride.paymentMode.isCash
                        ? Colors.green.shade700
                        : Colors.blue.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  /// Driver → pickup: Google Maps **driving** road distance first; then server; then straight-line.
  Widget _buildPickupDistanceInfo(
    BuildContext context,
    String label,
    RideRequest ride,
  ) {
    if (widget.driverLocation == null ||
        ride.pickupLat == 0 ||
        ride.pickupLng == 0) {
      final serverKm = ride.driverPickupDistanceKm;
      if (serverKm != null && serverKm >= 0) {
        return _buildDistanceInfo(
            context, label, NewRequestCard._formatDistance(serverKm));
      }
      return _buildDistanceInfo(
          context, label, NewRequestCard._formatDistance(null));
    }

    final pickupFut = _pickupRoadFuture;
    if (pickupFut == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: Responsive.fontSize(context, 12))),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: NewRequestCard.ugoBlue.withValues(alpha: 0.5),
            ),
          ),
        ],
      );
    }

    return FutureBuilder<double?>(
      future: pickupFut,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: Responsive.fontSize(context, 12))),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: NewRequestCard.ugoBlue.withValues(alpha: 0.5),
                ),
              ),
            ],
          );
        }

        double? km = snapshot.data;
        if (km == null || km == 0) {
          km = ride.driverPickupDistanceKm;
        }
        if (km == null || km == 0) {
          km = NewRequestCard._pickupDistanceKm(
              _driverSnapForRoadKm ?? widget.driverLocation, ride);
        }

        return _buildDistanceInfo(
          context,
          label,
          NewRequestCard._formatDistance(km),
        );
      },
    );
  }

  Widget _buildDropDistanceInfo(
    BuildContext context,
    String label,
    RideRequest ride,
  ) {
    // Trip leg only: pickup → drop (not driver → drop).
    if (ride.pickupLat == 0 ||
        ride.pickupLng == 0 ||
        ride.dropLat == 0 ||
        ride.dropLng == 0) {
      return _buildDistanceInfo(
          context, label, NewRequestCard._formatDistance(null),
          alignRight: true);
    }

    final dropFut = _dropRoadFuture;
    if (dropFut == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: Responsive.fontSize(context, 12))),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: NewRequestCard.ugoBlue.withValues(alpha: 0.5),
            ),
          ),
        ],
      );
    }

    return FutureBuilder<double?>(
      future: dropFut,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: Responsive.fontSize(context, 12))),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: NewRequestCard.ugoBlue.withValues(alpha: 0.5),
                ),
              ),
            ],
          );
        }

        double? km = snapshot.data;
        if (km == null || km == 0) {
          km = NewRequestCard._dropDistanceKm(ride);
        }

        return _buildDistanceInfo(
          context,
          label,
          NewRequestCard._formatDistance(km),
          alignRight: true,
        );
      },
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Color bg, VoidCallback? onTap,
      {bool isPro = false}) {
    final btnH = Responsive.buttonHeight(context, base: 48);
    return SizedBox(
      height: btnH,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPro
                ? Colors.white
                : Colors.white, // You can customize text color here
            fontWeight: FontWeight.bold,
            fontSize: Responsive.fontSize(context, 16),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

Widget _buildHighlightedAddressText({
  required String address,
  required String? highlightSegment,
  required TextStyle style,
}) {
  if (highlightSegment == null || highlightSegment.trim().isEmpty) {
    return Text(
      address,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }

  final normalizedAddress = address.toLowerCase();
  final normalizedHighlight = highlightSegment.toLowerCase();
  final matchIndex = normalizedAddress.indexOf(normalizedHighlight);

  if (matchIndex < 0) {
    return Text(
      address,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }

  final matchEnd = matchIndex + highlightSegment.length;

  return Text.rich(
    TextSpan(
      style: style,
      children: [
        if (matchIndex > 0) TextSpan(text: address.substring(0, matchIndex)),
        TextSpan(
          text: address.substring(matchIndex, matchEnd),
          style: style.copyWith(
              fontWeight: FontWeight.w800, color: Colors.black87),
        ),
        if (matchEnd < address.length)
          TextSpan(text: address.substring(matchEnd)),
      ],
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}

/// Rapido-style: area name highlighted with entrance animations.
class _AddressRowFromLatLng extends StatefulWidget {
  final double lat;
  final double lng;
  final String address;
  final Color color;
  final String label;

  const _AddressRowFromLatLng({
    required this.lat,
    required this.lng,
    required this.address,
    required this.color,
    required this.label,
  });

  @override
  State<_AddressRowFromLatLng> createState() => _AddressRowFromLatLngState();
}

class _AddressRowFromLatLngState extends State<_AddressRowFromLatLng>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boxSz =
        Responsive.value(context, small: 42.0, medium: 45.0, large: 48.0);
    return FutureBuilder(
      future: (widget.lat != 0 || widget.lng != 0)
          ? LocationGeocodeService()
              .getPincodeAndLocality(widget.lat, widget.lng)
          : Future.value((pincode: '', locality: '')),
      builder: (context, snapshot) {
        final code = snapshot.data?.pincode ?? '';
        final locality = snapshot.data?.locality ?? '';
        final areaName = locality.isNotEmpty
            ? locality
            : widget.address.split(',').firstOrNull?.trim() ?? widget.address;
        final highlightSegment =
            LocationGeocodeService().getAddressHighlightSegment(widget.address);
        if (snapshot.hasData &&
            !_animController.isAnimating &&
            !_animController.isCompleted) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _animController.forward());
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: boxSz,
              height: boxSz,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: widget.color.withValues(alpha: 0.5)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on,
                      color: widget.color,
                      size: Responsive.iconSize(context, base: 20)),
                  Text(
                    widget.label,
                    style: TextStyle(
                        fontSize: Responsive.fontSize(context, 10),
                        color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(width: Responsive.verticalSpacing(context)),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (code.isNotEmpty)
                        Text(
                          code,
                          style: TextStyle(
                            color: NewRequestCard.ugoOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.fontSize(context, 13),
                            letterSpacing: 0.5,
                          ),
                        ),
                      const SizedBox(height: 6),
                      _HighlightedAreaChip(
                        areaName: areaName,
                        color: widget.color,
                      ),
                      const SizedBox(height: 6),
                      _buildHighlightedAddressText(
                        address: widget.address,
                        highlightSegment: highlightSegment,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: Responsive.fontSize(context, 12),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Rapido-style highlighted area chip with pulse animation.
class _HighlightedAreaChip extends StatefulWidget {
  final String areaName;
  final Color color;

  const _HighlightedAreaChip({
    required this.areaName,
    required this.color,
  });

  @override
  State<_HighlightedAreaChip> createState() => _HighlightedAreaChipState();
}

class _HighlightedAreaChipState extends State<_HighlightedAreaChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnim,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: widget.color.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place, color: widget.color, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                widget.areaName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: widget.color,
                  fontWeight: FontWeight.w800,
                  fontSize: Responsive.fontSize(context, 15),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

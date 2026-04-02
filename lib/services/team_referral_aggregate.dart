import '/backend/api_requests/api_calls.dart';

/// Single load of dashboard + earnings + Pro referral V2 for team screens.
/// Does not expose referred-driver phone numbers in maps returned for UI.
class TeamReferralSnapshot {
  TeamReferralSnapshot({
    required this.dashboardBody,
    required this.earningsBody,
    required this.proMyBody,
    required this.proDailyBody,
    required this.proHistoryDriverRows,
    required this.proHistoryCompanyRows,
  });

  final Map<String, dynamic>? dashboardBody;
  final Map<String, dynamic>? earningsBody;
  final Map<String, dynamic>? proMyBody;
  final Map<String, dynamic>? proDailyBody;
  final List<dynamic> proHistoryDriverRows;
  final List<dynamic> proHistoryCompanyRows;

  String? get proReferralCode {
    if (proMyBody == null) return null;
    return DriverProReferralMyCall.referralCode(proMyBody);
  }

  int get proMyTotalFromApi =>
      proMyBody != null ? DriverProReferralMyCall.totalReferrals(proMyBody) : 0;

  List<Map<String, dynamic>> get todayLiveReferrals => _stripPhonesFromList(
      _listMap(_readList(dashboardBody, ['today_live', 'referrals'])));

  List<Map<String, dynamic>> get yesterdayReferrals =>
      _stripPhonesFromList(_listMap(
          _readList(dashboardBody, ['yesterday_statistics', 'referrals'])));

  /// Every referred captain we know about (today row wins, then yesterday, then Pro roster).
  List<Map<String, dynamic>> get mergedTeamMembers {
    final byId = <int, Map<String, dynamic>>{};

    void mergeIn(Map<String, dynamic> raw, {bool fromYesterday = false}) {
      final id = _driverId(raw);
      if (id == null) return;
      final m = _stripPhone(Map<String, dynamic>.from(raw));
      if (!byId.containsKey(id)) {
        byId[id] = m;
        return;
      }
      if (fromYesterday) return;
      final cur = byId[id]!;
      _preferLarger(cur, m, 'pro_rides_completed');
      _preferLarger(cur, m, 'normal_rides_completed');
      _preferLarger(cur, m, 'commission_earned');
      _preferLarger(cur, m, 'commission_earned_by_72');
      _copyIfEmpty(cur, m, 'vehicle_number');
      _copyIfEmpty(cur, m, 'matched_rides_now');
      _copyIfEmpty(cur, m, 'additional_rides_needed_to_match');
      _copyIfEmpty(cur, m, 'amount_per_pro_ride');
    }

    for (final m in todayLiveReferrals) {
      mergeIn(m);
    }
    for (final m in yesterdayReferrals) {
      mergeIn(m, fromYesterday: true);
    }

    final proList = proMyBody != null
        ? DriverProReferralMyCall.referrals(proMyBody)
        : <dynamic>[];
    for (final e in proList) {
      if (e is! Map) continue;
      final p = Map<String, dynamic>.from(e);
      p.remove('mobile_number');
      final id = _driverId(p);
      if (id == null) continue;
      if (!byId.containsKey(id)) {
        byId[id] = {
          'driver_id': id,
          'name': (p['name'] ?? 'Captain').toString(),
          'vehicle_number': null,
          'pro_rides_completed': 0,
          'normal_rides_completed': 0,
          'commission_earned': 0,
          'commission_earned_by_72': 0,
          'amount_per_pro_ride': p['amount_per_pro_ride'],
          'matched_rides_now': 0,
          'additional_rides_needed_to_match': 0,
        };
      } else {
        final cur = byId[id]!;
        if ((cur['amount_per_pro_ride'] == null ||
                _asNum(cur['amount_per_pro_ride']) == 0) &&
            p['amount_per_pro_ride'] != null) {
          cur['amount_per_pro_ride'] = p['amount_per_pro_ride'];
        }
      }
    }

    _applyFriendsProDailyToMap(byId);
    final out = byId.values.toList();
    out.sort((a, b) {
      final na = (a['name'] ?? '').toString().toLowerCase();
      final nb = (b['name'] ?? '').toString().toLowerCase();
      return na.compareTo(nb);
    });
    return out;
  }

  /// Merge [friends_pro_rides_by_pair] into today's referral rows (by driver_id).
  void applyDailyProToRows(List<Map<String, dynamic>> rows) {
    _applyFriendsProDailyToIterable(rows);
  }

  void _applyFriendsProDailyToMap(Map<int, Map<String, dynamic>> byId) {
    _applyFriendsProDailyToIterable(byId.values);
  }

  void _applyFriendsProDailyToIterable(Iterable<Map<String, dynamic>> rows) {
    final daily = proDailyBody;
    if (daily == null) return;
    final friends = daily['friends_pro_rides_by_pair'];
    if (friends is! List) return;
    for (final f in friends) {
      if (f is! Map) continue;
      final rid = (f['referred_driver_id'] as num?)?.toInt();
      if (rid == null) continue;
      final pr = (f['referred_pro_rides'] as num?)?.toInt() ?? 0;
      for (final row in rows) {
        if (_driverId(row) != rid) continue;
        final cur = (row['pro_rides_completed'] as num?)?.toInt() ?? 0;
        if (pr > cur) row['pro_rides_completed'] = pr;
      }
    }
  }

  static List<Map<String, dynamic>> _listMap(List<dynamic> raw) {
    return raw
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  static List<dynamic> _readList(
      Map<String, dynamic>? root, List<String> path) {
    dynamic cur = root;
    for (final p in path) {
      if (cur is! Map) return [];
      cur = cur[p];
    }
    return cur is List ? cur : [];
  }

  static int? _driverId(Map<String, dynamic> m) {
    final v = m['driver_id'];
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '');
  }

  static void _preferLarger(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
    String key,
  ) {
    if (_asNum(b[key]) > _asNum(a[key])) a[key] = b[key];
  }

  static void _copyIfEmpty(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
    String key,
  ) {
    final av = a[key];
    if (av == null ||
        av.toString().isEmpty ||
        av == '—' ||
        (av is num && av == 0)) {
      if (b[key] != null) a[key] = b[key];
    }
  }

  static double _asNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static Map<String, dynamic> _stripPhone(Map<String, dynamic> m) {
    m.remove('mobile_number');
    return m;
  }

  static List<Map<String, dynamic>> _stripPhonesFromList(
    List<Map<String, dynamic>> list,
  ) {
    return list.map((e) => _stripPhone(Map<String, dynamic>.from(e))).toList();
  }
}

/// Parallel fetch for team / referral UIs.
Future<TeamReferralSnapshot> loadTeamReferralSnapshot({
  required String token,
  required int driverId,
}) async {
  final futures = await Future.wait([
    ReferralDashboardCall.call(token: token, driverId: driverId),
    ReferralEarningsCall.call(token: token, driverId: driverId),
    DriverProReferralMyCall.call(token: token),
    DriverProReferralDailyEarningsCall.call(token: token),
    DriverProReferralHistoryCall.call(token: token, limit: 40),
  ]);

  Map<String, dynamic>? asMapBody(ApiCallResponse r) {
    if (!r.succeeded || r.jsonBody is! Map) return null;
    return Map<String, dynamic>.from(r.jsonBody as Map);
  }

  final dash = asMapBody(futures[0]);
  final earn = asMapBody(futures[1]);
  final proMy = asMapBody(futures[2]);
  Map<String, dynamic>? proDaily;
  if (futures[3].succeeded) {
    final d = DriverProReferralDailyEarningsCall.data(futures[3].jsonBody);
    if (d is Map) proDaily = Map<String, dynamic>.from(d);
  }

  final histDriver = futures[4].succeeded
      ? DriverProReferralHistoryCall.driverEarnings(futures[4].jsonBody)
      : <dynamic>[];
  final histCompany = futures[4].succeeded
      ? DriverProReferralHistoryCall.companyEarnings(futures[4].jsonBody)
      : <dynamic>[];

  return TeamReferralSnapshot(
    dashboardBody: dash,
    earningsBody: earn,
    proMyBody: proMy,
    proDailyBody: proDaily,
    proHistoryDriverRows: histDriver,
    proHistoryCompanyRows: histCompany,
  );
}

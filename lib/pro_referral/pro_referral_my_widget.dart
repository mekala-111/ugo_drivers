import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '/app_state.dart';
import '/backend/api_requests/api_calls.dart';
import '/constants/app_colors.dart';
import '/constants/responsive.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Pro driver-to-driver referral stats (backend V2).
class ProReferralMyWidget extends StatefulWidget {
  const ProReferralMyWidget({super.key});

  static const String routeName = 'ProReferralMy';
  static const String routePath = '/proReferralMy';

  @override
  State<ProReferralMyWidget> createState() => _ProReferralMyWidgetState();
}

class _ProReferralMyWidgetState extends State<ProReferralMyWidget> {
  bool _loading = true;
  String? _error;
  List<dynamic> _referrals = [];
  String? _myCode;
  int _totalReferrals = 0;
  Map<String, dynamic>? _daily;
  List<dynamic> _histDriver = [];
  List<dynamic> _histCompany = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = FFAppState().accessToken;
    if (token.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Not logged in';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final my = await DriverProReferralMyCall.call(token: token);
      final daily = await DriverProReferralDailyEarningsCall.call(token: token);
      final hist = await DriverProReferralHistoryCall.call(token: token);
      if (!mounted) return;
      setState(() {
        if (my.succeeded) {
          _referrals = DriverProReferralMyCall.referrals(my.jsonBody);
          _myCode = DriverProReferralMyCall.referralCode(my.jsonBody);
          _totalReferrals = DriverProReferralMyCall.totalReferrals(my.jsonBody);
        } else {
          _error = my.bodyText.isNotEmpty ? my.bodyText : 'Failed to load referrals';
        }
        if (daily.succeeded) {
          final d = DriverProReferralDailyEarningsCall.data(daily.jsonBody);
          if (d is Map) {
            _daily = Map<String, dynamic>.from(d);
          }
        }
        if (hist.succeeded) {
          _histDriver = DriverProReferralHistoryCall.driverEarnings(hist.jsonBody);
          _histCompany = DriverProReferralHistoryCall.companyEarnings(hist.jsonBody);
        }
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _shareCode() async {
    final c = (_myCode ?? '').trim();
    if (c.isEmpty) return;
    await Share.share(
      'Join me on UGO Driver — use my Pro referral code: $c',
      subject: 'UGO Driver referral',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Pro ride referrals',
          style: GoogleFonts.interTight(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _referrals.isEmpty && _daily == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.all(Responsive.horizontalPadding(context)),
                    children: [
                      if (_myCode != null && _myCode!.isNotEmpty) ...[
                        _card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your referral code',
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: Colors.grey.shade700)),
                              const SizedBox(height: 8),
                              SelectableText(
                                _myCode!,
                                style: GoogleFonts.jetBrainsMono(
                                    fontSize: 22, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  FilledButton.icon(
                                    onPressed: () async {
                                      await Clipboard.setData(
                                          ClipboardData(text: _myCode!));
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text('Code copied')),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.copy, size: 18),
                                    label: const Text('Copy'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: _shareCode,
                                    icon: const Icon(Icons.share, size: 18),
                                    label: const Text('Share'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_daily != null) ...[
                        _card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today (${_daily!['date'] ?? '—'})',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              _statRow('Your Pro rides',
                                  '${_daily!['my_pro_rides_today'] ?? 0}'),
                              _statRow('Matched rides (total)',
                                  '${_daily!['matched_rides_total'] ?? 0}'),
                              _statRow('Your referral earnings',
                                  '₹${_daily!['my_referral_earnings_inr'] ?? 0}'),
                              _statRow('Friend Pro rides (sum on pairs)',
                                  '${_daily!['friends_pro_rides_sum_on_pairs'] ?? 0}'),
                              _statRow('Extra friend rides → company',
                                  '${_daily!['company_extra_rides_total'] ?? 0}'),
                              _statRow('Company amount (your pairs)',
                                  '₹${_daily!['company_amount_inr_total'] ?? 0}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My referrals ($_totalReferrals)',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            if (_referrals.isEmpty)
                              Text(
                                'No active referrals yet. Share your code with other drivers.',
                                style: GoogleFonts.inter(
                                    fontSize: 14, color: Colors.grey.shade700),
                              )
                            else
                              ..._referrals.map((r) {
                                final m = r is Map
                                    ? Map<String, dynamic>.from(r)
                                    : <String, dynamic>{};
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    m['name']?.toString().isNotEmpty == true
                                        ? '${m['name']}'
                                        : 'Driver #${m['driver_id']}',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    '${m['mobile_number'] ?? '—'} · ₹${m['amount_per_pro_ride'] ?? 10}/Pro ride',
                                    style: GoogleFonts.inter(fontSize: 12),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Recent wallet movements',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      if (_histDriver.isEmpty && _histCompany.isEmpty)
                        Text('No entries yet.',
                            style: GoogleFonts.inter(color: Colors.grey.shade600))
                      else ...[
                        ..._histDriver.take(8).map((e) => _ledgerTile(e, 'You')),
                        ..._histCompany.take(8).map((e) => _ledgerTile(e, 'Company')),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: GoogleFonts.inter(fontSize: 13)),
          ),
          Text(value,
              style:
                  GoogleFonts.interTight(fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _ledgerTile(dynamic row, String who) {
    final m = row is Map ? Map<String, dynamic>.from(row) : <String, dynamic>{};
    final amt = m['amount_inr'] ?? m['amount'] ?? '';
    final typ = m['entry_type'] ?? '';
    return ListTile(
      dense: true,
      title: Text('$who · $typ', style: GoogleFonts.inter(fontSize: 13)),
      subtitle: Text('${m['summary_date'] ?? ''} · ride ${m['ride_id'] ?? '—'}',
          style: GoogleFonts.inter(fontSize: 11)),
      trailing: Text('₹$amt',
          style: GoogleFonts.interTight(fontWeight: FontWeight.w600)),
    );
  }
}

import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/constants/app_colors.dart';
import '/repositories/driver_repository.dart';
import '/index.dart';

class PreferredCityWidget extends StatefulWidget {
  const PreferredCityWidget({super.key, this.isRegistrationFlow = false});

  final bool isRegistrationFlow;

  static String routeName = 'preferredCity';
  static String routePath = '/preferredCity';

  @override
  State<PreferredCityWidget> createState() => _PreferredCityWidgetState();
}

class _PreferredCityWidgetState extends State<PreferredCityWidget> {
  bool _loading = true;
  bool _saving = false;
  List<dynamic> _cities = [];
  int? _selectedCityId;
  String _selectedCityName = '';
  bool _requestingApproval = false;

  @override
  void initState() {
    super.initState();
    _selectedCityId = FFAppState().preferredCityId > 0
        ? FFAppState().preferredCityId
        : null;
    _selectedCityName = FFAppState().preferredCityName;
    _fetchCities();
  }

  bool get _isLocked =>
      !widget.isRegistrationFlow && FFAppState().preferredCityId > 0;

  Future<void> _fetchCities() async {
    setState(() => _loading = true);
    final res = await DriverRepository.instance.getActiveCities(
      token: FFAppState().accessToken,
    );
    if (!mounted) return;
    if (res.succeeded && res.jsonBody != null) {
      final list = res.jsonBody['data'];
      if (list is List) {
        _cities = list;
      } else {
        _cities = [];
      }
    } else {
      _cities = [];
    }
    setState(() => _loading = false);
  }

  Future<void> _requestApproval() async {
    if (_cities.isEmpty) {
      _showSnack('drv_no_cities', isError: true);
      return;
    }

    int? requestedCityId = _selectedCityId;

    final selected = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(FFLocalizations.of(context).getText('drv_request_approval')),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<int>(
                value: requestedCityId,
                decoration: InputDecoration(
                  labelText: FFLocalizations.of(context).getText('drv_select_city'),
                ),
                items: _cities.map<DropdownMenuItem<int>>((city) {
                  final id = city['id'] is int
                      ? city['id'] as int
                      : int.tryParse(city['id']?.toString() ?? '');
                  final name = city['name']?.toString() ?? '';
                  return DropdownMenuItem<int>(
                    value: id ?? -1,
                    child: Text(name.isNotEmpty ? name : 'City'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == null || val <= 0) return;
                  _cities.firstWhere(
                      (c) => c['id'].toString() == val.toString(),
                      orElse: () => null);
                  setState(() {
                    requestedCityId = val;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(FFLocalizations.of(context).getText('drv_cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(FFLocalizations.of(context).getText('drv_send_request')),
            ),
          ],
        );
      },
    );

    if (selected != true) return;
    if (requestedCityId == null || requestedCityId! <= 0) {
      _showSnack('drv_select_city', isError: true);
      return;
    }
    if (requestedCityId == FFAppState().preferredCityId) {
      _showSnack('drv_request_same_city', isError: true);
      return;
    }

    setState(() => _requestingApproval = true);
    final res = await DriverRepository.instance.requestPreferredCityApproval(
      token: FFAppState().accessToken,
      requestedCityId: requestedCityId!,
    );
    if (!mounted) return;
    setState(() => _requestingApproval = false);

    if (res.succeeded) {
      _showSnack('drv_request_sent', isError: false);
    } else {
      final msg = getJsonField(res.jsonBody ?? {}, r'$.message')?.toString();
      if (msg != null && msg.isNotEmpty) {
        _showSnack(msg, isError: true);
      } else {
        _showSnack('drv_request_failed', isError: true);
      }
    }
  }

  Future<void> _saveCity() async {
    if (_selectedCityId == null || _selectedCityId! <= 0) {
      _showSnack('drv_select_preferred_city', isError: true);
      return;
    }
    if (widget.isRegistrationFlow || FFAppState().accessToken.isEmpty) {
      FFAppState().preferredCityId = _selectedCityId!;
      FFAppState().preferredCityName = _selectedCityName;
      if (mounted) {
        context.pushNamed(
          PreferredEarningModeWidget.routeName,
          extra: const TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.rightToLeft,
            duration: Duration(milliseconds: 300),
          ),
        );
      }
      return;
    }
    setState(() => _saving = true);
    final res = await DriverRepository.instance.setPreferredCity(
      token: FFAppState().accessToken,
      cityId: _selectedCityId!,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (res.succeeded) {
      FFAppState().preferredCityId = _selectedCityId!;
      FFAppState().preferredCityName = _selectedCityName;
      _showSnack('drv_city_saved', isError: false);
      Navigator.pop(context, true);
    } else {
      final msg = getJsonField(res.jsonBody ?? {}, r'$.message')?.toString();
      if (msg != null && msg.isNotEmpty) {
        _showSnack(msg, isError: true);
      } else {
        _showSnack('drv_city_failed', isError: true);
      }
    }
  }

  void _showSnack(String key, {bool isError = false}) {
    final localized = FFLocalizations.of(context).getText(key);
    final message = localized.isNotEmpty ? localized : key;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(FFLocalizations.of(context).getText('drv_preferred_city')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLocked)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.sectionOrange,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.accentAmber),
                      ),
                      child: Text(
                        FFLocalizations.of(context).getText('drv_preferred_city_locked'),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  Text(
                    FFLocalizations.of(context).getText('drv_select_city'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_cities.isEmpty)
                    Text(
                      FFLocalizations.of(context).getText('drv_no_cities'),
                      style: const TextStyle(color: Colors.grey),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: _cities.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final city = _cities[index];
                          final id = city['id'] is int
                              ? city['id'] as int
                              : int.tryParse(city['id']?.toString() ?? '');
                          final name = city['name']?.toString() ?? '';
                          return RadioListTile<int>(
                            value: id ?? -1,
                            groupValue: _selectedCityId,
                            title: Text(name.isNotEmpty ? name : 'City'),
                            onChanged: _isLocked ? null : (val) {
                              if (val == null || val <= 0) return;
                              setState(() {
                                _selectedCityId = val;
                                _selectedCityName = name;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (_isLocked)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _requestingApproval ? null : _requestApproval,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _requestingApproval
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                FFLocalizations.of(context).getText('drv_request_approval'),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  if (_isLocked) const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saving || _isLocked ? null : _saveCity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              FFLocalizations.of(context).getText('drv_save'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

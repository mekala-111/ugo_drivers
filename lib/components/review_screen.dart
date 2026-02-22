import 'package:flutter/material.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import '../home/ride_request_model.dart';

class ReviewScreen extends StatefulWidget {
  final RideRequest ride;
  final VoidCallback onSubmit;
  final VoidCallback onClose;

  const ReviewScreen({
    super.key,
    required this.ride,
    required this.onSubmit,
    required this.onClose,
  });

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _starRating = 0;
  List<String> _selectedTagKeys = [];
  static const List<String> _reviewTagKeys = ['drv_review_friendly', 'drv_review_safe', 'drv_review_worst', 'drv_review_fast', 'drv_review_clean'];

  static const Color ugoOrange = AppColors.primary;
  static const Color ugoGreen = AppColors.success;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ugoOrange,
        title:
            Text(FFLocalizations.of(context).getText('drv_ride_completed'), style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: widget.onClose,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Text(FFLocalizations.of(context).getText('drv_received_online'),
                      style: const TextStyle(
                          color: ugoGreen, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('₹${(widget.ride.finalFare ?? widget.ride.estimatedFare)?.toInt() ?? 0}',
                      style: const TextStyle(
                          color: ugoGreen, fontSize: 40, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  Text(FFLocalizations.of(context).getText('drv_review'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        5,
                        (index) => IconButton(
                              icon: Icon(
                                  index < _starRating ? Icons.star : Icons.star_border,
                                  color: Colors.grey[400],
                                  size: 40),
                              onPressed: () => setState(() => _starRating = index + 1),
                            )),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    children: _reviewTagKeys
                        .map((key) {
                          final tag = FFLocalizations.of(context).getText(key);
                          return ChoiceChip(
                            label: Text(tag),
                            selected: _selectedTagKeys.contains(key),
                            selectedColor: ugoOrange.withValues(alpha:0.2),
                            backgroundColor: Colors.grey[200],
                            onSelected: (sel) {
                              setState(() {
                                if (sel) {
                                  _selectedTagKeys = [..._selectedTagKeys, key];
                                } else {
                                  _selectedTagKeys = _selectedTagKeys.where((k) => k != key).toList();
                                }
                              });
                            },
                          );
                        })
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey[200]!))),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(FFLocalizations.of(context).getText('drv_total_fare'),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("₹${(widget.ride.finalFare ?? widget.ride.estimatedFare)?.toStringAsFixed(2) ?? '0.00'}",
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: widget.onSubmit,
                            style: ElevatedButton.styleFrom(backgroundColor: ugoOrange),
                            child: Text(FFLocalizations.of(context).getText('drv_submit'),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
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

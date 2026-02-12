import 'package:flutter/material.dart';
import '../home/home_model.dart';

class ReviewScreen extends StatefulWidget {
  final RideRequest ride;
  final VoidCallback onSubmit;
  final VoidCallback onClose;

  const ReviewScreen({
    Key? key,
    required this.ride,
    required this.onSubmit,
    required this.onClose,
  }) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _starRating = 0;
  List<String> _selectedTags = [];
  final List<String> _reviewTags = [
    'Friendly',
    'Safe',
    'Worst',
    'Fast',
    'Clean'
  ];

  static const Color ugoOrange = Color(0xFFFF7B10);
  static const Color ugoGreen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ugoOrange,
        title:
            const Text("Ride Completed", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: widget.onClose,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Text("You received it online",
              style: TextStyle(
                  color: ugoGreen, fontSize: 18, fontWeight: FontWeight.bold)),
          Text("₹${widget.ride.estimatedFare?.toInt() ?? 76}",
              style: const TextStyle(
                  color: ugoGreen, fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          const Text("Review",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
            children: _reviewTags
                .map((tag) => ChoiceChip(
                      label: Text(tag),
                      selected: _selectedTags.contains(tag),
                      selectedColor: ugoOrange.withOpacity(0.2),
                      backgroundColor: Colors.grey[200],
                      onSelected: (sel) => setState(() => sel
                          ? _selectedTags.add(tag)
                          : _selectedTags.remove(tag)),
                    ))
                .toList(),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Fare",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("₹${widget.ride.estimatedFare?.toStringAsFixed(2)}",
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
                    child: const Text("Submit",
                        style: TextStyle(
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
    );
  }
}

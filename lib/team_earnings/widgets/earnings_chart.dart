import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ugo_driver/constants/app_colors.dart';

class WeeklyEarningsChart extends StatelessWidget {
  final List<double> dailyEarnings;

  const WeeklyEarningsChart({super.key, required this.dailyEarnings});

  @override
  Widget build(BuildContext context) {
    if (dailyEarnings.length != 7) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text("Invalid data")),
      );
    }

    final double maxEarning =
        dailyEarnings.reduce((curr, next) => curr > next ? curr : next);
    // Add 10% padding to max so the highest bar doesn't touch the top
    final double maxY = maxEarning > 0 ? maxEarning * 1.1 : 100;

    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Earnings',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final val = dailyEarnings[index];
                final heightFactor =
                    val > 0 ? val / maxY : 0.05; // tiny height if 0

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Amount text
                    if (val > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          val.toInt().toString(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    // Bar
                    Container(
                      width: 28,
                      height: 100 * heightFactor,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Day label
                    Text(
                      days[index],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

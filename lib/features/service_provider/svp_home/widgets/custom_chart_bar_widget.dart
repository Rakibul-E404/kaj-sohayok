import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../gen/colors.gen.dart';

class CustomBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final String label;
  final double barWidth;

  const CustomBar({
    super.key,
    required this.value,
    required this.maxValue,
    required this.label,
    required this.barWidth,
  });

  @override
  Widget build(BuildContext context) {
    double maxBarHeight = 100.h;

    // Calculate percentage safely to prevent NaN
    double percentage = 0.0;
    if (maxValue != 0 &&
        maxValue.isFinite &&
        maxValue > 0 &&
        value.isFinite &&
        value >= 0) {
      percentage = (value / maxValue).clamp(0.0, 1.0); // Clamp between 0 and 1
    }
    // If maxValue is 0 but value is also 0, we still want to show a 0-height bar
    else if (maxValue == 0 && value == 0) {
      percentage = 0.0;
    }

    double barHeight = maxBarHeight * percentage;

    // Ensure barHeight is a valid number and non-negative
    if (!barHeight.isFinite || barHeight < 0) {
      barHeight = 0.0;
    }

    // Make sure barWidth is valid
    double safeBarWidth = barWidth.isFinite && barWidth > 0 ? barWidth : 14.0;

    return GestureDetector(
      onTap: () {
        // Show info dialog when bar is tapped
        _showInfoDialog(context, label, value);
      },
      child: SizedBox(
        width: safeBarWidth,
        height: maxBarHeight,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Background container (full height)
            Container(
              width: safeBarWidth,
              height: maxBarHeight,
              decoration: BoxDecoration(
                color: AppColors.cf1f3fd,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            // Foreground bar (actual value)
            Container(
              width: safeBarWidth - 4.w, // Slightly narrower to show background
              height: barHeight,
              decoration: BoxDecoration(
                color: AppColors.c778beb,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to show info dialog when bar is tapped
  void _showInfoDialog(BuildContext context, String label, double value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Chart Data Info',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.c778beb,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Day: $label',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                'Earned: \$${value.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                'This represents the income for $label day.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('OK', style: TextStyle(color: AppColors.c778beb)),
            ),
          ],
        );
      },
    );
  }
}

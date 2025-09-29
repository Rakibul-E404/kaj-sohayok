import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../gen/colors.gen.dart';

class CustomBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final String label;

  const CustomBar({
    super.key,
    required this.value,
    required this.maxValue,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    double barWidth = 28.w;
    double maxBarHeight = 100.h;

    double percentage = value / maxValue;
    double barHeight = maxBarHeight * percentage;

    return SizedBox(
      width: barWidth,
      height: maxBarHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background container (full height)
          Container(
            width: barWidth,
            height: maxBarHeight,
            decoration: BoxDecoration(
              color: AppColors.cf1f3fd,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          // Foreground bar (actual value)
          Container(
            width: barWidth - 4.w, // Slightly narrower to show background
            height: barHeight,
            decoration: BoxDecoration(
              color: AppColors.c778beb,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ],
      ),
    );
  }
}

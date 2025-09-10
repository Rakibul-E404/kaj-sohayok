import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

class OverallRatingWidget extends StatelessWidget {
  final double overallRating; // The average rating (e.g., 4.2)
  final int totalReviews; // Total number of reviews (e.g., 250)

  const OverallRatingWidget({
    super.key,
    required this.overallRating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.end, // Align everything to the right
      children: [
        // ===== Big Overall Rating Number =====
        Text(
          overallRating.toStringAsFixed(1), // Format with 1 decimal (e.g., 4.2)
          style: TextFontStyle.headline30w500c000000StyleSatoshi,
        ),

        // Small vertical gap
        UIHelper.verticalSpace(8.h),

        // ===== Star Icons (visual representation of rating) =====
        Row(
          mainAxisAlignment: MainAxisAlignment.end, // Align to right side
          children: List.generate(5, (index) {
            return Icon(
              Icons.star,
              // Fill star if index < floor(overallRating), else show gray star
              color: index < overallRating.floor()
                  ? const Color(0xFFFFB800) // Yellow star (filled)
                  : const Color(0xFFE8E8E8), // Gray star (empty)
              size: 20,
            );
          }),
        ),

        UIHelper.verticalSpace(8.h),

        // ===== Total Reviews Text =====
        Text(
          '$totalReviews Reviews', // Example: "250 Reviews"
          style: TextFontStyle.headline14w400c000000StyleSatoshi,
        ),
      ],
    );
  }
}

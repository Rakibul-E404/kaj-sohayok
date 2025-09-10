import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/app_constant_text.dart';
import 'package:kaz_bd/features/normal_user/details/widget/over_all_rating_widget.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

class RatingCard extends StatelessWidget {
  final double overallRating; // The overall average rating (e.g. 4.5)
  final int totalReviews; // Total number of reviews (e.g. 120)
  final Map<int, double> starDistribution;
  // A map showing what % of reviews are each star rating
  // Example: {5: 0.7, 4: 0.2, 3: 0.05, 2: 0.03, 1: 0.02}

  const RatingCard({
    super.key,
    required this.overallRating,
    required this.totalReviews,
    required this.starDistribution,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 200.h, // Fixed card height (responsive with ScreenUtil)
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ), // Inner spacing

      decoration: BoxDecoration(
        color: AppColors.cf1f3fd,
        borderRadius: BorderRadius.circular(8.r), // Rounded corners
        border: Border.all(color: AppColors.c000000), // Light border
      ),

      // The main row: Left = distribution bars, Right = overall rating summary
      child: Row(
        children: [
          // ================= LEFT SIDE =================
          Expanded(
            flex: 3, // Takes 60% of width
            child: ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Prevent scrolling (since inside fixed-height card)
              itemCount: AppText.baseStarNumber, // For 5 → 1 stars
              itemBuilder: (context, index) {
                int starNumber =
                    AppText.baseStarNumber - index; // Start from 5★ down to 1★
                double percentage = starDistribution[starNumber] ?? 0.0;
                // Get % of reviews for that star (default 0 if missing)

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      // Star number (5,4,3,2,1)
                      Text(
                        '$starNumber',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Star icon
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFB800), // Yellow star
                        size: 18,
                      ),
                      const SizedBox(width: 12),

                      // Progress bar showing percentage
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E8E8), // Gray background
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor:
                                percentage, // Fill width based on % value
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFFB800,
                                ), // Yellow filled part
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 24), // Gap between left & right sections
          // ================= RIGHT SIDE =================
          Expanded(
            flex: 2, // Takes 40% of width
            child: OverallRatingWidget(
              overallRating: overallRating, // Pass avg rating
              totalReviews: totalReviews, // Pass review count
            ),
          ),
        ],
      ),
    );
  }
}

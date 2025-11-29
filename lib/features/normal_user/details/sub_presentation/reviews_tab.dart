import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/details_screen_controller.dart';
import 'package:kaz_bd/features/normal_user/details/widget/rating_card_widget.dart';
import 'package:kaz_bd/custom_widgets/ratings_showing_widget.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../helpers/ui_helpers.dart';

class ReviewsTab extends StatelessWidget {
  const ReviewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    DetailsScreenController detailsScreenController =
        Get.find<DetailsScreenController>();
    return SingleChildScrollView(
      key: const PageStorageKey('reviews'),
      padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
      child: Obx(() {
        // Show loading indicator if still loading
        if (detailsScreenController.isLoading.value) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 50.h),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.c778beb),
              ),
            ),
          );
        }

        // Calculate star distribution from rating summary
        Map<int, double> starDistribution = {
          5: 0.0,
          4: 0.0,
          3: 0.0,
          2: 0.0,
          1: 0.0,
        }; // Initialize all star ratings
        int totalReviews = detailsScreenController.serviceReviews.length;

        if (detailsScreenController.ratingSummary.isNotEmpty) {
          for (var rating in detailsScreenController.ratingSummary) {
            if (rating.rating != null && rating.count != null) {
              starDistribution[rating.rating!] = totalReviews > 0
                  ? rating.count!.toDouble() / totalReviews
                  : 0.0;
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///Section : Top Review
            RatingCard(
              overallRating: (detailsScreenController.serviceRating ?? 0)
                  .toDouble(),
              totalReviews: totalReviews,
              starDistribution: starDistribution,
            ),
            UIHelper.verticalSpace(16.h),

            ///Section : Comments
            if (detailsScreenController.serviceReviews.isNotEmpty)
              ListView.separated(
                itemCount: detailsScreenController.serviceReviews.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) =>
                    UIHelper.verticalSpace(16.h),
                itemBuilder: (context, index) {
                  final review = detailsScreenController.serviceReviews[index];
                  return RatingsShowingWidget(
                    userImage: detailsScreenController.getUserProfileImage(
                      index,
                    ),
                    userName:
                        "User ${index + 1}", // Placeholder name, might need actual user name from a user service
                    givenRatings: (review.rating ?? 0).toDouble(),
                    timeFrame: _formatDate(review.createdAt),
                    comment:
                        review.review?.en ??
                        review.review?.bn ??
                        "No comment provided",
                  );
                },
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: Center(
                  child: Text(
                    "No reviews yet",
                    style: TextStyle(fontSize: 16.sp, color: AppColors.c000000),
                  ),
                ),
              ),
            UIHelper.verticalSpace(30.h),
          ],
        );
      }),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Recently";

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

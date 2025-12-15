/**
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../../../custom_widgets/custom_elevated_button.dart';
import 'payment_successfull_bottom_sheet.dart';
import 'show_feedback_thanks_bottomsheet.dart';

void showReviewGivingAlertDialog() {
  double rating = 0.0; // store the selected rating

  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        content: Container(
          width: 1.sw,
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.cFFFFFF,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// User Image + Name
              Row(
                children: [
                  ///Section : User Image
                  CircleAvatar(
                    radius: 30.r,
                    backgroundImage: AssetImage(Assets.images.userImage.path),
                  ),
                  UIHelper.horizontalSpace(8.w),

                  ///Section : User Name
                  Text(
                    "Ripon Mia",
                    style: TextFontStyle.headline16w500c202020StyleSatoshi,
                  ),
                  Spacer(),

                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(Icons.remove, color: AppColors.c000000),
                  ),
                ],
              ),
              UIHelper.verticalSpace(12.h),

              /// Title
              Text(
                "Rate the service",
                style: TextFontStyle.headline10w400c999999StyleSatoshi,
              ),
              UIHelper.verticalSpace(12.h),

              ///Section : Rating Bar
              RatingBar(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 28.sp,
                ratingWidget: RatingWidget(
                  full: Icon(Icons.star, color: Colors.amber), // filled
                  half: Icon(Icons.star_half, color: Colors.amber), // optional
                  empty: Icon(
                    Icons.star_border,
                    color: Colors.amber,
                  ), // outline
                ),
                onRatingUpdate: (value) {
                  rating = value;
                },
              ),
              UIHelper.verticalSpace(8.h),

              ///Section : Comment Box
              /// 📝 Comment Box
              Container(
                height: 94.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.cFFFFFF,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.ce6e6e6,
                  ), // light grey border
                ),
                child: TextField(
                  maxLines: null, // allows multiline input
                  expands: true, // expands to fit container height
                  style: TextFontStyle.headline14w500c000000StyleSatoshi,
                  decoration: InputDecoration(
                    hintText: "Add a Comment...",
                    hintStyle: TextFontStyle.headline12w700cb4b4b4StyleSatoshi,
                    border: InputBorder.none,
                  ),
                ),
              ),
              UIHelper.verticalSpace(16.h),

              /// Submit button
              CustomElevatedButton(
                onTap: () {
                  log(
                    "My bookings screen WorkCompletedTab Submit Review button Taped!",
                  );
                  Get.back();
                  showFeedBackThanksBottomSheet();
                },
                buttonTitle: "Submit Review",
              ),
            ],
          ),
        ),
      );
    },
  );
}
*/







///
///
///
/// todo::: setting the post api
///
///
///






import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/service/network_caller.dart';
import 'package:kaz_bd/service/network_response.dart';
import 'package:kaz_bd/service/secured_storage.dart';
import 'package:kaz_bd/utilities/app_constants.dart';
import 'package:kaz_bd/utilities/app_url.dart';

import '../../../../../../custom_widgets/custom_elevated_button.dart';
import 'payment_successfull_bottom_sheet.dart';
import 'show_feedback_thanks_bottomsheet.dart';

// Remove the local ReviewData class and import from work_completed_tab.dart
import '../presentation/work_completed_tab.dart'; // Add this line

// REMOVE THIS LOCAL CLASS:
// class ReviewData {
//   final String bookingId;
//   final String serviceProviderId;
//   final String providerId;
//
//   ReviewData({
//     required this.bookingId,
//     required this.serviceProviderId,
//     required this.providerId,
//   });
// }

void showReviewGivingAlertDialog() {
  double rating = 0.0;
  final TextEditingController commentController = TextEditingController();
  final RxBool isSubmitting = false.obs;

  // Get the review data from GetX storage
  final ReviewData? reviewData = Get.find<ReviewData>(tag: 'reviewData');

  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        content: Container(
          width: 1.sw,
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.cFFFFFF,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// User Image + Name
              Row(
                children: [
                  ///Section : User Image
                  CircleAvatar(
                    radius: 30.r,
                    backgroundImage: AssetImage(Assets.images.userImage.path),
                  ),
                  UIHelper.horizontalSpace(8.w),

                  ///Section : User Name
                  Text(
                    "Ripon Mia",
                    style: TextFontStyle.headline16w500c202020StyleSatoshi,
                  ),
                  Spacer(),

                  InkWell(
                    onTap: () {
                      if (!isSubmitting.value) {
                        Get.back();
                      }
                    },
                    child: Icon(Icons.remove, color: AppColors.c000000),
                  ),
                ],
              ),
              UIHelper.verticalSpace(12.h),

              /// Title
              Text(
                "Rate the service",
                style: TextFontStyle.headline10w400c999999StyleSatoshi,
              ),
              UIHelper.verticalSpace(12.h),

              ///Section : Rating Bar
              RatingBar(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 28.sp,
                ratingWidget: RatingWidget(
                  full: Icon(Icons.star, color: Colors.amber),
                  half: Icon(Icons.star_half, color: Colors.amber),
                  empty: Icon(
                    Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
                onRatingUpdate: (value) {
                  rating = value;
                },
              ),
              UIHelper.verticalSpace(8.h),

              ///Section : Comment Box
              Container(
                height: 94.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.cFFFFFF,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.ce6e6e6,
                  ),
                ),
                child: TextField(
                  controller: commentController,
                  maxLines: null,
                  expands: true,
                  style: TextFontStyle.headline14w500c000000StyleSatoshi,
                  decoration: InputDecoration(
                    hintText: "Add a Comment...",
                    hintStyle: TextFontStyle.headline12w700cb4b4b4StyleSatoshi,
                    border: InputBorder.none,
                  ),
                ),
              ),
              UIHelper.verticalSpace(16.h),

              /// Submit button with loading state
              Obx(() {
                return CustomElevatedButton(
                  onTap: isSubmitting.value
                      ? null
                      : () async {
                    // Validate inputs
                    if (rating == 0) {
                      Get.snackbar(
                        'Error',
                        'Please select a rating',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    if (reviewData == null || reviewData.bookingId.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Booking information not found',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    isSubmitting.value = true;

                    try {
                      log(
                        "📝 [REVIEW] Submitting review for booking: ${reviewData.bookingId}",
                      );
                      log("⭐ [REVIEW] Rating: $rating");
                      log("💬 [REVIEW] Comment: ${commentController.text}");

                      // Prepare review data
                      final reviewRequestData = {
                        "review": commentController.text.isNotEmpty
                            ? commentController.text
                            : "New review for service booking id ${reviewData.bookingId}",
                        "rating": rating.toInt().toString(),
                        "serviceBookingId": reviewData.bookingId,
                      };

                      log('📤 [REVIEW] Request data: $reviewRequestData');

                      // Get authentication token
                      final token = await SecureStorageService().read(AppConstants.accessToken);

                      if (token == null) {
                        Get.snackbar(
                          'Error',
                          'Authentication token not found',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        isSubmitting.value = false;
                        return;
                      }

                      // Prepare headers
                      final Map<String, String> headers = {
                        'Authorization': 'Bearer $token',
                        'Content-Type': 'application/json',
                      };

                      log('🌐 [REVIEW] Making API call to: ${AppUrl.workReview}');

                      // Make API call
                      NetworkResponse response = await NetworkCaller().postRequest(
                        AppUrl.workReview,
                        headers: headers,
                        body: reviewRequestData,
                      );

                      log('📥 [REVIEW] API Response Status Code: ${response.statusCode}');
                      log('📊 [REVIEW] API Response: ${response.jsonResponse}');

                      if (response.isSuccess && response.jsonResponse != null) {
                        final json = response.jsonResponse!;
                        final success = json['success'] == true;
                        final statusCode = json['code'] ?? 0;

                        if (success && statusCode == 200) {
                          log('✅ [REVIEW] Review submitted successfully');

                          // Close the dialog
                          Get.back();

                          // Show success feedback
                          showFeedBackThanksBottomSheet();

                        } else {
                          String errorMessage = json['message'] ?? 'Failed to submit review';
                          log('❌ [REVIEW] API error: $errorMessage');
                          Get.snackbar(
                            'Error',
                            errorMessage,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      } else {
                        String error = response.errorMessage ?? 'Something went wrong';
                        log('❌ [REVIEW] Network error: $error');
                        Get.snackbar(
                          'Error',
                          'Failed to submit review: $error',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    } catch (e, stackTrace) {
                      log('❌ [REVIEW] Exception: $e');
                      log('❌ [REVIEW] Stack trace: $stackTrace');
                      Get.snackbar(
                        'Error',
                        'An error occurred: ${e.toString()}',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    } finally {
                      isSubmitting.value = false;
                    }
                  },
                  buttonTitle: isSubmitting.value ? "Submitting..." : "Submit Review",
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}



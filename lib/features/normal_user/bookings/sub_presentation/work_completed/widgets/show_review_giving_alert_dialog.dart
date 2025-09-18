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

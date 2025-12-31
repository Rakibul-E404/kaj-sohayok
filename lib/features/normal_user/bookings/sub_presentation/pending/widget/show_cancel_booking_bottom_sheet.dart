import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

void showCancelBookingBottomSheet({
  required String bookingId,
  required VoidCallback onCancelConfirmed,
}) {
  Get.bottomSheet(
    Container(
      width: 1.sw,
      height: 0.5.sh,
      padding: EdgeInsets.only(left: 38.w, right: 38.w, top: 9.h, bottom: 32.h),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        borderRadius: BorderRadius.circular(48.r),
      ),
      child: Column(
        children: [
          ///Section : bottom Sheet Top Bar
          Container(
            width: 50.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: AppColors.cb5b5b5,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          UIHelper.verticalSpace(24.h),

          ///Section : Image -> Delete Icon Image
          Image.asset(
            height: 130.h,
            width: 130.w,
            fit: BoxFit.contain,
            Assets.images.deleteImage.path,
          ),
          UIHelper.verticalSpace(24.h),

          ///Section : Text -> Cancel Booking
          Text(
            "Cancel Booking",
            style: TextFontStyle.headline18w700c202020StyleSatoshi,
          ),
          UIHelper.verticalSpace(10.h),

          ///Section : Text -> You can cancel the order within.......
          Text(
            "You can cancel the order within 12 hours before it is accepted, "
            "but you cannot cancel it after the order has been accepted. Thank you.",
            textAlign: TextAlign.center,
            style: TextFontStyle.headline14w500cfb3f3fStyleSatoshi,
          ),
          UIHelper.verticalSpace(24.h),

          ///Section : Button -> No
          ///Section : Button -> Yes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // No Button - Keep Booking
              CustomElevatedButton(
                onTap: () {
                  log("No Button Tapped - Keeping booking: $bookingId");
                  Get.back(); // Close the bottom sheet
                },
                buttonTitle: "No",
                textStyle: TextFontStyle.headline14w500c111111StyleSatoshi,
                buttonWidth: 136.w,
                isButtonBorderUsed: true,
                buttonBorderWidth: 1.5.sp,
                buttonBorderColor: AppColors.c778beb,
                buttonColor: Colors.transparent,
              ),
              UIHelper.horizontalSpace(10.w),

              // Yes Button - Confirm Cancellation
              CustomElevatedButton(
                onTap: () {
                  log("Yes Button Tapped - Confirming cancellation for booking: $bookingId");
                  Get.back(); // Close the bottom sheet first
                  onCancelConfirmed(); // Then execute the cancellation callback
                },
                buttonTitle: "Yes",
                buttonWidth: 136.w,
                buttonColor:
                    AppColors.ce73d3d, // Red color for destructive action
              ),
            ],
          ),
        ],
      ),
    ),
    isScrollControlled: true,
    enableDrag: true,
  );
}

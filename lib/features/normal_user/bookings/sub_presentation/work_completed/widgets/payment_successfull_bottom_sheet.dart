import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/features/normal_user/bookings/sub_presentation/work_completed/widgets/show_review_giving_alert_dialog.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';

void showPaymentSuccessfullBottomSheet() {
  Get.bottomSheet(
    Container(
      width: 1.sw,
      height: 0.5.sh,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 44.w),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        borderRadius: BorderRadius.circular(34.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ///Sectoin : Bottom Sheet TopBar
          Container(
            width: 50.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: AppColors.c000000,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          UIHelper.verticalSpace(24.h),

          ///Section : Verified Image Icon
          Image.asset(
            width: 130.w,
            height: 130.h,
            fit: BoxFit.contain,
            Assets.images.verifiedCheckIcon.path,
          ),
          UIHelper.verticalSpace(24.h),

          ///Section : Text -> payment successful !
          Text(
            "Payment Successful !",
            style: TextFontStyle.headline18w700c1b1b1bStyleSatoshi,
          ),
          UIHelper.verticalSpace(10.h),

          ///Section : Text -> Your Payment  has been successfully processed
          Text(
            "Your Payment  has been successfully processed",
            textAlign: TextAlign.center,
            style: TextFontStyle.headline14w400c494949StyleSatoshi,
          ),
          UIHelper.verticalSpace(24.h),

          ///Section : Button -> Home
          ///Section : Button -> Review
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ///Section : Button -> Home
              CustomElevatedButton(
                onTap: () {
                  log("Home Button Taped!");
                  Get.toNamed(Routes.navigationScreen);
                },
                buttonWidth: 136.w,
                buttonTitle: "Home",
                textStyle: TextFontStyle.headline14w500c111111StyleSatoshi,
                isButtonBorderUsed: true,
                buttonBorderWidth: 1.5.sp,
                buttonBorderColor: AppColors.c778beb,
                buttonColor: Colors.transparent,
              ),
              UIHelper.horizontalSpace(16.w),

              ///Section -> Button -> give a review
              CustomElevatedButton(
                onTap: () {
                  log("Give a Review Button Taped!");
                  showReviewGivingAlertDialog();
                },
                buttonWidth: 136.w,
                buttonTitle: "Give a Review",
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

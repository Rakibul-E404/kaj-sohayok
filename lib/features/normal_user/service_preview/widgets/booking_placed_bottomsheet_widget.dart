import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer';

import '../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../constants/text_font_style.dart';

class BookingPlacedBottomSheet extends StatelessWidget {
  const BookingPlacedBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30.r),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Section: Top Bar
          Container(
            width: 50.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: AppColors.cb5b5b5,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          UIHelper.verticalSpace(24.h),

          /// Section: Done Image
          Image.asset(
            Assets.images.verifiedCheckIcon.path,
            width: 125.w,
            height: 125.h,
            fit: BoxFit.contain,
          ),
          UIHelper.verticalSpace(24.h),

          /// Section: Title
          Text(
            'Booking Placed Done',
            style: TextFontStyle.headline18w700c000000StyleSatoshi,
          ),
          UIHelper.verticalSpace(10.h),

          /// Section: Message
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                      "Your order has been successfully placed.\nOur logistic team will contact you"
                      " soon.\nFor any help please ",
                  style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                ),
                TextSpan(
                  text: 'Call (+1)444444.',
                  style: TextFontStyle.headline14w500c778bebStyleSatoshi,
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(24.h),

          /// Section: Button
          CustomElevatedButton(
            onTap: () {
              log("Go back to home page! button tapped...");
              Navigator.pop(context); // 👈 Close bottom sheet
            },
            buttonTitle: "Go To Home Page",
          ),
          UIHelper.verticalSpace(20.h),
        ],
      ),
    );
  }
}

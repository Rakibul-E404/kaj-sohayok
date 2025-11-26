import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/dotted_line_divider_widget.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../../../gen/colors.gen.dart';

class TransectionHistoryCard extends StatelessWidget {
  const TransectionHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.cf1f3fd,
        border: Border.all(color: AppColors.ce6e6e6, width: 1.5.sp),
        boxShadow: [
          BoxShadow(
            color: AppColors.ca4b1f2.withAlpha(80),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///Section : Text -> Withdrawal
          Text(
            "Withdrawal",
            style: TextFontStyle.headline16w700c4d4d4dStyleSatoshi,
          ),
          UIHelper.verticalSpace(8.h),

          ///Section : Divider
          DottedLineDividerWidget(),
          UIHelper.verticalSpace(8.h),

          ///Section : Total amount
          ///Section : Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ///Section : Total Amount
              Text(
                "Total Amount : ",
                style: TextFontStyle.headline14w400c111111StyleSatoshi,
              ),

              ///Section : Amount
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Completed :",
                      style: TextFontStyle.headline14w500c27d127StyleSatoshi,
                    ),
                    TextSpan(
                      text: " \$1000",
                      style: TextFontStyle.headline14w500c27d127StyleSatoshi,
                    ),
                  ],
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(8.h),

          ///Section : Divider
          DottedLineDividerWidget(),
          UIHelper.verticalSpace(8.h),

          ///Section : Text -> Payment Date
          ///Section : Payment Date & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ///Section : Text -> Payment Date
              Text(
                "Payment Date : ",
                style: TextFontStyle.headline14w400c111111StyleSatoshi,
              ),

              ///Section : Payment Date & Time
              Text(
                "12 Jan 25 8.00AM",
                style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

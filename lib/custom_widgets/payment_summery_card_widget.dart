import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/app_constant_text.dart';
import '../constants/text_font_style.dart';
import '../gen/assets.gen.dart';
import '../gen/colors.gen.dart';
import '../helpers/ui_helpers.dart';

class PaymentSummeryCardWidget extends StatelessWidget {
  final double initialPayablePrice;
  final double otherPartsPrice;
  final double totalPaymentPrice;
  final String transactionID;
  final bool isTranasectionIDSectionVisible;
  const PaymentSummeryCardWidget({
    super.key,
    required this.initialPayablePrice,
    required this.otherPartsPrice,
    required this.totalPaymentPrice,
    required this.transactionID,
    this.isTranasectionIDSectionVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        border: Border.all(color: AppColors.ce6e6e6),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.ca4b1f2.withAlpha(80),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///Section : Text -> Payment Summary
          Text(
            "Payment Summary",
            style: TextFontStyle.headline16w700c202020StyleSatoshi,
          ),
          UIHelper.verticalSpace(16.h),

          ///Section : Initial Payment
          Container(
            width: 1.sw,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.cf1f3fd,
              border: Border(top: BorderSide(color: AppColors.c778beb)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Initial Cost",
                  style: TextFontStyle.headline16w700c4d4d4dStyleSatoshi,
                ),
                Spacer(),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Start from ${AppText.bdTkSign}",
                          style:
                              TextFontStyle.headline12w500c6a6a6aStyleSatoshi,
                        ),
                        TextSpan(
                          text: "$initialPayablePrice",
                          style:
                              TextFontStyle.headline18w700c778bebStyleSatoshi,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(25.h),

          ///Section : Other Parts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Other Parts",
                style: TextFontStyle.headline16w500c202020StyleSatoshi,
              ),

              Text(
                "${AppText.bdTkSign}$otherPartsPrice",
                style: TextFontStyle.headline16w500c202020StyleSatoshi,
              ),
            ],
          ),
          UIHelper.verticalSpace(25.h),

          ///Section : Divider
          DottedLine(
            direction: Axis.horizontal,
            lineLength: double.infinity,
            lineThickness: 1.sp,
            dashLength: 4.w,
            dashGapLength: 4.w,
            dashColor: AppColors.cb4b4b4,
          ),
          UIHelper.verticalSpace(12.h),

          ///Section : Total Payment
          Container(
            width: 1.sw,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.cf1f3fd,
              border: Border.all(color: AppColors.ce6e6e6),
              borderRadius: BorderRadius.circular(8.r),

              boxShadow: [
                BoxShadow(
                  color: AppColors.ca4b1f2.withAlpha(80),
                  blurRadius: 12.r,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ///Section : Text-> Total Payment
                Text(
                  "Total Payment",
                  style: TextFontStyle.headline16w700c202020StyleSatoshi,
                ),

                ///Section : Payment Price
                Text(
                  "${AppText.bdTkSign}$totalPaymentPrice",
                  style: TextFontStyle.headline16w700c202020StyleSatoshi,
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(10.h),

          ///Section : Transection ID
          isTranasectionIDSectionVisible
              ? Container(
                  width: 1.sw,
                  padding: EdgeInsets.all(10.sp),
                  decoration: BoxDecoration(
                    color: AppColors.cFFFFFF,
                    border: Border.all(color: AppColors.ce6e6e6),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.c000000.withAlpha(40),
                        blurRadius: 12.r,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.sp),
                        decoration: BoxDecoration(
                          color: AppColors.c778beb,
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: SvgPicture.asset(Assets.icons.walletIcon),
                      ),
                      UIHelper.horizontalSpace(10.w),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Transaction ID",
                            style:
                                TextFontStyle.headline16w700c1d242dStyleSatoshi,
                          ),
                          UIHelper.verticalSpace(4.h),
                          Text(
                            "$transactionID",
                            style:
                                TextFontStyle.headline12w400c727272StyleSatoshi,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}

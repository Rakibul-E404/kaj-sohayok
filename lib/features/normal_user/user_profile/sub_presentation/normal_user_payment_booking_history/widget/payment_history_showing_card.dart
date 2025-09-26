import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../../constants/app_constant_text.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';

class PaymentHistoryShowingCard extends StatelessWidget {
  final String serviceName;
  final double initialPayablePrice;
  final String address;
  final String dateAndTime;
  final String serviceProviderProfileImage;
  final String serviceProviderName;
  final String serviceProviderDesignation;
  final void Function()? onTap;
  const PaymentHistoryShowingCard({
    super.key,
    required this.serviceName,
    required this.initialPayablePrice,
    required this.address,
    required this.dateAndTime,
    required this.serviceProviderProfileImage,
    required this.serviceProviderName,
    required this.serviceProviderDesignation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.sp),
        decoration: BoxDecoration(
          color: AppColors.cFFFFFF,
          border: Border.all(color: AppColors.ce6e6e6),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.ca4b1f2.withAlpha(80),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            ///Section : Service Name
            ///Section : Initial Payable Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 0.5.sw,
                  child: Text(
                    serviceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextFontStyle.headline18w700c000000StyleSatoshi,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Start from ",
                        style: TextFontStyle.headline12w500c6a6a6aStyleSatoshi,
                      ),
                      TextSpan(
                        text: "${AppText.bdTkSign}$initialPayablePrice",
                        style: TextFontStyle.headline18w700c778bebStyleSatoshi,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpace(12.h),

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

            ///Section : Address
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.location_pin, color: AppColors.c92a2ef, size: 24.sp),
                UIHelper.horizontalSpace(4.w),

                ///Section :  Location Address
                Expanded(
                  child: Text(
                    address,
                    style: TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpace(6.h),

            ///Section : Payment Date
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.watch_later, color: AppColors.c92a2ef, size: 24.sp),
                UIHelper.horizontalSpace(4.w),
                Text(
                  dateAndTime,
                  style: TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                ),
              ],
            ),
            UIHelper.verticalSpace(12.h),

            ///Sesction : Divider
            DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 1.sp,
              dashLength: 4.w,
              dashGapLength: 4.w,
              dashColor: AppColors.cb4b4b4,
            ),
            UIHelper.verticalSpace(14.h),

            ///Section : Service Provider
            Container(
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: AppColors.cf1f3fd,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                children: [
                  ///Section : Service Provider Profile Image
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 24.r,
                        backgroundImage: AssetImage(
                          serviceProviderProfileImage,
                        ),
                      ),
                      Positioned(
                        top: 0.h,
                        right: 0.w,
                        child: SvgPicture.asset(Assets.icons.verifiedIcon),
                      ),
                    ],
                  ),
                  UIHelper.horizontalSpace(6.w),

                  ///Section : Service Provider Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///Section : Name
                        Text(
                          serviceProviderName,
                          style:
                              TextFontStyle.headline14w500c000000StyleSatoshi,
                        ),
                        UIHelper.verticalSpace(2.h),

                        ///Section : Service Provider Designation
                        Text(
                          serviceProviderDesignation,
                          style:
                              TextFontStyle.headline10w500c4d4d4dStyleSatoshi,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

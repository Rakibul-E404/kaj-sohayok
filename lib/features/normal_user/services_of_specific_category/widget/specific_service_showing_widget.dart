import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/app_constant_text.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class SpecificServiceShowingWidget extends StatelessWidget {
  final String serviceImagePath;
  final String serviceName;
  final double initialPayablePrice;
  final String serviceProviderImage;
  final String serviceProviderName;
  final double serviceProviderRating;
  final void Function()? onTap;
  const SpecificServiceShowingWidget({
    super.key,
    required this.serviceImagePath,
    required this.serviceName,
    required this.initialPayablePrice,
    required this.serviceProviderImage,
    required this.serviceProviderName,
    required this.serviceProviderRating,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.cf1f3fd,
        border: Border.all(color: AppColors.c778beb),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          ///Section: Service Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Image.asset(
              serviceImagePath,
              height: 112.h,
              width: 1.sw,
              fit: BoxFit.cover,
            ),
          ),
          UIHelper.verticalSpace(14.h),

          ///Section : Service Name
          ///Section : Service Pricec
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                serviceName,
                style: TextFontStyle.headline14w700c000000StyleSatoshi,
              ),
              RichText(
                text: TextSpan(
                  style: TextFontStyle
                      .headline12w500c6a6a6aStyleSatoshi, // base style
                  children: [
                    const TextSpan(text: "Start from "),
                    TextSpan(
                      text: "${AppText.bdTkSign}$initialPayablePrice",
                      style: TextFontStyle.headline16w700c778bebStyleSatoshi,
                    ),
                  ],
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(8.h),

          ///Section : Dotted Divider
          DottedLine(
            direction: Axis.horizontal,
            lineLength: double.infinity,
            lineThickness: 1.sp,
            dashLength: 4.w,
            dashGapLength: 4.w,
            dashColor: Colors.grey,
          ),
          UIHelper.verticalSpace(8.h),

          ///Section : User Image
          ///Section : User Name
          ///Section : User Rating
          ///Section : Button -> Book Now
          Row(
            children: [
              ///Section : User Image
              CircleAvatar(
                radius: 20.r,
                backgroundImage: AssetImage(serviceProviderImage),
              ),
              UIHelper.horizontalSpace(6.w),

              ///Section : User Name
              ///Section : User Rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///Section : User Name
                  SizedBox(
                    width: 0.35.sw,
                    child: Text(
                      serviceProviderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextFontStyle.headline12w500c000000StyleSatoshi,
                    ),
                  ),
                  UIHelper.verticalSpace(2.h),

                  ///Section : User Ratings
                  Row(
                    children: [
                      Icon(Icons.star_rate_rounded, color: AppColors.cffcd22),
                      UIHelper.horizontalSpace(2.w),
                      Text(
                        serviceProviderRating.toString(),
                        style: TextFontStyle.headline10w500c000000StyleSatoshi,
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),

              ///Section : Button -> Book Now
              CustomElevatedButton(
                onTap: onTap,
                buttonTitle: "Book Now",
                textStyle: TextFontStyle.headline14w500cFFFFFFStyleSatoshi,
                buttonWidth: 109.w,
                buttonHeight: 32.h,
                borderRadius: 50.r,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

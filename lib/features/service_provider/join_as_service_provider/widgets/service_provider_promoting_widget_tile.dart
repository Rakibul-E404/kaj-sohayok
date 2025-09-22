import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class ServiceProviderPromotionWidgetTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subTitle;
  final bool isDividerVisible;

  const ServiceProviderPromotionWidgetTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subTitle,
    this.isDividerVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///Section : Clock Image
            Image.asset(
              height: 30.h,
              width: 30.w,
              fit: BoxFit.contain,
              imagePath,
            ),
            UIHelper.horizontalSpace(12.w),

            ///Section : Text -> Increased Job Opportunities
            ///Section : Text -> Expand your client base and enjoy flexible working hours.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///Section : Text -> Increased Job Opportunities
                  Text(
                    title,
                    style: TextFontStyle.headline16w700c202020StyleSatoshi,
                  ),
                  UIHelper.verticalSpace(8.h),

                  ///Section : Text -> Expand your client base and enjoy flexible working hours.
                  Text(
                    subTitle,
                    style: TextFontStyle.headline14w400ca5a5a5StyleSatoshi,
                  ),
                ],
              ),
            ),
          ],
        ),
        UIHelper.verticalSpace(8.h),

        ///Section : Divider
        isDividerVisible
            ? DottedLine(
                direction: Axis.horizontal,
                lineLength: double.infinity,
                lineThickness: 1.sp,
                dashLength: 4.w,
                dashGapLength: 4.w,
                dashColor: AppColors.cb4b4b4,
              )
            : SizedBox.shrink(),
        isDividerVisible ? UIHelper.verticalSpace(8.h) : SizedBox.shrink(),
      ],
    );
  }
}

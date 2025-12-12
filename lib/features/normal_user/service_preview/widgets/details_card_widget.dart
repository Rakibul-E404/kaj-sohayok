import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class ServicePreviewDetailsCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String data;
  final VoidCallback? onTap;

  const ServicePreviewDetailsCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        border: Border.all(color: AppColors.ce6e6e6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(title, style: TextFontStyle.headline12w500c4d4d4dStyleSatoshi),
          UIHelper.verticalSpace(12.h),

          /// Data + Edit Row
          Row(
            children: [
              Icon(icon, color: AppColors.c92a2ef),
              UIHelper.horizontalSpace(8.w),

              /// Data Text
              Expanded(
                child: Text(
                  data,
                  style: TextFontStyle.headline16w500c000000StyleSatoshi,
                ),
              ),

              /// Edit Button
              InkWell(
                onTap: () {
                  Get.back();
                },
                borderRadius: BorderRadius.circular(6.r),
                child: Row(
                  children: [
                    Text(
                      "Edit",
                      style: TextFontStyle.headline10w700c8b8b8bStyleSatoshi,
                    ),
                    UIHelper.horizontalSpace(2.w),
                    SvgPicture.asset(
                      Assets.icons.penEditIcon,
                      color: AppColors.c8b8b8b,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

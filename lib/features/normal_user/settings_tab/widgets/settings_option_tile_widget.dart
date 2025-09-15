import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class SettingsOptionTileWidget extends StatelessWidget {
  final String prefixIcon;
  final String title;
  final bool isLast;

  const SettingsOptionTileWidget({
    super.key,
    required this.prefixIcon,
    required this.title,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      alignment: Alignment.center,
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        border: Border.all(color: AppColors.ce6e6e6),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          /// Section: Settings Option Icon
          title == "Contact Us"
              ? Icon(Icons.help, size: 20.sp, color: AppColors.c92a2ef)
              : SvgPicture.asset(prefixIcon, height: 20.sp, width: 20.sp),

          UIHelper.horizontalSpace(10.w),

          /// Section: Settings Option Name
          Text(
            title,
            style: TextFontStyle.headline16w500c202020StyleSatoshi.copyWith(
              color: isLast ? AppColors.cee3333 : null,
            ),
          ),

          const Spacer(),

          Icon(
            Icons.keyboard_arrow_right_rounded,
            size: 24.sp,
            color: AppColors.c858c94,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class WorkCompleteDateAndTimeWidget extends StatelessWidget {
  final String title;
  final String data;
  final bool isIconVisible;
  const WorkCompleteDateAndTimeWidget({
    super.key,
    required this.title,
    required this.data,
    this.isIconVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ce6e6e6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi),
          UIHelper.verticalSpace(12.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data,
                style: TextFontStyle.headline16w700c202020StyleSatoshi,
              ),
              isIconVisible
                  ? SvgPicture.asset(Assets.icons.calendarLogo)
                  : SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }
}

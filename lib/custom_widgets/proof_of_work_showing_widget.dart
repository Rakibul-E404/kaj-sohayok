import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/text_font_style.dart';
import '../gen/colors.gen.dart';
import '../helpers/ui_helpers.dart';

class ProofOfWorkShowingWidget extends StatelessWidget {
  final String title;
  final Widget child;
  const ProofOfWorkShowingWidget({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.all(24.sp),
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
          /// Section : Title
          Text(title, style: TextFontStyle.headline16w700c111111StyleSatoshi),
          UIHelper.verticalSpace(16.h),

          /// Section : Dotted Border Image
          DottedBorder(
            options: RectDottedBorderOptions(
              color: AppColors.c778beb,
              dashPattern: [4, 2],
              strokeCap: StrokeCap.round,
              strokeWidth: 1.w,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

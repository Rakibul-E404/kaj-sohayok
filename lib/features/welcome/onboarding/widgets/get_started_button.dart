import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class GetStartedButton extends StatelessWidget {
  final String buttonTitle;
  final void Function()? onTap;
  const GetStartedButton({super.key, required this.buttonTitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w),
        decoration: BoxDecoration(
          color: AppColors.c778beb,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              buttonTitle,
              style: TextFontStyle.headline16w700cFFFFFFStyleSatoshi,
            ),
            UIHelper.horizontalSpace(10.w),

            ///Section : Button Icon
            Container(
              padding: EdgeInsets.all(6.sp),
              decoration: BoxDecoration(
                color: AppColors.cFFFFFF,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(fit: BoxFit.cover, Assets.icons.rocket),
            ),
          ],
        ),
      ),
    );
  }
}

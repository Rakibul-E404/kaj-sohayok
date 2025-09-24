import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_card.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../gen/colors.gen.dart';

class SvpJobCard extends StatelessWidget {
  final String title;
  final int totalJobs;
  final void Function()? onTap;
  const SvpJobCard({
    super.key,
    required this.title,
    required this.totalJobs,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.cFFFFFF,
          boxShadow: [
            BoxShadow(
              color: AppColors.c000000.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ///Section : Job Type Image
            Image.asset(
              height: 56.h,
              width: 56.w,
              fit: BoxFit.contain,
              Assets.images.svpJobTypeImage.path,
            ),
            UIHelper.verticalSpace(12.h),

            ///Section : Title
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextFontStyle.headline18w700c414141StyleSatoshi,
              ),
            ),
            UIHelper.verticalSpace(14.h),

            ///Section : Divider
            Divider(),
            UIHelper.verticalSpace(14.h),

            ///Section : Total Available count
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Total ",
                    style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                  ),
                  TextSpan(
                    text: "(${totalJobs})",
                    style: TextFontStyle.headline16w700c778bebStyleSatoshi,
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

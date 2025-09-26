import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constant_text.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';

class InitialCostWIdget extends StatelessWidget {
  const InitialCostWIdget({super.key, required this.initialCost});

  final double initialCost;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Start from ${AppText.bdTkSign}",
                  style: TextFontStyle.headline12w500c6a6a6aStyleSatoshi,
                ),
                TextSpan(
                  text: "$initialCost",
                  style: TextFontStyle.headline18w700c778bebStyleSatoshi,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_constant_text.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';

class TotalPaymentShowingWidget extends StatelessWidget {
  const TotalPaymentShowingWidget({super.key, required this.totalPayment});

  final double totalPayment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cf1f3fd,
        border: Border.all(color: AppColors.ce6e6e6),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.ca4b1f2.withAlpha(80),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ///Section : Text-> Total Payment
          Text(
            'total_payment'.tr,
            style: TextFontStyle.headline16w700c202020StyleSatoshi,
          ),

          ///Section : Payment Price
          Text(
            "${AppText.bdTkSign}$totalPayment",
            style: TextFontStyle.headline16w700c778bebStyleSatoshi,
          ),
        ],
      ),
    );
  }
}

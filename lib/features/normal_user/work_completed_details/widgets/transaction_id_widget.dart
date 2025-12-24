import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/utils.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class TransactionIdWidget extends StatelessWidget {
  const TransactionIdWidget({super.key, required this.transactionID});

  final String? transactionID;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        border: Border.all(color: AppColors.ce6e6e6),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.c000000.withAlpha(40),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: AppColors.c778beb,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: SvgPicture.asset(Assets.icons.walletIcon),
          ),
          UIHelper.horizontalSpace(10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'transaction_id'.tr,
                style: TextFontStyle.headline16w700c1d242dStyleSatoshi,
              ),
              UIHelper.verticalSpace(4.h),
              Text(
                "$transactionID",
                style: TextFontStyle.headline12w400c727272StyleSatoshi,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

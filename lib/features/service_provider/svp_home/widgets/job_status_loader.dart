import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/custom_widgets/custom_shimmer_effect.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class JobStatusLoader extends StatelessWidget {
  const JobStatusLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF.withValues(alpha: 0.05),

        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ///Section : Job Type Image
          CustomShimmerEffect(height: 56.h, width: 56.w),
          UIHelper.verticalSpace(12.h),

          ///Section : Title
          CustomShimmerEffect(height: 10.h, width: 1.sw),
          UIHelper.verticalSpace(14.h),

          ///Section : Divider
          CustomShimmerEffect(height: 10.h, width: 1.sw),
          UIHelper.verticalSpace(14.h),

          ///Section : Total Available count
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomShimmerEffect(height: 10.h, width: 30.w),
              UIHelper.horizontalSpace(10.w),
              CustomShimmerEffect(height: 10.h, width: 30.w),
            ],
          ),
        ],
      ),
    );
  }
}

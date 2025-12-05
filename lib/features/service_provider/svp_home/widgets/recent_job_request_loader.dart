import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/custom_widgets/custom_shimmer_effect.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

class RecentJobRequestLoader extends StatelessWidget {
  const RecentJobRequestLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.c000000.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomShimmerEffect(
                height: 40.h,
                width: 40.w,
                isShapUsed: true,
                shapType: BoxShape.circle,
              ),
              UIHelper.horizontalSpace(10.w),
              CustomShimmerEffect(height: 10.h, width: 0.6.sw),
            ],
          ),
          UIHelper.verticalSpace(10.h),

          CustomShimmerEffect(height: 2.h, width: 1.sw),
          UIHelper.verticalSpace(10.h),

          Row(
            children: [
              CustomShimmerEffect(
                height: 20,
                width: 20,
                isShapUsed: true,
                shapType: BoxShape.circle,
              ),
              UIHelper.horizontalSpace(10.w),
              CustomShimmerEffect(height: 5.h, width: 0.6.sw),
            ],
          ),
          UIHelper.verticalSpace(10.h),

          Row(
            children: [
              CustomShimmerEffect(
                height: 20,
                width: 20,
                isShapUsed: true,
                shapType: BoxShape.circle,
              ),
              UIHelper.horizontalSpace(10.w),
              CustomShimmerEffect(height: 5.h, width: 0.6.sw),
            ],
          ),
        ],
      ),
    );
  }
}

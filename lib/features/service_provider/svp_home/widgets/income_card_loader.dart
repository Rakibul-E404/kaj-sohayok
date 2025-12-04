import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/custom_widgets/custom_shimmer_effect.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../gen/colors.gen.dart';

class IncomeCardLoader extends StatelessWidget {
  const IncomeCardLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF.withValues(alpha: 0.05),

        borderRadius: BorderRadius.circular(16.r),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomShimmerEffect(height: 10.h, width: 120.w),
              CustomShimmerEffect(height: 30.h, width: 60.w),
            ],
          ),
          UIHelper.verticalSpace(10.h),
          CustomShimmerEffect(height: 30.h, width: 60.w),
          UIHelper.verticalSpace(20.h),
          Row(
            children: [
              Column(
                children: [
                  CustomShimmerEffect(height: 10.h, width: 20.w),
                  UIHelper.verticalSpace(10.h),

                  CustomShimmerEffect(height: 10.h, width: 20.w),
                  UIHelper.verticalSpace(10.h),

                  CustomShimmerEffect(height: 10.h, width: 20.w),
                  UIHelper.verticalSpace(10.h),

                  CustomShimmerEffect(height: 10.h, width: 20.w),
                  UIHelper.verticalSpace(10.h),

                  CustomShimmerEffect(height: 10.h, width: 20.w),
                  UIHelper.verticalSpace(10.h),
                ],
              ),
              UIHelper.horizontalSpace(20.w),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        CustomShimmerEffect(height: 70.h, width: 10.w),
                        UIHelper.verticalSpace(10.h),
                        CustomShimmerEffect(height: 10.h, width: 10.w),
                      ],
                    ),
                    UIHelper.horizontalSpace(10.w),

                    Column(
                      children: [
                        CustomShimmerEffect(height: 70.h, width: 10.w),
                        UIHelper.verticalSpace(10.h),
                        CustomShimmerEffect(height: 10.h, width: 10.w),
                      ],
                    ),
                    UIHelper.horizontalSpace(10.w),

                    Column(
                      children: [
                        CustomShimmerEffect(height: 70.h, width: 10.w),
                        UIHelper.verticalSpace(10.h),
                        CustomShimmerEffect(height: 10.h, width: 10.w),
                      ],
                    ),
                    UIHelper.horizontalSpace(10.w),

                    Column(
                      children: [
                        CustomShimmerEffect(height: 70.h, width: 10.w),
                        UIHelper.verticalSpace(10.h),
                        CustomShimmerEffect(height: 10.h, width: 10.w),
                      ],
                    ),
                    UIHelper.horizontalSpace(10.w),

                    Column(
                      children: [
                        CustomShimmerEffect(height: 70.h, width: 10.w),
                        UIHelper.verticalSpace(10.h),
                        CustomShimmerEffect(height: 10.h, width: 10.w),
                      ],
                    ),
                    UIHelper.horizontalSpace(10.w),

                    Column(
                      children: [
                        CustomShimmerEffect(height: 70.h, width: 10.w),
                        UIHelper.verticalSpace(10.h),
                        CustomShimmerEffect(height: 10.h, width: 10.w),
                      ],
                    ),
                    UIHelper.horizontalSpace(10.w),

                    Column(
                      children: [
                        CustomShimmerEffect(height: 70.h, width: 10.w),
                        UIHelper.verticalSpace(10.h),
                        CustomShimmerEffect(height: 10.h, width: 10.w),
                      ],
                    ),
                    UIHelper.horizontalSpace(10.w),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/custom_widgets/custom_shimmer_effect.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

class ProviderProfileDetailsShimmerEffect extends StatelessWidget {
  const ProviderProfileDetailsShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomShimmerEffect(
              height: 94.h,
              width: 94.w,
              isShapUsed: true,
              shapType: BoxShape.circle,
            ),
            UIHelper.horizontalSpace(10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomShimmerEffect(height: 10.h, width: 0.4.sw),
                    UIHelper.horizontalSpace(10.w),
                    CustomShimmerEffect(
                      height: 40.h,
                      width: 20.w,
                      isShapUsed: true,
                      shapType: BoxShape.circle,
                    ),
                    UIHelper.horizontalSpace(10.w),
                    CustomShimmerEffect(
                      height: 40.h,
                      width: 20.w,
                      isShapUsed: true,
                      shapType: BoxShape.circle,
                    ),
                  ],
                ),
                UIHelper.verticalSpace(10.h),
                Row(
                  children: [
                    CustomShimmerEffect(height: 10.h, width: 40.w),
                    UIHelper.horizontalSpace(10.w),
                    CustomShimmerEffect(height: 10.h, width: 40.w),
                  ],
                ),
              ],
            ),
          ],
        ),

        UIHelper.verticalSpace(10.h),
        CustomShimmerEffect(height: 10.h, width: 1.sw),
        UIHelper.verticalSpace(20.h),

        CustomShimmerEffect(height: 50.h, width: 1.sw),
        UIHelper.verticalSpace(20.h),

        CustomShimmerEffect(height: 50.h, width: 1.sw),
        UIHelper.verticalSpace(20.h),

        CustomShimmerEffect(height: 50.h, width: 1.sw),
        UIHelper.verticalSpace(20.h),

        CustomShimmerEffect(height: 50.h, width: 1.sw),
        UIHelper.verticalSpace(20.h),

        CustomShimmerEffect(height: 50.h, width: 1.sw),
        UIHelper.verticalSpace(20.h),

        CustomShimmerEffect(height: 0.h, width: 1.sw),
        UIHelper.verticalSpace(20.h),

        CustomShimmerEffect(height: 50.h, width: 1.sw),
        UIHelper.verticalSpace(20.h),
      ],
    );
  }
}

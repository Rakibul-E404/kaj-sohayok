import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/custom_widgets/custom_shimmer_effect.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

class CustomLoaderForAllPopularProvider extends StatelessWidget {
  const CustomLoaderForAllPopularProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.4.sw,
      height: 0.2.sh,
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomShimmerEffect(height: 50.h, width: 0.4.sw),
          UIHelper.verticalSpace(10.h),

          CustomShimmerEffect(height: 8.h, width: 0.4.sw),
          UIHelper.verticalSpace(10.h),
          Row(
            children: [
              CustomShimmerEffect(height: 5.h, width: 0.17.sw),
              UIHelper.horizontalSpace(10.w),
              CustomShimmerEffect(height: 5.h, width: 0.17.sw),
            ],
          ),
          UIHelper.verticalSpace(10.h),
          Row(
            children: [
              CustomShimmerEffect(height: 5.h, width: 0.1.sw),
              UIHelper.horizontalSpace(10.w),
              CustomShimmerEffect(height: 5.h, width: 0.1.sw),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/features/service_provider/svp_home/widgets/custom_chart_bar_widget.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/appList.dart';
import '../../../../controllers/svp_home_screen_controller.dart';

class IncomeChartCard extends StatelessWidget {
  IncomeChartCard({super.key});

  final SvpHomeScreenController controller = Get.put(
    SvpHomeScreenController(),
  ); // inject controller

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 250.h,
      padding: EdgeInsets.symmetric(horizontal: 18.0.w, vertical: 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.cFFFFFF,
        boxShadow: [
          BoxShadow(
            color: AppColors.c000000.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Income',
                style: TextFontStyle.headline16w700c4d4d4dStyleSatoshi,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.cf1f3fd,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.c92a2ef),
                ),
                child: Obx(
                  () => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isDense: true,
                      isExpanded: false,
                      value: controller.selectedPeriod.value,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        size: 14.sp,
                        color: AppColors.c000000,
                      ),
                      style: TextFontStyle.headline12w500c000000StyleSatoshi,
                      items: ['Weekly', 'Monthly'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        controller.selectedPeriod.value = newValue!;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(8.h),

          // Section: Total Income
          Obx(
            () => Text(
              controller.formattedIncome,
              style: TextFontStyle.headline22w700c778bebStyleSatoshi,
            ),
          ),
          UIHelper.verticalSpace(10.h),

          // Chart
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                Obx(
                  () => SizedBox(
                    height: 120.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.selectedPeriod.value == 'Weekly'
                              ? '20 K'
                              : '60 K',
                          style:
                              TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                        ),
                        Text(
                          controller.selectedPeriod.value == 'Weekly'
                              ? '15 K'
                              : '45 K',
                          style:
                              TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                        ),
                        Text(
                          controller.selectedPeriod.value == 'Weekly'
                              ? '10 K'
                              : '30 K',
                          style:
                              TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                        ),
                        Text(
                          controller.selectedPeriod.value == 'Weekly'
                              ? '5 K'
                              : '15 K',
                          style:
                              TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                        ),
                        Text(
                          '0 K',
                          style:
                              TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                        ),
                      ],
                    ),
                  ),
                ),
                UIHelper.horizontalSpace(8.w),

                // Custom Chart
                Expanded(
                  child: Obx(
                    () => SizedBox(
                      height: 120.h,
                      child: Column(
                        children: [
                          // Chart area
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: AppList
                                  .chartData[controller.selectedPeriod.value]!
                                  .map(
                                    (data) => CustomBar(
                                      value: data.value,
                                      maxValue: controller.maxValue,
                                      label: data.day,
                                      barWidth:
                                          controller.selectedPeriod.value ==
                                              "Monthly"
                                          ? 14.w
                                          : 28.w,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          UIHelper.verticalSpace(8.h),

                          // X-axis labels
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: AppList
                                .chartData[controller.selectedPeriod.value]!
                                .map(
                                  (data) => Text(
                                    data.day,
                                    style: TextFontStyle
                                        .headline12w500c4d4d4dStyleSatoshi
                                        .copyWith(
                                          fontSize:
                                              controller.selectedPeriod.value ==
                                                  "Monthly"
                                              ? 8.sp
                                              : 12.sp,
                                        ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

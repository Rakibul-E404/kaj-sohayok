import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/features/service_provider/svp_home/widgets/custom_chart_bar_widget.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../controllers/svp_home_screen_controller.dart';

class IncomeChartCard extends StatelessWidget {
  IncomeChartCard({super.key});

  final SvpHomeScreenController controller =
      Get.find<SvpHomeScreenController>();

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
                      items: ['weekly', 'monthly'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value[0].toUpperCase() + value.substring(1),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.selectedPeriod.value = newValue;
                          controller.getServiceProviderHomeData();
                        }
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
            child: Obx(() {
              final chartData = controller.chartData;
              final maxValue = controller.maxValue;

              final  List<String> yAxisLabels = _generateYAxisLabels(maxValue);
              if (chartData.isEmpty) {
                return const Center(child: Text('No chart data available'));
              }

              // Generate Y-axis labels based on maxValue

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Y-axis labels
                  SizedBox(
                    height: 120.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: yAxisLabels.reversed.map((label) {
                        return Text(
                          label,
                          style:
                              TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                        );
                      }).toList(),
                    ),
                  ),
                  UIHelper.horizontalSpace(8.w),

                  // Custom Chart
                  Expanded(
                    child: SizedBox(
                      height: 120.h,
                      child: Column(
                        children: [
                          // Combined chart area with bars and labels - Make it scrollable when there are too many items
                          Obx(() {
                            // Access the observable values to ensure reactivity
                            final localChartData = controller.chartData;
                            final localMaxValue = controller.maxValue;
                            final localSelectedPeriod = controller.selectedPeriod.value;

                            // If there are many items (> 7), make it horizontally scrollable
                            bool shouldScroll = localChartData.length > 7;

                            return Expanded(
                              child: shouldScroll
                                ? SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: localChartData.asMap().entries.map((entry) {
                                        var data = entry.value;
                                        return Container(
                                          margin: EdgeInsets.only(right: 8.w),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              // Bar
                                              CustomBar(
                                                value: (data.income ?? 0).toDouble(),
                                                maxValue: localMaxValue,
                                                label: data.label ?? '',
                                                barWidth: 14.w,
                                              ),
                                              UIHelper.verticalSpace(4.h), // Reduced to save space
                                              // Label below the bar
                                              Text(
                                                data.label ?? '',
                                                style: TextFontStyle
                                                    .headline12w500c4d4d4dStyleSatoshi
                                                    .copyWith(fontSize: 8.sp), // Reduced font size to save space
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: localChartData.asMap().entries.map((entry) {
                                      var data = entry.value;
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          // Bar
                                          CustomBar(
                                            value: (data.income ?? 0).toDouble(),
                                            maxValue: localMaxValue,
                                            label: data.label ?? '',
                                            barWidth: 14.w,
                                          ),
                                          UIHelper.verticalSpace(4.h), // Reduced to save space
                                          // Label below the bar
                                          Text(
                                            data.label ?? '',
                                            style: TextFontStyle
                                                .headline12w500c4d4d4dStyleSatoshi
                                                .copyWith(fontSize: 8.sp), // Reduced font size to save space
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // Helper method to generate Y-axis labels with proper "K" formatting
  List<String> _generateYAxisLabels(double maxValue) {
    // Create 5 evenly spaced labels (including 0 at bottom)
    final labels = <String>[];

    // Generate from 0 to maxValue (ascending)
    for (int i = 0; i <= 5; i++) {
      final value = (maxValue * i / 5).toInt();

      // Format the value with "K" for thousands if value >= 1000
      if (value >= 1000) {
        labels.add(
          '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K',
        );
      } else {
        labels.add(value.toString());
      }
    }

    return labels;
  }
}

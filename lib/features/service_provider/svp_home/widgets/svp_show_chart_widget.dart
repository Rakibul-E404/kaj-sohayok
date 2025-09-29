import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/features/service_provider/svp_home/widgets/custom_chart_bar_widget.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/appList.dart';
import '../model/chart_data_model.dart';

class IncomeChartCard extends StatefulWidget {
  const IncomeChartCard({super.key});

  @override
  IncomeChartCardState createState() => IncomeChartCardState();
}

class IncomeChartCardState extends State<IncomeChartCard> {
  String selectedPeriod = 'Weekly';
  double get totalIncome {
    return AppList.chartData[selectedPeriod]!.fold(
      0.0,
      (sum, item) => sum + item.value,
    );
  }

  String get formattedIncome {
    return '\$${totalIncome.toStringAsFixed(0)}';
  }

  double get maxValue {
    return selectedPeriod == 'Weekly' ? 20000 : 60000;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 250.h,
      padding: EdgeInsets.symmetric(horizontal: 18.0.w, vertical: 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.amber,
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
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.cf1f3fd,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.c92a2ef),
                ),
                child: DropdownButton<String>(
                  value: selectedPeriod,
                  underline: const SizedBox.shrink(),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16.sp,
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
                    setState(() {
                      selectedPeriod = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(8.h),

          //Section : Total Income
          Text(
            formattedIncome,
            style: TextFontStyle.headline22w700c778bebStyleSatoshi,
          ),
          UIHelper.verticalSpace(10.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                SizedBox(
                  height: 120.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedPeriod == 'Weekly' ? '20 K' : '60 K',
                        style: TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                      ),
                      Text(
                        selectedPeriod == 'Weekly' ? '15 K' : '45 K',
                        style: TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                      ),
                      Text(
                        selectedPeriod == 'Weekly' ? '10 K' : '30 K',
                        style: TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                      ),
                      Text(
                        selectedPeriod == 'Weekly' ? '5 K' : '15 K',
                        style: TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                      ),
                      Text(
                        '0 K',
                        style: TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                      ),
                    ],
                  ),
                ),
                UIHelper.horizontalSpace(8.w),

                // Custom Chart
                Expanded(
                  child: SizedBox(
                    height: 120.h,
                    child: Column(
                      children: [
                        // Chart area
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: AppList.chartData[selectedPeriod]!
                                .map(
                                  (data) => CustomBar(
                                    value: data.value,
                                    maxValue: maxValue,
                                    label: data.day,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        UIHelper.verticalSpace(8.h),

                        // X-axis labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: AppList.chartData[selectedPeriod]!
                              .map(
                                (data) => Text(
                                  data.day,
                                  style: TextFontStyle
                                      .headline12w500c4d4d4dStyleSatoshi,
                                ),
                              )
                              .toList(),
                        ),
                      ],
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

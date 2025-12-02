import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../../controllers/calender_controller.dart';

class CalenderHeaderWidget extends StatelessWidget {
  const CalenderHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ///------------------------------------------- Initialize the controller
    final CalendarController controller = Get.find<CalendarController>();
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.c778beb,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ///Section : Arrow Left
          IconButton(
            onPressed: () => controller.previousMonth(),
            icon: Icon(
              Icons.chevron_left,
              color: AppColors.cFFFFFF,
              size: 24.sp,
            ),
          ),

          ///Section : Month & Year at Middle
          GestureDetector(
            onDoubleTap: () => controller.goToToday(),
            child: Obx(
              () => Text(
                controller.currentMonthYear,
                style: TextFontStyle.headline18w600cFFFFFFStyleSatoshi,
              ),
            ),
          ),

          ///Section : Arrow Right
          IconButton(
            onPressed: () => controller.nextMonth(),
            icon: Icon(
              Icons.chevron_right,
              color: AppColors.cFFFFFF,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }
}

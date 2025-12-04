import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';

import '../../../../../controllers/calender_controller.dart';

class CalendarWeekDaysWidget extends StatelessWidget {
  const CalendarWeekDaysWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ///------------------------------------------- Initialize the controller
    final CalendarController controller = Get.find<CalendarController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: controller.weekDays.map((day) {
        return SizedBox(
          width: 40.w,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextFontStyle.headline14w500c202020StyleSatoshi,
          ),
        );
      }).toList(),
    );
  }
}

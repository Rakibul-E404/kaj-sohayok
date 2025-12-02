import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/features/normal_user/booking_date/presentation/widgets/calendar_week_days_widget.dart';
import 'package:kaz_bd/features/normal_user/booking_date/presentation/widgets/calender_header_widget.dart';
import 'package:kaz_bd/features/normal_user/booking_date/presentation/widgets/display_calendar_days.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

class CalenderContainerWidget extends StatelessWidget {
  const CalenderContainerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffe1e6fd),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.c000000.withValues(alpha: 0.1),
            blurRadius: 10.sp,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ///Section : Calender Header Widget
            CalenderHeaderWidget(),
            UIHelper.verticalSpace(20.h),

            ///Section : Calender Week Days Widget
            CalendarWeekDaysWidget(),
            UIHelper.verticalSpace(10.h),

            ///Section : Display Calender Dates at Days Widget
            Card(child: DisplayCalendarDays()),
          ],
        ),
      ),
    );
  }
}

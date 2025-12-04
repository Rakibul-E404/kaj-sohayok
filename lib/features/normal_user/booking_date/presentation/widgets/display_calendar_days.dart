import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../controllers/calender_controller.dart';

class DisplayCalendarDays extends StatelessWidget {
  const DisplayCalendarDays({super.key});

  @override
  Widget build(BuildContext context) {
    ///------------------------------------------- Initialize the controller
    final CalendarController controller = Get.find<CalendarController>();
    return Obx(() {
      final firstDay = DateTime(
        controller.focusedDay.value.year,
        controller.focusedDay.value.month,
        1,
      );
      int firstWeekday = firstDay.weekday % 7;
      DateTime startDate = firstDay.subtract(Duration(days: firstWeekday));

      List<Widget> weeks = [];

      for (int week = 0; week < 6; week++) {
        List<Widget> weekDays = [];

        for (int day = 0; day < 7; day++) {
          DateTime currentDate = startDate.add(Duration(days: week * 7 + day));

          bool isCurrentMonth =
              currentDate.month == controller.focusedDay.value.month;
          bool isSelected =
              controller.selectedDay.value != null &&
              controller.isSameDay(currentDate, controller.selectedDay.value!);
          bool isToday = controller.isSameDay(currentDate, DateTime.now());

          weekDays.add(
            GestureDetector(
              onTap: () => controller.selectDay(currentDate),
              child: Container(
                width: 40,
                height: 40,
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Color(0xFF6B73FF) : null,
                  border: isToday && !isSelected
                      ? Border.all(color: Color(0xFF6B73FF), width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${currentDate.day}',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isCurrentMonth
                          ? (isToday ? Color(0xFF6B73FF) : Colors.black87)
                          : Colors.grey[400],
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : isToday
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        weeks.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays,
          ),
        );
      }

      return Column(
        children: weeks
            .map(
              (week) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: week,
              ),
            )
            .toList(),
      );
    });
  }
}

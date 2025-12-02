import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalendarController extends GetxController {
  /// Observable variables
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime?> selectedDay = DateTime.now().obs;
  final Rx<TimeOfDay> selectedTime =
      TimeOfDay.now().obs; // Time picker observable

  ///------------------------------------ Static lists (no need to be observable)
  final List<String> weekDays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];
  final List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  ///================================ Methods for navigation
  void previousMonth() {
    focusedDay.value = DateTime(
      focusedDay.value.year,
      focusedDay.value.month - 1,
      1,
    );
  }

  void nextMonth() {
    focusedDay.value = DateTime(
      focusedDay.value.year,
      focusedDay.value.month + 1,
      1,
    );
  }

  void goToToday() {
    focusedDay.value = DateTime.now();
    selectedDay.value = DateTime.now();
  }

  void selectDay(DateTime day) {
    selectedDay.value = DateTime(day.year, day.month, day.day);
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String get currentMonthYear {
    return '${months[focusedDay.value.month - 1]} ${focusedDay.value.year}';
  }

  void selectTime(TimeOfDay time) {
    selectedTime.value = time;
  }
}

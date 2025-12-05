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

  ///Imtiaz Date Time Code Implemtation Start  Here,
  /// Combine selected date and time into DateTime
  DateTime get combinedDateTime {
    if (selectedDay.value == null) {
      // If no date selected, use today with selected time
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.value.hour,
        selectedTime.value.minute,
      );
    }

    return DateTime(
      selectedDay.value!.year,
      selectedDay.value!.month,
      selectedDay.value!.day,
      selectedTime.value.hour,
      selectedTime.value.minute,
    );
  }

  /// Format for API: "2025-12-03T10:55:00"
  String get apiFormattedDateTime {
    final dateTime = combinedDateTime;

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String fourDigits(int n) => n.toString().padLeft(4, '0');

    final year = fourDigits(dateTime.year);
    final month = twoDigits(dateTime.month);
    final day = twoDigits(dateTime.day);
    final hour = twoDigits(dateTime.hour);
    final minute = twoDigits(dateTime.minute);
    final second = twoDigits(dateTime.second);

    return '$year-$month-${day}T$hour:$minute:$second';
  }

  /// Check if selected date/time is in future
  bool get isFutureDateTime {
    final selected = combinedDateTime;
    final now = DateTime.now();
    return selected.isAfter(now);
  }

  /// Format for display: "Dec 03, 2025 10:55 AM"
  String get displayFormattedDateTime {
    final dateTime = combinedDateTime;
    final monthNames = [
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

    final month = monthNames[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final amPm = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$month $day, $year $displayHour:$minute $amPm';
  }

  ///Imtiaz Date Time Code Implemtation End  Here,
}

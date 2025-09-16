import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../../constants/text_font_style.dart';

///------------------------------------- GetX Controller for Calendar State Management
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

///----------------------------------screen class
class BookingDateScreen extends StatelessWidget {
  const BookingDateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ///------------------------------------------- Initialize the controller
    final CalendarController controller = Get.put(CalendarController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            // todo: back function
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          "Booking Date",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildCalendarContainer(controller),
              SizedBox(height: 20),
              _buildTimePicker(controller), // Add Time Picker here
              Spacer(), // This will push the button to the bottom
              _buildProceedButton(controller), // Proceed Button here
            ],
          ),
        ),
      ),
    );
  }

  ///-------------------------------------------- Calendar container
  Widget _buildCalendarContainer(CalendarController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffe1e6fd),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildHeader(controller),
            SizedBox(height: 20),
            _buildWeekDays(controller),
            SizedBox(height: 10),
            _buildCalendarDays(controller),
          ],
        ),
      ),
    );
  }

  ///--------------------------------- Calendar header with navigation buttons
  Widget _buildHeader(CalendarController controller) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B73FF), Color(0xFF6B73FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => controller.previousMonth(),
            icon: Icon(Icons.chevron_left, color: Colors.white, size: 24),
          ),
          GestureDetector(
            onDoubleTap: () => controller.goToToday(),
            child: Obx(
              () => Text(
                controller.currentMonthYear,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => controller.nextMonth(),
            icon: Icon(Icons.chevron_right, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  ///-------------------------------- Displaying week days (Sun, Mon, Tue...)
  Widget _buildWeekDays(CalendarController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: controller.weekDays.map((day) {
        return SizedBox(
          width: 40,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Displaying calendar days
  Widget _buildCalendarDays(CalendarController controller) {
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

  // Time picker widget
  Widget _buildTimePicker(CalendarController controller) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? selected = await showTimePicker(
          context: Get.context!,
          initialTime: controller.selectedTime.value,
        );
        if (selected != null) {
          controller.selectTime(selected);
        }
      },
      child: Obx(() {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: Color(0xffe1e6fd),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Selected Time:', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Text(
                    '${controller.selectedTime.value.format(Get.context!)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.access_time, color: Color(0xFF6B73FF)),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // Proceed button at the bottom
  Widget _buildProceedButton(CalendarController controller) {
    return SizedBox(
      width: Get.width,
      child: ElevatedButton(
        onPressed: () {
          Get.toNamed(Routes.searchLocationScreen);
          print("Proceed button pressed");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF6B73FF), // Button color
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Proceed',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

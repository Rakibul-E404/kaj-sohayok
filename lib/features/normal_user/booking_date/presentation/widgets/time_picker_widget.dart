import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../controllers/calender_controller.dart';

class TimePickerWidget extends StatelessWidget {
  const TimePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ///------------------------------------------- Initialize the controller
    final CalendarController controller = Get.find<CalendarController>();
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
}

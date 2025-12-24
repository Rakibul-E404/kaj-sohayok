// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kaz_bd/gen/colors.gen.dart';

// import '../../../../../controllers/calender_controller.dart';

// class TimePickerWidget extends StatelessWidget {
//   const TimePickerWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     ///------------------------------------------- Initialize the controller
//     final CalendarController controller = Get.find<CalendarController>();
//     return GestureDetector(
//       onTap: () async {
//         final TimeOfDay? selected = await showTimePicker(
//           context: Get.context!,
//           initialTime: controller.selectedTime.value,
//         );
//         if (selected != null) {
//           controller.selectTime(selected);
//         }
//       },
//       child: Obx(() {
//         final isFuture = controller.isFutureDateTime;
//         return Container(
//           padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
//           decoration: BoxDecoration(
//             color: isFuture ? AppColors.cee3333 : Color(0xffe1e6fd),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('Selected Time:', style: TextStyle(fontSize: 16)),
//               Row(
//                 children: [
//                   Text(
//                     '${controller.selectedTime.value.format(Get.context!)}',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   Icon(Icons.access_time, color: Color(0xFF6B73FF)),
//                 ],
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }

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
        final isFuture = controller.isFutureDateTime;
        return Container(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: isFuture ? Color(0xffe1e6fd) : Color(0xfffff0f0),
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
              Text('selected_time'.tr, style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Text(
                    '${controller.selectedTime.value.format(Get.context!)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isFuture ? Colors.black : Colors.red,
                    ),
                  ),
                  Icon(
                    Icons.access_time,
                    color: isFuture ? Color(0xFF6B73FF) : Colors.red,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

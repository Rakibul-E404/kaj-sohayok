// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:kaz_bd/features/normal_user/booking_date/presentation/widgets/calender_container_widget.dart';
// import 'package:kaz_bd/features/normal_user/booking_date/presentation/widgets/time_picker_widget.dart';
// import 'package:kaz_bd/helpers/ui_helpers.dart';

// import '../../../../constants/text_font_style.dart';
// import '../../../../controllers/calender_controller.dart';
// import '../../../../custom_widgets/custom_elevated_button.dart';
// import '../../../../gen/colors.gen.dart';
// import '../../../../routes/routes.dart';

// class BookingDateScreen extends StatelessWidget {
//   const BookingDateScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final arguments = Get.arguments as Map<String, dynamic>?;
//     final providerId = arguments?['providerId'] ?? '';

//     ///------------------------------------------- Initialize the controller
//     final CalendarController controller = Get.find<CalendarController>();
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         automaticallyImplyLeading: true,
//         title: Text(
//           "Booking Date",
//           style: TextFontStyle.headline18w700c000000StyleSatoshi,
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             children: [
//               CalenderContainerWidget(),
//               UIHelper.verticalSpace(20.h),

//               TimePickerWidget(),
//               Spacer(),

//               CustomElevatedButton(
//                 onTap: () {
//                   Get.toNamed(Routes.searchLocationScreen);
//                   log("Proceed button pressed");
//                 },
//                 buttonTitle: "Proceed",
//                 textStyle: TextFontStyle.headline16w700cFFFFFFStyleSatoshi,
//                 buttonColor: AppColors.c778beb,
//                 borderRadius: 12.r,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/features/normal_user/booking_date/presentation/widgets/calender_container_widget.dart';
import 'package:kaz_bd/features/normal_user/booking_date/presentation/widgets/time_picker_widget.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../controllers/calender_controller.dart';
import '../../../../controllers/normal_user_booking_service_provider_controller.dart';
import '../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../routes/routes.dart';

class BookingDateScreen extends StatelessWidget {
  const BookingDateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final providerId = arguments?['providerId'] ?? '';

    log('BookingDateScreen - Received providerId: $providerId');

    ///------------------------------------------- Initialize the controllers
    final CalendarController controller = Get.find<CalendarController>();
    final bookingController =
        Get.find<NormalUserBookingServiceProviderController>();

    // Set provider ID in the booking controller
    log(
      'BookingDateScreen - Before setting, bookingController.providerId: ${bookingController.serviceProviderId.value}',
    );
    bookingController.setServiceProviderId(svpId: providerId);
    log(
      'BookingDateScreen - After setting, bookingController.providerId: ${bookingController.serviceProviderId.value}',
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
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
              CalenderContainerWidget(),
              UIHelper.verticalSpace(20.h),

              TimePickerWidget(),

              Spacer(),

              CustomElevatedButton(
                onTap: () async {
                  // Validate if date/time is in future
                  if (!controller.isFutureDateTime) {
                    Get.snackbar(
                      'Invalid Selection',
                      'Please select a future date and time',
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  // Double check provider ID before availability check
                  final currentProviderId =
                      bookingController.serviceProviderId.value;
                  if (currentProviderId.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Provider ID is missing. Cannot check availability.',
                      backgroundColor: AppColors.cee3333,
                      colorText: AppColors.cFFFFFF,
                    );
                    log(
                      'BookingDateScreen - Provider ID is empty, cannot check availability',
                    );
                    return;
                  }

                  log(
                    'BookingDateScreen - Calling availability check with providerId: $currentProviderId',
                  );

                  // Check availability first using the already initialized booking controller
                  await bookingController
                      .checkAvailabilityWithCalendarController();

                  // Only proceed if available
                  if (bookingController.availabilityResponse.value?.success ==
                      true) {
                    final apiFormattedDateTime =
                        controller.apiFormattedDateTime;

                    log("Proceed button pressed");
                    log("Selected Date/Time: ${controller.combinedDateTime}");
                    log("API Format: $apiFormattedDateTime");

                    Get.toNamed(
                      Routes.searchLocationScreen,
                      arguments: {
                        'providerId':
                            currentProviderId, // Use the validated providerId
                        'bookingDateTime':
                            apiFormattedDateTime, // "2025-12-03T10:55:00"
                      },
                    );
                  }
                },
                buttonTitle: "Check Availability & Proceed",
                textStyle: TextFontStyle.headline16w700cFFFFFFStyleSatoshi,
                buttonColor: AppColors.c778beb,
                borderRadius: 12.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

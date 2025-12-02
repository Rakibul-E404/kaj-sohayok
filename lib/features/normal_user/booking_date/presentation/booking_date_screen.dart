import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/features/normal_user/booking_date/presentation/widgets/calender_container_widget.dart';
import 'package:kaz_bd/features/normal_user/booking_date/presentation/widgets/time_picker_widget.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../controllers/calender_controller.dart';
import '../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../routes/routes.dart';

class BookingDateScreen extends StatelessWidget {
  const BookingDateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final providerId = arguments?['providerId'] ?? '';

    ///------------------------------------------- Initialize the controller
    final CalendarController controller = Get.find<CalendarController>();
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
                onTap: () {
                  Get.toNamed(Routes.searchLocationScreen);
                  log("Proceed button pressed");
                },
                buttonTitle: "Proceed",
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

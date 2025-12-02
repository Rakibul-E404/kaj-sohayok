import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/features/normal_user/booking_date/presentation/widgets/build_proceed_button.dart';
import 'package:kaz_bd/features/normal_user/booking_date/presentation/widgets/calender_container_widget.dart';
import 'package:kaz_bd/features/normal_user/booking_date/presentation/widgets/time_picker_widget.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../controllers/calender_controller.dart';

class BookingDateScreen extends StatelessWidget {
  const BookingDateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ///------------------------------------------- Initialize the controller
    final CalendarController controller = Get.find<CalendarController>();
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
              CalenderContainerWidget(),
              UIHelper.verticalSpace(20.h),

              TimePickerWidget(),
              Spacer(),

              BuildProceedButton(),
            ],
          ),
        ),
      ),
    );
  }
}

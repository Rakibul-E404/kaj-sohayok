import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../routes/routes.dart';
import '../../svp_home/widgets/recent_job_request_widget.dart';

class SvpAcceptedBookingsScreen extends StatelessWidget {
  const SvpAcceptedBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Accepted Booking",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: ListView.separated(
          itemCount: 10,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
              child: RecentJobRequestWidget(
                onTap: () {
                  log("Taped on -> Card");
                  Get.toNamed(Routes.svpJobDetailsScreen);
                },
                startWorkOnTap: () {
                  log("Accept Bookings screen!");
                },
                isJobRequestAccpted: true,

                userImage: Assets.images.userImage.path,
                userName: "Chowdhury Md. Imtiazul Islam",
                location: "Rampura Dhaka, Bangladesh",
                dateTime: "Jun 17, 2025  09:31AM",
              ),
            );
          },
        ),
      ),
    );
  }
}

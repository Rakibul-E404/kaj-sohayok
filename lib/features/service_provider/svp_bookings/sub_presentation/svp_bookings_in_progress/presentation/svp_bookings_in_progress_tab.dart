import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';

class SvpBookingsInProgressTab extends StatelessWidget {
  const SvpBookingsInProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView.separated(
          itemCount: 10,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),

          itemBuilder: (context, index) {
            return RecentJobRequestStatusWidget(
              isJobInProgress: true,
              onTap: null,
              submitWorkButtonOnTap: () {
                log("Submit Button Taped!");
                Get.toNamed(Routes.svpSubmitWorkFormScreen);
              },
              messageButtonOnTap: () {
                log("Message button taped!");
              },
              userImageUrl: Assets.images.userImage.path,
              userName: "Swapon Mia",
              location: "Rampura Dhaka, Bangladesh",
              dateTime: "Jun 17, 2025  09:31AM",
            );
          },
        ),
      ),
    );
  }
}

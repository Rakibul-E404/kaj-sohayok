import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../../../constants/app_enums.dart';
import '../../../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';

class SvpAcceptedBookingsTab extends StatelessWidget {
  const SvpAcceptedBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
          child: ListView.separated(
            itemCount: 10,
            separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
            itemBuilder: (context, index) {
              return RecentJobRequestStatusWidget(
                onTap: () {
                  log("Taped on -> Card");
                  Get.toNamed(
                    Routes.svpJobDetailsScreen,
                    arguments: {"status": JobRequestStatusEnum.accepted},
                  );
                },

                startWorkOnTap: () {
                  log("Accept Bookings screen!");
                },
                isJobRequestAccpted: true,

                userImageUrl: Assets.images.userImage.path,
                userName: "Chowdhury Md. Imtiazul Islam",
                location: "Rampura Dhaka, Bangladesh",
                dateTime: "Jun 17, 2025  09:31AM",
              );
            },
          ),
        ),
      ),
    );
  }
}

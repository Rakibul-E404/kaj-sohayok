import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/recent_job_request_status_widget.dart';

class SvpInProgressScreen extends StatelessWidget {
  const SvpInProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "In Progress",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: UIHelper.kDefaulutPadding(),
          ),
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
                userImage: Assets.images.userImage.path,
                userName: "Swapon Mia",
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

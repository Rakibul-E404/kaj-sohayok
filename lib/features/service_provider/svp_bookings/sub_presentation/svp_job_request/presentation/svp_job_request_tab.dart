import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../constants/app_enums.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';

class SvpJobRequestTab extends StatelessWidget {
  const SvpJobRequestTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
          child: ListView.separated(
            itemCount: 20,
            separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
            itemBuilder: (context, index) {
              return RecentJobRequestStatusWidget(
                onTap: () {
                  log("Tapped on -> Card");
                  Get.toNamed(
                    Routes.svpJobDetailsScreen,
                    arguments: {"status": JobRequestStatusEnum.pending},
                  );
                },
                cancelOnTap: () {
                  log("Button Tapped -> Cancel");
                },
                acceptOnTap: () {
                  log("Button Tapped -> Accept");
                },
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

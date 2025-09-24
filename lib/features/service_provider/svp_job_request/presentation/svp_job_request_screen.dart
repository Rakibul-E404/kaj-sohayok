import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../svp_home/widgets/recent_job_request_widget.dart';

class SvpJobRequestScreen extends StatelessWidget {
  const SvpJobRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Job Request",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: ListView.separated(
            itemCount: 20,
            separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
            itemBuilder: (context, index) {
              return RecentJobRequestWidget(
                onTap: () {
                  log("Taped on -> Card");
                  Get.toNamed(Routes.svpJobDetailsScreen);
                },
                cancelOnTap: () {
                  log("Button Taped -> Cancel");
                },
                acceptOnTap: () {
                  log("Button Taped -> Accept");
                },
                userImage: Assets.images.userImage.path,
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

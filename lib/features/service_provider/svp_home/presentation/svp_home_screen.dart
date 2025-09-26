import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/appList.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../constants/app_enums.dart';
import '../../../../custom_widgets/home_section_applogo_and_notification.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../routes/routes.dart';
import '../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../widgets/svp_job_card.dart';

class SvpHomeScreen extends StatelessWidget {
  const SvpHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ///Section : AppLogo & Notification Section
              HomeSectionAppLogoAndNotification(
                onTap: () {
                  log("Notification Icon taped!");
                  Get.toNamed(Routes.notificationScreen);
                },
              ),
              UIHelper.verticalSpace(16.h),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: UIHelper.kDefaulutPadding(),
                ),
                child: Column(
                  children: [
                    ///Section : Graph Chart

                    ///Section : Job Status Card
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: AppList.svpJobsTypeList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 0.86,
                      ),
                      itemBuilder: (context, index) {
                        var data = AppList.svpJobsTypeList[index];
                        return SvpJobCard(
                          onTap: () {
                            log("${data.title} Card Taped!");
                            index == 0
                                ? Get.toNamed(Routes.svpJobRequestScreen)
                                : index == 1
                                ? Get.toNamed(Routes.svpAcceptedBookingsScreen)
                                : index == 2
                                ? Get.toNamed(Routes.svpInProgressScreen)
                                : index == 3
                                ? Get.toNamed(Routes.svpWorkCompletedScreen)
                                : null;
                          },
                          title: data.title,
                          totalJobs: data.totalJobs,
                        );
                      },
                    ),
                    UIHelper.verticalSpace(24.h),

                    ///Section : Recent Job Request Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Job Request",
                          style:
                              TextFontStyle.headline18w700c202020StyleSatoshi,
                        ),

                        ///Section : Total Available count
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Total ",
                                style: TextFontStyle
                                    .headline14w500c4d4d4dStyleSatoshi,
                              ),
                              TextSpan(
                                text: "(${10})",
                                style: TextFontStyle
                                    .headline16w700c778bebStyleSatoshi,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(16.h),

                    ///Section : Recent Job Requests
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: 10,
                      separatorBuilder: (context, index) =>
                          UIHelper.verticalSpace(24.h),
                      itemBuilder: (contextk, index) {
                        return RecentJobRequestStatusWidget(
                          onTap: () {
                            log("Taped on -> Card");
                            Get.toNamed(
                              Routes.svpJobDetailsScreen,
                              arguments: {
                                "status": JobRequestStatusEnum.pending,
                              },
                            );
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

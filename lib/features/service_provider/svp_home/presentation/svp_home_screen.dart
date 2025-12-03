import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:intl/intl.dart';

import '../../../../controllers/svp_home_screen_controller.dart';
import '../../../../custom_widgets/home_section_applogo_and_notification.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../routes/routes.dart';
import '../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../widgets/svp_job_card.dart';
import '../widgets/svp_show_chart_widget.dart';

class SvpHomeScreen extends StatelessWidget {
  SvpHomeScreen({super.key});

  final SvpHomeScreenController controller = Get.put(SvpHomeScreenController());

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown Date';

    // Create formatter with the required format: "Jun 17, 2025  09:31AM"
    final DateFormat formatter = DateFormat('MMM dd, yyyy  hh:mma');
    String formattedDate = formatter.format(dateTime);

    // Format the AM/PM to be uppercase with proper spacing
    return formattedDate.toUpperCase();
  }

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

              Obx(() {
                if (controller.isHomeDataLoading.value && controller.homeData.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: UIHelper.kDefaulutPadding(),
                  ),
                  child: Column(
                    children: [
                      ///Section : Graph Chart
                      IncomeChartCard(),
                      UIHelper.verticalSpace(16.h),

                      ///Section : Job Status Card
                      Obx(() {
                        final stats = controller.stats;
                        if (stats == null) return const SizedBox.shrink();

                        final jobTypes = [
                          {'title': 'Pending', 'totalJobs': stats.totalRequests ?? 0},
                          {'title': 'Accepted', 'totalJobs': stats.accepted ?? 0},
                          {'title': 'In Progress', 'totalJobs': stats.inProgress ?? 0},
                          {'title': 'Completed', 'totalJobs': stats.completed ?? 0},
                        ];

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: jobTypes.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.w,
                            mainAxisSpacing: 16.h,
                            childAspectRatio: 0.86,
                          ),
                          itemBuilder: (context, index) {
                            var data = jobTypes[index];
                            return SvpJobCard(
                              onTap: () {
                                log("${data['title']} Card Taped!");
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
                              title: data['title'] as String,
                              totalJobs: data['totalJobs'] as int,
                            );
                          },
                        );
                      }),
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
                          Obx(() {
                            final count = controller.recentJobRequests.length;
                            return RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Total ",
                                    style: TextFontStyle
                                        .headline14w500c4d4d4dStyleSatoshi,
                                  ),
                                  TextSpan(
                                    text: "($count)",
                                    style: TextFontStyle
                                        .headline16w700c778bebStyleSatoshi,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                      UIHelper.verticalSpace(16.h),

                      ///Section : Recent Job Requests
                      Obx(() {
                        final recentRequests = controller.recentJobRequests;
                        if (recentRequests.isEmpty) {
                          return const Center(child: Text('No recent job requests'));
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentRequests.length,
                          separatorBuilder: (context, index) =>
                              UIHelper.verticalSpace(24.h),
                          itemBuilder: (context, index) {
                            final request = recentRequests[index];
                            final userId = request.userId;
                            final address = request.address;

                            return RecentJobRequestStatusWidget(
                              onTap: () {
                                log("Taped on -> Card ${request.id}");
                                Get.toNamed(
                                  Routes.svpJobDetailsScreen,
                                  arguments: {
                                    "jobRequestId": request.id,
                                  },
                                );
                              },
                              cancelOnTap: () {
                                log("Button Taped -> Cancel for ${request.id}");
                              },
                              acceptOnTap: () {
                                log("Button Taped -> Accept for ${request.id}");
                              },
                              userImage: Assets.images.userImage.path,
                              userName: userId?.name ?? 'Unknown User',
                              location: address?.en ?? 'Unknown Location',
                              dateTime: _formatDateTime(request.bookingDateTime),
                            );
                          },
                        );
                      }),
                      UIHelper.verticalSpace(150.h),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

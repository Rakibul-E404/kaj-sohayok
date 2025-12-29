import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_shimmer_effect.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:intl/intl.dart';
import 'package:kaz_bd/helpers/loading_helper.dart';
import 'package:kaz_bd/utilities/logger_util.dart';
import 'package:lottie/lottie.dart';

import '../../../../controllers/svp_home_screen_controller.dart';
import '../../../../custom_widgets/home_section_applogo_and_notification.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../routes/routes.dart';
import '../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../widgets/income_card_loader.dart';
import '../widgets/job_status_loader.dart';
import '../widgets/recent_job_request_loader.dart';
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
        child: Padding(
          padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
          child: RefreshIndicator(
            onRefresh: () => controller
                .refreshData(), // 🔄 RISK HANDLING: Using dedicated refresh method to properly handle loading states
            child: SingleChildScrollView(
              physics:
                  AlwaysScrollableScrollPhysics(), // ⚡ RISK HANDLING: Ensures scroll physics allow pull-to-refresh
              child: Column(
                children: [
                  ///Section : AppLogo & Notification Section
                  Obx(() {
                    if (controller.isHomeDataLoading.value) {
                      return CustomShimmerEffect(
                          height: 40.h,
                          width: 1
                              .sw); // 📶 RISK HANDLING: Shows shimmer loading state to indicate data is being refreshed
                    }

                    return HomeSectionAppLogoAndNotification(
                      onTap: () {
                        log("Notification Icon tapped!");
                        Get.toNamed(Routes.notificationScreen);
                      },
                    );
                  }),
                  UIHelper.verticalSpace(16.h),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: UIHelper.kDefaulutPadding(),
                    ),
                    child: Column(
                      children: [
                        ///Section : Graph Chart
                        Obx(() {
                          if (controller.isHomeDataLoading.value) {
                            return const Center(
                                child:
                                    IncomeCardLoader()); // 📶 RISK HANDLING: Shows loading state during refresh
                          }

                          return IncomeChartCard();
                        }),
                        UIHelper.verticalSpace(16.h),

                        ///Section : Job Status Card
                        Obx(() {
                          if (controller.isHomeDataLoading.value) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 4,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16.w,
                                mainAxisSpacing: 16.h,
                                childAspectRatio: 0.86,
                              ),
                              itemBuilder: (context, index) {
                                return JobStatusLoader(); // 📶 RISK HANDLING: Shows loading state during refresh
                              },
                            );
                          }

                          final stats = controller.stats;
                          // if (stats == null)
                          if (controller.isHomeDataLoading.value) {
                            return CustomShimmerEffect(
                                height: 10.h, width: 15.w);
                          }

                          final List<Map<String, Object>> jobTypes = [
                            {
                              'title': 'pending'.tr,
                              'totalJobs': stats?.totalRequests ?? 0,
                            },
                            {
                              'title': 'accepted'.tr,
                              'totalJobs': stats?.accepted ?? 0
                            },
                            {
                              'title': 'in_progress'.tr,
                              'totalJobs': stats?.inProgress ?? 0,
                            },
                            {
                              'title': 'completed'.tr,
                              'totalJobs': stats?.completed ?? 0,
                            },
                          ];

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: jobTypes.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.w,
                              mainAxisSpacing: 16.h,
                              childAspectRatio: 0.86,
                            ),
                            itemBuilder: (context, index) {
                              var data = jobTypes[index];
                              return SvpJobCard(
                                onTap: () {
                                  log("${data['title']} Card Tapped!");
                                  switch (index) {
                                    case 0:
                                      Get.toNamed(Routes.svpJobRequestScreen);
                                      break;
                                    case 1:
                                      Get.toNamed(
                                          Routes.svpAcceptedBookingsScreen);
                                      break;
                                    case 2:
                                      Get.toNamed(Routes.svpInProgressScreen);
                                      break;
                                    case 3:
                                      Get.toNamed(
                                          Routes.svpWorkCompletedScreen);
                                      break;
                                  }
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
                              'recent_job_request'.tr,
                              style: TextFontStyle
                                  .headline18w700c202020StyleSatoshi,
                            ),

                            ///Section : Total Available count
                            Obx(() {
                              if (controller.isHomeDataLoading.value ||
                                  controller.homeData.isEmpty) {
                                return CustomShimmerEffect(
                                  height: 10.h,
                                  width: 0.2.sw,
                                );
                              }

                              final count = controller.recentJobRequests.length;
                              return RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "${'total'.tr} ",
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
                            return Center(
                                child: ThreeTimeLottie(
                                    lottieAssetPath:
                                        Assets.lottie.emptyScreen));
                          }

                          if (controller.isHomeDataLoading.value) {
                            return RecentJobRequestLoader(); // 📶 RISK HANDLING: Shows loading state during refresh
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

                              LoggerUtils.debug(
                                  "Svp Home Screen Recent Request : ${request.id}");

                              // Get the profile image URL from profileImage.imageUrl
                              String? profileImageUrl;
                              if (userId?.profileImage?.imageUrl != null &&
                                  userId!.profileImage!.imageUrl!.isNotEmpty) {
                                profileImageUrl = userId.profileImage!.imageUrl;
                              }

                              return RecentJobRequestStatusWidget(
                                onTap: () {
                                  LoggerUtils.info(
                                      "Tapped on -> Svp Home recent request card : ${request.id}");
                                  Get.toNamed(
                                    Routes.svpJobDetailsScreen,
                                    arguments: {'requestedJobID': request.id},
                                  );
                                },
                                cancelOnTap: () async {
                                  log("Button Tapped -> Cancel for ${request.id}");
                                  controller.setServiceID(
                                      servID: request.id ?? '');
                                  await controller
                                      .getCancelButtonApi()
                                      .waitingForFutureWithoutBg();
                                },
                                acceptOnTap: () async {
                                  log("Button Tapped -> Accept for ${request.id}");
                                  // serviceID = request.id ?? '';
                                  controller.setServiceID(
                                      servID: request.id ?? '');
                                  await controller
                                      .getSvpAcceptButtonApi()
                                      .waitingForFutureWithoutBg();
                                },
                                userImage: profileImageUrl ?? '',
                                userName: userId?.name ?? 'Unknown User',
                                location: address?.en ?? 'Unknown Location',
                                dateTime:
                                    _formatDateTime(request.bookingDateTime),
                              );
                            },
                          );
                        }),
                        UIHelper.verticalSpace(150.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ThreeTimeLottie extends StatefulWidget {
  final String lottieAssetPath;

  const ThreeTimeLottie({super.key, required this.lottieAssetPath});

  @override
  _ThreeTimeLottieState createState() => _ThreeTimeLottieState();
}

class _ThreeTimeLottieState extends State<ThreeTimeLottie>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int playCount = 0; // Track how many times played

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        playCount++;

        if (playCount < 2) {
          _controller.reset();
          _controller.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.lottieAssetPath,
      controller: _controller,
      fit: BoxFit.contain,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        _controller.forward(); // start first play
      },
    );
  }
}

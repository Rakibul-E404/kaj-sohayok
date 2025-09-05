import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OnboardingController controller = Get.put(OnboardingController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: controller
          .tabIndex
          .value, // Set initial tab index from GetX controller
    );
    _tabController.addListener(() {
      controller.changeTab(
        _tabController.index,
      ); // Update GetX reactive variable when tab changes
    });
  }

  @override
  void dispose() {
    _tabController
        .dispose(); // Dispose TabController when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cFFFFFF,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              children: [
                UIHelper.verticalSpace(68.h),

                // TabBar with custom indicator and styling
                Align(
                  alignment: Alignment.centerRight,
                  child: Obx(() {
                    return Container(
                      width: 100.w,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.c778beb),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: TabBar(
                        splashFactory: NoSplash.splashFactory,
                        controller: _tabController,
                        onTap: controller.changeTab,
                        labelPadding: EdgeInsets.zero,
                        indicatorColor: Colors.transparent,
                        indicatorWeight: 0,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: AppColors.c778beb,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              controller.tabIndex.value == 0 ? 100.r : 0.r,
                            ),
                            bottomLeft: Radius.circular(
                              controller.tabIndex.value == 0 ? 100.r : 0.r,
                            ),
                            topRight: Radius.circular(
                              controller.tabIndex.value == 1 ? 100.r : 0.r,
                            ),
                            bottomRight: Radius.circular(
                              controller.tabIndex.value == 1 ? 100.r : 0.r,
                            ),
                          ),
                        ),
                        labelColor: Colors.amber,
                        unselectedLabelColor: Colors.black,
                        tabs: [
                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Obx(() {
                                return Text(
                                  'English',
                                  style: TextFontStyle
                                      .headline10w700cFFFFFFStyleSatoshi
                                      .copyWith(
                                        color: controller.tabIndex.value == 0
                                            ? AppColors.cFFFFFF
                                            : AppColors.c000000,
                                      ),
                                );
                              }),
                            ),
                          ),
                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Obx(() {
                                log("tab index ${controller.tabIndex.value}");
                                return Text(
                                  'বাংলা',
                                  style: TextFontStyle
                                      .headline10w700cFFFFFFStyleSatoshi
                                      .copyWith(
                                        color: controller.tabIndex.value == 0
                                            ? AppColors.c000000
                                            : AppColors.cFFFFFF,
                                      ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                // Section: TabBarView to display content based on the selected tab
                // Expanded(
                //   child: TabBarView(
                //     physics: const NeverScrollableScrollPhysics(),
                //     controller: _tabController,
                //     children: [
                //       // Content for English Tab
                //       Center(
                //         child: Image.asset(
                //           Assets.images.appLogo.path,
                //           height: 98.h,
                //           width: 170.w,
                //           fit: BoxFit.cover,
                //         ),
                //       ),

                //       // Content for Bengali Tab
                //       Center(
                //         child: Image.asset(
                //           Assets
                //               .images
                //               .appLogo
                //               .path, // Use a different image for Bengali if needed
                //           height: 98.h,
                //           width: 170.w,
                //           fit: BoxFit.cover,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

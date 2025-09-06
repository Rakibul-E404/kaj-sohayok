import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../controllers/onboarding_controller.dart';
import '../../../../gen/colors.gen.dart';

class SelectLanguage extends StatelessWidget {
  const SelectLanguage({
    super.key,
    required TabController tabController,
    required this.controller,
    required this.leftTabTitle,
    required this.rightTabTitle,
  }) : _tabController = tabController;

  final TabController _tabController;
  final OnboardingController controller;
  final String leftTabTitle;
  final String rightTabTitle;

  @override
  Widget build(BuildContext context) {
    return Align(
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
                      leftTabTitle,
                      style: TextFontStyle.headline10w700cFFFFFFStyleSatoshi
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
                    log("Tab Index : ${controller.tabIndex.value}");
                    return Text(
                      rightTabTitle,
                      style: TextFontStyle.headline10w700cFFFFFFStyleSatoshi
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
    );
  }
}

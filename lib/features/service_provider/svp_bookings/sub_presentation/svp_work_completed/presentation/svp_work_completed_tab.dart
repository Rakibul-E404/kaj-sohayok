/**
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';

class SvpWorkCompletedTab extends StatelessWidget {
  const SvpWorkCompletedTab({super.key});

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
                isJobStatusCompleted: true,
                onTap: () {
                  Get.toNamed(Routes.svpWorkCompletedDetailsScreen);
                },
                userImageUrl: Assets.images.userImage.path,
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
*/

///
///
///
/// todo::: fetching from the api
///
///
///
///
///

// lib/.../svp_work_completed_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
// import '../controller/svp_work_completed_controller.dart';
import '../controller/svp_work_completed_tab_controller.dart';

class SvpWorkCompletedTab extends StatelessWidget {
  const SvpWorkCompletedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SvpWorkCompletedController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
          child: Obx(() => RefreshIndicator(
              onRefresh: () => controller.fetchCompletedBookings(),
              child: _buildContent(controller))),
        ),
      ),
    );
  }

  Widget _buildContent(SvpWorkCompletedController controller) {
    if (controller.isLoading.value) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 600,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.c000e08),
                    UIHelper.verticalSpace(16.h),
                    Text(
                      'loading_completed_work'.tr,
                      style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (controller.hasError.value) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 600,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 50.h, color: Colors.red),
                    UIHelper.verticalSpace(16.h),
                    Text(
                      controller.errorMessage.value,
                      style: TextFontStyle.headline10w400c6c606cStyleSatoshi
                          .copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    UIHelper.verticalSpace(16.h),
                    ElevatedButton(
                      onPressed: () => controller.fetchCompletedBookings(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.c000e08,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('retry'.tr),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (controller.completedBookings.isEmpty) {
      return ListView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 600,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 60.h, color: Colors.grey),
                  UIHelper.verticalSpace(16.h),
                  Text(
                    'no_completed_work_yet'.tr,
                    style: TextFontStyle.headline10w500c000000StyleSatoshi
                        .copyWith(color: Colors.grey),
                  ),
                  UIHelper.verticalSpace(8.h),
                  Text(
                    'finished_jobs_will_appear_here'.tr,
                    style: TextFontStyle.headline10w400c6c606cStyleSatoshi
                        .copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: controller.completedBookings.length,
      separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
      itemBuilder: (context, index) {
        return controller.buildCompletedBookingWidget(index);
      },
    );
  }
}

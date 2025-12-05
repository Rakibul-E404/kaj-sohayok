/**
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';

class SvpBookingsInProgressTab extends StatelessWidget {
  const SvpBookingsInProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
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
              userImageUrl: Assets.images.userImage.path,
              userName: "Swapon Mia",
              location: "Rampura Dhaka, Bangladesh",
              dateTime: "Jun 17, 2025  09:31AM",
            );
          },
        ),
      ),
    );
  }
}
*/






///
///
/// todo:: fro mteh api
///
///
///







// lib/.../svp_bookings_in_progress_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../controller/svp_bookings_in_prgress_tab_controller.dart';

class SvpBookingsInProgressTab extends StatelessWidget {
  const SvpBookingsInProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SvpBookingsInProgressController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
          child: Obx(() => _buildContent(controller)),
        ),
      ),
    );
  }

  Widget _buildContent(SvpBookingsInProgressController controller) {
    if (controller.isLoading.value) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.c000e08),
              UIHelper.verticalSpace(16.h),
              Text(
                'Loading in-progress bookings...',
                style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
              ),
            ],
          ),
        ),
      );
    }

    if (controller.hasError.value) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50.h, color: Colors.red),
              UIHelper.verticalSpace(16.h),
              Text(
                controller.errorMessage.value,
                style: TextFontStyle.headline10w400c6c606cStyleSatoshi.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              UIHelper.verticalSpace(16.h),
              ElevatedButton(
                onPressed: () => controller.fetchInProgressBookings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.c000e08,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.jobRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pending_actions, size: 60.h, color: Colors.grey),
            UIHelper.verticalSpace(16.h),
            Text(
              'No bookings in progress',
              style: TextFontStyle.headline10w500c000000StyleSatoshi.copyWith(color: Colors.grey),
            ),
            UIHelper.verticalSpace(8.h),
            Text(
              'Active jobs will appear here',
              style: TextFontStyle.headline10w400c6c606cStyleSatoshi.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchInProgressBookings(),
      color: AppColors.c000e08,
      child: ListView.separated(
        itemCount: controller.jobRequests.length,
        separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
        itemBuilder: (context, index) {
          return controller.buildInProgressBookingWidget(index);
        },
      ),
    );
  }
}
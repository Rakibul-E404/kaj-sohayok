/**
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';
import '../controller/svp_accepted_bookings_screen_controller.dart';

class SvpAcceptedBookingsScreen extends StatelessWidget {
  const SvpAcceptedBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SvpAcceptedBookingsScreenController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Accepted Booking",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() => _buildContent(controller)),
      ),
    );
  }

  Widget _buildContent(SvpAcceptedBookingsScreenController controller) {
    if (controller.isLoading.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.c000e08),
            UIHelper.verticalSpace(16.h),
            Text(
              'Loading accepted bookings...',
              style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
            ),
          ],
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
                onPressed: () => controller.fetchAcceptedBookings(),
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

    if (controller.acceptedBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 60.h, color: Colors.grey),
            UIHelper.verticalSpace(16.h),
            Text(
              'No accepted bookings yet',
              style: TextFontStyle.headline10w500c000000StyleSatoshi.copyWith(color: Colors.grey),
            ),
            UIHelper.verticalSpace(8.h),
            Text(
              'Accepted jobs will appear here',
              style: TextFontStyle.headline10w400c6c606cStyleSatoshi.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchAcceptedBookings(),
      color: AppColors.c000e08,
      child: ListView.separated(
        itemCount: controller.acceptedBookings.length,
        separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: controller.buildAcceptedBookingWidget(index),
          );
        },
      ),
    );
  }
}*/

///
///
///
/// todo:: applyting all the functionality
///
///
///

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';
import '../controller/svp_accepted_bookings_screen_controller.dart';

class SvpAcceptedBookingsScreen extends StatelessWidget {
  const SvpAcceptedBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SvpAcceptedBookingsScreenController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'accepted_bookings'.tr,
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: Obx(() => _buildContent(controller)),
        ),
      ),
    );
  }

  Widget _buildContent(SvpAcceptedBookingsScreenController controller) {
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
                'loading_accepted_bookings'.tr,
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
                style: TextFontStyle.headline10w400c6c606cStyleSatoshi
                    .copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              UIHelper.verticalSpace(16.h),
              ElevatedButton(
                onPressed: () => controller.fetchAcceptedBookings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.c000e08,
                  foregroundColor: Colors.white,
                ),
                child: Text('retry'.tr),
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
            Icon(Icons.check_circle_outline, size: 60.h, color: Colors.grey),
            UIHelper.verticalSpace(16.h),
            Text(
              'no_accepted_bookings_yet'.tr,
              style: TextFontStyle.headline10w500c000000StyleSatoshi
                  .copyWith(color: Colors.grey),
            ),
            UIHelper.verticalSpace(8.h),
            Text(
              'accepted_job_requests_will_appear_here'.tr,
              style: TextFontStyle.headline10w400c6c606cStyleSatoshi
                  .copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchAcceptedBookings(),
      color: AppColors.c000e08,
      child: ListView.separated(
        itemCount: controller.jobRequests.length,
        separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
        itemBuilder: (context, index) {
          return controller.buildAcceptedBookingWidget(index);
        },
      ),
    );
  }
}

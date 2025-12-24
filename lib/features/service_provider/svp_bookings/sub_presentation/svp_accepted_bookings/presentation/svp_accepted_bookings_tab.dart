import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../controller/svp_accepted_bookings_tab_controller.dart';

class SvpAcceptedBookingsTab extends StatelessWidget {
  const SvpAcceptedBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SvpAcceptedBookingsController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
          child: Obx(() => RefreshIndicator(
              onRefresh: () => controller.fetchAcceptedBookings(),
              child: _buildContent(controller))),
        ),
      ),
    );
  }

  Widget _buildContent(SvpAcceptedBookingsController controller) {
    if (controller.isLoading.value) {
      // return Center(
      //   child: Padding(
      //     padding: EdgeInsets.all(20.h),
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         CircularProgressIndicator(color: AppColors.c000e08),
      //         UIHelper.verticalSpace(16.h),
      //         Text(
      //           'Loading accepted bookings...',
      //           style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
      //         ),
      //       ],
      //     ),
      //   ),
      // );

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 600, // ensures enough scrollable space
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UIHelper.verticalSpace(16.h),
                  Text(
                    'loading_accepted_bookings'.tr,
                    style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
                  ),
                ],
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
            ),
          ),
        ],
      );
    }

    if (controller.jobRequests.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 600,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 60.h, color: Colors.grey),
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
            ),
          )
        ],
      );
    }

    return ListView.separated(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: controller.jobRequests.length,
      separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
      itemBuilder: (context, index) {
        return controller.buildAcceptedBookingWidget(index);
      },
    );
  }
}

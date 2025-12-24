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
    print(
        '🎯 SvpBookingsInProgressTab - Tab Opened at ${DateTime.now().toLocal()}');

    final controller = Get.put(SvpBookingsInProgressController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
          child: Obx(() {
            // Print when widget rebuilds with data
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!controller.isLoading.value &&
                  !controller.hasError.value &&
                  controller.jobRequests.isNotEmpty) {
                print(
                    '📊 Tab Data Loaded - ${controller.jobRequests.length} booking(s) available');
              }
            });

            return RefreshIndicator(
                onRefresh: () => controller.fetchInProgressBookings(),
                child: _buildContent(controller));
          }),
        ),
      ),
    );
  }

  Widget _buildContent(SvpBookingsInProgressController controller) {
    if (controller.isLoading.value) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 600.h,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UIHelper.verticalSpace(16.h),
                    Text(
                      'loading_inprogress_bookings'.tr,
                      style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      );
    }

    if (controller.hasError.value) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 600.h,
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
                      onPressed: () => controller.fetchInProgressBookings(),
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

    return Obx(() {
      // Empty state
      if (controller.jobRequests.isEmpty) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Text(
                    'Currently there is no booking in progress',
                    textAlign: TextAlign.center,
                    style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
                  ),
                ),
              ),
            );
          },
        );
      }

      // Data available
      return ListView.separated(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.jobRequests.length,
        separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
        itemBuilder: (context, index) {
          return controller.buildInProgressBookingWidget(index);
        },
      );
    });

  }

}

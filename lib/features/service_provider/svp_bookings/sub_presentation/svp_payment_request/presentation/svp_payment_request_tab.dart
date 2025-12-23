/**
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/custom_widgets/dotted_line_divider_widget.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../../../constants/app_enums.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../../../custom_widgets/date_and_time_widget_tile.dart';
import '../../../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';
import '../widgets/svp_payment_request_tab_card.dart';

class SvpPaymentRequestTab extends StatelessWidget {
  const SvpPaymentRequestTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
          child: ListView.separated(
            itemCount: 20,
            separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
            itemBuilder: (context, index) {
              return SvpPaymentRequestTabCard(
                cardOnTap: () {
                  log("Taped -> Pending Request Card");
                  Get.toNamed(Routes.svpPendingPaymentRequestDetailsScreen);
                },
                pendingPaymentButtonOnTap: () {
                  log("Taped -> Pending Payment Button!");
                },
                userImage: Assets.images.userImage.path,
                userName: "Chowdhury Md. Imtiazul Islam",
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
/// todo:: fetching the info from the api
///
///
///

// lib/.../svp_payment_request_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
// import '../controller/svp_payment_request_controller.dart';
import '../controller/svp_payment_request_tab_controller.dart';

class SvpPaymentRequestTab extends StatelessWidget {
  const SvpPaymentRequestTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SvpPaymentRequestController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
          child: Obx(() => RefreshIndicator(
              onRefresh: () => controller.fetchPaymentRequests(),
              child: _buildContent(controller))),
        ),
      ),
    );
  }

  Widget _buildContent(SvpPaymentRequestController controller) {
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
                      'loading_payment_requests'.tr,
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
                      onPressed: () => controller.fetchPaymentRequests(),
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

    if (controller.paymentRequests.isEmpty) {
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
                  Icon(Icons.payments, size: 60.h, color: Colors.grey),
                  UIHelper.verticalSpace(16.h),
                  Text(
                    'no_payment_requests'.tr,
                    style: TextFontStyle.headline10w500c000000StyleSatoshi
                        .copyWith(color: Colors.grey),
                  ),
                  UIHelper.verticalSpace(8.h),
                  Text(
                    'payment_request_will_appear_here'.tr,
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
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.paymentRequests.length,
      separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
      itemBuilder: (context, index) {
        return controller.buildPaymentRequestCard(index);
      },
    );
  }
}

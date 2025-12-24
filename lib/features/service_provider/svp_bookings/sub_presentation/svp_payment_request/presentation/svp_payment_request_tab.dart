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
            height: MediaQuery.of(Get.context!).size.height * 0.7,
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
            height: MediaQuery.of(Get.context!).size.height * 0.7,
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
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(Get.context!).size.height * 0.7,
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
          ),
        ],
      );

    }

    return ListView.separated(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: controller.paymentRequests.length,
      separatorBuilder: (_, __) => UIHelper.verticalSpace(24.h),
      itemBuilder: (context, index) {
        return controller.buildPaymentRequestCard(index);
      },
    );

  }
}

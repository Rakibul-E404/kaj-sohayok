/**
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/custom_widgets/date_and_time_widget_tile.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/appList.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/payment_summery_widget.dart';
import '../../../../custom_widgets/proof_of_image_uploading_widget.dart';
import '../../../../controllers/svp_submit_work_form_screen_controller.dart';
import '../../../../custom_widgets/work_address_and_date_widget.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../custom_widgets/more_info_widget_tile.dart';
import '../../../normal_user/work_completed_details/widgets/additional_cost_popup.dart';

class SvpSubmitWorkFormScreen extends StatelessWidget {
  SvpSubmitWorkFormScreen({super.key});

  SvpSubmitWorkFormScreenController controller = Get.put(
    SvpSubmitWorkFormScreenController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Submit Work From",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: UIHelper.kDefaulutPadding(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Section : Working Address
                ///Section : Booking Order Date
                WorkAddressAndDateWidget(
                  address: "Rampura Dhaka, Bangladesh",
                  dateTime: "Jun 17, 2025  09:31AM",
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Text -> Proof Of Work Complete Information
                Text(
                  "Proof Of Work Complete Information",
                  style: TextFontStyle.headline16w700c202020StyleSatoshi,
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Completation Date
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(), // today by default
                      firstDate: DateTime(2000), // earliest date
                      lastDate: DateTime(2100), // latest date
                    );

                    if (picked != null) {
                      final formatted = DateFormat('MM-dd-yyyy').format(picked);
                      controller.completionDateController.text = formatted;
                    }
                  },
                  child: MoreInfoWidgetTile(
                    title: "Completion Date",
                    hintText: "Select Date",
                    isEnabled: false,
                    controller: controller.completionDateController,
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Duration Time
                MoreInfoWidgetTile(
                  title: "Duration Time",
                  hintText: "Type Day's In Numbers",
                  keyboardType: TextInputType.number,
                  controller: controller.durationTimeController,
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : ProofOfImageUploadWidget
                Obx(() {
                  return ProofOfImageUploadWidget(
                    onTap: () {
                      log("Browse Button Tapede");
                      controller.showImageSourceDialog();
                    },
                    removeImageOnTap: () {
                      controller.removeImage();
                    },
                    imagePath: controller.selectedImage.value,
                    title: "Proof of Image",
                  );
                }),
                UIHelper.verticalSpace(24.h),

                ///Section : Payment Summery
                PaymentSummeryWidget(
                  onTap: () {
                    showAdditionalCostDialog(
                      context: context,
                      additionlCostSubmitOnTap: () {
                        Get.back();
                      },
                    );
                  },

                  initialCost: 30,
                  additionalCostList: AppList.additionalCosts,
                  totalPayment:
                      30 +
                      AppList.additionalCosts.fold(
                        0,
                        (sum, item) => sum + item.price,
                      ),
                  isAddAdditionalCostButtonVisible: true,
                ),
                UIHelper.verticalSpace(32.h),

                ///Section : Payment Request
                CustomElevatedButton(
                  onTap: () {
                    log("Button Taped -> Payment Request!");
                  },
                  buttonTitle: "Payment Request",
                ),
                UIHelper.verticalSpace(32.h),
              ],
            ),
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
/// todo:: uplodd test for video
///
///
///








import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import '../../../../constants/appList.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/payment_summery_widget.dart';
import '../../../../custom_widgets/proof_of_image_uploading_widget.dart';
import '../../../../controllers/svp_submit_work_form_screen_controller.dart';
import '../../../../custom_widgets/work_address_and_date_widget.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../custom_widgets/more_info_widget_tile.dart';
import '../../../normal_user/work_completed_details/widgets/additional_cost_popup.dart';

class SvpSubmitWorkFormScreen extends StatelessWidget {
  SvpSubmitWorkFormScreen({super.key});

  SvpSubmitWorkFormScreenController controller = Get.put(
    SvpSubmitWorkFormScreenController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Submit Work Form",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: UIHelper.kDefaulutPadding(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Section : Working Address & Booking Order Date
                WorkAddressAndDateWidget(
                  address: "Rampura Dhaka, Bangladesh",
                  dateTime: "Jun 17, 2025  09:31AM",
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Text -> Proof Of Work Complete Information
                Text(
                  "Proof Of Work Complete Information",
                  style: TextFontStyle.headline16w700c202020StyleSatoshi,
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Completion Date
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(), // today by default
                      firstDate: DateTime(2000), // earliest date
                      lastDate: DateTime(2100), // latest date
                    );

                    if (picked != null) {
                      final formatted = DateFormat('MM-dd-yyyy').format(picked);
                      controller.completionDateController.text = formatted;
                    }
                  },
                  child: MoreInfoWidgetTile(
                    title: "Completion Date",
                    hintText: "Select Date",
                    isEnabled: false,
                    controller: controller.completionDateController,
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Duration Time
                MoreInfoWidgetTile(
                  title: "Duration Time",
                  hintText: "Type Day's In Numbers",
                  keyboardType: TextInputType.number,
                  controller: controller.durationTimeController,
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Proof of Image Upload
                Obx(() {
                  return ProofOfImageUploadWidget(
                    onTap: () {
                      log("Browse Button Tapped - Image");
                      controller.showImageSourceDialog();
                    },
                    removeImageOnTap: () {
                      controller.removeImage();
                    },
                    imagePath: controller.selectedImage.value,
                    title: "Proof of Image",
                  );
                }),
                UIHelper.verticalSpace(24.h),

                ///Section : Proof of Video Upload
                Obx(() {
                  return controller.selectedVideo.value.isEmpty
                      ? ProofOfImageUploadWidget(
                    onTap: () {
                      log("Browse Button Tapped - Video");
                      controller.showVideoSourceDialog();
                    },
                    removeImageOnTap: () {
                      controller.removeVideo();
                    },
                    imagePath: controller.selectedVideo.value,
                    title: "Proof of Video",
                  )
                      : Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title for video section
                        Text(
                          "Proof of Video",
                          style: TextFontStyle.headline16w700c202020StyleSatoshi,
                        ),
                        UIHelper.verticalSpace(12.h),

                        // Video preview container with remove button
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              // Video Player
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: VideoPlayerWidget(controller.selectedVideo.value),
                              ),
                              UIHelper.verticalSpace(12.h),

                              // Remove button at the bottom of container
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () {
                                    controller.removeVideo();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      "Remove",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                UIHelper.verticalSpace(24.h),

                ///Section : Payment Summary
                PaymentSummeryWidget(
                  onTap: () {
                    showAdditionalCostDialog(
                      context: context,
                      additionlCostSubmitOnTap: () {
                        Get.back();
                      },
                    );
                  },
                  initialCost: 30,
                  additionalCostList: AppList.additionalCosts,
                  totalPayment:
                  30 +
                      AppList.additionalCosts.fold(
                        0,
                            (sum, item) => sum + item.price,
                      ),
                  isAddAdditionalCostButtonVisible: true,
                ),
                UIHelper.verticalSpace(32.h),

                ///Section : Payment Request Button
                CustomElevatedButton(
                  onTap: () {
                    log("Button Tapped -> Payment Request!");
                  },
                  buttonTitle: "Payment Request",
                ),
                UIHelper.verticalSpace(32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

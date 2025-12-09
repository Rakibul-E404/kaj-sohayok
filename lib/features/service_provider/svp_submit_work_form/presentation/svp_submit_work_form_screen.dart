/**

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

class SvpSubmitWorkFormScreen extends StatefulWidget {
  const SvpSubmitWorkFormScreen({super.key});

  @override
  State<SvpSubmitWorkFormScreen> createState() => _SvpSubmitWorkFormScreenState();
}

class _SvpSubmitWorkFormScreenState extends State<SvpSubmitWorkFormScreen> {
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
*/







///
///
///
/// todo:: merging the image-video field
///
///
///



// import 'dart:log';
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
import '../../../../controllers/svp_submit_work_form_screen_controller.dart';
import '../../../../custom_widgets/proof_of_image_uploading_widget.dart';
import '../../../../custom_widgets/work_address_and_date_widget.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../custom_widgets/more_info_widget_tile.dart';
import '../../../normal_user/work_completed_details/widgets/additional_cost_popup.dart';
// import '../../../../custom_widgets/proof_of_media_upload_widget.dart';

class SvpSubmitWorkFormScreen extends StatefulWidget {
  const SvpSubmitWorkFormScreen({super.key});

  @override
  State<SvpSubmitWorkFormScreen> createState() => _SvpSubmitWorkFormScreenState();
}

class _SvpSubmitWorkFormScreenState extends State<SvpSubmitWorkFormScreen> {
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
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
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

                ///Section : Single upload field for both images and videos
                Obx(() {
                  return ProofOfMediaUploadWidget(
                    title: "Proof Files",
                    mediaFiles: controller.mediaFiles.toList(), // Convert RxList to List
                    onTap: () {
                      log("Browse Button Tapped");
                      controller.showMediaSourceDialog();
                    },
                    removeMediaOnTap: (index) async {
                      await controller.removeMediaFile(index);
                    },
                  );
                }),
                UIHelper.verticalSpace(24.h),

                ///Section : Media Summary
                Obx(() {
                  final totalMedia = controller.totalMediaCount;
                  final imageCount = controller.imageCount;
                  final videoCount = controller.videoCount;

                  if (totalMedia > 0) {
                    return Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Media Summary",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Total: $totalMedia file${totalMedia > 1 ? 's' : ''}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (imageCount > 0)
                                Container(
                                  margin: EdgeInsets.only(right: 8.w),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: 14.h,
                                        color: Colors.green.shade800,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        "$imageCount",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (videoCount > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade100,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.videocam,
                                        size: 14.h,
                                        color: Colors.purple.shade800,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        "$videoCount",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.purple.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  return SizedBox();
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

                ///Section : Submit Button
                CustomElevatedButton(
                  onTap: () {
                    log("Button Tapped -> Submit Work Form!");

                    final totalMedia = controller.totalMediaCount;

                    if (totalMedia == 0) {
                      Get.snackbar(
                        "Warning",
                        "Please add at least one file as proof",
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    // Show success dialog
                    Get.dialog(
                      AlertDialog(
                        title: const Text("Work Form Ready"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Your work form includes $totalMedia file${totalMedia > 1 ? 's' : ''}:"),
                            SizedBox(height: 8),
                            if (controller.imageCount > 0)
                              Text("• ${controller.imageCount} image${controller.imageCount > 1 ? 's' : ''}"),
                            if (controller.videoCount > 0)
                              Text("• ${controller.videoCount} video${controller.videoCount > 1 ? 's' : ''}"),
                            SizedBox(height: 16),
                            const Text("Are you sure you want to submit?"),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: Get.back,
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              // Submit the form
                              _submitWorkForm();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              "Submit",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  buttonTitle: "Submit Work Form",
                ),
                UIHelper.verticalSpace(32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitWorkForm() {
    final totalMedia = controller.totalMediaCount;

    log("Submitting work form with $totalMedia file(s)");
    log("Completion Date: ${controller.completionDateController.text}");
    log("Duration Time: ${controller.durationTimeController.text}");

    Get.snackbar(
      "Success",
      "Work form submitted successfully!",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    // Clear form after submission
    Future.delayed(const Duration(seconds: 2), () {
      controller.completionDateController.clear();
      controller.durationTimeController.clear();
      controller.clearAllMediaFiles();
    });
  }
}


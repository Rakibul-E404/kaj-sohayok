import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/payment_summery_widget.dart';
import 'package:kaz_bd/controllers/svp_submit_work_form_screen_controller.dart';
import 'package:kaz_bd/custom_widgets/proof_of_image_uploading_widget.dart';
import 'package:kaz_bd/custom_widgets/work_address_and_date_widget.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/custom_widgets/more_info_widget_tile.dart';

class SvpSubmitWorkFormScreen extends StatefulWidget {
  const SvpSubmitWorkFormScreen({super.key});

  @override
  State<SvpSubmitWorkFormScreen> createState() => _SvpSubmitWorkFormScreenState();
}

class _SvpSubmitWorkFormScreenState extends State<SvpSubmitWorkFormScreen> {
  final SvpSubmitWorkFormScreenController controller = Get.put(SvpSubmitWorkFormScreenController());

  final RxBool isMediaCompleted = false.obs;

  // Function to show image in fullscreen dialog
  void _showImageInDialog(String imageUrl, String? title) {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.all(20.w),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Semi-transparent background
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            // Image viewer
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title if available
                    if (title != null && title.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Image container
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 0.9.sw,
                        maxHeight: 0.7.sh,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Container(
                            width: 200.w,
                            height: 200.h,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 200.w,
                            height: 200.h,
                            color: Colors.grey.shade800,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 48.h,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Failed to load image',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Gesture detector to close on tap outside
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Get.back(),
                behavior: HitTestBehavior.translucent,
              ),
            ),
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.7),
    );
  }

  // Function to upload media files via PUT API
  Future<void> _uploadMediaFiles() async {
    if (controller.bookingId.value == null || controller.bookingId.value!.isEmpty) {
      Get.snackbar(
        "Error",
        "Booking ID not found",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (controller.mediaFiles.isEmpty) {
      Get.snackbar(
        "Info",
        "No new files to upload",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      isMediaCompleted.value = true;
      return;
    }

    try {
      // Prepare files for multipart request
      final List<File> fileObjects = [];

      // Collect all valid files
      for (final mediaFile in controller.mediaFiles) {
        final file = File(mediaFile.path);
        if (file.existsSync()) {
          fileObjects.add(file);
        }
      }

      if (fileObjects.isEmpty) {
        Get.snackbar(
          "Error",
          "No valid files to upload",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      log("Uploading ${fileObjects.length} media files to PUT API...");

      // Call the new method that handles multiple files
      final response = await controller.uploadMultipleMediaFiles(
        bookingId: controller.bookingId.value!,
        files: fileObjects,
      );

      if (response.isSuccess) {
        // ✅ Hide the Done button and show success message
        isMediaCompleted.value = true;

        Get.snackbar(
          "Success",
          "${fileObjects.length} file(s) uploaded successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        // Optional: Clear media files after successful upload
        // controller.mediaFiles.clear();
      } else {
        final errorMsg = response.errorMessage ?? "Failed to upload files";
        Get.snackbar(
          "Upload Failed",
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      log("Error uploading media: $e", error: e, stackTrace: stackTrace);
      Get.snackbar(
        "Error",
        "Failed to upload files: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isLoadingWorkDetails.value ? "Loading..." : "Submit Work Form",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        )),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingWorkDetails.value && controller.bookingId.value != null) {
          return Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: UIHelper.kDefaulutPadding()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Section: Working Address & Booking Order Date
                  WorkAddressAndDateWidget(
                    address: controller.address.value.isNotEmpty
                        ? controller.address.value
                        : "Address not available",
                    dateTime: controller.bookingDateTime.value.isNotEmpty
                        ? controller.bookingDateTime.value
                        : "Date not available",
                  ),
                  UIHelper.verticalSpace(24.h),

                  /// Section: Proof Of Work Complete Information
                  Text(
                    "Proof Of Work Complete Information",
                    style: TextFontStyle.headline16w700c202020StyleSatoshi,
                  ),
                  UIHelper.verticalSpace(16.h),

                  /// Section: Completion Date
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

                  /// Section: Duration Time
                  MoreInfoWidgetTile(
                    title: "Duration Time",
                    hintText: "Type Day's In Numbers",
                    keyboardType: TextInputType.number,
                    controller: controller.durationTimeController,
                  ),
                  UIHelper.verticalSpace(24.h),

                  /// Section: Existing API Attachments
                  Obx(() {
                    if (controller.apiAttachments.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Existing Proof Files",
                                style: TextFontStyle.headline16w700c202020StyleSatoshi,
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: AppColors.c000e08,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  '${controller.apiAttachments.length}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          UIHelper.verticalSpace(12.h),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: controller.apiAttachments.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final attachment = entry.value;
                                    final imageUrl = controller.getImageUrl(attachment.url);

                                    return GestureDetector(
                                      onTap: () {
                                        // ✅ Show image in dialog when tapped
                                        _showImageInDialog(imageUrl, "Proof File ${index + 1}");
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 80.w,
                                            height: 80.h,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8.r),
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8.r),
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => Center(
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                                errorWidget: (context, url, error) => Center(
                                                  child: Icon(Icons.error, color: Colors.red, size: 24),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 4,
                                            left: 4,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.6),
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                UIHelper.verticalSpace(8.h),
                                Text(
                                  "Note: Tap on any image to view in full screen",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          UIHelper.verticalSpace(16.h),
                        ],
                      );
                    }
                    return SizedBox();
                  }),

                  /// Section: Upload new media files
                  Obx(() {
                    return ProofOfMediaUploadWidget(
                      title: "Add New Proof Files",
                      mediaFiles: controller.mediaFiles.toList(),
                      onTap: () {
                        log("Browse Button Tapped");
                        controller.showMediaSourceDialog();
                      },
                      removeMediaOnTap: (index) async {
                        await controller.removeMediaFile(index);
                      },
                    );
                  }),
                  UIHelper.verticalSpace(16.h),

                  /// Section: Media Done Button (Hides after tapping + Uploads files via PUT API)
                  Obx(() {
                    final hasNewMedia = controller.mediaFiles.isNotEmpty;
                    final showMediaDoneButton = hasNewMedia && !isMediaCompleted.value;

                    if (!showMediaDoneButton) {
                      return SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (controller.isUploadingMedia.value)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: Colors.blue.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16.h,
                                      height: 16.h,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "Uploading...",
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              CustomElevatedButton(
                                onTap: _uploadMediaFiles,
                                buttonWidth: 120.w,
                                buttonHeight: 36.h,
                                buttonTitle: "Done",
                              ),
                          ],
                        ),
                        UIHelper.verticalSpace(24.h),
                      ],
                    );
                  }),

                  /// Section: Payment Summary
                  Obx(() {
                    return PaymentSummeryWidget(
                      initialCost: controller.initialCost.value,
                      additionalCostList: controller.additionalCosts.toList(),
                      totalPayment: controller.calculateTotalPayment(),
                      isAddAdditionalCostButtonVisible: true,
                      onTap: () {
                        _showAddAdditionalCostDialog();
                      },
                    );
                  }),
                  UIHelper.verticalSpace(16.h),

                  /// Section: Payment Request Button
                  Obx(() {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: CustomElevatedButton(
                        onTap: controller.isPaymentRequestLoading.value
                            ? null
                            : () {
                          _requestPayment();
                        },
                        buttonTitle: controller.isPaymentRequestLoading.value
                            ? "Requesting..."
                            : "Request Payment",
                      ),
                    );
                  }),
                  UIHelper.verticalSpace(32.h),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // Additional Cost Dialog
  Future<void> _showAddAdditionalCostDialog() async {
    final TextEditingController additionalCostTitle = TextEditingController();
    final TextEditingController additionalCost = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cFFFFFF,
        title: Text(
          "Add Additional Cost",
          style: TextFontStyle.headline16w500c000000StyleSatoshi,
        ),
        content: Form(
          key: formKey,
          child: Container(
            width: 1.sw,
            decoration: BoxDecoration(color: AppColors.cFFFFFF),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Section: Additional Cost Title Field
                TextFormField(
                  controller: additionalCostTitle,
                  decoration: InputDecoration(
                    hintText: "Enter cost title",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.ce6e6e6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter cost title';
                    }
                    return null;
                  },
                ),
                UIHelper.verticalSpace(10.h),

                /// Section: Additional Cost Field
                TextFormField(
                  controller: additionalCost,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: "Enter cost amount",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.ce6e6e6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter cost amount';
                    }
                    final price = double.tryParse(value.trim());
                    if (price == null || price <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                UIHelper.verticalSpace(10.h),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              CustomElevatedButton(
                onTap: () async {
                  if (formKey.currentState != null && formKey.currentState!.validate()) {
                    final name = additionalCostTitle.text.trim();
                    final price = double.parse(additionalCost.text.trim());

                    final success = await controller.addAdditionalCost(name, price);

                    // ✅ Close the dialog on success
                    if (success) {
                      Get.back();
                    }
                  }
                },
                buttonWidth: 107.w,
                buttonHeight: 38.h,
                buttonTitle: "Save",
              ),
            ],
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _requestPayment() {
    if (controller.completionDateController.text.isEmpty) {
      Get.snackbar("Warning", "Please select completion date");
      return;
    }

    if (controller.durationTimeController.text.isEmpty) {
      Get.snackbar("Warning", "Please enter duration time");
      return;
    }

    final duration = double.tryParse(controller.durationTimeController.text);
    if (duration == null) {
      Get.snackbar("Warning", "Please enter a valid number for duration");
      return;
    }

    final totalMedia = controller.totalMediaCount;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: AppColors.c000e08),
            SizedBox(width: 8.w),
            Text("Request Payment", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("You are about to request payment with the following details:",
                  style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 16.h),
              _buildDetailRow("Completion Date:", controller.completionDateController.text),
              _buildDetailRow("Duration:", "${controller.durationTimeController.text} days"),
              _buildDetailRow("Total Files:", "$totalMedia"),
              if (controller.apiAttachments.isNotEmpty)
                _buildDetailRow("  - Existing files:", "${controller.apiAttachments.length}"),
              if (controller.mediaFiles.isNotEmpty)
                _buildDetailRow("  - New files:", "${controller.mediaFiles.length}"),
              SizedBox(height: 12.h),
              Divider(),
              SizedBox(height: 12.h),
              _buildDetailRow("Initial Cost:", "\$${controller.initialCost.value.toStringAsFixed(2)}"),
              if (controller.additionalCosts.isNotEmpty)
                _buildDetailRow(
                    "Additional Costs:", "\$${(controller.calculateTotalPayment() - controller.initialCost.value).toStringAsFixed(2)}"),
              SizedBox(height: 8.h),
              _buildDetailRow(
                "Total Payment:",
                "\$${controller.calculateTotalPayment().toStringAsFixed(2)}",
                isBold: true,
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  "The client will be notified about this payment request.",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue.shade900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.requestPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.c000e08,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text("Send Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
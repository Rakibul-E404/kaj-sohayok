import 'dart:developer';
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
import '../../../normal_user/work_completed_details/widgets/additional_cost_popup.dart';

class SvpSubmitWorkFormScreen extends StatefulWidget {
  const SvpSubmitWorkFormScreen({super.key});

  @override
  State<SvpSubmitWorkFormScreen> createState() => _SvpSubmitWorkFormScreenState();
}

class _SvpSubmitWorkFormScreenState extends State<SvpSubmitWorkFormScreen> {
  final SvpSubmitWorkFormScreenController controller = Get.put(
    SvpSubmitWorkFormScreenController(),
  );

  // Track completion status
  final RxBool isMediaCompleted = false.obs;
  final RxBool isPaymentCompleted = false.obs;

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
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: UIHelper.kDefaulutPadding(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///Section : Working Address & Booking Order Date
                  WorkAddressAndDateWidget(
                    address: controller.address.value.isNotEmpty
                        ? controller.address.value
                        : "Address not available",
                    dateTime: controller.bookingDateTime.value.isNotEmpty
                        ? controller.bookingDateTime.value
                        : "Date not available",
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

                  ///Section : Existing API Attachments
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

                                    return Stack(
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
                                          top: 2,
                                          right: 2,
                                          child: GestureDetector(
                                            onTap: () {
                                              controller.removeApiAttachment(index);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 12,
                                                color: Colors.white,
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
                                    );
                                  }).toList(),
                                ),
                                UIHelper.verticalSpace(8.h),
                                Text(
                                  "Note: These are existing files from the work order",
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

                  ///Section : Upload new media files
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

                  ///Section : Media Done Button (Only visible when media is added)
                  Obx(() {
                    final hasMedia = controller.totalMediaCount > 0;

                    if (!hasMedia) {
                      return SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isMediaCompleted.value)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: Colors.green.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 16.h),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "Completed",
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              CustomElevatedButton(
                                onTap: () {
                                  isMediaCompleted.value = true;
                                  Get.snackbar(
                                    "Success",
                                    "Media files marked as complete",
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                },
                                buttonWidth: 120.w,
                                buttonHeight: 36.h,
                                buttonTitle: "Done",
                                // backgroundColor: AppColors.c000e08,
                              ),
                          ],
                        ),
                        UIHelper.verticalSpace(24.h),
                      ],
                    );
                  }),

                  ///Section : Payment Summary
                  Obx(() {
                    return PaymentSummeryWidget(
                      initialCost: controller.initialCost.value,
                      additionalCostList: controller.additionalCosts.toList(),
                      totalPayment: controller.calculateTotalPayment(),
                      isAddAdditionalCostButtonVisible: true,
                      onTap: () {
                        showAdditionalCostDialog(
                          context: context,
                          additionlCostSubmitOnTap: (String name, double price) {
                            controller.addAdditionalCost(name, price);
                          },
                        );
                      },
                    );
                  }),
                  UIHelper.verticalSpace(16.h),

                  ///Section : Payment Done Button (Only visible when additional costs are added)
                  Obx(() {
                    final hasAdditionalCosts = controller.additionalCosts.isNotEmpty;

                    if (!hasAdditionalCosts) {
                      return SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isPaymentCompleted.value)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: Colors.green.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 16.h),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "Completed",
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              CustomElevatedButton(
                                onTap: () {
                                  isPaymentCompleted.value = true;
                                  Get.snackbar(
                                    "Success",
                                    "Payment details marked as complete",
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                },
                                buttonWidth: 120.w,
                                buttonHeight: 36.h,
                                buttonTitle: "Done",
                                // backgroundColor: AppColors.c000e08,
                              ),
                          ],
                        ),
                        UIHelper.verticalSpace(32.h),
                      ],
                    );
                  }),

                  ///Section : Payment Request Button (Always visible)
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

  void _requestPayment() {
    // Validate all fields
    if (controller.completionDateController.text.isEmpty) {
      Get.snackbar(
        "Warning",
        "Please select completion date",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (controller.durationTimeController.text.isEmpty) {
      Get.snackbar(
        "Warning",
        "Please enter duration time",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
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
              Text(
                "You are about to request payment with the following details:",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
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
                _buildDetailRow("Additional Costs:", "\$${(controller.calculateTotalPayment() - controller.initialCost.value).toStringAsFixed(2)}"),
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
            child: Text(
              "Send Request",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
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
}
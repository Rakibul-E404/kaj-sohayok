import 'dart:developer';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/app_constant_text.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/features/normal_user/service_preview/widgets/booking_placed_bottomsheet_widget.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/loading_helper.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';
import 'package:kaz_bd/utilities/logger_util.dart';

import '../../../../controllers/normal_user_service_preview_screen_controller.dart';
import '../../../../custom_widgets/custom_shimmer_effect.dart';
import '../../../../utilities/app_url.dart';
import '../widgets/details_card_widget.dart';

class ServicesPreviewScreen extends StatelessWidget {
  const ServicesPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final NormalUserServicePreviewScreenController controller =
        Get.find<NormalUserServicePreviewScreenController>();

    final arguments = Get.arguments as Map<String, dynamic>?;
    final providerID = arguments?['providerID'] ?? '';
    final bookingDateTime = arguments?['bookingDateTime'] ?? '';
    final address = arguments?['address'] ?? '';
    final latDynamic = arguments?['lat'];
    final longDynamic = arguments?['long'];

    // Helper to get month name
    String _getMonthName(int month) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return month >= 1 && month <= 12 ? months[month - 1] : '';
    }

    // Helper to format time in 12-hour format
    String _formatTime12Hour(int hour, int minute) {
      String period = hour >= 12 ? 'PM' : 'AM';
      int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      String formattedMinute = minute.toString().padLeft(2, '0');
      return "${displayHour}:${formattedMinute}$period";
    }

    // Helper function to format date time for display
    String _formatDisplayDateTime(String apiDateTime) {
      try {
        DateTime dateTime = DateTime.parse(apiDateTime);
        // Format as "Jun 17, 2025  09:31AM" or similar format
        String formattedDate =
            "${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}";
        String formattedTime =
            _formatTime12Hour(dateTime.hour, dateTime.minute);
        return "$formattedDate  $formattedTime";
      } catch (e) {
        log('Error parsing date time: $e');
        return apiDateTime; // Return original if parsing fails
      }
    }

    // In your ServicesPreviewScreen:
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Reset controller to clear previous values before setting new ones
      controller.reset();

      controller.setProviderId(pid: providerID);
      controller.setBookingDateTime(bDateTime: bookingDateTime);
      controller.setAddress(addr: address);

      // Handle both string and numeric values for lat and long
      try {
        double? latDouble;
        double? longDouble;

        // Parse latitude
        if (latDynamic is String) {
          latDouble = double.tryParse(latDynamic);
        } else if (latDynamic is num) {
          latDouble = latDynamic.toDouble();
        } else {
          latDouble = null;
        }

        // Parse longitude
        if (longDynamic is String) {
          longDouble = double.tryParse(longDynamic);
        } else if (longDynamic is num) {
          longDouble = longDynamic.toDouble();
        } else {
          longDouble = null;
        }

        // Set values with appropriate validity status
        controller.setLatValue(
          latValue: latDouble ?? 0.0,
          isValid: latDouble != null,
        );
        controller.setLongValue(
          longValue: longDouble ?? 0.0,
          isValid: longDouble != null,
        );

        // If parsing failed, make sure validity flags are set appropriately
        if (latDouble == null || longDouble == null) {
          log(
            'Warning: One or both coordinates could not be parsed - lat: ${latDouble ?? "null"}, long: ${longDouble ?? "null"}',
          );
        } else {
          log('Successfully parsed lat: $latDouble, long: $longDouble');
        }
      } catch (e) {
        log('Error parsing lat/long: $e');
        // Mark as invalid in case of exception
        controller.setLatValue(latValue: 0.0, isValid: false);
        controller.setLongValue(longValue: 0.0, isValid: false);
      }

      // Load service data preview after setting up the provider ID
      await controller.getServiceDataPreview();
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'service_preview'.tr,
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 2.sp, color: AppColors.cb4b4b4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image container with rounded corners and fit image

                    /// --- Service Image ---
                    Stack(
                      children: [
                        Obx(() {
                          // Get the first gallery attachment from service details if available
                          String? imageUrl;
                          if (controller.serviceImage != null) {
                            imageUrl = controller.serviceImage;
                          }

                          // Show network image if URL is available, otherwise show placeholder
                          if (imageUrl != null && imageUrl.isNotEmpty) {
                            // Make sure the URL is properly formatted
                            String fullImageUrl = imageUrl;
                            if (!imageUrl.startsWith('http')) {
                              // If it's a relative path, prepend the base URL
                              fullImageUrl = '${AppUrl.imageBaseUrl}$imageUrl';
                            }

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.network(
                                fullImageUrl,
                                height: 170.h,
                                width: 1.sw,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // If network image fails, show placeholder
                                  return CustomShimmerEffect(
                                    height: 170.h,
                                    width: 1.sw,
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return CustomShimmerEffect(
                                    height: 170.h,
                                    width: 1.sw,
                                  );
                                },
                              ),
                            );
                          } else {
                            // Show placeholder if no image is available
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(24.r),
                              child: Image.asset(
                                Assets.images.errorImage.path,
                                width: 1.sw,
                                height: 170.h,
                                fit: BoxFit.contain,
                              ),
                            );
                          }
                        }),
                        Positioned(
                          right: 10.w,
                          top: 10.h,
                          child: GestureDetector(
                            onTap: () {
                              LoggerUtils.info("Date/Time Edit Button Taped!");
                              Get.toNamed(Routes.bookingDateScreen, arguments: {
                                'providerID': providerID,
                              });
                            },
                            child: Icon(
                              Icons.pending,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Section : Service title
                    // Section : Service price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() {
                          if (controller.isServicePreViewDataLoading.value ==
                              true) {
                            return CustomShimmerEffect(
                              height: 10.h,
                              width: 0.5.sw,
                            );
                          }

                          return Text(
                            controller.serviceName.toString(),
                            style:
                                TextFontStyle.headline16w700c000000StyleSatoshi,
                          );
                        }),
                        Obx(() {
                          if (controller.isServicePreViewDataLoading.value ==
                              true) {
                            return CustomShimmerEffect(
                              height: 10.h,
                              width: 0.3.sw,
                            );
                          }
                          return RichText(
                            text: TextSpan(
                              text: '${AppText.bdTkSign} ${'start_from'.tr} ',
                              style: TextFontStyle
                                  .headline12w500c6a6a6aStyleSatoshi,
                              children: [
                                TextSpan(
                                  text: '${controller.serviceStartPrice}',
                                  style: TextFontStyle
                                      .headline16w700c778bebStyleSatoshi,
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),

                    ///Sesction : Divider
                    UIHelper.verticalSpace(18.h),
                    DottedLine(
                      direction: Axis.horizontal,
                      lineLength: double.infinity,
                      lineThickness: 1.sp,
                      dashLength: 4.w,
                      dashGapLength: 4.w,
                      dashColor: AppColors.cb4b4b4,
                    ),
                    UIHelper.verticalSpace(18.h),

                    // Details header
                    Text(
                      'deails'.tr,
                      style: TextFontStyle.headline16w700c000000StyleSatoshi,
                    ),
                    UIHelper.verticalSpace(16.h),

                    // Location card with icon, text, and edit button
                    ServicePreviewDetailsCardWidget(
                      // onTap: () {
                      //   log("Location Edit Button Taped!");
                      //   Get.back();
                      // },
                      title: 'location'.tr,
                      data: address,
                      icon: Icons.location_on,
                    ),

                    UIHelper.verticalSpace(10.h),

                    // Date/time card with icon, text, and edit button
                    ServicePreviewDetailsCardWidget(
                      // onTap: () {
                      //   log("Date/Time Edit Button Taped!");
                      //   Get.toNamed(Routes.bookingDateScreen, arguments: {
                      //     'providerID': providerID,
                      //   });
                      // },
                      title: 'date_time'.tr,
                      data: bookingDateTime.isNotEmpty
                          ? _formatDisplayDateTime(bookingDateTime)
                          : 'Select Date & Time',
                      icon: Icons.watch_later,
                    ),
                  ],
                ),
              ),
              const Spacer(),

              /// Confirm Booking button
              Obx(() {
                return CustomElevatedButton(
                  onTap: controller.isCSBLoading.value
                      ? null
                      : () async {
                          LoggerUtils.info(
                              "🤒🤒🤒🤒🤒🤒🤒-------Confirm Booking Button Tapped!!!");
                          // Call the API
                          await controller.confirmServiceBooking();

                          // Check if booking was successful
                          if (controller.serviceBookingModel.value?.success ==
                              true) {
                            // Show success bottom sheet
                            _showBottomModal(context);
                          }
                        },
                  buttonTitle: controller.isCSBLoading.value
                      ? 'confirming_your_order'.tr
                      : 'confirm_booking'.tr,
                );
              }),
              UIHelper.verticalSpace(20.h),
            ],
          ),
        ),
      ),
    );
  }

  ///----------------- Function to show the bottom modal
  void _showBottomModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BookingPlacedBottomSheet();
      },
    );
  }
}

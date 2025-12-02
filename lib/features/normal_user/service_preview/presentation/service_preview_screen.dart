import 'dart:developer';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/features/normal_user/service_preview/widgets/booking_placed_bottomsheet_widget.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../controllers/normal_user_service_preview_screen_controller.dart';
import '../widgets/details_card_widget.dart';

class ServicesPreviewScreen extends StatelessWidget {
  const ServicesPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final NormalUserServicePreviewScreenController controller =
        Get.find<NormalUserServicePreviewScreenController>();

    final arguments = Get.arguments as Map<String, dynamic>?;
    final providerId = arguments?['userId'] ?? '';
    final bookingDateTime = arguments?['bookingDateTime'] ?? '';
    final address = arguments?['address'] ?? '';
    final latDynamic = arguments?['lat'];
    final longDynamic = arguments?['long'];

    // In your ServicesPreviewScreen:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setProviderId(pid: providerId);
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
        controller.setLatValue(latValue: latDouble ?? 0.0, isValid: latDouble != null);
        controller.setLongValue(longValue: longDouble ?? 0.0, isValid: longDouble != null);

        // If parsing failed, make sure validity flags are set appropriately
        if (latDouble == null || longDouble == null) {
          log('Warning: One or both coordinates could not be parsed - lat: ${latDouble ?? "null"}, long: ${longDouble ?? "null"}');
        } else {
          log('Successfully parsed lat: $latDouble, long: $longDouble');
        }
      } catch (e) {
        log('Error parsing lat/long: $e');
        // Mark as invalid in case of exception
        controller.setLatValue(latValue: 0.0, isValid: false);
        controller.setLongValue(longValue: 0.0, isValid: false);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Services Preview",
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: Image.network(
                        'https://deax38zvkau9d.cloudfront.net/prod/assets/images/uploads/services/1708074899how-to-start-cleaning-house.webp',
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Section : Service title
                    // Section : Service price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Home Cleaning',
                          style:
                              TextFontStyle.headline16w700c000000StyleSatoshi,
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Start From ',
                            style:
                                TextFontStyle.headline12w500c6a6a6aStyleSatoshi,
                            children: [
                              TextSpan(
                                text: '\$30.90',
                                style: TextFontStyle
                                    .headline16w700c778bebStyleSatoshi,
                              ),
                            ],
                          ),
                        ),
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
                      'Details',
                      style: TextFontStyle.headline16w700c000000StyleSatoshi,
                    ),
                    UIHelper.verticalSpace(16.h),

                    // Location card with icon, text, and edit button
                    ServicePreviewDetailsCardWidget(
                      onTap: () {
                        log("Location Edit Button Taped!");
                      },
                      title: "Location",
                      data: address,
                      icon: Icons.location_on,
                    ),

                    UIHelper.verticalSpace(10.h),

                    // Date/time card with icon, text, and edit button
                    ServicePreviewDetailsCardWidget(
                      onTap: () {
                        log("Date/Time Edit Button Taped!");
                      },
                      title: "Date/Time",
                      data: 'Jun 17, 2025  09:31AM',
                      icon: Icons.watch_later,
                    ),
                  ],
                ),
              ),
              const Spacer(),

              /// Confirm Booking button
              Obx(() {
                return CustomElevatedButton(
                  onTap: () async {
                    // Call the API
                    await controller.confirmServiceBooking();

                    // Check if booking was successful
                    if (controller.serviceBookingModel.value?.success == true) {
                      // Show success bottom sheet
                      _showBottomModal(context);
                    }
                  },
                  buttonTitle: controller.isCSBLoading.value
                      ? "Confirming Your Order"
                      : "Confirm Booking",
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

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/app_enums.dart';
import 'package:kaz_bd/routes/routes.dart';
import 'package:kaz_bd/utilities/logger_util.dart';

import '../../../../../../controllers/message_screen_controller.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../widgets/bookings_details_card_widget.dart';
import '../controller/accepted_booking_controller.dart';

class AcceptedBookingTab extends StatelessWidget {
  AcceptedBookingTab({super.key});

  final AcceptedBookingsController controller =
      Get.put(AcceptedBookingsController());

  String _formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  String _getServiceName(Map<String, dynamic>? serviceName) {
    if (serviceName == null) return 'Unknown Service';
    return serviceName['en'] ?? serviceName['bn'] ?? 'Unknown Service';
  }

  String _getAddress(Map<String, dynamic>? address) {
    if (address == null) return 'Unknown Location';
    return address['en'] ?? address['bn'] ?? 'Unknown Location';
  }

  String _getImageUrl(String bookingId) {
    final imageUrl = controller.getImageUrl(bookingId);

    if (imageUrl.isNotEmpty && controller.hasImage(bookingId)) {
      return imageUrl;
    }

    return Assets.images.userImage.path;
  }

  bool _isNetworkImage(String bookingId) {
    final imageUrl = controller.getImageUrl(bookingId);
    return imageUrl.isNotEmpty && controller.hasImage(bookingId);
  }

  // FIXED: Extract provider ID from the correct location based on JSON structure
  String _getProviderId(Map<String, dynamic> booking) {
    String? providerId;

    // According to the JSON structure, the provider ID is in:
    // providerDetailsId._ServiceProviderId
    if (booking['providerDetailsId'] != null) {
      final providerDetailsMap =
          booking['providerDetailsId'] as Map<String, dynamic>?;
      if (providerDetailsMap != null &&
          providerDetailsMap['_ServiceProviderId'] != null) {
        providerId = providerDetailsMap['_ServiceProviderId'].toString();
        log('✅ Provider ID extracted from providerDetailsId._ServiceProviderId: $providerId');
        return providerId;
      }
    }

    // Fallback: Try to get from providerId._userId if providerDetailsId is not available
    if (booking['providerId'] != null && booking['providerId'] is Map) {
      final providerMap = booking['providerId'] as Map<String, dynamic>;
      if (providerMap['_userId'] != null) {
        providerId = providerMap['_userId'].toString();
        log('⚠️ Provider ID extracted from providerId._userId (fallback): $providerId');
        return providerId;
      }
    }

    log('❌ ERROR: No provider ID found in booking data');
    log('Booking data: $booking');
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              UIHelper.verticalSpace(16.h),
              Text(
                'Loading accepted bookings...',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: Colors.red,
                ),
                UIHelper.verticalSpace(16.h),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                UIHelper.verticalSpace(20.h),
                ElevatedButton(
                  onPressed: () => controller.getAcceptedBookings(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.acceptedBookings.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 64.sp,
                color: Colors.grey,
              ),
              UIHelper.verticalSpace(16.h),
              Text(
                'No accepted bookings found',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.getAcceptedBookings(),
        child: ListView.separated(
          padding: EdgeInsets.only(top: 16.sp),
          itemCount: controller.acceptedBookings.length,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
          itemBuilder: (context, index) {
            final booking = controller.acceptedBookings[index];
            final bookingId = booking['_ServiceBookingId'] ?? '';

            // Extract provider ID from providerDetailsId._ServiceProviderId
            final providerId = _getProviderId(booking);

            final serviceName = booking['providerDetailsId']?['serviceName'];
            final address = booking['address'];
            final provider = booking['providerId'];

            final imageUrl = _getImageUrl(bookingId);
            final isNetworkImage = _isNetworkImage(bookingId);

            // Log for debugging
            log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            log('📋 Booking Index: $index');
            log('🆔 Booking ID: $bookingId');
            log('👤 Provider ID: $providerId');
            log('📝 Service Name: ${_getServiceName(serviceName)}');
            log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

            return BookingDetailsCardWidget(
              onTap: () {
                if (providerId.isEmpty) {
                  log('❌ Cannot navigate: Provider ID is empty');
                  Get.snackbar(
                    'Error',
                    'Provider information not available',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                log('🚀 Card tapped - Navigating to details screen');
                log('   Status: ${BookingStatusEnum.acceptedBooking}');
                log('   Booking ID: $bookingId');
                log('   Provider ID: $providerId');

                Get.toNamed(
                  Routes.serviceDetailsScreen,
                  arguments: {
                    "status": BookingStatusEnum.acceptedBooking,
                    "bookingId": bookingId,
                    "providerId": providerId,
                  },
                );
              },
              isAcceptedBookingTab: true,

              ///Button OnTap : View
              isAcceptedBookingTabViewOnTap: () {
                if (providerId.isEmpty) {
                  log('❌ Cannot navigate: Provider ID is empty');
                  Get.snackbar(
                    'Error',
                    'Provider information not available',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                log('👁️ VIEW button tapped - Navigating to details screen');
                log('   Status: ${BookingStatusEnum.acceptedBooking}');
                log('   Booking ID: $bookingId');
                log('   Provider ID: $providerId');

                Get.toNamed(
                  Routes.serviceDetailsScreen,
                  arguments: {
                    "status": BookingStatusEnum.acceptedBooking,
                    "bookingId": bookingId,
                    "providerId": providerId,
                  },
                );
              },

              ///Button OnTap : Message
              isAcceptedBookingTabMessageOnTap: () async {
                log("💬 Message button tapped for booking: $bookingId");
                Get.find<MessageScreenController>().createMessage(
                    participantId: booking['providerId']['_userId'],
                    name: _getServiceName(serviceName),
                    imageUrl: imageUrl);
              },
              title: _getServiceName(serviceName),
              initialPayablePrice: (booking['startPrice'] ?? 0).toString(),
              location: _getAddress(address),
              dateTime: _formatDateTime(booking['bookingDateTime'] ?? ''),
              serviceProviderProfileImage: imageUrl,
              serviceProviderName: provider?['name'] ?? 'Unknown Provider',
              serviceProviderDesignation: 'Service Provider',
              isNetworkImage: isNetworkImage,
            );
          },
        ),
      );
    });
  }
}

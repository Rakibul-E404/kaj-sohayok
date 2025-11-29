

import 'dart:developer';
// import 'dart:log';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../constants/app_enums.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';
import '../../../widgets/bookings_details_card_widget.dart';

// Import the controller
// import '../controller/in_progress_bookings_controller.dart';
import '../in_progress_controller/in_progress_controller.dart';

class InProgressTab extends StatelessWidget {
  InProgressTab({super.key});

  final InProgressBookingsController controller = Get.put(InProgressBookingsController());

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

  // Return network URL when available, otherwise asset path
  String _getImageUrl(String bookingId) {
    final imageUrl = controller.getImageUrl(bookingId);

    log('Getting image for booking $bookingId: $imageUrl');
    log('Has image: ${controller.hasImage(bookingId)}');

    // If we have a valid network image URL and it's accessible, return it
    if (imageUrl.isNotEmpty && controller.hasImage(bookingId)) {
      log('✅ Using network image: $imageUrl');
      return imageUrl;
    }

    // Return fallback asset path
    log('❌ Using fallback asset image');
    return Assets.images.userImage.path;
  }

  // Check if the image is a network image
  bool _isNetworkImage(String bookingId) {
    final imageUrl = controller.getImageUrl(bookingId);
    final isNetwork = imageUrl.isNotEmpty && controller.hasImage(bookingId);
    log('Is network image for $bookingId: $isNetwork');
    return isNetwork;
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
                'Loading in-progress bookings...',
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
                  onPressed: () => controller.getInProgressBookings(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.inProgressBookings.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.build_circle_outlined,
                size: 64.sp,
                color: Colors.grey,
              ),
              UIHelper.verticalSpace(16.h),
              Text(
                'No in-progress bookings found',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.getInProgressBookings(),
        child: ListView.separated(
          padding: EdgeInsets.only(top: 16.sp),
          itemCount: controller.inProgressBookings.length,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
          itemBuilder: (context, index) {
            final booking = controller.inProgressBookings[index];
            final bookingId = booking['_ServiceBookingId'] ?? '';

            final serviceName = booking['providerDetailsId']?['serviceName'];
            final address = booking['address'];
            final provider = booking['providerId'];

            final imageUrl = _getImageUrl(bookingId);
            final isNetworkImage = _isNetworkImage(bookingId);

            log('Building booking card for $bookingId');
            log('Final image URL: $imageUrl');
            log('Is network image: $isNetworkImage');

            return BookingDetailsCardWidget(
              onTap: () {
                Get.toNamed(
                  Routes.serviceDetailsScreen,
                  arguments: {
                    "status": BookingStatusEnum.inProgress,
                    "bookingId": bookingId,
                  },
                );
              },
              isInProgressTab: true,

              ///Button OnTap -> Message
              isInProgressTabMessageOnTap: () {
                log("My Bookings screen inProgress tab message button tapped for booking: $bookingId");
                // Add your message functionality here
              },

              ///Button OnTap -> View
              isInProgressTabViewOnTap: () {
                Get.toNamed(
                  Routes.serviceDetailsScreen,
                  arguments: {
                    "status": BookingStatusEnum.inProgress,
                    "bookingId": bookingId,
                  },
                );
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
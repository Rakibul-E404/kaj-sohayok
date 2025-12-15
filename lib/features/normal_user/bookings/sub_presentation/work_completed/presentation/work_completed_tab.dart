import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../controller/work_completed_controller.dart' as booking_ctrl;
import '../widgets/show_review_giving_alert_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/features/normal_user/bookings/widgets/bookings_details_card_widget.dart';

class WorkCompletedTab extends StatelessWidget {
  const WorkCompletedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(booking_ctrl.WorkCompletedBookingsController());

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              UIHelper.verticalSpace(16.h),
              Text(
                'Loading work completed bookings...',
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
                Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
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
                  onPressed: () => controller.getWorkCompletedBookings(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.workCompletedBookings.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_outline, size: 64.sp, color: Colors.grey),
              UIHelper.verticalSpace(16.h),
              Text(
                'No work completed bookings found',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.getWorkCompletedBookings(),
        child: ListView.separated(
          padding: EdgeInsets.only(top: 16.sp),
          itemCount: controller.workCompletedBookings.length,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
          itemBuilder: (context, index) {
            final booking = controller.workCompletedBookings[index];
            final bookingId = booking['_ServiceBookingId']?.toString() ?? '';
            final serviceName = booking['providerDetailsId']?['serviceName'] as Map<String, dynamic>?;
            final address = booking['address'] as Map<String, dynamic>?;
            final provider = booking['providerId'] as Map<String, dynamic>?;

            // Get image information
            final imageInfo = controller.getImageInfo(bookingId);
            final imageUrl = _getImageUrl(imageInfo);
            final isNetworkImage = _isNetworkImage(imageInfo);
            final isReviewGiven = controller.isReviewGiven(bookingId);

            return BookingDetailsCardWidget(
              onTap: () => _handleCardTap(booking),
              isWorkCompletedTab: true,
              isReviewGiven: isReviewGiven,
              isWorkCompletedTabGiveReviewOnTap: () => _handleReviewButton(booking),
              title: _getServiceName(serviceName),
              initialPayablePrice: (booking['startPrice'] ?? 0).toString(),
              location: _getAddress(address),
              dateTime: _formatDateTime(booking['bookingDateTime']?.toString() ?? ''),
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

  // ═══════════════════════════════════════════════════════════════
  // CARD TAP HANDLER - SIMPLIFIED VERSION
  // ═══════════════════════════════════════════════════════════════
  static void _handleCardTap(Map<String, dynamic> booking) {
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    log('👆 [WORK COMPLETED TAB] Card tapped');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      // Extract booking ID
      final bookingId = booking['_ServiceBookingId']?.toString() ?? '';

      log('📊 [EXTRACTED ID]');
      log('   bookingId: "$bookingId"');

      // Validate required ID
      if (bookingId.isEmpty) {
        log('❌ [VALIDATION FAILED] bookingId is empty');
        Get.snackbar(
          'Navigation Error',
          'Cannot load service details. Booking ID is missing.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      log('✅ [NAVIGATION] Preparing to navigate with bookingId: $bookingId');
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Navigate with just the booking ID
      Get.toNamed(
        Routes.workCompletedDetailsScreen,
        arguments: bookingId, // Pass only bookingId as String
      );

      log('✅ [NAVIGATION] Successfully navigated to details screen');

    } catch (e, stackTrace) {
      log('❌ [ERROR] Exception in _handleCardTap:');
      log('   Error: $e');
      log('   Stack trace: $stackTrace');
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      Get.snackbar(
        'Error',
        'Failed to open details: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // REVIEW BUTTON HANDLER
  // ═══════════════════════════════════════════════════════════════
  static void _handleReviewButton(Map<String, dynamic> booking) {
    log('⭐ [REVIEW] Give review button tapped');

    try {
      final bookingId = booking['_ServiceBookingId']?.toString() ?? '';

      String serviceProviderId = '';
      if (booking['providerDetailsId'] is Map<String, dynamic>) {
        serviceProviderId = (booking['providerDetailsId'] as Map<String, dynamic>)['_ServiceProviderId']?.toString() ?? '';
      } else if (booking['providerDetailsId'] is String) {
        serviceProviderId = booking['providerDetailsId'].toString();
      }

      String providerId = '';
      if (booking['providerId'] is Map<String, dynamic>) {
        providerId = (booking['providerId'] as Map<String, dynamic>)['_userId']?.toString() ?? '';
      }

      log('⭐ [REVIEW] IDs: bookingId=$bookingId, serviceProviderId=$serviceProviderId, providerId=$providerId');

      // Store data for dialog
      Get.put<ReviewData>(
        ReviewData(
          bookingId: bookingId,
          serviceProviderId: serviceProviderId,
          providerId: providerId,
        ),
        tag: 'reviewData',
      );

      showReviewGivingAlertDialog();
      log('✅ [REVIEW] Dialog opened successfully');

    } catch (e) {
      log('❌ [REVIEW] Error: $e');
      Get.snackbar(
        'Error',
        'Failed to open review dialog',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // IMAGE HANDLING METHODS
  // ═══════════════════════════════════════════════════════════════
  static String _getImageUrl(booking_ctrl.ImageInfo imageInfo) {
    if (imageInfo.url.isEmpty) {
      // Return default image path
      return Assets.images.userImage.path;
    }

    // Return the URL from image info
    return imageInfo.url;
  }

  static bool _isNetworkImage(booking_ctrl.ImageInfo imageInfo) {
    if (imageInfo.url.isEmpty) {
      return false; // Using local asset
    }

    // For AWS URLs or accessible non-AWS URLs, it's a network image
    return imageInfo.isAwsUrl || imageInfo.isAccessible;
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════
  static String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  static String _getServiceName(Map<String, dynamic>? serviceName) {
    if (serviceName == null) return 'Unknown Service';
    return serviceName['en'] ?? serviceName['bn'] ?? 'Unknown Service';
  }

  static String _getAddress(Map<String, dynamic>? address) {
    if (address == null) return 'Unknown Location';
    return address['en'] ?? address['bn'] ?? 'Unknown Location';
  }
}

// ═══════════════════════════════════════════════════════════════
// REVIEW DATA CLASS
// ═══════════════════════════════════════════════════════════════
class ReviewData {
  final String bookingId;
  final String serviceProviderId;
  final String providerId;

  ReviewData({
    required this.bookingId,
    required this.serviceProviderId,
    required this.providerId,
  });
}



import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/app_enums.dart';
import 'package:kaz_bd/features/normal_user/bookings/widgets/bookings_details_card_widget.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';
import '../controller/service_canceled_controller.dart';

class ServicesCanceledTab extends StatelessWidget {
  const ServicesCanceledTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CanceledBookingsController());

    return RefreshIndicator(
      onRefresh: () => controller.getCanceledBookings(),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UIHelper.verticalSpace(16.h),
                Text(
                  'Loading Canceled Bookings...'.tr,
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
                    onPressed: () => controller.getCanceledBookings(),
                    child: Text('retry'.tr),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.canceledBookings.isEmpty) {
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UIHelper.verticalSpace(0.2.sh),
                  Icon(
                    Icons.cancel_outlined,
                    size: 64.sp,
                    color: Colors.grey,
                  ),
                  UIHelper.verticalSpace(16.h),
                  Text(
                    'no_canceled_bookings_found'.tr,
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // ✅ SCROLLABLE LIST — NO NESTED SCROLL CONFLICT
        return ListView.separated(
          padding: EdgeInsets.only(
              top: 16.sp, bottom: 100.h), // Bottom padding for safe area / FAB
          itemCount: controller.canceledBookings.length,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
          itemBuilder: (context, index) {
            final booking = controller.canceledBookings[index];
            final bookingId = booking['_ServiceBookingId']?.toString() ?? '';

            final serviceProviderId = _getServiceProviderId(booking);
            final providerId = _getProviderUserId(booking);

            log('🧾 [CANCELED TAB] Card #$index →');
            log('   Booking ID: "$bookingId"');
            log('   Service Provider ID: "$serviceProviderId"');
            log('   Provider User ID: "$providerId"');

            final serviceName = booking['providerDetailsId']?['serviceName']
                as Map<String, dynamic>?;
            final address = booking['address'] as Map<String, dynamic>?;
            final provider = booking['providerId'] as Map<String, dynamic>?;

            final imageUrl = _getImageUrl(bookingId, controller);
            final isNetworkImage = _isNetworkImage(bookingId, controller);

            return BookingDetailsCardWidget(
              onTap: () {
                _navigateToDetailsScreen(
                    bookingId, serviceProviderId, providerId);
              },
              isCanceledTab: true,
              isCanceledTabCancelOnTap: () {
                log("❌ [CANCELED TAB] Cancel button tapped for booking: $bookingId");
                // Add rebooking/feedback logic here if needed
              },
              title: _getServiceName(serviceName),
              initialPayablePrice: (booking['startPrice'] ?? 0).toString(),
              location: _getAddress(address),
              dateTime: _formatDateTime(
                booking['bookingDateTime']?.toString() ?? '',
              ),
              serviceProviderProfileImage:
                  imageUrl ?? Assets.images.userImage.path,
              serviceProviderName: provider?['name'] ?? 'Unknown Provider',
              serviceProviderDesignation: 'services_provider'.tr,
              isNetworkImage: isNetworkImage,
            );
          },
        );
      }),
    );
  }

  // ─── HELPER METHODS ───────────────────────────────────────────────

  static String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      log('⚠️ [CANCELED TAB] DateTime parse error: $e');
      return dateTimeString;
    }
  }

  static String _getServiceName(Map<String, dynamic>? serviceName) {
    if (serviceName == null) return 'unknown_service'.tr;
    return serviceName['en'] ?? serviceName['bn'] ?? 'unknown_service'.tr;
  }

  static String _getAddress(Map<String, dynamic>? address) {
    if (address == null) return 'unknown_location'.tr;
    return address['en'] ?? address['bn'] ?? 'unknown_location'.tr;
  }

  static String _getServiceProviderId(Map<String, dynamic> booking) {
    final providerDetails =
        booking['providerDetailsId'] as Map<String, dynamic>?;
    if (providerDetails?['_ServiceProviderId'] != null) {
      final id = providerDetails!['_ServiceProviderId'].toString();
      log('✅ [CANCELED TAB] Service Provider ID from providerDetailsId._ServiceProviderId: $id');
      return id;
    }

    if (booking['serviceProviderDetailsId'] != null) {
      final id = booking['serviceProviderDetailsId'].toString();
      log('✅ [CANCELED TAB] Service Provider ID from serviceProviderDetailsId: $id');
      return id;
    }

    log('⚠️ [CANCELED TAB] No Service Provider ID found');
    return '';
  }

  static String _getProviderUserId(Map<String, dynamic> booking) {
    final provider = booking['providerId'] as Map<String, dynamic>?;
    if (provider?['_userId'] != null) {
      final id = provider!['_userId'].toString();
      log('✅ [CANCELED TAB] Provider User ID from providerId._userId: $id');
      return id;
    }

    log('⚠️ [CANCELED TAB] No Provider User ID found in providerId');
    return '';
  }

  static String? _getImageUrl(
      String bookingId, CanceledBookingsController controller) {
    final url = controller.getImageUrl(bookingId);
    if (url.isEmpty) return null;

    if (url.toLowerCase().contains('amazonaws')) {
      return url;
    }

    return controller.hasImage(bookingId) ? url : null;
  }

  static bool _isNetworkImage(
      String bookingId, CanceledBookingsController controller) {
    final url = controller.getImageUrl(bookingId);
    if (url.isEmpty) return false;

    if (url.toLowerCase().contains('amazonaws')) return true;
    return controller.hasImage(bookingId);
  }

  static void _navigateToDetailsScreen(
      String bookingId, String serviceProviderId, String providerId) {
    log('🔍 [CANCELED TAB] Navigation to DetailsScreen → preparing arguments...');
    log('   ➤ bookingId = "$bookingId"');
    log('   ➤ serviceProviderId = "$serviceProviderId"');
    log('   ➤ providerId = "$providerId"');

    if (serviceProviderId.isEmpty) {
      log('❌ [CANCELED TAB] Navigation ABORTED: serviceProviderId is empty!');
      Get.snackbar(
        'navigation_error'.tr,
        'service_provider_details_unavilable'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (providerId.isEmpty) {
      log('⚠️ [CANCELED TAB] Warning: providerId is empty (may cause issues in details screen)');
    }

    log('✅ [CANCELED TAB] Navigating to service details screen with required IDs');

    Get.toNamed(
      Routes.serviceDetailsScreen,
      arguments: {
        "status": BookingStatusEnum.canceled,
        "bookingId": bookingId,
        "serviceProviderID": serviceProviderId,
        "providerID": providerId,
      },
    );
  }
}

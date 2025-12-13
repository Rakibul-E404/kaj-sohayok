import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/features/normal_user/bookings/widgets/bookings_details_card_widget.dart';
import '../../../../../../constants/app_enums.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';
import '../controller/pending_controller.dart';
import '../widget/show_cancel_booking_bottom_sheet.dart';

class PendingTab extends StatelessWidget {
  const PendingTab({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Initialize controller (GetX singleton)
    final controller = Get.put(PendingBookingsController());

    return Obx(() {
      if (controller.isLoading.value) {
        return RefreshIndicator(
          onRefresh: () => controller.getPendingBookings(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 600,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      UIHelper.verticalSpace(16.h),
                      Text(
                        'Loading bookings...',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }

      if (controller.errorMessage.isNotEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.getPendingBookings(),
          child: ListView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 600,
                child: Center(
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
                          onPressed: () => controller.getPendingBookings(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (controller.pendingBookings.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.getPendingBookings(),
          child: ListView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 600,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        size: 64.sp,
                        color: Colors.grey,
                      ),
                      UIHelper.verticalSpace(16.h),
                      Text(
                        'No pending bookings found',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.getPendingBookings(),
        child: ListView.separated(
          padding: EdgeInsets.only(top: 16.sp),
          controller: controller.scrollController,
          itemCount: controller.pendingBookings.length,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
          itemBuilder: (context, index) {
            final booking = controller.pendingBookings[index];
            final bookingId = booking['_ServiceBookingId']?.toString() ?? '';

            // 🔴 FIXED: Extract BOTH IDs for the DetailsScreen
            final serviceProviderId = _getServiceProviderId(booking);
            final providerId = _getProviderUserId(booking);

            // 🔍 DEBUG: Log what IDs are extracted for this card
            log('🧾 [PENDING TAB] Card #$index →');
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
              // ➤ CARD TAP → Navigate with ALL required parameters
              onTap: () {
                _navigateToDetailsScreen(
                    bookingId, serviceProviderId, providerId);
              },

              // Cancel action
              isPendingTab: true,
              isPendingTabCancelOnTap: () {
                showCancelBookingBottomSheet(
                  bookingId: bookingId,
                  onCancelConfirmed: () async {
                    final success = await controller.cancelBooking(bookingId);
                    if (success) {
                      log('✅ [PENDING TAB] Booking $bookingId cancelled successfully');
                    }
                  },
                );
              },

              // Data
              title: _getServiceName(serviceName),
              initialPayablePrice: (booking['startPrice'] ?? 0).toString(),
              location: _getAddress(address),
              dateTime:
                  _formatDateTime(booking['bookingDateTime']?.toString() ?? ''),
              serviceProviderProfileImage:
                  imageUrl ?? Assets.images.userImage.path,
              serviceProviderName: provider?['name'] ?? 'Unknown Provider',
              serviceProviderDesignation: 'Service Provider',
              isNetworkImage: isNetworkImage,
            );
          },
        ),
      );
    });
  }

  // ─── HELPER METHODS ───────────────────────────────────────────────

  static String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      log('⚠️ [PENDING TAB] DateTime parse error: $e');
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

  // 🔴 FIXED: Extract Service Provider ID (_ServiceProviderId)
  static String _getServiceProviderId(Map<String, dynamic> booking) {
    // Primary: providerDetailsId._ServiceProviderId
    final providerDetails =
        booking['providerDetailsId'] as Map<String, dynamic>?;
    if (providerDetails?['_ServiceProviderId'] != null) {
      final id = providerDetails!['_ServiceProviderId'].toString();
      log('✅ [PENDING TAB] Service Provider ID from providerDetailsId._ServiceProviderId: $id');
      return id;
    }

    log('⚠️ [PENDING TAB] No Service Provider ID found in providerDetailsId');
    return '';
  }

  // 🔴 FIXED: Extract Provider User ID (_userId)
  static String _getProviderUserId(Map<String, dynamic> booking) {
    // From providerId._userId
    final provider = booking['providerId'] as Map<String, dynamic>?;
    if (provider?['_userId'] != null) {
      final id = provider!['_userId'].toString();
      log('✅ [PENDING TAB] Provider User ID from providerId._userId: $id');
      return id;
    }

    log('⚠️ [PENDING TAB] No Provider User ID found in providerId');
    return '';
  }

  static String? _getImageUrl(
      String bookingId, PendingBookingsController controller) {
    final url = controller.getImageUrl(bookingId);
    if (url.isEmpty) return null;

    if (url.toLowerCase().contains('amazonaws')) {
      return url;
    }

    return controller.hasImage(bookingId) ? url : null;
  }

  static bool _isNetworkImage(
      String bookingId, PendingBookingsController controller) {
    final url = controller.getImageUrl(bookingId);
    if (url.isEmpty) return false;

    if (url.toLowerCase().contains('amazonaws')) return true;
    return controller.hasImage(bookingId);
  }

  // 🔴 FIXED: Navigation with ALL required parameters for DetailsScreen
  static void _navigateToDetailsScreen(
      String bookingId, String serviceProviderId, String providerId) {
    log('🔍 [PENDING TAB] Navigation to DetailsScreen → preparing arguments...');
    log('   ➤ bookingId = "$bookingId"');
    log('   ➤ serviceProviderId = "$serviceProviderId"');
    log('   ➤ providerId = "$providerId"');

    if (serviceProviderId.isEmpty) {
      log('❌ [PENDING TAB] Navigation ABORTED: serviceProviderId is empty!');
      Get.snackbar(
        'Navigation Error',
        'Service provider details unavailable',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (providerId.isEmpty) {
      log('⚠️ [PENDING TAB] Warning: providerId is empty (may cause issues in details screen)');
    }

    log('✅ [PENDING TAB] Navigating to service details screen with required IDs');

    Get.toNamed(
      Routes.serviceDetailsScreen,
      arguments: {
        "status": BookingStatusEnum.pending,
        "bookingId": bookingId,
        "serviceProviderID": serviceProviderId, // Required for service details
        "providerID": providerId, // Required for booking flow
      },
    );
  }
}

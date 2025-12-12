import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:kaz_bd/utilities/logger_util.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../gen/assets.gen.dart';
import 'package:kaz_bd/constants/app_enums.dart';
import '../../../../../../helpers/ui_helpers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../utilities/app_url.dart';
import '../in_progress_controller/in_progress_controller.dart';
import '../../../../../../controllers/message_screen_controller.dart';
import 'package:kaz_bd/features/normal_user/bookings/widgets/bookings_details_card_widget.dart';

class InProgressTab extends StatelessWidget {
  const InProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Initialize controller
    final controller = Get.put(InProgressBookingsController());

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
            final bookingId = booking['_ServiceBookingId']?.toString() ?? '';

            // 🔴 FIXED: Extract BOTH IDs for the DetailsScreen
            final serviceProviderId = _getServiceProviderId(booking);
            final providerId = _getProviderUserId(booking);

            // 🔍 DEBUG: Log what IDs are extracted
            log('🧾 [IN PROGRESS TAB] Card #$index →');
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

              isInProgressTab: true,

              ///Button OnTap -> Message
              isInProgressTabMessageOnTap: () async {
                log("💬 [IN PROGRESS TAB] Message button tapped for booking: $bookingId");

                // 🔴 ADDED: Use providerId for message (user ID)
                final messageProviderId = providerId.isNotEmpty
                    ? providerId
                    : _getProviderUserId(booking);

                // 🔴 ADDED: Debug logging
                log('   📊 provider object: ${provider?.toString()}');
                log('   🆔 providerId from args: $providerId');
                log('   🔍 Extracted provider userId: ${_getProviderUserId(booking)}');
                log('   ✅ Final messageProviderId to use: $messageProviderId');

                if (messageProviderId.isEmpty) {
                  log('❌ [IN PROGRESS TAB] Cannot send message: Provider ID is empty');
                  Get.snackbar(
                    'Error',
                    'Cannot send message: Provider information not available',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                try {
                  // 🔴 ADDED: Check if MessageScreenController exists
                  final msgController = Get.find<MessageScreenController>();

                  LoggerUtils.info(imageUrl);
                  msgController.createMessage(
                    participantId: messageProviderId,
                    name: provider?['name'] ?? 'Unknown Provider',
                    imageUrl: imageUrl ?? '',
                  );

                  log('   ✅ createMessage called successfully');
                } catch (e) {
                  log('❌ [IN PROGRESS TAB] Error with MessageScreenController: $e');
                  Get.snackbar(
                    'Error',
                    'Messaging service not available',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },

              ///Button OnTap -> View
              isInProgressTabViewOnTap: () {
                _navigateToDetailsScreen(
                    bookingId, serviceProviderId, providerId);
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
      log('⚠️ [IN PROGRESS TAB] DateTime parse error: $e');
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
    // 1. Primary: providerDetailsId._ServiceProviderId
    final providerDetails =
        booking['providerDetailsId'] as Map<String, dynamic>?;
    if (providerDetails?['_ServiceProviderId'] != null) {
      final id = providerDetails!['_ServiceProviderId'].toString();
      log('✅ [IN PROGRESS TAB] Service Provider ID from providerDetailsId._ServiceProviderId: $id');
      return id;
    }

    // 2. Secondary: serviceProviderDetailsId
    if (booking['serviceProviderDetailsId'] != null) {
      final id = booking['serviceProviderDetailsId'].toString();
      log('✅ [IN PROGRESS TAB] Service Provider ID from serviceProviderDetailsId: $id');
      return id;
    }

    log('⚠️ [IN PROGRESS TAB] No Service Provider ID found');
    return '';
  }

  // 🔴 FIXED: Extract Provider User ID (_userId)
  static String _getProviderUserId(Map<String, dynamic> booking) {
    // From providerId._userId
    final provider = booking['providerId'] as Map<String, dynamic>?;
    if (provider?['_userId'] != null) {
      final id = provider!['_userId'].toString();
      log('✅ [IN PROGRESS TAB] Provider User ID from providerId._userId: $id');
      return id;
    }

    log('⚠️ [IN PROGRESS TAB] No Provider User ID found in providerId');
    return '';
  }

  static String? _getImageUrl(
      String bookingId, InProgressBookingsController controller) {
    final url = controller.getImageUrl(bookingId);
    if (url.isEmpty) return null;

    if (url.toLowerCase().contains('amazonaws')) {
      return url;
    }

    return controller.hasImage(bookingId) ? url : null;
  }

  static bool _isNetworkImage(
      String bookingId, InProgressBookingsController controller) {
    final url = controller.getImageUrl(bookingId);
    if (url.isEmpty) return false;

    if (url.toLowerCase().contains('amazonaws')) return true;
    return controller.hasImage(bookingId);
  }

  // 🔴 FIXED: Navigation with ALL required parameters for DetailsScreen
  static void _navigateToDetailsScreen(
      String bookingId, String serviceProviderId, String providerId) {
    log('🔍 [IN PROGRESS TAB] Navigation to DetailsScreen → preparing arguments...');
    log('   ➤ bookingId = "$bookingId"');
    log('   ➤ serviceProviderId = "$serviceProviderId"');
    log('   ➤ providerId = "$providerId"');

    if (serviceProviderId.isEmpty) {
      log('❌ [IN PROGRESS TAB] Navigation ABORTED: serviceProviderId is empty!');
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
      log('⚠️ [IN PROGRESS TAB] Warning: providerId is empty (may cause issues in details screen)');
    }

    log('✅ [IN PROGRESS TAB] Navigating to service details screen with required IDs');

    Get.toNamed(
      Routes.serviceDetailsScreen,
      arguments: {
        "status": BookingStatusEnum.inProgress,
        "bookingId": bookingId,
        "serviceProviderID": serviceProviderId, // Required for service details
        "providerID": providerId, // Required for booking flow
      },
    );
  }
}

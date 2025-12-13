
/**
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/features/normal_user/bookings/widgets/bookings_details_card_widget.dart';

import '../../../../../../constants/app_enums.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';
import '../controller/work_completed_controller.dart';
import '../widgets/show_review_giving_alert_dialog.dart';


class WorkCompletedTab extends StatelessWidget {
  WorkCompletedTab({super.key});

  final WorkCompletedBookingsController controller = Get.put(WorkCompletedBookingsController());

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

  // Check if review is given for a booking
  bool _isReviewGiven(String bookingId) {
    return controller.isReviewGiven(bookingId);
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
              Icon(
                Icons.work_outline,
                size: 64.sp,
                color: Colors.grey,
              ),
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
            final bookingId = booking['_ServiceBookingId'] ?? '';

            final serviceName = booking['providerDetailsId']?['serviceName'];
            final address = booking['address'];
            final provider = booking['providerId'];
            final hasReview = booking['hasReview'] ?? false;

            final imageUrl = _getImageUrl(bookingId);
            final isNetworkImage = _isNetworkImage(bookingId);
            final isReviewGiven = _isReviewGiven(bookingId);

            log('Building work completed booking card for $bookingId');
            log('Final image URL: $imageUrl');
            log('Is network image: $isNetworkImage');
            log('Has review: $hasReview');

            return BookingDetailsCardWidget(
              onTap: () {
                Get.toNamed(
                  Routes.workCompletedDetailsScreen,
                  arguments: {
                    "status": BookingStatusEnum.workCompleted,
                    "bookingId": bookingId,
                  },
                );
              },
              isWorkCompletedTab: true,
              isReviewGiven: isReviewGiven,
              isWorkCompletedTabGiveReviewOnTap: () {
                showReviewGivingAlertDialog();
                // You can pass bookingId to the dialog if needed
                // showReviewGivingAlertDialog(bookingId: bookingId);
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
}*/














///
///
///
/// todo::: upper was mine and now trying to fix as per imtiaz vai's details screen code
///
///
///









// import 'dart:developer';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import '../../../../../../routes/routes.dart';
// import '../../../../../../gen/assets.gen.dart';
// import 'package:kaz_bd/constants/app_enums.dart';
// import '../../../../../../helpers/ui_helpers.dart';
// import '../controller/work_completed_controller.dart';
// import '../widgets/show_review_giving_alert_dialog.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kaz_bd/features/normal_user/bookings/widgets/bookings_details_card_widget.dart';
//
// class WorkCompletedTab extends StatelessWidget {
//   const WorkCompletedTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // ✅ Initialize controller
//     final controller = Get.put(WorkCompletedBookingsController());
//
//     return Obx(() {
//       if (controller.isLoading.value) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               UIHelper.verticalSpace(16.h),
//               Text(
//                 'Loading work completed bookings...',
//                 style: TextStyle(fontSize: 16.sp, color: Colors.grey),
//               ),
//             ],
//           ),
//         );
//       }
//
//       if (controller.errorMessage.isNotEmpty) {
//         return Center(
//           child: Padding(
//             padding: EdgeInsets.all(20.sp),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.error_outline,
//                   size: 64.sp,
//                   color: Colors.red,
//                 ),
//                 UIHelper.verticalSpace(16.h),
//                 Text(
//                   controller.errorMessage.value,
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     color: Colors.red,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 UIHelper.verticalSpace(20.h),
//                 ElevatedButton(
//                   onPressed: () => controller.getWorkCompletedBookings(),
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }
//
//       if (controller.workCompletedBookings.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.work_outline,
//                 size: 64.sp,
//                 color: Colors.grey,
//               ),
//               UIHelper.verticalSpace(16.h),
//               Text(
//                 'No work completed bookings found',
//                 style: TextStyle(fontSize: 16.sp, color: Colors.grey),
//               ),
//             ],
//           ),
//         );
//       }
//
//       return RefreshIndicator(
//         onRefresh: () => controller.getWorkCompletedBookings(),
//         child: ListView.separated(
//           padding: EdgeInsets.only(top: 16.sp),
//           itemCount: controller.workCompletedBookings.length,
//           separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
//           itemBuilder: (context, index) {
//             final booking = controller.workCompletedBookings[index];
//             final bookingId = booking['_ServiceBookingId']?.toString() ?? '';
//
//             // 🔴 FIXED: Extract BOTH IDs for the DetailsScreen
//             final serviceProviderId = _getServiceProviderId(booking);
//             final providerId = _getProviderUserId(booking);
//
//             // 🔍 DEBUG: Log what IDs are extracted
//             log('🧾 [WORK COMPLETED TAB] Card #$index →');
//             log('   Booking ID: "$bookingId"');
//             log('   Service Provider ID: "$serviceProviderId"');
//             log('   Provider User ID: "$providerId"');
//
//             final serviceName = booking['providerDetailsId']?['serviceName'] as Map<String, dynamic>?;
//             final address = booking['address'] as Map<String, dynamic>?;
//             final provider = booking['providerId'] as Map<String, dynamic>?;
//             final hasReview = booking['hasReview'] ?? false;
//
//             final imageUrl = _getImageUrl(bookingId, controller);
//             final isNetworkImage = _isNetworkImage(bookingId, controller);
//             final isReviewGiven = _isReviewGiven(bookingId, controller);
//
//             return BookingDetailsCardWidget(
//               // ➤ CARD TAP → Navigate with ALL required parameters
//               onTap: () {
//                 _navigateToDetailsScreen(bookingId, serviceProviderId, providerId);
//               },
//
//               isWorkCompletedTab: true,
//               isReviewGiven: isReviewGiven,
//
//               // Review button functionality
//               isWorkCompletedTabGiveReviewOnTap: () {
//                 log('⭐ [WORK COMPLETED TAB] Give review button tapped for booking: $bookingId');
//
//                 // FIXED: Call the existing dialog function without parameters
//                 // or store IDs for later use if needed
//                 _handleReviewButton(bookingId, serviceProviderId, providerId);
//               },
//
//               // Data
//               title: _getServiceName(serviceName),
//               initialPayablePrice: (booking['startPrice'] ?? 0).toString(),
//               location: _getAddress(address),
//               dateTime: _formatDateTime(booking['bookingDateTime']?.toString() ?? ''),
//               serviceProviderProfileImage: imageUrl ?? Assets.images.userImage.path,
//               serviceProviderName: provider?['name'] ?? 'Unknown Provider',
//               serviceProviderDesignation: 'Service Provider',
//               isNetworkImage: isNetworkImage,
//             );
//           },
//         ),
//       );
//     });
//   }
//
//   // ─── HELPER METHODS ───────────────────────────────────────────────
//
//   static String _formatDateTime(String dateTimeString) {
//     try {
//       final dateTime = DateTime.parse(dateTimeString).toLocal();
//       return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
//     } catch (e) {
//       log('⚠️ [WORK COMPLETED TAB] DateTime parse error: $e');
//       return dateTimeString;
//     }
//   }
//
//   static String _getServiceName(Map<String, dynamic>? serviceName) {
//     if (serviceName == null) return 'Unknown Service';
//     return serviceName['en'] ?? serviceName['bn'] ?? 'Unknown Service';
//   }
//
//   static String _getAddress(Map<String, dynamic>? address) {
//     if (address == null) return 'Unknown Location';
//     return address['en'] ?? address['bn'] ?? 'Unknown Location';
//   }
//
//   // 🔴 FIXED: Extract Service Provider ID (_ServiceProviderId)
//   static String _getServiceProviderId(Map<String, dynamic> booking) {
//     // 1. Primary: providerDetailsId._ServiceProviderId
//     final providerDetails = booking['providerDetailsId'] as Map<String, dynamic>?;
//     if (providerDetails?['_ServiceProviderId'] != null) {
//       final id = providerDetails!['_ServiceProviderId'].toString();
//       log('✅ [WORK COMPLETED TAB] Service Provider ID from providerDetailsId._ServiceProviderId: $id');
//       return id;
//     }
//
//     // 2. Secondary: serviceProviderDetailsId
//     if (booking['serviceProviderDetailsId'] != null) {
//       final id = booking['serviceProviderDetailsId'].toString();
//       log('✅ [WORK COMPLETED TAB] Service Provider ID from serviceProviderDetailsId: $id');
//       return id;
//     }
//
//     log('⚠️ [WORK COMPLETED TAB] No Service Provider ID found');
//     return '';
//   }
//
//   // 🔴 FIXED: Extract Provider User ID (_userId)
//   static String _getProviderUserId(Map<String, dynamic> booking) {
//     // From providerId._userId
//     final provider = booking['providerId'] as Map<String, dynamic>?;
//     if (provider?['_userId'] != null) {
//       final id = provider!['_userId'].toString();
//       log('✅ [WORK COMPLETED TAB] Provider User ID from providerId._userId: $id');
//       return id;
//     }
//
//     log('⚠️ [WORK COMPLETED TAB] No Provider User ID found in providerId');
//     return '';
//   }
//
//   static String? _getImageUrl(String bookingId, WorkCompletedBookingsController controller) {
//     final url = controller.getImageUrl(bookingId);
//     if (url.isEmpty) return null;
//
//     if (url.toLowerCase().contains('amazonaws')) {
//       return url;
//     }
//
//     return controller.hasImage(bookingId) ? url : null;
//   }
//
//   static bool _isNetworkImage(String bookingId, WorkCompletedBookingsController controller) {
//     final url = controller.getImageUrl(bookingId);
//     if (url.isEmpty) return false;
//
//     if (url.toLowerCase().contains('amazonaws')) return true;
//     return controller.hasImage(bookingId);
//   }
//
//   static bool _isReviewGiven(String bookingId, WorkCompletedBookingsController controller) {
//     return controller.isReviewGiven(bookingId);
//   }
//
//   // 🔴 FIXED: Navigation with ALL required parameters for DetailsScreen
//   static void _navigateToDetailsScreen(String bookingId, String serviceProviderId, String providerId) {
//     log('🔍 [WORK COMPLETED TAB] Navigation to DetailsScreen → preparing arguments...');
//     log('   ➤ bookingId = "$bookingId"');
//     log('   ➤ serviceProviderId = "$serviceProviderId"');
//     log('   ➤ providerId = "$providerId"');
//
//     if (serviceProviderId.isEmpty) {
//       log('❌ [WORK COMPLETED TAB] Navigation ABORTED: serviceProviderId is empty!');
//       Get.snackbar(
//         'Navigation Error',
//         'Service provider details unavailable',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }
//
//     if (providerId.isEmpty) {
//       log('⚠️ [WORK COMPLETED TAB] Warning: providerId is empty (may cause issues in details screen)');
//     }
//
//     log('✅ [WORK COMPLETED TAB] Navigating to work completed details screen with required IDs');
//
//     Get.toNamed(
//       Routes.workCompletedDetailsScreen,
//       arguments: {
//         "status": BookingStatusEnum.workCompleted,
//         "bookingId": bookingId,
//         "serviceProviderID": serviceProviderId,  // Required for service details
//         "providerID": providerId,                // Required for user identification
//       },
//     );
//   }
//
//   // FIXED: Handle review button - check dialog function signature
//   static void _handleReviewButton(String bookingId, String serviceProviderId, String providerId) {
//     try {
//       log('⭐ [WORK COMPLETED TAB] Starting review process for booking: $bookingId');
//
//       // Check if review dialog accepts parameters
//       // Option 1: If dialog needs parameters, check its signature
//       // Option 2: If dialog doesn't accept parameters, store IDs somewhere accessible
//
//       // Store IDs in GetX for the dialog to access later if needed
//       Get.put<ReviewData>(ReviewData(
//         bookingId: bookingId,
//         serviceProviderId: serviceProviderId,
//         providerId: providerId,
//       ), tag: 'reviewData');
//
//       // Call the dialog - adjust based on its actual signature
//       showReviewGivingAlertDialog();
//
//     } catch (e) {
//       log('❌ [WORK COMPLETED TAB] Error showing review dialog: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to open review dialog',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
// }
//
// // Helper class to pass data to review dialog if needed
// class ReviewData {
//   final String bookingId;
//   final String serviceProviderId;
//   final String providerId;
//
//   ReviewData({
//     required this.bookingId,
//     required this.serviceProviderId,
//     required this.providerId,
//   });
// }



import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:kaz_bd/models/user_payment_history_details_model.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../gen/assets.gen.dart';
import 'package:kaz_bd/constants/app_enums.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../controller/work_completed_controller.dart';
import '../widgets/show_review_giving_alert_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/features/normal_user/bookings/widgets/bookings_details_card_widget.dart';

class WorkCompletedTab extends StatelessWidget {
  const WorkCompletedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkCompletedBookingsController());

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

            final imageUrl = _getImageUrl(bookingId, controller);
            final isNetworkImage = _isNetworkImage(bookingId, controller);
            final isReviewGiven = _isReviewGiven(bookingId, controller);

            return BookingDetailsCardWidget(
              onTap: () => _handleCardTap(booking),
              isWorkCompletedTab: true,
              isReviewGiven: isReviewGiven,
              isWorkCompletedTabGiveReviewOnTap: () => _handleReviewButton(booking),
              title: _getServiceName(serviceName),
              initialPayablePrice: (booking['startPrice'] ?? 0).toString(),
              location: _getAddress(address),
              dateTime: _formatDateTime(booking['bookingDateTime']?.toString() ?? ''),
              serviceProviderProfileImage: imageUrl ?? Assets.images.userImage.path,
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
  // CARD TAP HANDLER
  // ═══════════════════════════════════════════════════════════════
  static void _handleCardTap(Map<String, dynamic> booking) {
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    log('👆 [WORK COMPLETED TAB] Card tapped');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      // Extract all possible IDs from booking data
      final bookingId = booking['_ServiceBookingId']?.toString() ?? '';

      // Try multiple extraction methods for service provider ID
      String serviceProviderId = '';

      // Method 1: providerDetailsId._ServiceProviderId
      if (booking['providerDetailsId'] is Map<String, dynamic>) {
        final providerDetails = booking['providerDetailsId'] as Map<String, dynamic>;
        serviceProviderId = providerDetails['_ServiceProviderId']?.toString() ?? '';
        if (serviceProviderId.isNotEmpty) {
          log('✅ [ID EXTRACTION] Method 1: providerDetailsId._ServiceProviderId = $serviceProviderId');
        }
      }

      // Method 2: Direct providerDetailsId (if it's a string)
      if (serviceProviderId.isEmpty && booking['providerDetailsId'] is String) {
        serviceProviderId = booking['providerDetailsId'].toString();
        log('✅ [ID EXTRACTION] Method 2: providerDetailsId (string) = $serviceProviderId');
      }

      // Method 3: serviceProviderDetailsId
      if (serviceProviderId.isEmpty && booking['serviceProviderDetailsId'] != null) {
        serviceProviderId = booking['serviceProviderDetailsId'].toString();
        log('✅ [ID EXTRACTION] Method 3: serviceProviderDetailsId = $serviceProviderId');
      }

      // Method 4: Direct _ServiceProviderId field
      if (serviceProviderId.isEmpty && booking['_ServiceProviderId'] != null) {
        serviceProviderId = booking['_ServiceProviderId'].toString();
        log('✅ [ID EXTRACTION] Method 4: _ServiceProviderId = $serviceProviderId');
      }

      // Extract provider user ID
      String providerId = '';
      if (booking['providerId'] is Map<String, dynamic>) {
        final providerData = booking['providerId'] as Map<String, dynamic>;
        providerId = providerData['_userId']?.toString() ?? '';
        log('✅ [ID EXTRACTION] providerId._userId = $providerId');
      }

      if (providerId.isEmpty && booking['userId'] != null) {
        providerId = booking['userId'].toString();
        log('✅ [ID EXTRACTION] Fallback: userId = $providerId');
      }

      log('📊 [EXTRACTED IDs]');
      log('   bookingId: "$bookingId"');
      log('   serviceProviderId: "$serviceProviderId"');
      log('   providerId: "$providerId"');

      // Validate required IDs
      if (serviceProviderId.isEmpty) {
        log('❌ [VALIDATION FAILED] serviceProviderId is empty');
        log('📋 [DEBUG] Full booking keys: ${booking.keys.toList()}');
        log('📋 [DEBUG] providerDetailsId: ${booking['providerDetailsId']}');
        log('📋 [DEBUG] providerDetailsId type: ${booking['providerDetailsId']?.runtimeType}');

        Get.snackbar(
          'Navigation Error',
          'Cannot load service details. Service provider ID is missing.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      if (bookingId.isEmpty) {
        log('⚠️ [VALIDATION] bookingId is empty (non-critical)');
      }

      if (providerId.isEmpty) {
        log('⚠️ [VALIDATION] providerId is empty (non-critical)');
      }

      // Create navigation arguments as a simple Map
      final arguments = <String, dynamic>{
        'status': BookingStatusEnum.workCompleted,
        'bookingId': bookingId,
        'serviceProviderID': serviceProviderId,
        'providerID': providerId,
      };

      log('✅ [NAVIGATION] Preparing to navigate with arguments:');
      log('   ${arguments.toString()}');
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Navigate
      Get.toNamed(
        Routes.workCompletedDetailsScreen,
        arguments: UserPaymentHistoryDetailsModel(),
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

  static String? _getImageUrl(String bookingId, WorkCompletedBookingsController controller) {
    final url = controller.getImageUrl(bookingId);
    if (url.isEmpty) return null;
    if (url.toLowerCase().contains('amazonaws')) return url;
    return controller.hasImage(bookingId) ? url : null;
  }

  static bool _isNetworkImage(String bookingId, WorkCompletedBookingsController controller) {
    final url = controller.getImageUrl(bookingId);
    if (url.isEmpty) return false;
    if (url.toLowerCase().contains('amazonaws')) return true;
    return controller.hasImage(bookingId);
  }

  static bool _isReviewGiven(String bookingId, WorkCompletedBookingsController controller) {
    return controller.isReviewGiven(bookingId);
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


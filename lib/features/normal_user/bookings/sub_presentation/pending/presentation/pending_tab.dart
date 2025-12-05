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
import '../controller/pending_controller.dart';
import '../widget/show_cancel_booking_bottom_sheet.dart';

class PendingTab extends StatelessWidget {
  PendingTab({super.key});

  final PendingBookingsController controller = Get.put(PendingBookingsController());

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

  // Check if URL is from AWS S3
  bool _isAwsS3Url(String imageUrl) {
    return imageUrl.toLowerCase().contains('amazonaws');
  }

  String? _getImageUrl(String bookingId) {
    final imageUrl = controller.getImageUrl(bookingId);

    if (imageUrl.isEmpty) {
      return null;
    }

    // Check if it's an AWS S3 URL
    if (_isAwsS3Url(imageUrl)) {
      log('✅ AWS S3 URL detected for booking $bookingId: $imageUrl');
      return imageUrl;
    }

    // For non-AWS URLs, check accessibility
    final hasImage = controller.hasImage(bookingId);
    if (hasImage) {
      log('✅ Non-AWS image accessible for booking $bookingId: $imageUrl');
      return imageUrl;
    }

    log('❌ Image not accessible for booking $bookingId');
    return null;
  }

  String _getFallbackImagePath() {
    return Assets.images.userImage.path;
  }

  // Check if the image is a network image
  bool _isNetworkImage(String bookingId) {
    final imageUrl = controller.getImageUrl(bookingId);

    if (imageUrl.isEmpty) {
      return false;
    }

    // AWS S3 URLs are always treated as network images
    if (_isAwsS3Url(imageUrl)) {
      return true;
    }

    // For non-AWS URLs, check if accessible
    return controller.hasImage(bookingId);
  }

  // NEW: Handle cancel booking
  void _handleCancelBooking(String bookingId) {
    showCancelBookingBottomSheet(
      bookingId: bookingId,
      onCancelConfirmed: () async {
        // Call the cancel booking API
        bool success = await controller.cancelBooking(bookingId);

        if (success) {
          log('Booking $bookingId cancelled successfully');
        }
      },
    );
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
                'Loading bookings...',
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
                  onPressed: () => controller.getPendingBookings(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.pendingBookings.isEmpty) {
        return Center(
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
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.getPendingBookings(),
        child: ListView.separated(
          padding: EdgeInsets.only(top: 16.sp),
          itemCount: controller.pendingBookings.length,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
          itemBuilder: (context, index) {
            final booking = controller.pendingBookings[index];
            final bookingId = booking['_ServiceBookingId'] ?? '';

            final serviceName = booking['providerDetailsId']?['serviceName'];
            final address = booking['address'];
            final provider = booking['providerId'];

            final imageUrl = _getImageUrl(bookingId);
            final fallbackImagePath = _getFallbackImagePath();
            final isNetworkImage = _isNetworkImage(bookingId);

            log('Building pending booking card for $bookingId');
            log('Final image URL: ${imageUrl ?? fallbackImagePath}');
            log('Is network image: $isNetworkImage');

            return BookingDetailsCardWidget(
              onTap: () {
                Get.toNamed(
                  Routes.serviceDetailsScreen,
                  arguments: {
                    "status": BookingStatusEnum.pending,
                    "bookingId": bookingId,
                  },
                );
              },
              isPendingTab: true,
              isPendingTabCancelOnTap: () {
                _handleCancelBooking(bookingId);
              },
              title: _getServiceName(serviceName),
              initialPayablePrice: (booking['startPrice'] ?? 0).toString(),
              location: _getAddress(address),
              dateTime: _formatDateTime(booking['bookingDateTime'] ?? ''),
              serviceProviderProfileImage: imageUrl ?? fallbackImagePath,
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
*/





///
///
///
/// todo:: passing the providerId
///
///
///
///








// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:kaz_bd/features/normal_user/bookings/widgets/bookings_details_card_widget.dart';
// import '../../../../../../constants/app_enums.dart';
// import '../../../../../../gen/assets.gen.dart';
// import '../../../../../../helpers/ui_helpers.dart';
// import '../../../../../../routes/routes.dart';
// import '../controller/pending_controller.dart';
// import '../widget/show_cancel_booking_bottom_sheet.dart';
//
// class PendingTab extends StatelessWidget {
//   PendingTab({super.key});
//
//   final PendingBookingsController controller = Get.put(PendingBookingsController());
//
//   String _formatDateTime(String dateTimeString) {
//     try {
//       DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
//       return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
//     } catch (e) {
//       return dateTimeString;
//     }
//   }
//
//   String _getServiceName(Map<String, dynamic>? serviceName) {
//     if (serviceName == null) return 'Unknown Service';
//     return serviceName['en'] ?? serviceName['bn'] ?? 'Unknown Service';
//   }
//
//   String _getAddress(Map<String, dynamic>? address) {
//     if (address == null) return 'Unknown Location';
//     return address['en'] ?? address['bn'] ?? 'Unknown Location';
//   }
//
//   // Check if URL is from AWS S3
//   bool _isAwsS3Url(String imageUrl) {
//     return imageUrl.toLowerCase().contains('amazonaws');
//   }
//
//   String? _getImageUrl(String bookingId) {
//     final imageUrl = controller.getImageUrl(bookingId);
//
//     if (imageUrl.isEmpty) {
//       return null;
//     }
//
//     // Check if it's an AWS S3 URL
//     if (_isAwsS3Url(imageUrl)) {
//       log('✅ AWS S3 URL detected for booking $bookingId: $imageUrl');
//       return imageUrl;
//     }
//
//     // For non-AWS URLs, check accessibility
//     final hasImage = controller.hasImage(bookingId);
//     if (hasImage) {
//       log('✅ Non-AWS image accessible for booking $bookingId: $imageUrl');
//       return imageUrl;
//     }
//
//     log('❌ Image not accessible for booking $bookingId');
//     return null;
//   }
//
//   String _getFallbackImagePath() {
//     return Assets.images.userImage.path;
//   }
//
//   // Check if the image is a network image
//   bool _isNetworkImage(String bookingId) {
//     final imageUrl = controller.getImageUrl(bookingId);
//
//     if (imageUrl.isEmpty) {
//       return false;
//     }
//
//     // AWS S3 URLs are always treated as network images
//     if (_isAwsS3Url(imageUrl)) {
//       return true;
//     }
//
//     // For non-AWS URLs, check if accessible
//     return controller.hasImage(bookingId);
//   }
//
//   // NEW: Extract provider ID (same as accepted tab)
//   String _getProviderId(Map<String, dynamic> booking) {
//     String? providerId;
//
//     // According to the JSON structure, the provider ID is in:
//     // providerDetailsId._ServiceProviderId
//     if (booking['providerDetailsId'] != null) {
//       final providerDetailsMap = booking['providerDetailsId'] as Map<String, dynamic>?;
//       if (providerDetailsMap != null && providerDetailsMap['_ServiceProviderId'] != null) {
//         providerId = providerDetailsMap['_ServiceProviderId'].toString();
//         log('✅ Provider ID extracted from providerDetailsId._ServiceProviderId: $providerId');
//         return providerId;
//       }
//     }
//
//     // Fallback: Try to get from providerId._userId if providerDetailsId is not available
//     if (booking['providerId'] != null && booking['providerId'] is Map) {
//       final providerMap = booking['providerId'] as Map<String, dynamic>;
//       if (providerMap['_userId'] != null) {
//         providerId = providerMap['_userId'].toString();
//         log('⚠️ Provider ID extracted from providerId._userId (fallback): $providerId');
//         return providerId;
//       }
//     }
//
//     log('❌ ERROR: No provider ID found in booking data');
//     return '';
//   }
//
//   // NEW: Navigation function for card tap
//   void _navigateToDetails(String bookingId, String providerId) {
//     if (providerId.isEmpty) {
//       log('❌ Cannot navigate: Provider ID is empty');
//       Get.snackbar(
//         'Error',
//         'Provider information not available',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }
//
//     log('🚀 Card tapped - Navigating to details screen');
//     log('   Status: ${BookingStatusEnum.pending}');
//     log('   Booking ID: $bookingId');
//     log('   Provider ID: $providerId');
//
//     Get.toNamed(
//       Routes.serviceDetailsScreen,
//       arguments: {
//         "status": BookingStatusEnum.pending,
//         "bookingId": bookingId,
//         "providerId": providerId,
//       },
//     );
//   }
//
//   // Handle cancel booking (keep as is)
//   void _handleCancelBooking(String bookingId) {
//     showCancelBookingBottomSheet(
//       bookingId: bookingId,
//       onCancelConfirmed: () async {
//         bool success = await controller.cancelBooking(bookingId);
//         if (success) {
//           log('Booking $bookingId cancelled successfully');
//         }
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (controller.isLoading.value) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               UIHelper.verticalSpace(16.h),
//               Text(
//                 'Loading bookings...',
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
//                   onPressed: () => controller.getPendingBookings(),
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }
//
//       if (controller.pendingBookings.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.event_note_outlined,
//                 size: 64.sp,
//                 color: Colors.grey,
//               ),
//               UIHelper.verticalSpace(16.h),
//               Text(
//                 'No pending bookings found',
//                 style: TextStyle(fontSize: 16.sp, color: Colors.grey),
//               ),
//             ],
//           ),
//         );
//       }
//
//       return RefreshIndicator(
//         onRefresh: () => controller.getPendingBookings(),
//         child: ListView.separated(
//           padding: EdgeInsets.only(top: 16.sp),
//           itemCount: controller.pendingBookings.length,
//           separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
//           itemBuilder: (context, index) {
//             final booking = controller.pendingBookings[index];
//             final bookingId = booking['_ServiceBookingId'] ?? '';
//
//             // Extract provider ID for navigation
//             final providerId = _getProviderId(booking);
//
//             final serviceName = booking['providerDetailsId']?['serviceName'];
//             final address = booking['address'];
//             final provider = booking['providerId'];
//
//             final imageUrl = _getImageUrl(bookingId);
//             final fallbackImagePath = _getFallbackImagePath();
//             final isNetworkImage = _isNetworkImage(bookingId);
//
//             log('Building pending booking card for $bookingId');
//             log('Provider ID extracted: $providerId');
//             log('Final image URL: ${imageUrl ?? fallbackImagePath}');
//             log('Is network image: $isNetworkImage');
//
//             return BookingDetailsCardWidget(
//               // NEW: Add onTap for card - navigate with providerId
//               onTap: () {
//                 _navigateToDetails(bookingId, providerId);
//               },
//
//               // Keep existing parameters as they are
//               isPendingTab: true,
//
//               // This is the correct parameter name from your working code
//               // DO NOT CHANGE THIS
//               isPendingTabCancelOnTap: () {
//                 _handleCancelBooking(bookingId);
//               },
//
//               title: _getServiceName(serviceName),
//               initialPayablePrice: (booking['startPrice'] ?? 0).toString(),
//               location: _getAddress(address),
//               dateTime: _formatDateTime(booking['bookingDateTime'] ?? ''),
//               serviceProviderProfileImage: imageUrl ?? fallbackImagePath,
//               serviceProviderName: provider?['name'] ?? 'Unknown Provider',
//               serviceProviderDesignation: 'Service Provider',
//               isNetworkImage: isNetworkImage,
//             );
//           },
//         ),
//       );
//     });
//   }
// }






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
        return Center(
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
                  onPressed: () => controller.getPendingBookings(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.pendingBookings.isEmpty) {
        return Center(
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
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.getPendingBookings(),
        child: ListView.separated(
          padding: EdgeInsets.only(top: 16.sp),
          itemCount: controller.pendingBookings.length,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
          itemBuilder: (context, index) {
            final booking = controller.pendingBookings[index];
            final bookingId = booking['_ServiceBookingId']?.toString() ?? '';
            final providerId = _getProviderId(booking);

            // 🔍 DEBUG: Log what IDs are extracted for this card
            log('🧾 [PENDING TAB] Card #$index → bookingId: "$bookingId", providerId: "$providerId"');

            final serviceName = booking['providerDetailsId']?['serviceName'] as Map<String, dynamic>?;
            final address = booking['address'] as Map<String, dynamic>?;
            final provider = booking['providerId'] as Map<String, dynamic>?;

            final imageUrl = _getImageUrl(bookingId, controller);
            final isNetworkImage = _isNetworkImage(bookingId, controller);

            return BookingDetailsCardWidget(
              // ➤ CARD TAP → Navigate with both IDs (same as Accepted tab)
              onTap: () {
                _navigateToDetails(context, bookingId, providerId);
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

  static String _getProviderId(Map<String, dynamic> booking) {
    // Primary: providerDetailsId._ServiceProviderId
    final providerDetails = booking['providerDetailsId'] as Map<String, dynamic>?;
    if (providerDetails?['_ServiceProviderId'] != null) {
      final id = providerDetails!['_ServiceProviderId'].toString();
      return id;
    }

    // Fallback: providerId._userId
    final provider = booking['providerId'] as Map<String, dynamic>?;
    if (provider?['_userId'] != null) {
      final id = provider!['_userId'].toString();
      return id;
    }

    return '';
  }

  static String? _getImageUrl(String bookingId, PendingBookingsController controller) {
    final url = controller.getImageUrl(bookingId);
    if (url.isEmpty) return null;

    if (url.toLowerCase().contains('amazonaws')) {
      return url;
    }

    return controller.hasImage(bookingId) ? url : null;
  }

  static bool _isNetworkImage(String bookingId, PendingBookingsController controller) {
    final url = controller.getImageUrl(bookingId);
    if (url.isEmpty) return false;

    if (url.toLowerCase().contains('amazonaws')) return true;
    return controller.hasImage(bookingId);
  }

  // 🔍 ENHANCED DEBUG NAVIGATION
  static void _navigateToDetails(BuildContext context, String bookingId, String providerId) {
    log('🔍 [PENDING TAB] Navigation triggered → preparing arguments...');
    log('   ➤ bookingId = "$bookingId"');
    log('   ➤ providerId = "$providerId"');

    if (providerId.isEmpty) {
      log('❌ [PENDING TAB] Navigation ABORTED: providerId is empty!');
      Get.snackbar(
        'Navigation Error',
        'Provider details unavailable',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (bookingId.isEmpty) {
      log('⚠️ [PENDING TAB] Warning: bookingId is empty (continuing navigation)');
    }

    log('✅ [PENDING TAB] Navigating to service details screen with valid IDs');

    Get.toNamed(
      Routes.serviceDetailsScreen,
      arguments: {
        "status": BookingStatusEnum.pending,
        "bookingId": bookingId,
        "providerId": providerId,
      },
    );
  }
}




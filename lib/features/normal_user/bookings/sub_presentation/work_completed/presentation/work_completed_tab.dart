/**

import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../routes/routes.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../controller/work_completed_controller.dart' as booking_ctrl;
import '../widgets/show_review_giving_alert_dialog.dart';
import 'package:kaz_bd/features/normal_user/bookings/widgets/bookings_details_card_widget.dart';

class WorkCompletedTab extends StatelessWidget {
  const WorkCompletedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(booking_ctrl.WorkCompletedBookingsController());

    return RefreshIndicator(
      onRefresh: () => controller.getWorkCompletedBookings(),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                UIHelper.verticalSpace(16.h),
                Text(
                  'loading_work_completed_bookings'.tr,
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
                    child: Text('retry'.tr),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.workCompletedBookings.isEmpty) {
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UIHelper.verticalSpace(0.2.sh),
                  Icon(Icons.work_outline, size: 64.sp, color: Colors.grey),
                  UIHelper.verticalSpace(16.h),
                  Text(
                    'no_works_completed_bookings_found'.tr,
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.only(top: 16.sp),
          itemCount: controller.workCompletedBookings.length,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
          itemBuilder: (context, index) {
            final booking = controller.workCompletedBookings[index];
            final bookingId = booking['_ServiceBookingId']?.toString() ?? '';
            final serviceName = booking['providerDetailsId']?['serviceName']
            as Map<String, dynamic>?;
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
              isWorkCompletedTabGiveReviewOnTap: () =>
                  _handleReviewButton(booking),
              title: _getServiceName(serviceName),
              initialPayablePrice: (booking['startPrice'] ?? 0).toString(),
              location: _getAddress(address),
              dateTime:
              _formatDateTime(booking['bookingDateTime']?.toString() ?? ''),
              serviceProviderProfileImage: imageUrl,
              serviceProviderName: provider?['name'] ?? 'unknown_provider'.tr,
              serviceProviderDesignation: 'services_provider'.tr,
              isNetworkImage: isNetworkImage,
            );
          },
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD TAP HANDLER
  // ═══════════════════════════════════════════════════════════════
  void _handleCardTap(Map<String, dynamic> booking) {
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
          'navigation_error'.tr,
          'cannot_load_service_details_bookings_id_is_missing'.tr,
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
        arguments: bookingId,
      );

      log('✅ [NAVIGATION] Successfully navigated to details screen');
    } catch (e, stackTrace) {
      log('❌ [ERROR] Exception in _handleCardTap:');
      log('   Error: $e');
      log('   Stack trace: $stackTrace');
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      Get.snackbar(
        'error'.tr,
        '${'failed_to_open_details'.tr} ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // REVIEW BUTTON HANDLER
  // ═══════════════════════════════════════════════════════════════
  void _handleReviewButton(Map<String, dynamic> booking) {
    log('⭐ [REVIEW] Give review button tapped');

    try {
      final bookingId = booking['_ServiceBookingId']?.toString() ?? '';

      String serviceProviderId = '';
      if (booking['providerDetailsId'] is Map<String, dynamic>) {
        serviceProviderId = (booking['providerDetailsId']
        as Map<String, dynamic>)['_ServiceProviderId']
            ?.toString() ??
            '';
      } else if (booking['providerDetailsId'] is String) {
        serviceProviderId = booking['providerDetailsId'].toString();
      }

      String providerId = '';
      if (booking['providerId'] is Map<String, dynamic>) {
        providerId = (booking['providerId'] as Map<String, dynamic>)['_userId']
            ?.toString() ??
            '';
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
        'error'.tr,
        'failed_to_open_review_dialog'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // IMAGE HANDLING METHODS
  // ═══════════════════════════════════════════════════════════════
  String _getImageUrl(booking_ctrl.ImageInfo imageInfo) {
    if (imageInfo.url.isEmpty) {
      return Assets.images.userImage.path;
    }
    return imageInfo.url;
  }

  bool _isNetworkImage(booking_ctrl.ImageInfo imageInfo) {
    if (imageInfo.url.isEmpty) {
      return false;
    }
    return imageInfo.isAwsUrl || imageInfo.isAccessible;
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════
  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  String _getServiceName(Map<String, dynamic>? serviceName) {
    if (serviceName == null) return 'unknown_service'.tr;
    return serviceName['en'] ?? serviceName['bn'] ?? 'unknown_service'.tr;
  }

  String _getAddress(Map<String, dynamic>? address) {
    if (address == null) return 'unknown_location'.tr;
    return address['en'] ?? address['bn'] ?? 'unknown_location'.tr;
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
}*/


























import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../routes/routes.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../controller/work_completed_controller.dart' as booking_ctrl;
import '../widgets/show_review_giving_alert_dialog.dart';
import 'package:kaz_bd/features/normal_user/bookings/widgets/bookings_details_card_widget.dart';

class WorkCompletedTab extends StatelessWidget {
  const WorkCompletedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(booking_ctrl.WorkCompletedBookingsController());

    return RefreshIndicator(
      onRefresh: () => controller.getWorkCompletedBookings(),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                UIHelper.verticalSpace(16.h),
                Text(
                  'loading_work_completed_bookings'.tr,
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
                    child: Text('retry'.tr),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.workCompletedBookings.isEmpty) {
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UIHelper.verticalSpace(0.2.sh),
                  Icon(Icons.work_outline, size: 64.sp, color: Colors.grey),
                  UIHelper.verticalSpace(16.h),
                  Text(
                    'no_works_completed_bookings_found'.tr,
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.only(top: 16.sp),
          itemCount: controller.workCompletedBookings.length,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
          itemBuilder: (context, index) {
            try {
              final booking = controller.workCompletedBookings[index];

              // Extract booking ID
              final bookingId = _safeToString(booking['_ServiceBookingId']) ?? '';

              // Debug log
              log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              log('📋 [BOOKING $index]');
              log('   Booking ID: $bookingId');

              // Get provider details
              final providerDetails = _safeCast<Map<String, dynamic>>(booking['providerDetailsId']);
              final provider = _safeCast<Map<String, dynamic>>(booking['providerId']);

              // Get service name - FIXED: Handle Map<String, dynamic> properly
              String serviceTitle = 'unknown_service'.tr;
              if (providerDetails != null) {
                final serviceNameData = providerDetails['serviceName'];
                serviceTitle = _extractServiceName(serviceNameData);
                log('🔧 [SERVICE NAME EXTRACTED]: $serviceTitle');
                log('🔧 [SERVICE NAME RAW DATA]: $serviceNameData');
                log('🔧 [SERVICE NAME DATA TYPE]: ${serviceNameData.runtimeType}');
              }

              // Get provider name
              String providerName = 'unknown_provider'.tr;
              if (provider != null) {
                providerName = _safeToString(provider['name']) ?? 'unknown_provider'.tr;
                log('👤 [PROVIDER NAME]: $providerName');
              }

              // Get address - FIXED: Handle Map<String, dynamic> properly
              String location = 'unknown_location'.tr;
              final addressData = booking['address'];
              location = _extractAddress(addressData);
              log('📍 [ADDRESS]: $location');

              // Get provider image
              String providerImage = '';
              if (provider != null) {
                final profileImage = _safeCast<Map<String, dynamic>>(provider['profileImage']);
                if (profileImage != null) {
                  providerImage = _safeToString(profileImage['imageUrl']) ?? '';
                }
              }

              log('🖼️ [PROVIDER IMAGE URL]: $providerImage');

              // Get image info from controller
              final imageInfo = controller.getImageInfo(bookingId);
              final isNetworkImage = _isNetworkImage(imageInfo);

              // Use controller image if provider image is empty
              if (providerImage.isEmpty) {
                providerImage = _getImageUrl(imageInfo);
              }

              final isReviewGiven = controller.isReviewGiven(bookingId);

              // Extract date time
              final dateTimeString = _safeToString(booking['bookingDateTime']) ?? '';
              final formattedDateTime = _formatDateTime(dateTimeString);

              // Extract price
              final price = _safeToString(booking['startPrice']) ?? '0';

              log('📝 [FINAL DATA FOR CARD]');
              log('   Title: $serviceTitle');
              log('   Provider Name: $providerName');
              log('   Location: $location');
              log('   Date: $formattedDateTime');
              log('   Price: $price');
              log('   Image: $providerImage');
              log('   Is Network Image: $isNetworkImage');
              log('   Is Review Given: $isReviewGiven');

              return BookingDetailsCardWidget(
                onTap: () => _handleCardTap(booking),
                isWorkCompletedTab: true,
                isReviewGiven: isReviewGiven,
                isWorkCompletedTabGiveReviewOnTap: () =>
                    _handleReviewButton(booking),
                title: serviceTitle,
                initialPayablePrice: price,
                location: location,
                dateTime: formattedDateTime,
                serviceProviderProfileImage: providerImage,
                serviceProviderName: providerName,
                serviceProviderDesignation: 'services_provider'.tr,
                isNetworkImage: isNetworkImage || (providerImage.isNotEmpty && providerImage != Assets.images.userImage.path),
              );
            } catch (e, stackTrace) {
              log('❌ [ERROR] Building item $index: $e');
              log('   Stack trace: $stackTrace');
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: Column(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        UIHelper.verticalSpace(8.h),
                        Text(
                          'Error loading booking',
                          style: TextStyle(color: Colors.red),
                        ),
                        UIHelper.verticalSpace(4.h),
                        Text(
                          'Tap to retry',
                          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TYPE-SAFE UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Safely cast a value to a specific type
  T? _safeCast<T>(dynamic value) {
    try {
      if (value is T) {
        return value;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Safely convert any value to string
  String? _safeToString(dynamic value) {
    if (value == null) return null;
    try {
      return value.toString();
    } catch (e) {
      return null;
    }
  }

  /// Extract service name handling both Map and String cases
  String _extractServiceName(dynamic serviceNameData) {
    try {
      if (serviceNameData == null) return 'unknown_service'.tr;

      log('🔧 [EXTRACT SERVICE NAME] Input type: ${serviceNameData.runtimeType}');
      log('🔧 [EXTRACT SERVICE NAME] Input value: $serviceNameData');

      if (serviceNameData is String) {
        log('🔧 [EXTRACT SERVICE NAME] It\'s a String');
        return serviceNameData;
      } else if (serviceNameData is Map<String, dynamic>) {
        log('🔧 [EXTRACT SERVICE NAME] It\'s a Map<String, dynamic>');
        // Check for different possible keys in the map
        final serviceName = serviceNameData['en'] ??
            serviceNameData['bn'] ??
            serviceNameData['name'] ??
            serviceNameData['title'] ??
            serviceNameData['serviceName'] ??
            'unknown_service'.tr;
        log('🔧 [EXTRACT SERVICE NAME] Extracted from map: $serviceName');
        return serviceName;
      } else if (serviceNameData is Map) {
        log('🔧 [EXTRACT SERVICE NAME] It\'s a generic Map');
        // Handle generic Map (non-String keys)
        try {
          final map = Map<String, dynamic>.from(serviceNameData);
          final serviceName = map['en'] ??
              map['bn'] ??
              map['name'] ??
              map['title'] ??
              map['serviceName'] ??
              'unknown_service'.tr;
          log('🔧 [EXTRACT SERVICE NAME] Extracted from generic map: $serviceName');
          return serviceName;
        } catch (e) {
          log('❌ [EXTRACT SERVICE NAME] Error converting map: $e');
          return 'unknown_service'.tr;
        }
      } else {
        log('🔧 [EXTRACT SERVICE NAME] It\'s another type, converting to string');
        return serviceNameData.toString();
      }
    } catch (e) {
      log('❌ [EXTRACT SERVICE NAME] Error: $e');
      return 'unknown_service'.tr;
    }
  }

  /// Extract address handling both Map and String cases
  String _extractAddress(dynamic addressData) {
    try {
      if (addressData == null) return 'unknown_location'.tr;

      log('📍 [EXTRACT ADDRESS] Input type: ${addressData.runtimeType}');
      log('📍 [EXTRACT ADDRESS] Input value: $addressData');

      if (addressData is String) {
        log('📍 [EXTRACT ADDRESS] It\'s a String');
        return addressData;
      } else if (addressData is Map<String, dynamic>) {
        log('📍 [EXTRACT ADDRESS] It\'s a Map<String, dynamic>');
        // Check for different possible keys in the map
        final address = addressData['en'] ??
            addressData['bn'] ??
            addressData['address'] ??
            addressData['fullAddress'] ??
            addressData['location'] ??
            addressData['street'] ??
            'unknown_location'.tr;
        log('📍 [EXTRACT ADDRESS] Extracted from map: $address');
        return address;
      } else if (addressData is Map) {
        log('📍 [EXTRACT ADDRESS] It\'s a generic Map');
        // Handle generic Map (non-String keys)
        try {
          final map = Map<String, dynamic>.from(addressData);
          final address = map['en'] ??
              map['bn'] ??
              map['address'] ??
              map['fullAddress'] ??
              map['location'] ??
              map['street'] ??
              'unknown_location'.tr;
          log('📍 [EXTRACT ADDRESS] Extracted from generic map: $address');
          return address;
        } catch (e) {
          log('❌ [EXTRACT ADDRESS] Error converting map: $e');
          return 'unknown_location'.tr;
        }
      } else {
        log('📍 [EXTRACT ADDRESS] It\'s another type, converting to string');
        return addressData.toString();
      }
    } catch (e) {
      log('❌ [EXTRACT ADDRESS] Error: $e');
      return 'unknown_location'.tr;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD TAP HANDLER
  // ═══════════════════════════════════════════════════════════════
  void _handleCardTap(Map<String, dynamic> booking) {
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    log('👆 [WORK COMPLETED TAB] Card tapped');

    try {
      final bookingId = _safeToString(booking['_ServiceBookingId']) ?? '';

      if (bookingId.isEmpty) {
        log('❌ [VALIDATION FAILED] bookingId is empty');
        Get.snackbar(
          'navigation_error'.tr,
          'cannot_load_service_details_bookings_id_is_missing'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      Get.toNamed(
        Routes.workCompletedDetailsScreen,
        arguments: bookingId,
      );

      log('✅ [NAVIGATION] Successfully navigated to details screen');
    } catch (e, stackTrace) {
      log('❌ [ERROR] Exception in _handleCardTap:');
      log('   Error: $e');
      log('   Stack trace: $stackTrace');

      Get.snackbar(
        'error'.tr,
        'failed_to_open_details'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // REVIEW BUTTON HANDLER
  // ═══════════════════════════════════════════════════════════════
  void _handleReviewButton(Map<String, dynamic> booking) {
    log('⭐ [REVIEW] Give review button tapped');

    try {
      final bookingId = _safeToString(booking['_ServiceBookingId']) ?? '';

      String serviceProviderId = '';
      final providerDetails = _safeCast<Map<String, dynamic>>(booking['providerDetailsId']);
      if (providerDetails != null) {
        serviceProviderId = _safeToString(providerDetails['_ServiceProviderId']) ?? '';
      } else if (booking['providerDetailsId'] is String) {
        serviceProviderId = booking['providerDetailsId'].toString();
      }

      String providerId = '';
      final provider = _safeCast<Map<String, dynamic>>(booking['providerId']);
      if (provider != null) {
        providerId = _safeToString(provider['_userId']) ?? '';
      }

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
        'error'.tr,
        'failed_to_open_review_dialog'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // IMAGE HANDLING METHODS
  // ═══════════════════════════════════════════════════════════════
  String _getImageUrl(booking_ctrl.ImageInfo imageInfo) {
    if (imageInfo.url.isEmpty) {
      return Assets.images.userImage.path;
    }
    return imageInfo.url;
  }

  bool _isNetworkImage(booking_ctrl.ImageInfo imageInfo) {
    if (imageInfo.url.isEmpty) {
      return false;
    }
    return imageInfo.isAwsUrl || imageInfo.isAccessible;
  }

  // ═══════════════════════════════════════════════════════════════
  // DATE FORMATTING
  // ═══════════════════════════════════════════════════════════════
  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
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
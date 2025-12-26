import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kaz_bd/constants/app_enums.dart';
import 'package:kaz_bd/features/normal_user/bookings/widgets/bookings_details_card_widget.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';
import '../controller/payment_request_controller.dart';

class PaymentRequestTab extends StatelessWidget {
  const PaymentRequestTab({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Initialize controller
    final bookingController = Get.put(PaymentRequestBookingsController());

    return RefreshIndicator(
      onRefresh: () => bookingController.getPaymentRequestBookings(),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Obx(() {
            if (bookingController.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // CircularProgressIndicator(),
                    UIHelper.verticalSpace(16.h),
                    Text(
                      'Loading Payment Request...'.tr,
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            if (bookingController.errorMessage.isNotEmpty) {
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
                        bookingController.errorMessage.value,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      UIHelper.verticalSpace(20.h),
                      ElevatedButton(
                        onPressed: () =>
                            bookingController.getPaymentRequestBookings(),
                        child: Text('retry'.tr),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (bookingController.paymentRequestBookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.payment_outlined,
                      size: 64.sp,
                      color: Colors.grey,
                    ),
                    UIHelper.verticalSpace(16.h),
                    Text(
                      'no_payments_request_bookings_found'.tr,
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: EdgeInsets.only(bottom: 100.h),
              child: ListView.separated(
                shrinkWrap: false,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 16.sp),
                itemCount: bookingController.paymentRequestBookings.length,
                separatorBuilder: (context, index) =>
                    UIHelper.verticalSpace(16.h),
                itemBuilder: (context, index) {
                  final booking =
                      bookingController.paymentRequestBookings[index];
                  final bookingId =
                      booking['_ServiceBookingId']?.toString() ?? '';

                  // 🔴 FIXED: Extract BOTH IDs for the DetailsScreen
                  final serviceProviderId = _getServiceProviderId(booking);
                  final providerId = _getProviderUserId(booking);

                  // 🔍 DEBUG: Log what IDs are extracted
                  log('🧾 [PAYMENT REQUEST TAB] Card #$index →');
                  log('   Booking ID: "$bookingId"');
                  log('   Service Provider ID: "$serviceProviderId"');
                  log('   Provider User ID: "$providerId"');

                  final serviceName = booking['providerDetailsId']
                      ?['serviceName'] as Map<String, dynamic>?;
                  final address = booking['address'] as Map<String, dynamic>?;
                  final provider =
                      booking['providerId'] as Map<String, dynamic>?;

                  final imageUrl = _getImageUrl(bookingId, bookingController);
                  final isNetworkImage =
                      _isNetworkImage(bookingId, bookingController);

                  return BookingDetailsCardWidget(
                    // ➤ CARD TAP → Navigate with ALL required parameters
                    onTap: () {
                      _navigateToDetailsScreen(
                          bookingId, serviceProviderId, providerId);
                    },

                    isPaymentRequestTab: true,

                    ///Button OnTap -> Pay
                    isPaymentRequestTabPayOnTap: () {
                      _handlePayment(bookingId, bookingController);
                    },

                    ///Button OnTap -> View
                    isPaymentRequestTabViewOnTap: () {
                      _navigateToDetailsScreen(
                          bookingId, serviceProviderId, providerId);
                    },

                    // Data
                    title: _getServiceName(serviceName),
                    initialPayablePrice:
                        (booking['startPrice'] ?? 0).toString(),
                    location: _getAddress(address),
                    dateTime: _formatDateTime(
                        booking['bookingDateTime']?.toString() ?? ''),
                    serviceProviderProfileImage:
                        imageUrl ?? Assets.images.userImage.path,
                    serviceProviderName:
                        provider?['name'] ?? 'Unknown Provider',
                    serviceProviderDesignation: 'services_provider'.tr,
                    isNetworkImage: isNetworkImage,
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─── HELPER METHODS ───────────────────────────────────────────────

  static String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      log('⚠️ [PAYMENT REQUEST TAB] DateTime parse error: $e');
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

  // 🔴 FIXED: Extract Service Provider ID (_ServiceProviderId)
  static String _getServiceProviderId(Map<String, dynamic> booking) {
    // 1. Primary: providerDetailsId._ServiceProviderId
    final providerDetails =
        booking['providerDetailsId'] as Map<String, dynamic>?;
    if (providerDetails?['_ServiceProviderId'] != null) {
      final id = providerDetails!['_ServiceProviderId'].toString();
      log('✅ [PAYMENT REQUEST TAB] Service Provider ID from providerDetailsId._ServiceProviderId: $id');
      return id;
    }

    // 2. Secondary: serviceProviderDetailsId
    if (booking['serviceProviderDetailsId'] != null) {
      final id = booking['serviceProviderDetailsId'].toString();
      log('✅ [PAYMENT REQUEST TAB] Service Provider ID from serviceProviderDetailsId: $id');
      return id;
    }

    log('⚠️ [PAYMENT REQUEST TAB] No Service Provider ID found');
    return '';
  }

  // 🔴 FIXED: Extract Provider User ID (_userId)
  static String _getProviderUserId(Map<String, dynamic> booking) {
    // From providerId._userId
    final provider = booking['providerId'] as Map<String, dynamic>?;
    if (provider?['_userId'] != null) {
      final id = provider!['_userId'].toString();
      log('✅ [PAYMENT REQUEST TAB] Provider User ID from providerId._userId: $id');
      return id;
    }

    log('⚠️ [PAYMENT REQUEST TAB] No Provider User ID found in providerId');
    return '';
  }

  static String? _getImageUrl(
      String bookingId, PaymentRequestBookingsController controller) {
    final url = controller.getImageUrl(bookingId);
    if (url.isEmpty) return null;

    if (url.toLowerCase().contains('amazonaws')) {
      return url;
    }

    return controller.hasImage(bookingId) ? url : null;
  }

  static bool _isNetworkImage(
      String bookingId, PaymentRequestBookingsController controller) {
    final url = controller.getImageUrl(bookingId);
    if (url.isEmpty) return false;

    if (url.toLowerCase().contains('amazonaws')) return true;
    return controller.hasImage(bookingId);
  }

  // 🔴 FIXED: Navigation with ALL required parameters for DetailsScreen
  static void _navigateToDetailsScreen(
      String bookingId, String serviceProviderId, String providerId) {
    log('🔍 [PAYMENT REQUEST TAB] Navigation to DetailsScreen → preparing arguments...');
    log('   ➤ bookingId = "$bookingId"');
    log('   ➤ serviceProviderId = "$serviceProviderId"');
    log('   ➤ providerId = "$providerId"');

    if (serviceProviderId.isEmpty) {
      log('❌ [PAYMENT REQUEST TAB] Navigation ABORTED: serviceProviderId is empty!');
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
      log('⚠️ [PAYMENT REQUEST TAB] Warning: providerId is empty (may cause issues in details screen)');
    }

    log('✅ [PAYMENT REQUEST TAB] Navigating to service details screen with required IDs');

    Get.toNamed(
      Routes.serviceDetailsScreen,
      arguments: {
        "status": BookingStatusEnum.paymentRequest,
        "bookingId": bookingId,
        "serviceProviderID": serviceProviderId, // Required for service details
        "providerID": providerId, // Required for booking flow
      },
    );
  }

  // Handle payment process - OPEN IN EXTERNAL BROWSER
  static Future<void> _handlePayment(
      String bookingId, PaymentRequestBookingsController controller) async {
    log("💰 [PAYMENT REQUEST TAB] Pay Button Tapped for booking: $bookingId");

    // Show confirmation dialog
    bool proceed = await Get.dialog<bool>(
          AlertDialog(
            title: Text('proceed_to_payment'.tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payment, size: 48.sp, color: Colors.blue),
                UIHelper.verticalSpace(16.h),
                Text(
                  'you_will_be_redirected_to_ssl_commerce'.tr,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('cancel'.tr),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                child: Text('open_in_browser'.tr),
              ),
            ],
          ),
        ) ??
        false;

    if (!proceed) return;

    // Show loading dialog
    Get.dialog(
      Center(
        child: Container(
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.sp),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              UIHelper.verticalSpace(16.h),
              Text(
                'preparing_payment'.tr,
                style: TextStyle(fontSize: 16.sp),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Process payment
    final paymentData = await controller.processPayment(bookingId);

    // Close loading dialog
    Get.back();

    if (paymentData != null && paymentData['url'] != null) {
      final String paymentUrl = paymentData['url'];
      log('✅ [PAYMENT REQUEST TAB] Payment URL received: $paymentUrl');

      // Open payment URL in external browser
      await _openPaymentInBrowser(paymentUrl, bookingId, controller);
    } else {
      log('❌ [PAYMENT REQUEST TAB] Failed to get payment URL');
    }
  }

  // Open in external browser
  static Future<void> _openPaymentInBrowser(String paymentUrl, String bookingId,
      PaymentRequestBookingsController controller) async {
    try {
      log('🌐 [PAYMENT REQUEST TAB] Attempting to open URL in external browser: $paymentUrl');

      final uri = Uri.parse(paymentUrl);

      // Try to open in external application
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        log('✅ [PAYMENT REQUEST TAB] Browser launched successfully');

        // Show success message
        Get.snackbar(
          'payment_page_opened'.tr,
          'complete_your_payment_and_return_to_app',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 5),
          isDismissible: true,
          mainButton: TextButton(
            onPressed: () {
              Get.back(); // Close snackbar
              // Show refresh option
              _showRefreshOption(bookingId, controller);
            },
            child: Text('refresh'.tr, style: TextStyle(color: Colors.white)),
          ),
        );
      } else {
        log('❌ [PAYMENT REQUEST TAB] Browser launch failed');
        _showBrowserError(paymentUrl);
      }
    } catch (e) {
      log('❌ [PAYMENT REQUEST TAB] Error launching browser: $e');
      _showBrowserError(paymentUrl);
    }
  }

  // Show browser error and alternatives
  static void _showBrowserError(String paymentUrl) {
    Get.dialog(
      AlertDialog(
        title: Text('unable_to_open_browser'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
            UIHelper.verticalSpace(16.h),
            Text(
              'could_not_open_the_payment_page_automatically'.tr,
              textAlign: TextAlign.center,
            ),
            UIHelper.verticalSpace(16.h),
            Text(
              'please_manually_copy_and_open_the_link'.tr,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            UIHelper.verticalSpace(8.h),
            GestureDetector(
              onTap: () {
                // Copy to clipboard
                // import 'package:flutter/services.dart';
                // Clipboard.setData(ClipboardData(text: paymentUrl));
                Get.snackbar(
                  'copied'.tr,
                  'copied_to_clip_board'.tr,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              child: Container(
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.sp),
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  paymentUrl,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('close'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              // Try again with different mode
              await launchUrl(
                Uri.parse(paymentUrl),
                mode: LaunchMode.platformDefault,
              );
            },
            child: Text('try_again'.tr),
          ),
        ],
      ),
    );
  }

  // Show refresh option after browser opens
  static void _showRefreshOption(
      String bookingId, PaymentRequestBookingsController controller) {
    Future.delayed(Duration(seconds: 3), () {
      Get.showSnackbar(
        GetSnackBar(
          title: 'payment_in_progress'.tr,
          message: 'tap_to_refresh'.tr,
          duration: Duration(seconds: 15),
          backgroundColor: Colors.blue,
          mainButton: TextButton(
            onPressed: () {
              Get.back(); // Close snackbar
              controller.getPaymentRequestBookings();
              Get.snackbar(
                'refreshing'.tr,
                'checking_for_payment_updates'.tr,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text('refresh'.tr, style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    });
  }
}

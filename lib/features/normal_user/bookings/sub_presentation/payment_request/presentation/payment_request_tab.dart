/**
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../constants/app_enums.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';
import '../../../widgets/bookings_details_card_widget.dart';
import '../controller/payment_request_controller.dart';

class PaymentRequestTab extends StatelessWidget {
  PaymentRequestTab({super.key});

  final PaymentRequestBookingsController bookingController = Get.put(PaymentRequestBookingsController());

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

  // Return network URL when available, otherwise asset path
  String _getImageUrl(String bookingId) {
    final imageUrl = bookingController.getImageUrl(bookingId);

    log('=== Getting image for booking $bookingId ===');
    log('Image URL from controller: $imageUrl');
    log('Image URL is empty: ${imageUrl.isEmpty}');

    if (imageUrl.isEmpty) {
      log('❌ No image URL, using fallback asset image');
      return Assets.images.userImage.path;
    }

    // Check if it's an AWS S3 URL
    if (_isAwsS3Url(imageUrl)) {
      log('✅ AWS S3 URL detected, using directly: $imageUrl');
      return imageUrl;
    }

    // For non-AWS URLs, check accessibility
    final hasImage = bookingController.hasImage(bookingId);
    log('Has image (non-AWS): $hasImage');

    if (hasImage) {
      log('✅ Non-AWS image accessible: $imageUrl');
      return imageUrl;
    }

    // Return fallback asset path
    log('❌ Image not accessible, using fallback asset image');
    return Assets.images.userImage.path;
  }

  // Check if the image is a network image
  bool _isNetworkImage(String bookingId) {
    final imageUrl = bookingController.getImageUrl(bookingId);

    if (imageUrl.isEmpty) {
      return false;
    }

    // AWS S3 URLs are always treated as network images
    if (_isAwsS3Url(imageUrl)) {
      return true;
    }

    // For non-AWS URLs, check if accessible
    return bookingController.hasImage(bookingId);
  }

  // Handle payment process - OPEN IN EXTERNAL BROWSER
  Future<void> _handlePayment(String bookingId) async {
    log("My Bookings Screen Payment Request Tab Pay Button Tapped for booking: $bookingId");

    // Show confirmation dialog
    bool proceed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Proceed to Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payment, size: 48.sp, color: Colors.blue),
            UIHelper.verticalSpace(16.h),
            Text(
              'You will be redirected to SSLCommerz in your browser to complete your payment.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('Open in Browser'),
          ),
        ],
      ),
    ) ?? false;

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
                'Preparing payment...',
                style: TextStyle(fontSize: 16.sp),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Process payment
    final paymentData = await bookingController.processPayment(bookingId);

    // Close loading dialog
    Get.back();

    if (paymentData != null && paymentData['url'] != null) {
      final String paymentUrl = paymentData['url'];
      log('Payment URL received: $paymentUrl');

      // Open payment URL in external browser
      await _openPaymentInBrowser(paymentUrl, bookingId);
    }
  }

  // Open in external browser - SIMPLIFIED AND FIXED
  Future<void> _openPaymentInBrowser(String paymentUrl, String bookingId) async {
    try {
      log('Attempting to open URL in external browser: $paymentUrl');

      final uri = Uri.parse(paymentUrl);

      // SIMPLE DIRECT APPROACH - No complex checks first
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        log('✅ Browser launched successfully');

        // Show success message
        Get.snackbar(
          'Payment Page Opened',
          'Complete your payment in the browser and return to this app',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 5),
          isDismissible: true,
          mainButton: TextButton(
            onPressed: () {
              Get.back(); // Close snackbar
              // Show refresh option
              _showRefreshOption(bookingId);
            },
            child: Text('Refresh', style: TextStyle(color: Colors.white)),
          ),
        );
      } else {
        log('❌ Browser launch failed');
        _showBrowserError(paymentUrl);
      }

    } catch (e) {
      log('Error launching browser: $e');
      _showBrowserError(paymentUrl);
    }
  }

  // Show browser error and alternatives
  void _showBrowserError(String paymentUrl) {
    Get.dialog(
      AlertDialog(
        title: Text('Unable to Open Browser'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
            UIHelper.verticalSpace(16.h),
            Text(
              'Could not open the payment page automatically.',
              textAlign: TextAlign.center,
            ),
            UIHelper.verticalSpace(16.h),
            Text(
              'Please manually open this URL in your browser:',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            UIHelper.verticalSpace(8.h),
            GestureDetector(
              onTap: () {
                // Copy to clipboard
                // Add: import 'package:flutter/services.dart';
                // Clipboard.setData(ClipboardData(text: paymentUrl));
                Get.snackbar(
                  'Copied',
                  'URL copied to clipboard',
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
            child: Text('Close'),
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
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // Show refresh option after browser opens
  void _showRefreshOption(String bookingId) {
    Future.delayed(Duration(seconds: 3), () {
      Get.showSnackbar(
        GetSnackBar(
          title: 'Payment in Progress',
          message: 'Tap here to refresh after completing payment',
          duration: Duration(seconds: 15),
          backgroundColor: Colors.blue,
          mainButton: TextButton(
            onPressed: () {
              Get.back(); // Close snackbar
              bookingController.getPaymentRequestBookings();
              Get.snackbar(
                'Refreshing',
                'Checking for payment updates...',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text('Refresh', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (bookingController.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              UIHelper.verticalSpace(16.h),
              Text(
                'Loading payment request bookings...',
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
                  onPressed: () => bookingController.getPaymentRequestBookings(),
                  child: const Text('Retry'),
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
                'No payment request bookings found',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => bookingController.getPaymentRequestBookings(),
        child: ListView.separated(
          padding: EdgeInsets.only(top: 16.sp),
          itemCount: bookingController.paymentRequestBookings.length,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
          itemBuilder: (context, index) {
            final booking = bookingController.paymentRequestBookings[index];
            final bookingId = booking['_ServiceBookingId'] ?? '';

            final serviceName = booking['providerDetailsId']?['serviceName'];
            final address = booking['address'];
            final provider = booking['providerId'];

            final imageUrl = _getImageUrl(bookingId);
            final isNetworkImage = _isNetworkImage(bookingId);

            log('Building payment request booking card for $bookingId');
            log('Final image URL: $imageUrl');
            log('Is network image: $isNetworkImage');

            return BookingDetailsCardWidget(
              onTap: () {
                Get.toNamed(
                  Routes.bookingsPaymentRequestDetailsScreen,
                  arguments: {
                    "status": BookingStatusEnum.paymentRequest,
                    "bookingId": bookingId,
                  },
                );
              },
              isPaymentRequestTab: true,

              ///Button OnTap -> Pay
              isPaymentRequestTabPayOnTap: () {
                _handlePayment(bookingId);
              },

              ///Button OnTap -> View
              isPaymentRequestTabViewOnTap: () {
                log("My Bookings Screen Payment Request Tab View Button Tapped for booking: $bookingId");
                Get.toNamed(
                  Routes.bookingsPaymentRequestDetailsScreen,
                  arguments: {
                    "status": BookingStatusEnum.paymentRequest,
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
*/








///
///
///
///
/// todo::: passing the value of the providerId
///
///
///
///







import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../constants/app_enums.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';
import '../../../widgets/bookings_details_card_widget.dart';
import '../controller/payment_request_controller.dart';

class PaymentRequestTab extends StatelessWidget {
  PaymentRequestTab({super.key});

  final PaymentRequestBookingsController bookingController = Get.put(PaymentRequestBookingsController());

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

  // Extract provider ID from the correct location based on JSON structure
  String _getProviderId(Map<String, dynamic> booking) {
    String? providerId;

    // Check multiple possible locations for providerId
    // 1. First try: providerDetailsId._ServiceProviderId
    if (booking['providerDetailsId'] != null) {
      final providerDetailsMap = booking['providerDetailsId'] as Map<String, dynamic>?;
      if (providerDetailsMap != null && providerDetailsMap['_ServiceProviderId'] != null) {
        providerId = providerDetailsMap['_ServiceProviderId'].toString();
        log('✅ PaymentRequest Tab - Provider ID from providerDetailsId._ServiceProviderId: $providerId');
        return providerId;
      }
    }

    // 2. Second try: serviceProviderDetailsId
    if (booking['serviceProviderDetailsId'] != null) {
      providerId = booking['serviceProviderDetailsId'].toString();
      log('✅ PaymentRequest Tab - Provider ID from serviceProviderDetailsId: $providerId');
      return providerId;
    }

    // 3. Third try: providerId._userId
    if (booking['providerId'] != null && booking['providerId'] is Map) {
      final providerMap = booking['providerId'] as Map<String, dynamic>;
      if (providerMap['_userId'] != null) {
        providerId = providerMap['_userId'].toString();
        log('⚠️ PaymentRequest Tab - Provider ID from providerId._userId (fallback): $providerId');
        return providerId;
      }
    }

    log('❌ PaymentRequest Tab - ERROR: No provider ID found in booking data');
    log('Booking data keys: ${booking.keys}');
    return '';
  }

  // Check if URL is from AWS S3
  bool _isAwsS3Url(String imageUrl) {
    return imageUrl.toLowerCase().contains('amazonaws');
  }

  // Return network URL when available, otherwise asset path
  String _getImageUrl(String bookingId) {
    final imageUrl = bookingController.getImageUrl(bookingId);

    log('=== Getting image for booking $bookingId ===');
    log('Image URL from controller: $imageUrl');
    log('Image URL is empty: ${imageUrl.isEmpty}');

    if (imageUrl.isEmpty) {
      log('❌ No image URL, using fallback asset image');
      return Assets.images.userImage.path;
    }

    // Check if it's an AWS S3 URL
    if (_isAwsS3Url(imageUrl)) {
      log('✅ AWS S3 URL detected, using directly: $imageUrl');
      return imageUrl;
    }

    // For non-AWS URLs, check accessibility
    final hasImage = bookingController.hasImage(bookingId);
    log('Has image (non-AWS): $hasImage');

    if (hasImage) {
      log('✅ Non-AWS image accessible: $imageUrl');
      return imageUrl;
    }

    // Return fallback asset path
    log('❌ Image not accessible, using fallback asset image');
    return Assets.images.userImage.path;
  }

  // Check if the image is a network image
  bool _isNetworkImage(String bookingId) {
    final imageUrl = bookingController.getImageUrl(bookingId);

    if (imageUrl.isEmpty) {
      return false;
    }

    // AWS S3 URLs are always treated as network images
    if (_isAwsS3Url(imageUrl)) {
      return true;
    }

    // For non-AWS URLs, check if accessible
    return bookingController.hasImage(bookingId);
  }

  // Handle payment process - OPEN IN EXTERNAL BROWSER
  Future<void> _handlePayment(String bookingId) async {
    log("My Bookings Screen Payment Request Tab Pay Button Tapped for booking: $bookingId");

    // Show confirmation dialog
    bool proceed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Proceed to Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payment, size: 48.sp, color: Colors.blue),
            UIHelper.verticalSpace(16.h),
            Text(
              'You will be redirected to SSLCommerz in your browser to complete your payment.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('Open in Browser'),
          ),
        ],
      ),
    ) ?? false;

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
                'Preparing payment...',
                style: TextStyle(fontSize: 16.sp),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Process payment
    final paymentData = await bookingController.processPayment(bookingId);

    // Close loading dialog
    Get.back();

    if (paymentData != null && paymentData['url'] != null) {
      final String paymentUrl = paymentData['url'];
      log('Payment URL received: $paymentUrl');

      // Open payment URL in external browser
      await _openPaymentInBrowser(paymentUrl, bookingId);
    }
  }

  // Open in external browser - SIMPLIFIED AND FIXED
  Future<void> _openPaymentInBrowser(String paymentUrl, String bookingId) async {
    try {
      log('Attempting to open URL in external browser: $paymentUrl');

      final uri = Uri.parse(paymentUrl);

      // SIMPLE DIRECT APPROACH - No complex checks first
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        log('✅ Browser launched successfully');

        // Show success message
        Get.snackbar(
          'Payment Page Opened',
          'Complete your payment in the browser and return to this app',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 5),
          isDismissible: true,
          mainButton: TextButton(
            onPressed: () {
              Get.back(); // Close snackbar
              // Show refresh option
              _showRefreshOption(bookingId);
            },
            child: Text('Refresh', style: TextStyle(color: Colors.white)),
          ),
        );
      } else {
        log('❌ Browser launch failed');
        _showBrowserError(paymentUrl);
      }

    } catch (e) {
      log('Error launching browser: $e');
      _showBrowserError(paymentUrl);
    }
  }

  // Show browser error and alternatives
  void _showBrowserError(String paymentUrl) {
    Get.dialog(
      AlertDialog(
        title: Text('Unable to Open Browser'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
            UIHelper.verticalSpace(16.h),
            Text(
              'Could not open the payment page automatically.',
              textAlign: TextAlign.center,
            ),
            UIHelper.verticalSpace(16.h),
            Text(
              'Please manually open this URL in your browser:',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            UIHelper.verticalSpace(8.h),
            GestureDetector(
              onTap: () {
                // Copy to clipboard
                // Add: import 'package:flutter/services.dart';
                // Clipboard.setData(ClipboardData(text: paymentUrl));
                Get.snackbar(
                  'Copied',
                  'URL copied to clipboard',
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
            child: Text('Close'),
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
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // Show refresh option after browser opens
  void _showRefreshOption(String bookingId) {
    Future.delayed(Duration(seconds: 3), () {
      Get.showSnackbar(
        GetSnackBar(
          title: 'Payment in Progress',
          message: 'Tap here to refresh after completing payment',
          duration: Duration(seconds: 15),
          backgroundColor: Colors.blue,
          mainButton: TextButton(
            onPressed: () {
              Get.back(); // Close snackbar
              bookingController.getPaymentRequestBookings();
              Get.snackbar(
                'Refreshing',
                'Checking for payment updates...',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text('Refresh', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (bookingController.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              UIHelper.verticalSpace(16.h),
              Text(
                'Loading payment request bookings...',
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
                  onPressed: () => bookingController.getPaymentRequestBookings(),
                  child: const Text('Retry'),
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
                'No payment request bookings found',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => bookingController.getPaymentRequestBookings(),
        child: ListView.separated(
          padding: EdgeInsets.only(top: 16.sp),
          itemCount: bookingController.paymentRequestBookings.length,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
          itemBuilder: (context, index) {
            final booking = bookingController.paymentRequestBookings[index];
            final bookingId = booking['_ServiceBookingId'] ?? '';

            // Extract provider ID
            final providerId = _getProviderId(booking);

            final serviceName = booking['providerDetailsId']?['serviceName'];
            final address = booking['address'];
            final provider = booking['providerId'];

            final imageUrl = _getImageUrl(bookingId);
            final isNetworkImage = _isNetworkImage(bookingId);

            log('Building payment request booking card for $bookingId');
            log('Final image URL: $imageUrl');
            log('Is network image: $isNetworkImage');
            log('Provider ID for details screen: $providerId');

            return BookingDetailsCardWidget(
              onTap: () {
                if (providerId.isEmpty) {
                  log('❌ PaymentRequest Tab - Cannot navigate to details: Provider ID is empty');
                  Get.snackbar(
                    'Error',
                    'Provider information not available',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                log('🚀 PaymentRequest Tab - Navigating to service details');
                log('   Status: ${BookingStatusEnum.paymentRequest}');
                log('   Booking ID: $bookingId');
                log('   Provider ID: $providerId');

                Get.toNamed(
                  Routes.serviceDetailsScreen,
                  arguments: {
                    "status": BookingStatusEnum.paymentRequest,
                    "bookingId": bookingId,
                    "providerId": providerId,
                  },
                );
              },
              isPaymentRequestTab: true,

              ///Button OnTap -> Pay
              isPaymentRequestTabPayOnTap: () {
                _handlePayment(bookingId);
              },

              ///Button OnTap -> View
              isPaymentRequestTabViewOnTap: () {
                if (providerId.isEmpty) {
                  log('❌ PaymentRequest Tab - Cannot navigate to details: Provider ID is empty');
                  Get.snackbar(
                    'Error',
                    'Provider information not available',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                log("👁️ PaymentRequest Tab - View Button Tapped for booking: $bookingId");
                log('   Status: ${BookingStatusEnum.paymentRequest}');
                log('   Booking ID: $bookingId');
                log('   Provider ID: $providerId');

                Get.toNamed(
                  Routes.serviceDetailsScreen,
                  arguments: {
                    "status": BookingStatusEnum.paymentRequest,
                    "bookingId": bookingId,
                    "providerId": providerId,
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



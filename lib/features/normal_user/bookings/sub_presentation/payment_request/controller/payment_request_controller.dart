import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kaz_bd/controllers/svp_home_screen_controller.dart';
import 'package:kaz_bd/features/service_provider/svp_bookings/sub_presentation/svp_work_completed/controller/svp_work_completed_tab_controller.dart';
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';
import '../../../../../service_provider/svp_bookings/sub_presentation/svp_payment_request/controller/svp_payment_request_tab_controller.dart';

class PaymentRequestBookingsController extends GetxController {
  SvpHomeScreenController svpHomeScreenController =
      Get.find<SvpHomeScreenController>();
  SvpPaymentRequestController svpPaymentRequestController =
      Get.put(SvpPaymentRequestController());
  SvpWorkCompletedController svpWorkCompletedController =
      Get.put(SvpWorkCompletedController());
  final RxList<dynamic> paymentRequestBookings = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, String> bookingImageUrls = <String, String>{}.obs;
  final RxMap<String, bool> imageLoadStatus = <String, bool>{}.obs;
  final RxBool isProcessingPayment = false.obs;
  final RxString paymentErrorMessage = ''.obs;

  Future<void> getPaymentRequestBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      log('🚀 [PAYMENT REQUEST CONTROLLER] Starting to fetch payment request bookings...');

      final token = await SecureStorageService().read(AppConstants.accessToken);
      log('🔑 [PAYMENT REQUEST CONTROLLER] Token retrieved: ${token != null ? 'Yes' : 'No'}');

      if (token == null) {
        errorMessage.value =
            'Authentication token not found. Please login again.';
        isLoading.value = false;
        log('❌ [PAYMENT REQUEST CONTROLLER] No token found');
        return;
      }

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      log('🌐 [PAYMENT REQUEST CONTROLLER] Making API call to: ${AppUrl.paymentRequests}');

      NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.paymentRequests,
        headers: headers,
      );

      log('📥 [PAYMENT REQUEST CONTROLLER] API Response - Status Code: ${response.statusCode}');
      log('📊 [PAYMENT REQUEST CONTROLLER] API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('📋 [PAYMENT REQUEST CONTROLLER] Full API Response Data: ${response.jsonResponse}');

        if (response.jsonResponse!['success'] == true) {
          List<dynamic> results =
              response.jsonResponse!['data']['attributes']['results'];
          log('✅ [PAYMENT REQUEST CONTROLLER] Found ${results.length} payment request bookings');

          // Log the structure of first booking for debugging
          if (results.isNotEmpty) {
            final firstBooking = results.first;
            log('🔍 [PAYMENT REQUEST CONTROLLER] First booking structure:');
            log('   Booking ID: ${firstBooking['_ServiceBookingId']}');
            log('   providerDetailsId exists: ${firstBooking['providerDetailsId'] != null}');
            if (firstBooking['providerDetailsId'] != null) {
              log('   providerDetailsId._ServiceProviderId: ${firstBooking['providerDetailsId']['_ServiceProviderId']}');
            }
            log('   serviceProviderDetailsId exists: ${firstBooking['serviceProviderDetailsId'] != null}');
            if (firstBooking['serviceProviderDetailsId'] != null) {
              log('   serviceProviderDetailsId: ${firstBooking['serviceProviderDetailsId']}');
            }
            log('   providerId exists: ${firstBooking['providerId'] != null}');
            if (firstBooking['providerId'] != null) {
              log('   providerId._userId: ${firstBooking['providerId']['_userId']}');
              log('   providerId.name: ${firstBooking['providerId']['name']}');
            }
          }

          paymentRequestBookings.assignAll(results);

          // Process image URLs for all bookings
          await _processBookingImages(results);
        } else {
          String apiMessage =
              response.jsonResponse!['message'] ?? 'Failed to load bookings';
          errorMessage.value = apiMessage;
          log('❌ [PAYMENT REQUEST CONTROLLER] API returned error: $apiMessage');
        }
      } else {
        String error = response.errorMessage ?? 'Something went wrong';
        errorMessage.value = error;
        log('❌ [PAYMENT REQUEST CONTROLLER] Network error: $error');
      }
    } catch (e) {
      errorMessage.value =
          'Connection error: Please check your internet connection';
      log('❌ [PAYMENT REQUEST CONTROLLER] Exception in getPaymentRequestBookings: $e');
    } finally {
      isLoading.value = false;
      log('🏁 [PAYMENT REQUEST CONTROLLER] Loading completed');
    }
  }

  // Process payment for a booking
  Future<Map<String, dynamic>?> processPayment(String bookingId) async {
    try {
      isProcessingPayment.value = true;
      paymentErrorMessage.value = '';
      log('💰 [PAYMENT REQUEST CONTROLLER] Starting payment process for booking: $bookingId');

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        paymentErrorMessage.value =
            'Authentication token not found. Please login again.';
        isProcessingPayment.value = false;
        log('❌ [PAYMENT REQUEST CONTROLLER] No token found for payment');
        return null;
      }

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Construct payment URL
      String paymentUrl =
          '${AppUrl.baseUrl}v1/service-bookings/pay/create/$bookingId';
      log('🌐 [PAYMENT REQUEST CONTROLLER] Making POST call to: $paymentUrl');

      NetworkResponse response = await NetworkCaller().postRequest(
        paymentUrl,
        headers: headers,
        body: {},
      );

      log('📥 [PAYMENT REQUEST CONTROLLER] Payment API Response - Status Code: ${response.statusCode}');
      log('📊 [PAYMENT REQUEST CONTROLLER] Payment API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('📋 [PAYMENT REQUEST CONTROLLER] Payment API Response Data: ${response.jsonResponse}');

        if (response.jsonResponse!['code'] == 200) {
          svpHomeScreenController.getServiceProviderHomeData();
          svpPaymentRequestController.fetchPaymentRequests();
          svpWorkCompletedController.fetchCompletedBookings();

          Map<String, dynamic> paymentData =
              response.jsonResponse!['data']['attributes'];
          String paymentUrl = paymentData['url'];
          String transactionId = paymentData['transactionId'];

          log('✅ [PAYMENT REQUEST CONTROLLER] Payment URL generated: $paymentUrl');
          log('💳 [PAYMENT REQUEST CONTROLLER] Transaction ID: $transactionId');

          return {
            'url': paymentUrl,
            'transactionId': transactionId,
            'bookingId': paymentData['bookingId'],
          };
        } else {
          String apiMessage =
              response.jsonResponse!['message'] ?? 'Failed to process payment';
          paymentErrorMessage.value = apiMessage;
          log('❌ [PAYMENT REQUEST CONTROLLER] Payment API returned error: $apiMessage');

          Get.snackbar(
            'Payment Error',
            apiMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );

          return null;
        }
      } else {
        String error = response.errorMessage ?? 'Failed to process payment';
        paymentErrorMessage.value = error;
        log('❌ [PAYMENT REQUEST CONTROLLER] Payment Network error: $error');

        Get.snackbar(
          'Payment Error',
          error,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        return null;
      }
    } catch (e) {
      paymentErrorMessage.value =
          'Connection error: Please check your internet connection';
      log('❌ [PAYMENT REQUEST CONTROLLER] Exception in processPayment: $e');

      Get.snackbar(
        'Payment Error',
        'Connection error: Please check your internet connection',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      return null;
    } finally {
      isProcessingPayment.value = false;
      log('🏁 [PAYMENT REQUEST CONTROLLER] Payment process completed');
    }
  }

  // Handle payment callback from SSLCommerz
  void handlePaymentCallback(Map<String, dynamic> callbackData) {
    try {
      log('🔄 [PAYMENT REQUEST CONTROLLER] Payment callback received: $callbackData');

      final String message = callbackData['message'] ?? 'Payment processed';
      final Map<String, dynamic>? data = callbackData['data'];

      if (data != null) {
        final String transactionId = data['transactionId'] ?? '';
        final String status = data['status']?.toString().toLowerCase() ?? '';
        final String amount = data['amount']?.toString() ?? '';
        final String currency = data['currency'] ?? '';

        log('💳 [PAYMENT REQUEST CONTROLLER] Payment Details:');
        log('   Transaction ID: $transactionId');
        log('   Status: $status');
        log('   Amount: $amount $currency');
        log('   Message: $message');

        // Show success message
        Color backgroundColor = Colors.blue;
        String title = 'Payment Status';

        if (status == 'success' || status == 'valid' || status == 'completed') {
          backgroundColor = Colors.green;
          title = 'Payment Successful';
        } else if (status == 'failed' ||
            status == 'error' ||
            status == 'cancelled') {
          backgroundColor = Colors.red;
          title = 'Payment Failed';
        } else if (status == 'pending' || status == 'processing') {
          backgroundColor = Colors.orange;
          title = 'Payment Processing';
        }

        Get.snackbar(
          title,
          message,
          backgroundColor: backgroundColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 5),
        );

        // Refresh bookings list to update UI if payment was successful
        if (status == 'success' || status == 'valid' || status == 'completed') {
          getPaymentRequestBookings();
        }
      } else {
        Get.snackbar(
          'Payment Info',
          message,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      log('❌ [PAYMENT REQUEST CONTROLLER] Error handling payment callback: $e');
      Get.snackbar(
        'Error',
        'Failed to process payment result',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _processBookingImages(List<dynamic> bookings) async {
    log('🖼️ [PAYMENT REQUEST CONTROLLER] Processing images for ${bookings.length} bookings');

    for (final booking in bookings) {
      final bookingId = booking['_ServiceBookingId'] ?? '';
      final profileImage = booking['providerId']?['profileImage'];

      if (profileImage != null && profileImage['imageUrl'] != null) {
        String imageUrl = profileImage['imageUrl'];
        log("🖼️ [PAYMENT REQUEST CONTROLLER] Booking $bookingId image: $imageUrl");

        // Check if it's an AWS S3 URL
        if (_isAwsS3Url(imageUrl)) {
          log('✅ [PAYMENT REQUEST CONTROLLER] AWS S3 URL detected for booking $bookingId');
          bookingImageUrls[bookingId] = imageUrl;
          imageLoadStatus[bookingId] = true;
        } else {
          // For non-AWS URLs, construct full URL
          String constructedUrl = _constructImageUrl(imageUrl);
          bookingImageUrls[bookingId] = constructedUrl;
          log('🖼️ [PAYMENT REQUEST CONTROLLER] Non-AWS image URL for booking $bookingId: $constructedUrl');

          // Verify if image is accessible
          await _verifyImageAccessibility(bookingId, constructedUrl);
        }
      } else {
        // Store empty string to indicate no image
        bookingImageUrls[bookingId] = '';
        imageLoadStatus[bookingId] = false;
        log('⚠️ [PAYMENT REQUEST CONTROLLER] No image found for booking $bookingId');
      }
    }
  }

  // Check if the URL is from AWS S3 (contains 'amazonaws')
  bool _isAwsS3Url(String imageUrl) {
    return imageUrl.toLowerCase().contains('amazonaws');
  }

  String _constructImageUrl(String imageUrl) {
    // If it's already a full URL, return it as is
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }

    // Handle relative URLs
    String cleanImageUrl = imageUrl;

    // Remove leading slash if present to avoid double slashes
    if (cleanImageUrl.startsWith('/')) {
      cleanImageUrl = cleanImageUrl.substring(1);
    }

    // Construct full URL using AppUrl.imageBaseUrl
    String fullUrl = '${AppUrl.imageBaseUrl}/$cleanImageUrl';
    log('🔗 [PAYMENT REQUEST CONTROLLER] Constructed image URL: $fullUrl');

    return fullUrl;
  }

  Future<void> _verifyImageAccessibility(
      String bookingId, String imageUrl) async {
    try {
      log('🔍 [PAYMENT REQUEST CONTROLLER] Verifying image accessibility for: $imageUrl');

      final token = await SecureStorageService().read(AppConstants.accessToken);

      final response = await http.get(
        Uri.parse(imageUrl),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      log('📊 [PAYMENT REQUEST CONTROLLER] Image verification response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        imageLoadStatus[bookingId] = true;
        log('✅ [PAYMENT REQUEST CONTROLLER] Image accessible for booking $bookingId');
      } else {
        imageLoadStatus[bookingId] = false;
        log('❌ [PAYMENT REQUEST CONTROLLER] Image not accessible for booking $bookingId. Status: ${response.statusCode}');
      }
    } catch (e) {
      imageLoadStatus[bookingId] = false;
      log('❌ [PAYMENT REQUEST CONTROLLER] Error verifying image for booking $bookingId: $e');
    }
  }

  String getImageUrl(String bookingId) {
    return bookingImageUrls[bookingId] ?? '';
  }

  bool hasImage(String bookingId) {
    return bookingImageUrls.containsKey(bookingId) &&
        bookingImageUrls[bookingId]!.isNotEmpty &&
        imageLoadStatus[bookingId] == true;
  }

  bool isImageLoading(String bookingId) {
    return !imageLoadStatus.containsKey(bookingId);
  }

  @override
  void onInit() {
    log('🎯 [PAYMENT REQUEST CONTROLLER] Controller initialized perfectly');
    getPaymentRequestBookings();
    super.onInit();
  }
}

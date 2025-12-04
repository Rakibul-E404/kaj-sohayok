/**
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

class PaymentRequestBookingsController extends GetxController {
  final RxList<dynamic> paymentRequestBookings = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, String> bookingImageUrls = <String, String>{}.obs;
  final RxMap<String, bool> imageLoadStatus = <String, bool>{}.obs;

  Future<void> getPaymentRequestBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      log('Starting to fetch payment request bookings...');

      final token = await SecureStorageService().read(AppConstants.accessToken);
      log('Token retrieved: ${token != null ? 'Yes' : 'No'}');

      if (token == null) {
        errorMessage.value = 'Authentication token not found. Please login again.';
        isLoading.value = false;
        log('No token found');
        return;
      }

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      log('Making API call to: ${AppUrl.paymentRequests}');

      NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.paymentRequests,
        headers: headers,
      );

      log('API Response - Status Code: ${response.statusCode}');
      log('API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('API Response Data: ${response.jsonResponse}');

        if (response.jsonResponse!['success'] == true) {
          List<dynamic> results = response.jsonResponse!['data']['attributes']['results'];
          log('Found ${results.length} payment request bookings');
          paymentRequestBookings.assignAll(results);

          // Process image URLs for all bookings
          await _processBookingImages(results);
        } else {
          String apiMessage = response.jsonResponse!['message'] ?? 'Failed to load bookings';
          errorMessage.value = apiMessage;
          log('API returned error: $apiMessage');
        }
      } else {
        String error = response.errorMessage ?? 'Something went wrong';
        errorMessage.value = error;
        log('Network error: $error');
      }
    } catch (e) {
      errorMessage.value = 'Connection error: Please check your internet connection';
      log('Exception in getPaymentRequestBookings: $e');
    } finally {
      isLoading.value = false;
      log('Loading completed');
    }
  }

  Future<void> _processBookingImages(List<dynamic> bookings) async {
    for (final booking in bookings) {
      final bookingId = booking['_ServiceBookingId'] ?? '';
      final profileImage = booking['providerId']?['profileImage'];

      if (profileImage != null && profileImage['imageUrl'] != null) {
        String imageUrl = _constructImageUrl(profileImage['imageUrl']);
        bookingImageUrls[bookingId] = imageUrl;
        log('Image URL for booking $bookingId: $imageUrl');

        // Verify if image is accessible
        await _verifyImageAccessibility(bookingId, imageUrl);
      } else {
        // Store empty string to indicate no image
        bookingImageUrls[bookingId] = '';
        imageLoadStatus[bookingId] = false;
        log('No image found for booking $bookingId');
      }
    }
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
    log('Constructed image URL: $fullUrl');

    return fullUrl;
  }

  Future<void> _verifyImageAccessibility(String bookingId, String imageUrl) async {
    try {
      log('Verifying image accessibility for: $imageUrl');

      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      log('Image verification response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        imageLoadStatus[bookingId] = true;
        log('✅ Image accessible for booking $bookingId');
      } else {
        imageLoadStatus[bookingId] = false;
        log('❌ Image not accessible for booking $bookingId. Status: ${response.statusCode}');
      }
    } catch (e) {
      imageLoadStatus[bookingId] = false;
      log('❌ Error verifying image for booking $bookingId: $e');
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
    log('PaymentRequestBookingsController initialized');
    getPaymentRequestBookings();
    super.onInit();
  }
}*/







///
///
///
/// todo:: checkign the image file  for the ''amazonaws''
///
///
///




/**
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

class PaymentRequestBookingsController extends GetxController {
  final RxList<dynamic> paymentRequestBookings = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, String> bookingImageUrls = <String, String>{}.obs;
  final RxMap<String, bool> imageLoadStatus = <String, bool>{}.obs;

  Future<void> getPaymentRequestBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      log('Starting to fetch payment request bookings...');

      final token = await SecureStorageService().read(AppConstants.accessToken);
      log('Token retrieved: ${token != null ? 'Yes' : 'No'}');

      if (token == null) {
        errorMessage.value = 'Authentication token not found. Please login again.';
        isLoading.value = false;
        log('No token found');
        return;
      }

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      log('Making API call to: ${AppUrl.paymentRequests}');

      NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.paymentRequests,
        headers: headers,
      );

      log('API Response - Status Code: ${response.statusCode}');
      log('API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('API Response Data: ${response.jsonResponse}');

        if (response.jsonResponse!['success'] == true) {
          List<dynamic> results = response.jsonResponse!['data']['attributes']['results'];
          log('Found ${results.length} payment request bookings');
          paymentRequestBookings.assignAll(results);

          // Process image URLs for all bookings
          await _processBookingImages(results);
        } else {
          String apiMessage = response.jsonResponse!['message'] ?? 'Failed to load bookings';
          errorMessage.value = apiMessage;
          log('API returned error: $apiMessage');
        }
      } else {
        String error = response.errorMessage ?? 'Something went wrong';
        errorMessage.value = error;
        log('Network error: $error');
      }
    } catch (e) {
      errorMessage.value = 'Connection error: Please check your internet connection';
      log('Exception in getPaymentRequestBookings: $e');
    } finally {
      isLoading.value = false;
      log('Loading completed');
    }
  }

  Future<void> _processBookingImages(List<dynamic> bookings) async {
    for (final booking in bookings) {
      final bookingId = booking['_ServiceBookingId'] ?? '';
      final profileImage = booking['providerId']?['profileImage'];

      if (profileImage != null && profileImage['imageUrl'] != null) {
        String imageUrl = profileImage['imageUrl'];

        // Check if it's an AWS S3 URL (contains 'amazonaws')
        if (_isAwsS3Url(imageUrl)) {
          log('AWS S3 URL detected for booking $bookingId: $imageUrl');
          bookingImageUrls[bookingId] = imageUrl;
          imageLoadStatus[bookingId] = true; // Assume AWS URLs are accessible
          log('✅ AWS S3 image set for booking $bookingId');
        } else {
          // For non-AWS URLs, construct full URL and verify accessibility
          String constructedUrl = _constructImageUrl(imageUrl);
          bookingImageUrls[bookingId] = constructedUrl;
          log('Non-AWS image URL for booking $bookingId: $constructedUrl');

          // Verify if image is accessible
          await _verifyImageAccessibility(bookingId, constructedUrl);
        }
      } else {
        // Store empty string to indicate no image
        bookingImageUrls[bookingId] = '';
        imageLoadStatus[bookingId] = false;
        log('No image found for booking $bookingId');
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
    log('Constructed image URL: $fullUrl');

    return fullUrl;
  }

  Future<void> _verifyImageAccessibility(String bookingId, String imageUrl) async {
    try {
      log('Verifying image accessibility for: $imageUrl');

      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      log('Image verification response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        imageLoadStatus[bookingId] = true;
        log('✅ Image accessible for booking $bookingId');
      } else {
        imageLoadStatus[bookingId] = false;
        log('❌ Image not accessible for booking $bookingId. Status: ${response.statusCode}');
      }
    } catch (e) {
      imageLoadStatus[bookingId] = false;
      log('❌ Error verifying image for booking $bookingId: $e');
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
    log('PaymentRequestBookingsController initialized');
    getPaymentRequestBookings();
    super.onInit();
  }
}*/






///
///
///
/// todo::: adding the payment method
///
///
///
///









/**
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

class PaymentRequestBookingsController extends GetxController {
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
      log('Starting to fetch payment request bookings...');

      final token = await SecureStorageService().read(AppConstants.accessToken);
      log('Token retrieved: ${token != null ? 'Yes' : 'No'}');

      if (token == null) {
        errorMessage.value = 'Authentication token not found. Please login again.';
        isLoading.value = false;
        log('No token found');
        return;
      }

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      log('Making API call to: ${AppUrl.paymentRequests}');

      NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.paymentRequests,
        headers: headers,
      );

      log('API Response - Status Code: ${response.statusCode}');
      log('API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('API Response Data: ${response.jsonResponse}');

        if (response.jsonResponse!['success'] == true) {
          List<dynamic> results = response.jsonResponse!['data']['attributes']['results'];
          log('Found ${results.length} payment request bookings');
          paymentRequestBookings.assignAll(results);

          // Process image URLs for all bookings
          await _processBookingImages(results);
        } else {
          String apiMessage = response.jsonResponse!['message'] ?? 'Failed to load bookings';
          errorMessage.value = apiMessage;
          log('API returned error: $apiMessage');
        }
      } else {
        String error = response.errorMessage ?? 'Something went wrong';
        errorMessage.value = error;
        log('Network error: $error');
      }
    } catch (e) {
      errorMessage.value = 'Connection error: Please check your internet connection';
      log('Exception in getPaymentRequestBookings: $e');
    } finally {
      isLoading.value = false;
      log('Loading completed');
    }
  }

  // NEW: Process payment for a booking
  Future<Map<String, dynamic>?> processPayment(String bookingId) async {
    try {
      isProcessingPayment.value = true;
      paymentErrorMessage.value = '';
      log('Starting payment process for booking: $bookingId');

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        paymentErrorMessage.value = 'Authentication token not found. Please login again.';
        isProcessingPayment.value = false;
        log('No token found for payment');
        return null;
      }

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Construct payment URL
      String paymentUrl = '${AppUrl.baseUrl}v1/service-bookings/pay/create/$bookingId';
      log('Making POST call to: $paymentUrl');

      NetworkResponse response = await NetworkCaller().postRequest(
        paymentUrl,
        headers: headers,
        body: {}, // Empty body as per your API example
      );

      log('Payment API Response - Status Code: ${response.statusCode}');
      log('Payment API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('Payment API Response Data: ${response.jsonResponse}');

        if (response.jsonResponse!['code'] == 200) {
          Map<String, dynamic> paymentData = response.jsonResponse!['data']['attributes'];
          String paymentUrl = paymentData['url'];
          String transactionId = paymentData['transactionId'];

          log('✅ Payment URL generated: $paymentUrl');
          log('Transaction ID: $transactionId');

          return {
            'url': paymentUrl,
            'transactionId': transactionId,
            'bookingId': paymentData['bookingId'],
          };
        } else {
          String apiMessage = response.jsonResponse!['message'] ?? 'Failed to process payment';
          paymentErrorMessage.value = apiMessage;
          log('Payment API returned error: $apiMessage');

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
        log('Payment Network error: $error');

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
      paymentErrorMessage.value = 'Connection error: Please check your internet connection';
      log('Exception in processPayment: $e');

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
      log('Payment process completed');
    }
  }

  Future<void> _processBookingImages(List<dynamic> bookings) async {
    for (final booking in bookings) {
      final bookingId = booking['_ServiceBookingId'] ?? '';
      final profileImage = booking['providerId']?['profileImage'];

      if (profileImage != null && profileImage['imageUrl'] != null) {
        String imageUrl = profileImage['imageUrl'];

        // Check if it's an AWS S3 URL (contains 'amazonaws')
        if (_isAwsS3Url(imageUrl)) {
          log('AWS S3 URL detected for booking $bookingId: $imageUrl');
          bookingImageUrls[bookingId] = imageUrl;
          imageLoadStatus[bookingId] = true; // Assume AWS URLs are accessible
          log('✅ AWS S3 image set for booking $bookingId');
        } else {
          // For non-AWS URLs, construct full URL and verify accessibility
          String constructedUrl = _constructImageUrl(imageUrl);
          bookingImageUrls[bookingId] = constructedUrl;
          log('Non-AWS image URL for booking $bookingId: $constructedUrl');

          // Verify if image is accessible
          await _verifyImageAccessibility(bookingId, constructedUrl);
        }
      } else {
        // Store empty string to indicate no image
        bookingImageUrls[bookingId] = '';
        imageLoadStatus[bookingId] = false;
        log('No image found for booking $bookingId');
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
    log('Constructed image URL: $fullUrl');

    return fullUrl;
  }

  Future<void> _verifyImageAccessibility(String bookingId, String imageUrl) async {
    try {
      log('Verifying image accessibility for: $imageUrl');

      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      log('Image verification response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        imageLoadStatus[bookingId] = true;
        log('✅ Image accessible for booking $bookingId');
      } else {
        imageLoadStatus[bookingId] = false;
        log('❌ Image not accessible for booking $bookingId. Status: ${response.statusCode}');
      }
    } catch (e) {
      imageLoadStatus[bookingId] = false;
      log('❌ Error verifying image for booking $bookingId: $e');
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
    log('PaymentRequestBookingsController initialized');
    getPaymentRequestBookings();
    super.onInit();
  }
}*/






///
///
///
///
/// todo:::: receiving the response form the SSL
///
///
///
///








import 'dart:developer';
// import 'dart:log';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

class PaymentRequestBookingsController extends GetxController {
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
      log('Starting to fetch payment request bookings...');

      final token = await SecureStorageService().read(AppConstants.accessToken);
      log('Token retrieved: ${token != null ? 'Yes' : 'No'}');

      if (token == null) {
        errorMessage.value = 'Authentication token not found. Please login again.';
        isLoading.value = false;
        log('No token found');
        return;
      }

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      log('Making API call to: ${AppUrl.paymentRequests}');

      NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.paymentRequests,
        headers: headers,
      );

      log('API Response - Status Code: ${response.statusCode}');
      log('API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('API Response Data: ${response.jsonResponse}');

        if (response.jsonResponse!['success'] == true) {
          List<dynamic> results = response.jsonResponse!['data']['attributes']['results'];
          log('Found ${results.length} payment request bookings');
          paymentRequestBookings.assignAll(results);

          // Process image URLs for all bookings
          await _processBookingImages(results);
        } else {
          String apiMessage = response.jsonResponse!['message'] ?? 'Failed to load bookings';
          errorMessage.value = apiMessage;
          log('API returned error: $apiMessage');
        }
      } else {
        String error = response.errorMessage ?? 'Something went wrong';
        errorMessage.value = error;
        log('Network error: $error');
      }
    } catch (e) {
      errorMessage.value = 'Connection error: Please check your internet connection';
      log('Exception in getPaymentRequestBookings: $e');
    } finally {
      isLoading.value = false;
      log('Loading completed');
    }
  }

  // Process payment for a booking
  Future<Map<String, dynamic>?> processPayment(String bookingId) async {
    try {
      isProcessingPayment.value = true;
      paymentErrorMessage.value = '';
      log('Starting payment process for booking: $bookingId');

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        paymentErrorMessage.value = 'Authentication token not found. Please login again.';
        isProcessingPayment.value = false;
        log('No token found for payment');
        return null;
      }

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Construct payment URL
      String paymentUrl = '${AppUrl.baseUrl}v1/service-bookings/pay/create/$bookingId';
      log('Making POST call to: $paymentUrl');

      NetworkResponse response = await NetworkCaller().postRequest(
        paymentUrl,
        headers: headers,
        body: {},
      );

      log('Payment API Response - Status Code: ${response.statusCode}');
      log('Payment API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('Payment API Response Data: ${response.jsonResponse}');

        if (response.jsonResponse!['code'] == 200) {
          Map<String, dynamic> paymentData = response.jsonResponse!['data']['attributes'];
          String paymentUrl = paymentData['url'];
          String transactionId = paymentData['transactionId'];

          log('✅ Payment URL generated: $paymentUrl');
          log('Transaction ID: $transactionId');

          return {
            'url': paymentUrl,
            'transactionId': transactionId,
            'bookingId': paymentData['bookingId'],
          };
        } else {
          String apiMessage = response.jsonResponse!['message'] ?? 'Failed to process payment';
          paymentErrorMessage.value = apiMessage;
          log('Payment API returned error: $apiMessage');

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
        log('Payment Network error: $error');

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
      paymentErrorMessage.value = 'Connection error: Please check your internet connection';
      log('Exception in processPayment: $e');

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
      log('Payment process completed');
    }
  }

  // Handle payment callback from SSLCommerz
  void handlePaymentCallback(Map<String, dynamic> callbackData) {
    try {
      log('Payment callback received: $callbackData');

      final String message = callbackData['message'] ?? 'Payment processed';
      final Map<String, dynamic>? data = callbackData['data'];

      if (data != null) {
        final String transactionId = data['transactionId'] ?? '';
        final String status = data['status']?.toString().toLowerCase() ?? '';
        final String amount = data['amount']?.toString() ?? '';
        final String currency = data['currency'] ?? '';

        log('Payment Details:');
        log('  Transaction ID: $transactionId');
        log('  Status: $status');
        log('  Amount: $amount $currency');
        log('  Message: $message');

        // Show success message
        Color backgroundColor = Colors.blue;
        String title = 'Payment Status';

        if (status == 'success' || status == 'valid' || status == 'completed') {
          backgroundColor = Colors.green;
          title = 'Payment Successful';
        } else if (status == 'failed' || status == 'error' || status == 'cancelled') {
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
      log('Error handling payment callback: $e');
      Get.snackbar(
        'Error',
        'Failed to process payment result',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _processBookingImages(List<dynamic> bookings) async {
    for (final booking in bookings) {
      final bookingId = booking['_ServiceBookingId'] ?? '';
      final profileImage = booking['providerId']?['profileImage'];

      if (profileImage != null && profileImage['imageUrl'] != null) {
        String imageUrl = profileImage['imageUrl'];

        // Check if it's an AWS S3 URL (contains 'amazonaws')
        if (_isAwsS3Url(imageUrl)) {
          log('AWS S3 URL detected for booking $bookingId: $imageUrl');
          bookingImageUrls[bookingId] = imageUrl;
          imageLoadStatus[bookingId] = true; // Assume AWS URLs are accessible
          log('✅ AWS S3 image set for booking $bookingId');
        } else {
          // For non-AWS URLs, construct full URL and verify accessibility
          String constructedUrl = _constructImageUrl(imageUrl);
          bookingImageUrls[bookingId] = constructedUrl;
          log('Non-AWS image URL for booking $bookingId: $constructedUrl');

          // Verify if image is accessible
          await _verifyImageAccessibility(bookingId, constructedUrl);
        }
      } else {
        // Store empty string to indicate no image
        bookingImageUrls[bookingId] = '';
        imageLoadStatus[bookingId] = false;
        log('No image found for booking $bookingId');
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
    log('Constructed image URL: $fullUrl');

    return fullUrl;
  }

  Future<void> _verifyImageAccessibility(String bookingId, String imageUrl) async {
    try {
      log('Verifying image accessibility for: $imageUrl');

      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      log('Image verification response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        imageLoadStatus[bookingId] = true;
        log('✅ Image accessible for booking $bookingId');
      } else {
        imageLoadStatus[bookingId] = false;
        log('❌ Image not accessible for booking $bookingId. Status: ${response.statusCode}');
      }
    } catch (e) {
      imageLoadStatus[bookingId] = false;
      log('❌ Error verifying image for booking $bookingId: $e');
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
    log('PaymentRequestBookingsController initialized perfectly');
    getPaymentRequestBookings();
    super.onInit();
  }
}

/// todo;:: now working
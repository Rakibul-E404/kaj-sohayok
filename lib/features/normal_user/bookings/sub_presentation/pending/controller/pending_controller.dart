import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kaz_bd/utilities/logger_util.dart';
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

class PendingBookingsController extends GetxController {
  final RxList<dynamic> pendingBookings = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, String> bookingImageUrls = <String, String>{}.obs;
  final RxMap<String, bool> imageLoadStatus = <String, bool>{}.obs;
  final RxBool isCancelling = false.obs;
  final RxString cancelErrorMessage = ''.obs;

  Future<void> getPendingBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      log('Starting to fetch pending bookings...');

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

      log('Making API call to: ${AppUrl.pendingBookings}');

      NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.pendingBookings,
        headers: headers,
      );

      log('API Response - Status Code: ${response.statusCode}');
      log('API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('API Response Data: ${response.jsonResponse}');

        if (response.jsonResponse!['success'] == true) {
          List<dynamic> results = response.jsonResponse!['data']['attributes']['results'];
          log('Found ${results.length} pending bookings');
          pendingBookings.assignAll(results);

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
      log('Exception in getPendingBookings: $e');
    } finally {
      isLoading.value = false;
      log('Loading completed');
    }
  }

  // UPDATED: Cancel booking method with PUT request
  Future<bool> cancelBooking(String bookingId) async {
    try {
      isCancelling.value = true;
      cancelErrorMessage.value = '';
      log('Starting to cancel booking: $bookingId');

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        cancelErrorMessage.value = 'Authentication token not found. Please login again.';
        isCancelling.value = false;
        log('No token found for cancellation');
        return false;
      }

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Construct the cancel URL
      String cancelUrl = '${AppUrl.baseUrl}v1/service-bookings/update-status/$bookingId/status/cancel';
      log('Making PUT call to: $cancelUrl');

      // FIXED: Use PUT request instead of POST
      NetworkResponse response = await NetworkCaller().putRequest(
        cancelUrl,
        headers: headers,
        body: {
          "status": "cancel"
          // Add any other required fields if needed by your API
        },
      );

      log('Cancel API Response - Status Code: ${response.statusCode}');
      log('Cancel API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('Cancel API Response Data: ${response.jsonResponse}');

        if (response.isSuccess) {
          log('✅ Booking $bookingId cancelled successfully');

          // Remove the cancelled booking from the list
          pendingBookings.removeWhere((booking) => booking['_ServiceBookingId'] == bookingId);

          // Show success message
          Get.back();
          Get.snackbar(
            'Success',
            'Booking cancelled successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );

          LoggerUtils.debug("uytfuyd6tuutr");
          return true;
        } else {
          String apiMessage = response.jsonResponse!['message'] ?? 'Failed to cancel booking';
          cancelErrorMessage.value = apiMessage;
          log('Cancel API returned error: $apiMessage');

          Get.snackbar(
            'Error',
            apiMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );

          return false;
        }
      } else {
        // Enhanced error handling
        String error = 'Failed to cancel booking. Status: ${response.statusCode}';
        if (response.jsonResponse != null) {
          if (response.jsonResponse!['message'] != null) {
            error = response.jsonResponse!['message'];
          }
          log('Cancel API Error Response: ${response.jsonResponse}');
        } else if (response.errorMessage != null) {
          error = response.errorMessage!;
        }

        cancelErrorMessage.value = error;
        log('Cancel Network error: $error');

        Get.snackbar(
          'Error',
          error,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        return false;
      }
    } catch (e) {
      cancelErrorMessage.value = 'Connection error: Please check your internet connection';
      log('Exception in cancelBooking: $e');

      Get.snackbar(
        'Error',
        'Connection error: Please check your internet connection',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isCancelling.value = false;
      log('Cancel booking process completed');
    }
  }

  Future<void> _processBookingImages(List<dynamic> bookings) async {
    for (final booking in bookings) {
      final bookingId = booking['_ServiceBookingId'] ?? '';
      final profileImage = booking['providerId']?['profileImage'];

      if (profileImage != null && profileImage['imageUrl'] != null) {
        String imageUrl = profileImage['imageUrl'];
        log("image:::: $imageUrl");

        // Check if it's an AWS S3 URL (contains 'amazonaws')
        if (_isAwsS3Url(imageUrl)) {
          log('AWS S3 URL detected for booking $bookingId: $imageUrl');
          bookingImageUrls[bookingId] = imageUrl;
          imageLoadStatus[bookingId] = true; // Assume AWS URLs are accessible
          log('✅ AWS S3 image set for booking $bookingId');
        } else {
          // For non-AWS URLs, construct full URL
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
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    } else {
      // Remove any leading slash to avoid double slashes in URL
      String cleanImageUrl = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;

      // Construct the URL using AppUrl.imageBaseUrl
      return '${AppUrl.imageBaseUrl}/$cleanImageUrl';
    }
  }

  Future<void> _verifyImageAccessibility(String bookingId, String imageUrl) async {
    try {
      final token = await SecureStorageService().read(AppConstants.accessToken);

      final response = await http.get(
        Uri.parse(imageUrl),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (response.statusCode == 200) {
        imageLoadStatus[bookingId] = true;
        log('Image accessible for booking $bookingId');
      } else {
        imageLoadStatus[bookingId] = false;
        log('Image not accessible for booking $bookingId. Status: ${response.statusCode}');
      }
    } catch (e) {
      imageLoadStatus[bookingId] = false;
      log('Error verifying image for booking $bookingId: $e');
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
    log('PendingBookingsController initialized');
    getPendingBookings();
    super.onInit();
  }
}



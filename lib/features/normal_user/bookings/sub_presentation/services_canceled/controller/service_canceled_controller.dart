import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

class CanceledBookingsController extends GetxController {
  final RxList<dynamic> canceledBookings = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, String> bookingImageUrls = <String, String>{}.obs;
  final RxMap<String, bool> imageLoadStatus = <String, bool>{}.obs;

  Future<void> getCanceledBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      log('Starting to fetch canceled bookings...');

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

      log('Making API call to: ${AppUrl.cancelledBookings}');

      NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.cancelledBookings,
        headers: headers,
      );

      log('API Response - Status Code: ${response.statusCode}');
      log('API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('API Response Data: ${response.jsonResponse}');

        if (response.jsonResponse!['success'] == true) {
          List<dynamic> results = response.jsonResponse!['data']['attributes']['results'];
          log('Found ${results.length} canceled bookings');
          canceledBookings.assignAll(results);

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
      log('Exception in getCanceledBookings: $e');
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
    log('CanceledBookingsController initialized');
    getCanceledBookings();
    super.onInit();
  }
}
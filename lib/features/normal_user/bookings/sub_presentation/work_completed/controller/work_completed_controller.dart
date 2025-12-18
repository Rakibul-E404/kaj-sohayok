/**
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

class WorkCompletedBookingsController extends GetxController {
  final RxList<dynamic> workCompletedBookings = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, String> bookingImageUrls = <String, String>{}.obs;
  final RxMap<String, bool> imageLoadStatus = <String, bool>{}.obs;

  Future<void> getWorkCompletedBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      log('Starting to fetch work completed bookings...');

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

      log('Making API call to: ${AppUrl.completedBookings}');

      NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.completedBookings,
        headers: headers,
      );

      log('API Response - Status Code: ${response.statusCode}');
      log('API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('API Response Data: ${response.jsonResponse}');

        if (response.jsonResponse!['success'] == true) {
          List<dynamic> results = response.jsonResponse!['data']['attributes']['results'];
          log('Found ${results.length} work completed bookings');
          workCompletedBookings.assignAll(results);

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
      log('Exception in getWorkCompletedBookings: $e');
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

  // Check if review is given for a booking
  bool isReviewGiven(String bookingId) {
    final booking = workCompletedBookings.firstWhere(
          (booking) => booking['_ServiceBookingId'] == bookingId,
      orElse: () => {},
    );

    return booking['hasReview'] == true;
  }

  @override
  void onInit() {
    log('WorkCompletedBookingsController initialized');
    getWorkCompletedBookings();
    super.onInit();
  }
}*/

///
///
///
/// todo::: upper was mine and now trying to fix as per imtiaz vai's details screen code
///
///
///

import 'dart:developer';
// import 'dart:log';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

class WorkCompletedBookingsController extends GetxController {
  final RxList<dynamic> workCompletedBookings = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, String> bookingImageUrls = <String, String>{}.obs;
  final RxMap<String, bool> imageLoadStatus = <String, bool>{}.obs;

  Future<void> getWorkCompletedBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      log('🚀 [WORK COMPLETED CONTROLLER] Starting to fetch work completed bookings...');

      final token = await SecureStorageService().read(AppConstants.accessToken);
      log('🔑 [WORK COMPLETED CONTROLLER] Token retrieved: ${token != null ? 'Yes' : 'No'}');

      if (token == null) {
        errorMessage.value =
            'Authentication token not found. Please login again.';
        isLoading.value = false;
        log('❌ [WORK COMPLETED CONTROLLER] No token found');
        return;
      }

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      log('🌐 [WORK COMPLETED CONTROLLER] Making API call to: ${AppUrl.completedBookings}');

      NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.completedBookings,
        headers: headers,
      );

      log('📥 [WORK COMPLETED CONTROLLER] API Response - Status Code: ${response.statusCode}');
      log('📊 [WORK COMPLETED CONTROLLER] API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('📋 [WORK COMPLETED CONTROLLER] Full API Response Data: ${response.jsonResponse}');

        if (response.jsonResponse!['success'] == true) {
          List<dynamic> results =
              response.jsonResponse!['data']['attributes']['results'];
          log('✅ [WORK COMPLETED CONTROLLER] Found ${results.length} work completed bookings');

          // Log the structure of first booking for debugging
          if (results.isNotEmpty) {
            final firstBooking = results.first;
            log('🔍 [WORK COMPLETED CONTROLLER] First booking structure:');
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
            log('   hasReview: ${firstBooking['hasReview']}');
          }

          workCompletedBookings.assignAll(results);

          // Process image URLs for all bookings
          await _processBookingImages(results);
        } else {
          String apiMessage =
              response.jsonResponse!['message'] ?? 'Failed to load bookings';
          errorMessage.value = apiMessage;
          log('❌ [WORK COMPLETED CONTROLLER] API returned error: $apiMessage');
        }
      } else {
        String error = response.errorMessage ?? 'Something went wrong';
        errorMessage.value = error;
        log('❌ [WORK COMPLETED CONTROLLER] Network error: $error');
      }
    } catch (e) {
      errorMessage.value =
          'Connection error: Please check your internet connection';
      log('❌ [WORK COMPLETED CONTROLLER] Exception in getWorkCompletedBookings: $e');
    } finally {
      isLoading.value = false;
      log('🏁 [WORK COMPLETED CONTROLLER] Loading completed');
    }
  }

  Future<void> _processBookingImages(List<dynamic> bookings) async {
    log('🖼️ [WORK COMPLETED CONTROLLER] Processing images for ${bookings.length} bookings');

    for (final booking in bookings) {
      final bookingId = booking['_ServiceBookingId'] ?? '';
      final profileImage = booking['providerId']?['profileImage'];

      if (profileImage != null && profileImage['imageUrl'] != null) {
        String imageUrl = profileImage['imageUrl'];
        log("🖼️ [WORK COMPLETED CONTROLLER] Booking $bookingId image: $imageUrl");

        // Check if it's an AWS S3 URL
        if (_isAwsS3Url(imageUrl)) {
          log('✅ [WORK COMPLETED CONTROLLER] AWS S3 URL detected for booking $bookingId');
          bookingImageUrls[bookingId] = imageUrl;
          imageLoadStatus[bookingId] = true;
        } else {
          // For non-AWS URLs, construct full URL
          String constructedUrl = _constructImageUrl(imageUrl);
          bookingImageUrls[bookingId] = constructedUrl;
          log('🖼️ [WORK COMPLETED CONTROLLER] Non-AWS image URL for booking $bookingId: $constructedUrl');

          // Verify if image is accessible
          await _verifyImageAccessibility(bookingId, constructedUrl);
        }
      } else {
        // Store empty string to indicate no image
        bookingImageUrls[bookingId] = '';
        imageLoadStatus[bookingId] = false;
        log('⚠️ [WORK COMPLETED CONTROLLER] No image found for booking $bookingId');
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
    log('🔗 [WORK COMPLETED CONTROLLER] Constructed image URL: $fullUrl');

    return fullUrl;
  }

  Future<void> _verifyImageAccessibility(
      String bookingId, String imageUrl) async {
    try {
      log('🔍 [WORK COMPLETED CONTROLLER] Verifying image accessibility for: $imageUrl');

      final token = await SecureStorageService().read(AppConstants.accessToken);

      final response = await http.get(
        Uri.parse(imageUrl),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      log('📊 [WORK COMPLETED CONTROLLER] Image verification response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        imageLoadStatus[bookingId] = true;
        log('✅ [WORK COMPLETED CONTROLLER] Image accessible for booking $bookingId');
      } else {
        imageLoadStatus[bookingId] = false;
        log('❌ [WORK COMPLETED CONTROLLER] Image not accessible for booking $bookingId. Status: ${response.statusCode}');
      }
    } catch (e) {
      imageLoadStatus[bookingId] = false;
      log('❌ [WORK COMPLETED CONTROLLER] Error verifying image for booking $bookingId: $e');
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

  // Check if review is given for a booking
  bool isReviewGiven(String bookingId) {
    try {
      final booking = workCompletedBookings.firstWhere(
        (booking) => booking['_ServiceBookingId'] == bookingId,
        orElse: () => {},
      );

      bool hasReview = booking['hasReview'] == true;
      log('📝 [WORK COMPLETED CONTROLLER] Review status for $bookingId: $hasReview');

      return hasReview;
    } catch (e) {
      log('❌ [WORK COMPLETED CONTROLLER] Error checking review status for $bookingId: $e');
      return false;
    }
  }

  @override
  void onInit() {
    log('🎯 [WORK COMPLETED CONTROLLER] Controller initialized');
    getWorkCompletedBookings();
    super.onInit();
  }
}

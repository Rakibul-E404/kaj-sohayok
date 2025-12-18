import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

// Image Info class to store image data
class ImageInfo {
  final String url;
  final bool isAwsUrl;
  final bool isAccessible;

  ImageInfo({
    required this.url,
    required this.isAwsUrl,
    required this.isAccessible,
  });
}

class WorkCompletedBookingsController extends GetxController {
  final RxList<dynamic> workCompletedBookings = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, ImageInfo> bookingImageInfo = <String, ImageInfo>{}.obs;
  final RxMap<String, bool> bookingReviewStatus = <String, bool>{}.obs;

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

          // Clear previous data
          bookingImageInfo.clear();
          bookingReviewStatus.clear();

          // Process image URLs for all bookings
          await _processBookingImages(results);

          // Process review status
          _processReviewStatus(results);

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

  void _processReviewStatus(List<dynamic> bookings) {
    for (final booking in bookings) {
      final bookingId = booking['_ServiceBookingId']?.toString() ?? '';
      final hasReview = booking['hasReview'] == true;
      bookingReviewStatus[bookingId] = hasReview;
      log('📝 [WORK COMPLETED CONTROLLER] Review status for $bookingId: $hasReview');
    }
  }

  Future<void> _processBookingImages(List<dynamic> bookings) async {
    log('🖼️ [WORK COMPLETED CONTROLLER] Processing images for ${bookings.length} bookings');

    for (final booking in bookings) {
      final bookingId = booking['_ServiceBookingId']?.toString() ?? '';
      final profileImage = booking['providerId']?['profileImage'];

      if (profileImage != null && profileImage['imageUrl'] != null) {
        String originalUrl = profileImage['imageUrl'];
        log("🖼️ [WORK COMPLETED CONTROLLER] Booking $bookingId image: $originalUrl");

        // Check if it's an AWS S3 URL
        bool isAwsUrl = _isAwsS3Url(originalUrl);

        String finalUrl;
        bool isAccessible = false;

        if (isAwsUrl) {
          // AWS URL - use directly
          finalUrl = originalUrl;
          isAccessible = true; // Assume AWS URLs are accessible
          log('✅ [WORK COMPLETED CONTROLLER] AWS S3 URL detected for booking $bookingId');
        } else {
          // Non-AWS URL - construct full URL
          finalUrl = _constructImageUrl(originalUrl);
          log('🖼️ [WORK COMPLETED CONTROLLER] Non-AWS image URL for booking $bookingId: $finalUrl');

          // Verify if image is accessible
          isAccessible = await _verifyImageAccessibility(bookingId, finalUrl);
        }

        // Store image info
        bookingImageInfo[bookingId] = ImageInfo(
          url: finalUrl,
          isAwsUrl: isAwsUrl,
          isAccessible: isAccessible,
        );

      } else {
        // Store empty image info
        bookingImageInfo[bookingId] = ImageInfo(
          url: '',
          isAwsUrl: false,
          isAccessible: false,
        );
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

  Future<bool> _verifyImageAccessibility(String bookingId, String imageUrl) async {
    try {
      log('🔍 [WORK COMPLETED CONTROLLER] Verifying image accessibility for: $imageUrl');

      final token = await SecureStorageService().read(AppConstants.accessToken);

      final response = await http.get(
        Uri.parse(imageUrl),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      log('📊 [WORK COMPLETED CONTROLLER] Image verification response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('✅ [WORK COMPLETED CONTROLLER] Image accessible for booking $bookingId');
        return true;
      } else {
        log('❌ [WORK COMPLETED CONTROLLER] Image not accessible for booking $bookingId. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('❌ [WORK COMPLETED CONTROLLER] Error verifying image for booking $bookingId: $e');
      return false;
    }
  }

  // Get image info for a booking
  ImageInfo getImageInfo(String bookingId) {
    return bookingImageInfo[bookingId] ?? ImageInfo(
      url: '',
      isAwsUrl: false,
      isAccessible: false,
    );
  }

  // Get image URL (backward compatibility)
  String getImageUrl(String bookingId) {
    return getImageInfo(bookingId).url;
  }

  // Check if image exists and is accessible
  bool hasImage(String bookingId) {
    final info = getImageInfo(bookingId);
    return info.url.isNotEmpty && info.isAccessible;
  }

  // Check if review is given for a booking
  bool isReviewGiven(String bookingId) {
    return bookingReviewStatus[bookingId] ?? false;
  }

  @override
  void onInit() {
    log('🎯 [WORK COMPLETED CONTROLLER] Controller initialized');
    getWorkCompletedBookings();
    super.onInit();
  }
}

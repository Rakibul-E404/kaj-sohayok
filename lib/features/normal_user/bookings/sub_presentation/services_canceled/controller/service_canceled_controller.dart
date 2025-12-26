import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kaz_bd/utilities/logger_util.dart';
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
      log('🚀 [CANCELED CONTROLLER] Starting to fetch canceled bookings...');

      final token = await SecureStorageService().read(AppConstants.accessToken);
      log('🔑 [CANCELED CONTROLLER] Token retrieved: ${token != null ? 'Yes' : 'No'}');

      LoggerUtils.info("Authentication Token Check : $token");

      if (token == null) {
        errorMessage.value =
            'Authentication token not found. Please login again.';
        isLoading.value = false;
        log('❌ [CANCELED CONTROLLER] No token found');
        return;
      }

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      log('🌐 [CANCELED CONTROLLER] Making API call to: ${AppUrl.cancelledBookings}');

      NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.cancelledBookings,
        headers: headers,
      );

      log('📥 [CANCELED CONTROLLER] API Response - Status Code: ${response.statusCode}');
      log('📊 [CANCELED CONTROLLER] API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('📋 [CANCELED CONTROLLER] Full API Response Data: ${response.jsonResponse}');

        if (response.jsonResponse!['success'] == true) {
          List<dynamic> results =
              response.jsonResponse!['data']['attributes']['results'];
          log('✅ [CANCELED CONTROLLER] Found ${results.length} canceled bookings');

          // Log the structure of first booking for debugging
          if (results.isNotEmpty) {
            final firstBooking = results.first;
            log('🔍 [CANCELED CONTROLLER] First booking structure:');
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

          canceledBookings.assignAll(results);

          // Process image URLs for all bookings
          await _processBookingImages(results);
        } else {
          String apiMessage =
              response.jsonResponse!['message'] ?? 'failed_to_load_bookings'.tr;
          errorMessage.value = apiMessage;
          log('❌ [CANCELED CONTROLLER] API returned error: $apiMessage');
        }
      } else {
        String error = response.errorMessage ?? 'something_went_wrong'.tr;
        errorMessage.value = error;
        log('❌ [CANCELED CONTROLLER] Network error: $error');
      }
    } catch (e) {
      errorMessage.value =
          'Connection error: Please check your internet connection';
      log('❌ [CANCELED CONTROLLER] Exception in getCanceledBookings: $e');
    } finally {
      isLoading.value = false;
      log('🏁 [CANCELED CONTROLLER] Loading completed');
    }
  }

  Future<void> _processBookingImages(List<dynamic> bookings) async {
    log('🖼️ [CANCELED CONTROLLER] Processing images for ${bookings.length} bookings');

    for (final booking in bookings) {
      final bookingId = booking['_ServiceBookingId'] ?? '';
      final profileImage = booking['providerId']?['profileImage'];

      if (profileImage != null && profileImage['imageUrl'] != null) {
        String imageUrl = profileImage['imageUrl'];
        log("🖼️ [CANCELED CONTROLLER] Booking $bookingId image: $imageUrl");

        // Check if it's an AWS S3 URL
        if (_isAwsS3Url(imageUrl)) {
          log('✅ [CANCELED CONTROLLER] AWS S3 URL detected for booking $bookingId');
          bookingImageUrls[bookingId] = imageUrl;
          imageLoadStatus[bookingId] = true;
        } else {
          // For non-AWS URLs, construct full URL
          String constructedUrl = _constructImageUrl(imageUrl);
          bookingImageUrls[bookingId] = constructedUrl;
          log('🖼️ [CANCELED CONTROLLER] Non-AWS image URL for booking $bookingId: $constructedUrl');

          // Verify if image is accessible
          await _verifyImageAccessibility(bookingId, constructedUrl);
        }
      } else {
        // Store empty string to indicate no image
        bookingImageUrls[bookingId] = '';
        imageLoadStatus[bookingId] = false;
        log('⚠️ [CANCELED CONTROLLER] No image found for booking $bookingId');
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
    log('🔗 [CANCELED CONTROLLER] Constructed image URL: $fullUrl');

    return fullUrl;
  }

  Future<void> _verifyImageAccessibility(
      String bookingId, String imageUrl) async {
    try {
      log('🔍 [CANCELED CONTROLLER] Verifying image accessibility for: $imageUrl');

      final token = await SecureStorageService().read(AppConstants.accessToken);

      final response = await http.get(
        Uri.parse(imageUrl),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      log('📊 [CANCELED CONTROLLER] Image verification response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        imageLoadStatus[bookingId] = true;
        log('✅ [CANCELED CONTROLLER] Image accessible for booking $bookingId');
      } else {
        imageLoadStatus[bookingId] = false;
        log('❌ [CANCELED CONTROLLER] Image not accessible for booking $bookingId. Status: ${response.statusCode}');
      }
    } catch (e) {
      imageLoadStatus[bookingId] = false;
      log('❌ [CANCELED CONTROLLER] Error verifying image for booking $bookingId: $e');
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
    log('🎯 [CANCELED CONTROLLER] Controller initialized');
    getCanceledBookings();
    super.onInit();
  }
}

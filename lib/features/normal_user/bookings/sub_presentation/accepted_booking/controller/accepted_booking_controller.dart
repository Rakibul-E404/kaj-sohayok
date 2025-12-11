import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

class AcceptedBookingsController extends GetxController {
  final RxList<dynamic> acceptedBookings = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, String> bookingImageUrls = <String, String>{}.obs;
  final RxMap<String, bool> imageLoadStatus = <String, bool>{}.obs;

  Future<void> getAcceptedBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      log('🚀 [ACCEPTED CONTROLLER] Starting to fetch accepted bookings...');

      final token = await SecureStorageService().read(AppConstants.accessToken);
      log('🔑 [ACCEPTED CONTROLLER] Token retrieved: ${token != null ? 'Yes' : 'No'}');

      if (token == null) {
        errorMessage.value = 'Authentication token not found. Please login again.';
        isLoading.value = false;
        log('❌ [ACCEPTED CONTROLLER] No token found');
        return;
      }

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      log('🌐 [ACCEPTED CONTROLLER] Making API call to: ${AppUrl.acceptedBookings}');

      NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.acceptedBookings,
        headers: headers,
      );

      log('📥 [ACCEPTED CONTROLLER] API Response - Status Code: ${response.statusCode}');
      log('📊 [ACCEPTED CONTROLLER] API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        log('📋 [ACCEPTED CONTROLLER] Full API Response Data: ${response.jsonResponse}');

        if (response.jsonResponse!['success'] == true) {
          List<dynamic> results = response.jsonResponse!['data']['attributes']['results'];
          log('✅ [ACCEPTED CONTROLLER] Found ${results.length} accepted bookings');

          // Log the structure of first booking for debugging
          if (results.isNotEmpty) {
            final firstBooking = results.first;
            log('🔍 [ACCEPTED CONTROLLER] First booking structure:');
            log('   Booking ID: ${firstBooking['_ServiceBookingId']}');
            log('   providerDetailsId exists: ${firstBooking['providerDetailsId'] != null}');
            if (firstBooking['providerDetailsId'] != null) {
              log('   providerDetailsId._ServiceProviderId: ${firstBooking['providerDetailsId']['_ServiceProviderId']}');
            }
            log('   providerId exists: ${firstBooking['providerId'] != null}');
            if (firstBooking['providerId'] != null) {
              log('   providerId._userId: ${firstBooking['providerId']['_userId']}');
              log('   providerId.name: ${firstBooking['providerId']['name']}');
            }
          }

          acceptedBookings.assignAll(results);

          // Process image URLs for all bookings
          await _processBookingImages(results);
        } else {
          String apiMessage = response.jsonResponse!['message'] ?? 'Failed to load bookings';
          errorMessage.value = apiMessage;
          log('❌ [ACCEPTED CONTROLLER] API returned error: $apiMessage');
        }
      } else {
        String error = response.errorMessage ?? 'Something went wrong';
        errorMessage.value = error;
        log('❌ [ACCEPTED CONTROLLER] Network error: $error');
      }
    } catch (e) {
      errorMessage.value = 'Connection error: Please check your internet connection';
      log('❌ [ACCEPTED CONTROLLER] Exception in getAcceptedBookings: $e');
    } finally {
      isLoading.value = false;
      log('🏁 [ACCEPTED CONTROLLER] Loading completed');
    }
  }

  Future<void> _processBookingImages(List<dynamic> bookings) async {
    log('🖼️ [ACCEPTED CONTROLLER] Processing images for ${bookings.length} bookings');

    for (final booking in bookings) {
      final bookingId = booking['_ServiceBookingId'] ?? '';
      final profileImage = booking['providerId']?['profileImage'];

      if (profileImage != null && profileImage['imageUrl'] != null) {
        String imageUrl = profileImage['imageUrl'];
        log("🖼️ [ACCEPTED CONTROLLER] Booking $bookingId image: $imageUrl");

        // Check if it's an AWS S3 URL
        if (_isAwsS3Url(imageUrl)) {
          log('✅ [ACCEPTED CONTROLLER] AWS S3 URL detected for booking $bookingId');
          bookingImageUrls[bookingId] = imageUrl;
          imageLoadStatus[bookingId] = true;
        } else {
          // For non-AWS URLs, construct full URL
          String constructedUrl = _constructImageUrl(imageUrl);
          bookingImageUrls[bookingId] = constructedUrl;
          log('🖼️ [ACCEPTED CONTROLLER] Non-AWS image URL for booking $bookingId: $constructedUrl');

          // Verify if image is accessible
          await _verifyImageAccessibility(bookingId, constructedUrl);
        }
      } else {
        // Store empty string to indicate no image
        bookingImageUrls[bookingId] = '';
        imageLoadStatus[bookingId] = false;
        log('⚠️ [ACCEPTED CONTROLLER] No image found for booking $bookingId');
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
        log('✅ [ACCEPTED CONTROLLER] Image accessible for booking $bookingId');
      } else {
        imageLoadStatus[bookingId] = false;
        log('❌ [ACCEPTED CONTROLLER] Image not accessible for booking $bookingId. Status: ${response.statusCode}');
      }
    } catch (e) {
      imageLoadStatus[bookingId] = false;
      log('❌ [ACCEPTED CONTROLLER] Error verifying image for booking $bookingId: $e');
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
    log('🎯 [ACCEPTED CONTROLLER] Controller initialized');
    getAcceptedBookings();
    super.onInit();
  }
}





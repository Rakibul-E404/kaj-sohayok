/**
// lib/.../controller/svp_job_request_screen_controller.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/app_enums.dart';
import '../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../routes/routes.dart';
import '../../../../service/network_caller.dart';
import '../../../../service/network_response.dart';
import '../../../../service/secured_storage.dart';
import '../../../../utilities/app_constants.dart';
import '../../../../utilities/app_url.dart';

class SvpJobRequestScreenController extends GetxController {
  final jobRequests = <dynamic>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    fetchJobRequests();
  }

  Future<void> fetchJobRequests() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        hasError.value = true;
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.jobRequests,
        headers: {'Authorization': 'Bearer $token'},
      );

      log('Job Requests Screen API Response: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null &&
            responseData['data']['attributes']['results'] != null) {
          jobRequests.assignAll(List<dynamic>.from(responseData['data']['attributes']['results']));
          isLoading.value = false;
        } else {
          hasError.value = true;
          errorMessage.value = 'Unexpected response format';
          isLoading.value = false;
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to load job requests';

        hasError.value = true;
        errorMessage.value = errorMsg;
        isLoading.value = false;

        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }
      }
    } catch (e, stackTrace) {
      log('Error fetching job requests: $e', error: e, stackTrace: stackTrace);
      hasError.value = true;
      errorMessage.value = 'Network error. Please check your connection.';
      isLoading.value = false;
    }
  }

  String getImageUrl(String? imageUrl) {
    final trimmed = (imageUrl ?? '').trim();
    if (trimmed.isEmpty) return '';

    if (trimmed.startsWith('http')) {
      return trimmed;
    }

    final cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    return '${AppUrl.imageBaseUrl}/$cleanPath';
  }

  String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[dateTime.month - 1];
      final day = dateTime.day;
      final year = dateTime.year;
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour < 12 ? 'AM' : 'PM';
      return '$month $day, $year  ${hour.toString().padLeft(2, '0')}:$minute$period';
    } catch (e) {
      log('Error formatting date: $e');
      return dateTimeString;
    }
  }

  String getAddress(Map<String, dynamic>? address) {
    if (address == null) return 'Address not available';
    return address['en'] ?? address['bn'] ?? 'Address not available';
  }

  void navigateToJobDetails(Map<String, dynamic> jobRequest) {
    final bookingId = jobRequest['_ServiceBookingId'] as String? ?? '';
    final userId = (jobRequest['userId'] as Map<String, dynamic>?)?['_userId'] as String? ?? '';
    log("Navigating to job details: $bookingId");

    Get.toNamed(
      Routes.svpJobDetailsScreen,
      arguments: {
        "status": JobRequestStatusEnum.pending,
        "bookingId": bookingId,
        "jobRequest": jobRequest,
        "userId": userId,
      },
    );
  }

  void showCancelConfirmation(String bookingId, String userName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Job Request'),
        content: Text('Are you sure you want to cancel the job request from $userName?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('No')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              cancelJobRequest(bookingId, userName);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> cancelJobRequest(String bookingId, String userName) async {
    // Show loader
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    final token = await SecureStorageService().read(AppConstants.accessToken);
    if (token == null) {
      Get.back();
      Get.snackbar('Error', 'Authentication required', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final response = await _networkCaller.postRequest(
      '${AppUrl.jobRequests}/$bookingId/cancel',
      headers: {'Authorization': 'Bearer $token'},
    );

    Get.back();

    if (response.isSuccess) {
      Get.snackbar('Success', 'Job request cancelled', backgroundColor: Colors.green, colorText: Colors.white);
      fetchJobRequests(); // Refresh
    } else {
      final msg = response.jsonResponse?['message'] ?? response.errorMessage ?? 'Failed to cancel';
      Get.snackbar('Error', msg, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> acceptJobRequest(String bookingId, String userName) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    final token = await SecureStorageService().read(AppConstants.accessToken);
    if (token == null) {
      Get.back();
      Get.snackbar('Error', 'Authentication required', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final response = await _networkCaller.postRequest(
      '${AppUrl.jobRequests}/$bookingId/accept',
      headers: {'Authorization': 'Bearer $token'},
    );

    Get.back();

    if (response.isSuccess) {
      Get.snackbar('Success', 'Job request accepted', backgroundColor: Colors.green, colorText: Colors.white);
      fetchJobRequests();
    } else {
      final msg = response.jsonResponse?['message'] ?? response.errorMessage ?? 'Failed to accept';
      Get.snackbar('Error', msg, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  RecentJobRequestStatusWidget buildJobRequestWidget(int index) {
    final job = jobRequests[index];
    final userData = job['userId'] as Map<String, dynamic>? ?? {};
    final address = getAddress(job['address'] as Map<String, dynamic>?);
    final bookingDateTime = job['bookingDateTime'] as String? ?? '';
    final bookingId = job['_ServiceBookingId'] as String? ?? '';
    final userName = userData['name'] as String? ?? 'Unknown User';
    final profileImage = userData['profileImage']?['imageUrl'] as String?;

    return RecentJobRequestStatusWidget(
      onTap: () => navigateToJobDetails(job),
      cancelOnTap: () => showCancelConfirmation(bookingId, userName),
      acceptOnTap: () => acceptJobRequest(bookingId, userName),
      userImage: getImageUrl(profileImage),
      userName: userName,
      location: address,
      dateTime: formatDateTime(bookingDateTime),
    );
  }
}*/










///
///
///
/// todo:: applying the full functionality
///
///
///
///





import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/app_enums.dart';
import '../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../routes/routes.dart';
import '../../../../service/network_caller.dart';
import '../../../../service/network_response.dart';
import '../../../../service/secured_storage.dart';
import '../../../../utilities/app_constants.dart';
import '../../../../utilities/app_url.dart';

class SvpJobRequestScreenController extends GetxController {
  // Reactive state variables
  final jobRequests = <dynamic>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    log('SvpJobRequestScreenController initialized - fetching job requests');
    fetchJobRequests();
  }

  Future<void> fetchJobRequests() async {
    try {
      log('fetchJobRequests() called');
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        log('No token found in storage');
        hasError.value = true;
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      log('Token found, length: ${token.length}');
      log('Making GET request to: ${AppUrl.jobRequests}');

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.jobRequests,
        headers: {'Authorization': 'Bearer $token'},
      );

      log('Job Requests API Response Status: ${response.statusCode}');
      log('Job Requests API Success: ${response.isSuccess}');

      if (response.jsonResponse != null) {
        log('Job Requests API Response Body: ${jsonEncode(response.jsonResponse)}');
      } else {
        log('Job Requests API Response Body is null');
      }

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;
        log('Parsing job requests data...');

        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null &&
            responseData['data']['attributes']['results'] != null) {

          final results = List<dynamic>.from(responseData['data']['attributes']['results']);
          log('Found ${results.length} job requests');

          // Log each job request for debugging
          for (int i = 0; i < results.length; i++) {
            final job = results[i];
            log('Job Request [$i]:');
            log('  Booking ID: ${job['_ServiceBookingId']}');
            log('  User Name: ${job['userId']?['name']}');
            log('  Booking Date: ${job['bookingDateTime']}');
            log('  Address: ${jsonEncode(job['address'])}');
          }

          jobRequests.assignAll(results);
          isLoading.value = false;
          log('Job requests loaded successfully');
        } else {
          log('Unexpected response format - Missing required fields');
          log('Response structure:');
          log('  success: ${responseData['success']}');
          log('  data: ${responseData['data'] != null ? "present" : "null"}');
          if (responseData['data'] != null) {
            log('  data.attributes: ${responseData['data']['attributes'] != null ? "present" : "null"}');
          }

          hasError.value = true;
          errorMessage.value = 'Unexpected response format';
          isLoading.value = false;
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to load job requests';

        log('API Error: $errorMsg');
        hasError.value = true;
        errorMessage.value = errorMsg;
        isLoading.value = false;

        if (response.statusCode == 401 || response.statusCode == 403) {
          log('Authentication error (${response.statusCode}) - Clearing tokens');
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }
      }
    } catch (e, stackTrace) {
      log('Error fetching job requests: $e', error: e, stackTrace: stackTrace);
      hasError.value = true;
      errorMessage.value = 'Network error. Please check your connection.';
      isLoading.value = false;
    }
  }

  String getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      log('getImageUrl: Empty image URL');
      return ''; // Empty string avoids null issues in Image.network
    }

    // If URL already points to AWS, use it directly
    if (imageUrl.contains('amazonaws')) {
      log('getImageUrl: AWS URL detected - $imageUrl');
      return imageUrl;
    }

    // Otherwise, construct full URL using base path
    final cleanPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
    final fullUrl = '${AppUrl.imageBaseUrl}/$cleanPath';
    log('getImageUrl: Constructed URL - $fullUrl');
    return fullUrl;
  }

  String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final month = _getMonthName(dateTime.month);
      final day = dateTime.day;
      final year = dateTime.year;
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour < 12 ? 'AM' : 'PM';
      return '$month $day, $year  ${hour.toString().padLeft(2, '0')}:$minute$period';
    } catch (e) {
      log('Error formatting date "$dateTimeString": $e');
      return dateTimeString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String getAddress(Map<String, dynamic>? address) {
    if (address == null) {
      log('getAddress: Address is null');
      return 'Address not available';
    }

    final englishAddress = address['en'];
    final banglaAddress = address['bn'];
    log('getAddress: English="$englishAddress", Bangla="$banglaAddress"');

    return englishAddress ?? banglaAddress ?? 'Address not available';
  }

  Future<void> cancelJobRequest(String bookingId, String userName) async {
    try {
      log('cancelJobRequest called for Booking ID: $bookingId, User: $userName');

      // Show confirmation dialog first
      Get.dialog(
        AlertDialog(
          title: const Text('Cancel Job Request'),
          content: Text('Are you sure you want to cancel the job request from $userName?'),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _performCancelJobRequest(bookingId, userName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      log('Error in cancelJobRequest: $e', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _performCancelJobRequest(String bookingId, String userName) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final token = await SecureStorageService().read(AppConstants.accessToken);
      if (token == null) {
        log('No token found for cancel request');
        Get.back();
        Get.snackbar('Error', 'Authentication required',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Use the reusable API URL method
      final cancelUrl = AppUrl.providerJobRequestCancelButton(bookingId);

      log('Making PUT request to cancel job: $cancelUrl');
      log('Full API Endpoint: $cancelUrl');
      log('Booking ID: $bookingId');
      log('Token length: ${token.length}');
      log('Sending empty JSON object as body');

      // Prepare headers
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      log('Headers: ${jsonEncode(headers)}');

      // The server expects a valid JSON body. Send empty JSON object "{}"
      final Map<String, dynamic> requestBody = {};
      log('Request body: $requestBody');

      NetworkResponse response;

      try {
        // Try with empty JSON object as Map
        response = await _networkCaller.putRequest(
          cancelUrl,
          headers: headers,
          body: requestBody,
        );
        log('PUT request made with body: {} (as Map)');
      } catch (e) {
        log('Error with body parameter as Map: $e - trying with null body');
        // Try alternative approach without body
        try {
          response = await _networkCaller.putRequest(
            cancelUrl,
            headers: headers,
            body: null,
          );
          log('PUT request made with null body');
        } catch (e2) {
          log('Both approaches failed: $e2');
          Get.back();
          Get.snackbar('Error', 'Network error: ${e2.toString()}',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      }

      Get.back();

      log('Cancel API Response Status: ${response.statusCode}');
      log('Cancel API Success: ${response.isSuccess}');

      if (response.jsonResponse != null) {
        log('Cancel API Response Body: ${jsonEncode(response.jsonResponse)}');
      } else {
        log('Cancel API Response Body is null');
      }

      if (response.isSuccess) {
        log('Job cancelled successfully - status: ${response.statusCode}');
        Get.snackbar('Success', 'Job request cancelled successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchJobRequests(); // Refresh the list
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to cancel job request';
        log('Cancel API Error: $errorMsg');

        // If we get JSON error, try a different body format
        if (errorMsg.contains('JSON') || errorMsg.contains('body')) {
          log('JSON parsing error. Trying alternative body formats...');
          await tryAlternativeCancelBodyFormats(cancelUrl, headers, bookingId, userName);
          return;
        }

        Get.snackbar('Error', errorMsg,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e, stackTrace) {
      Get.back();
      log('Error cancelling job request: $e', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to cancel job request',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> tryAlternativeCancelBodyFormats(
      String cancelUrl,
      Map<String, String> headers,
      String bookingId,
      String userName
      ) async {
    log('Trying alternative body formats for PUT cancel request');

    // List of different body formats to try as Maps
    final List<Map<String, dynamic>?> bodyFormats = [
      null, // null body
      {}, // empty map
      {'status': 'cancelled'}, // map with status
      {'cancelledBy': 'provider'}, // map with cancelled by
    ];

    for (int i = 0; i < bodyFormats.length; i++) {
      final body = bodyFormats[i];
      log('Trying format [$i]: ${body == null ? "null" : jsonEncode(body)}');

      try {
        final NetworkResponse response = await _networkCaller.putRequest(
          cancelUrl,
          headers: headers,
          body: body,
        );

        if (response.isSuccess) {
          log('SUCCESS with format: ${body == null ? "null" : jsonEncode(body)}');
          Get.snackbar('Success', 'Job request cancelled successfully',
              backgroundColor: Colors.green, colorText: Colors.white);
          fetchJobRequests();
          return;
        } else {
          log('FAILED with format: ${response.statusCode}');
          if (response.jsonResponse != null) {
            log('Error response: ${jsonEncode(response.jsonResponse)}');
          }
        }
      } catch (e) {
        log('Error with format: $e');
      }

      // Small delay between attempts
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // If all formats failed
    Get.snackbar('Error', 'Failed to cancel job request - Server configuration issue',
        backgroundColor: Colors.red, colorText: Colors.white);
    log('All body format attempts failed for booking ID: $bookingId');
  }

  Future<void> acceptJobRequest(String bookingId, String userName) async {
    try {
      log('acceptJobRequest called for Booking ID: $bookingId, User: $userName');
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final token = await SecureStorageService().read(AppConstants.accessToken);
      if (token == null) {
        log('No token found for accept request');
        Get.back();
        Get.snackbar('Error', 'Authentication required',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Use the reusable API URL method
      final acceptUrl = AppUrl.providerJobRequestAcceptButton(bookingId);

      log('Making PUT request to accept job: $acceptUrl');
      log('Full API Endpoint: $acceptUrl');
      log('Booking ID: $bookingId');
      log('Token length: ${token.length}');
      log('Sending empty JSON object as body');

      // Prepare headers
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      log('Headers: ${jsonEncode(headers)}');

      // The server expects a valid JSON body. Send empty JSON object "{}"
      final Map<String, dynamic> requestBody = {};
      log('Request body: $requestBody');

      NetworkResponse response;

      try {
        // First try with empty JSON object as Map
        response = await _networkCaller.putRequest(
          acceptUrl,
          headers: headers,
          body: requestBody,
        );
        log('PUT request made with body: {} (as Map)');
      } catch (e) {
        log('Error with body parameter as Map: $e - trying with null body');
        // Try alternative approach without body
        try {
          response = await _networkCaller.putRequest(
            acceptUrl,
            headers: headers,
            body: null,
          );
          log('PUT request made with null body');
        } catch (e2) {
          log('Both approaches failed: $e2');
          Get.back();
          Get.snackbar('Error', 'Network error: ${e2.toString()}',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      }

      Get.back();

      log('Accept API Response Status: ${response.statusCode}');
      log('Accept API Success: ${response.isSuccess}');

      if (response.jsonResponse != null) {
        log('Accept API Response Body: ${jsonEncode(response.jsonResponse)}');
      } else {
        log('Accept API Response Body is null');
      }

      if (response.isSuccess) {
        log('Job accepted successfully - status: ${response.statusCode}');
        Get.snackbar('Success', 'Job request accepted successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchJobRequests(); // Refresh the list
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to accept job request';
        log('Accept API Error: $errorMsg');

        // If we still get JSON error, try a different body format
        if (errorMsg.contains('JSON') || errorMsg.contains('body')) {
          log('JSON parsing error still occurring. Trying alternative body formats...');
          await tryAlternativeBodyFormats(acceptUrl, headers, bookingId, userName);
          return;
        }

        Get.snackbar('Error', errorMsg,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e, stackTrace) {
      Get.back();
      log('Error accepting job request: $e', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to accept job request',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> tryAlternativeBodyFormats(
      String acceptUrl,
      Map<String, String> headers,
      String bookingId,
      String userName
      ) async {
    log('Trying alternative body formats for PUT request');

    // List of different body formats to try as Maps
    final List<Map<String, dynamic>?> bodyFormats = [
      null, // null body
      {}, // empty map
      {'status': 'accepted'}, // map with status
      {'data': {}}, // nested empty map
    ];

    for (int i = 0; i < bodyFormats.length; i++) {
      final body = bodyFormats[i];
      log('Trying format [$i]: ${body == null ? "null" : jsonEncode(body)}');

      try {
        final NetworkResponse response = await _networkCaller.putRequest(
          acceptUrl,
          headers: headers,
          body: body,
        );

        if (response.isSuccess) {
          log('SUCCESS with format: ${body == null ? "null" : jsonEncode(body)}');
          Get.snackbar('Success', 'Job request accepted successfully',
              backgroundColor: Colors.green, colorText: Colors.white);
          fetchJobRequests();
          return;
        } else {
          log('FAILED with format: ${response.statusCode}');
          if (response.jsonResponse != null) {
            log('Error response: ${jsonEncode(response.jsonResponse)}');
          }
        }
      } catch (e) {
        log('Error with format: $e');
      }

      // Small delay between attempts
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // If all formats failed
    Get.snackbar('Error', 'Failed to accept job request - Server configuration issue',
        backgroundColor: Colors.red, colorText: Colors.white);
    log('All body format attempts failed for booking ID: $bookingId');
  }

  RecentJobRequestStatusWidget buildRecentJobRequestWidget(int index) {
    log('Building job request widget for index: $index');

    final jobRequest = jobRequests[index];
    log('Raw job request data: ${jsonEncode(jobRequest)}');

    final userData = jobRequest['userId'] as Map<String, dynamic>? ?? {};
    final address = getAddress(jobRequest['address'] as Map<String, dynamic>?);
    final bookingDateTime = jobRequest['bookingDateTime'] as String? ?? '';
    final bookingId = jobRequest['_ServiceBookingId'] as String? ?? '';
    final userName = userData['name'] as String? ?? 'Unknown User';
    final profileImage = userData['profileImage']?['imageUrl'] as String?;
    final userId = userData['_userId'] as String? ?? '';

    log('Parsed job request:');
    log('  Booking ID: $bookingId');
    log('  User ID: $userId');
    log('  User Name: $userName');
    log('  Profile Image: $profileImage');
    log('  Booking Date: $bookingDateTime');
    log('  Address: $address');

    return RecentJobRequestStatusWidget(
      onTap: () {
        log("Tapped on -> Card with ID: $bookingId");
        Get.toNamed(
          Routes.svpJobDetailsScreen,
          arguments: {
            "status": JobRequestStatusEnum.pending,
            "bookingId": bookingId,
            "jobRequest": jobRequest,
            "userId": userId,
          },
        );
      },
      cancelOnTap: () {
        log("Button Tapped -> Cancel for ID: $bookingId");
        cancelJobRequest(bookingId, userName);
      },
      acceptOnTap: () {
        log("Button Tapped -> Accept for ID: $bookingId");
        acceptJobRequest(bookingId, userName);
      },
      userImage: getImageUrl(profileImage),
      userName: userName,
      location: address,
      dateTime: formatDateTime(bookingDateTime),
    );
  }
}




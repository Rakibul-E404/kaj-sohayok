/**
import 'dart:developer';
import 'package:get/get.dart';
import '../../../../constants/app_enums.dart';
import '../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../routes/routes.dart';
import '../../../../service/network_caller.dart';
import '../../../../service/network_response.dart';
import '../../../../service/secured_storage.dart';
import '../../../../utilities/app_constants.dart';
import '../../../../utilities/app_url.dart';

class SvpAcceptedBookingsScreenController extends GetxController {
  final acceptedBookings = <dynamic>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    fetchAcceptedBookings();
  }

  Future<void> fetchAcceptedBookings() async {
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
        AppUrl.providerAcceptedBookings,
        headers: {'Authorization': 'Bearer $token'},
      );

      log('Accepted Bookings Screen API Response: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null &&
            responseData['data']['attributes']['results'] != null) {
          acceptedBookings.assignAll(List<dynamic>.from(responseData['data']['attributes']['results']));
          isLoading.value = false;
        } else {
          hasError.value = true;
          errorMessage.value = 'Unexpected response format';
          isLoading.value = false;
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to load accepted bookings';

        hasError.value = true;
        errorMessage.value = errorMsg;
        isLoading.value = false;

        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }
      }
    } catch (e, stackTrace) {
      log('Error fetching accepted bookings: $e', error: e, stackTrace: stackTrace);
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

  void navigateToJobDetails(Map<String, dynamic> booking) {
    final bookingId = booking['_ServiceBookingId'] as String? ?? '';
    final userId = (booking['userId'] as Map<String, dynamic>?)?['_userId'] as String? ?? '';
    log("Navigating to job details for accepted booking: $bookingId");

    Get.toNamed(
      Routes.svpJobDetailsScreen,
      arguments: {
        "status": JobRequestStatusEnum.accepted,
        "bookingId": bookingId,
        "jobRequest": booking,
        "userId": userId,
      },
    );
  }

  RecentJobRequestStatusWidget buildAcceptedBookingWidget(int index) {
    final booking = acceptedBookings[index];
    final userData = booking['userId'] as Map<String, dynamic>? ?? {};
    final address = getAddress(booking['address'] as Map<String, dynamic>?);
    final bookingDateTime = booking['bookingDateTime'] as String? ?? '';
    final bookingId = booking['_ServiceBookingId'] as String? ?? '';
    final userName = userData['name'] as String? ?? 'Unknown User';
    final profileImage = userData['profileImage']?['imageUrl'] as String?;

    return RecentJobRequestStatusWidget(
      onTap: () => navigateToJobDetails(booking),
      startWorkOnTap: () {
        log("Start Work tapped for booking: $bookingId");
        // Add real logic here if needed (e.g., call API to start work)
      },
      isJobRequestAccpted: true,
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
/// todo::: applying all the functionality
///
///
///
///

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/svp_home_screen_controller.dart';
import 'package:kaz_bd/utilities/logger_util.dart';
import '../../../../constants/app_enums.dart';
import '../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../routes/routes.dart';
import '../../../../service/network_caller.dart';
import '../../../../service/network_response.dart';
import '../../../../service/secured_storage.dart';
import '../../../../utilities/app_constants.dart';
import '../../../../utilities/app_url.dart';

class SvpAcceptedBookingsScreenController extends GetxController {
  SvpHomeScreenController svpHomeScreenController =
      Get.find<SvpHomeScreenController>();
  final jobRequests = <dynamic>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final processingStartWork = <String, bool>{}.obs; // Track loading per booking

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    log('SvpAcceptedBookingsScreenController initialized - fetching accepted bookings');
    fetchAcceptedBookings();
  }

  Future<void> fetchAcceptedBookings() async {
    try {
      log('fetchAcceptedBookings() called');
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      processingStartWork.clear();

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        log('No token found in storage');
        hasError.value = true;
        errorMessage.value = 'authentication_required_login_again'.tr;
        isLoading.value = false;
        return;
      }

      log('Token found, length: ${token.length}');
      log('Making GET request to: ${AppUrl.providerAcceptedBookings}');

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.providerAcceptedBookings,
        headers: {'Authorization': 'Bearer $token'},
      );

      log('Accepted Bookings API Response Status: ${response.statusCode}');
      log('Accepted Bookings API Success: ${response.isSuccess}');

      if (response.jsonResponse != null) {
        LoggerUtils.info(
            'Accepted Bookings API Response Body: ${jsonEncode(response.jsonResponse)}');
      } else {
        log('Accepted Bookings API Response Body is null');
      }

      if (response.isSuccess && response.jsonResponse != null) {
        await svpHomeScreenController.getServiceProviderHomeData();

        final responseData = response.jsonResponse!;
        log('Parsing accepted bookings data...');

        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null &&
            responseData['data']['attributes']['results'] != null) {
          final results =
              List<dynamic>.from(responseData['data']['attributes']['results']);
          log('Found ${results.length} accepted bookings');

          // Log each booking for debugging
          for (int i = 0; i < results.length; i++) {
            final booking = results[i];
            log('Accepted Booking [$i]:');
            log('  Booking ID: ${booking['_ServiceBookingId']}');
            log('  User Name: ${booking['userId']?['name']}');
            log('  Status: ${booking['status']}');
            log('  Booking Date: ${booking['bookingDateTime']}');
            log('  Address: ${jsonEncode(booking['address'])}');
          }

          jobRequests.assignAll(results);
          isLoading.value = false;
          log('Accepted bookings loaded successfully');
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
            'failed_to_load_accepted_bookings'.tr;

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
      log('Error fetching accepted bookings: $e',
          error: e, stackTrace: stackTrace);
      hasError.value = true;
      errorMessage.value = 'network_error_check_again'.tr;
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
    final cleanPath =
        imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
    final fullUrl = '${AppUrl.imageBaseUrl}/$cleanPath';
    log('getImageUrl: Constructed URL - $fullUrl');
    return fullUrl;
  }

  String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final month = months[dateTime.month - 1];
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

  String getAddress(Map<String, dynamic>? address) {
    if (address == null) {
      log('getAddress: Address is null');
      return 'address_not_available'.tr;
    }

    final englishAddress = address['en'];
    final banglaAddress = address['bn'];
    log('getAddress: English="$englishAddress", Bangla="$banglaAddress"');

    return englishAddress ?? banglaAddress ?? 'address_not_available'.tr;
  }

  void navigateToJobDetails(Map<String, dynamic> jobRequest) {
    final bookingId = jobRequest['_ServiceBookingId'] as String? ?? '';
    final userId = (jobRequest['userId'] as Map<String, dynamic>?)?['_userId']
            as String? ??
        '';
    log("Navigating to job details for booking ID: $bookingId");

    Get.toNamed(
      Routes.svpJobDetailsScreen,
      arguments: {
        "status": JobRequestStatusEnum.accepted,
        "bookingId": bookingId,
        "jobRequest": jobRequest,
        "userId": userId,
      },
    );
  }

  Future<void> startWork(String bookingId, int index) async {
    try {
      log('startWork called for Booking ID: $bookingId, Index: $index');

      // Set loading state for this specific booking
      processingStartWork[bookingId] = true;

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        log('No token found for start work request');
        Get.snackbar(
          'error'.tr,
          'authentication_required_login_again'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        processingStartWork[bookingId] = false;
        return;
      }

      log('Making PUT request to start work: ${AppUrl.providerStartWorkButton(bookingId)}');
      log('Token length: ${token.length}');
      log('Sending empty JSON object as body');

      // Prepare headers
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      log('Headers: ${jsonEncode(headers)}');

      // Make PUT request to start work
      final NetworkResponse response = await _networkCaller.putRequest(
        AppUrl.providerStartWorkButton(bookingId),
        headers: headers,
        body: {}, // Empty body as requested
      );

      log('Start Work API Response Status: ${response.statusCode}');
      log('Start Work API Success: ${response.isSuccess}');

      if (response.jsonResponse != null) {
        log('Start Work API Response Body: ${jsonEncode(response.jsonResponse)}');
      } else {
        log('Start Work API Response Body is null');
      }

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['code'] == 200) {
          log('Work started successfully!');

          // Show success message
          Get.snackbar(
            'success'.tr,
            'work_started_successfully'.tr,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Update the status in the local list
          if (index >= 0 && index < jobRequests.length) {
            final updatedJobRequest =
                Map<String, dynamic>.from(jobRequests[index]);
            updatedJobRequest['status'] = 'inProgress';
            jobRequests[index] = updatedJobRequest;
          }

          // Optionally refresh the list
          await fetchAcceptedBookings();
        } else {
          final errorMsg = responseData['message'] ?? 'failed_to_start_work'.tr;
          log('Start Work API Error: $errorMsg');
          Get.snackbar(
            'error'.tr,
            errorMsg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'failed_to_start_work'.tr;

        log('Start Work API Error: $errorMsg');
        Get.snackbar(
          'error'.tr,
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        // Handle authentication errors
        if (response.statusCode == 401 || response.statusCode == 403) {
          log('Authentication error - Clearing tokens');
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }
      }
    } catch (e, stackTrace) {
      log('Error starting work: $e', error: e, stackTrace: stackTrace);
      Get.snackbar(
        'network_error'.tr,
        'failed_to_start_work_check_your_connection'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Clear loading state for this booking
      processingStartWork[bookingId] = false;
    }
  }

  RecentJobRequestStatusWidget buildAcceptedBookingWidget(int index) {
    log('Building accepted booking widget for index: $index');

    final jobRequest = jobRequests[index];
    log('Raw accepted booking data: ${jsonEncode(jobRequest)}');

    final userData = jobRequest['userId'] as Map<String, dynamic>? ?? {};
    final address = getAddress(jobRequest['address'] as Map<String, dynamic>?);
    final bookingDateTime = jobRequest['bookingDateTime'] as String? ?? '';
    final bookingId = jobRequest['_ServiceBookingId'] as String? ?? '';
    final userName = userData['name'] as String? ?? 'Unknown User';
    final profileImage = userData['profileImage']?['imageUrl'] as String?;
    final currentStatus = jobRequest['status'] as String? ?? '';

    // Check if work is already started
    final isWorkStarted =
        currentStatus == 'inProgress' || currentStatus == 'completed';

    // Get loading state for this booking
    final isLoadingStartWork = processingStartWork[bookingId] ?? false;

    log('Parsed accepted booking:');
    log('  Booking ID: $bookingId');
    log('  User Name: $userName');
    log('  Status: $currentStatus');
    log('  Is Work Started: $isWorkStarted');
    log('  Is Loading Start Work: $isLoadingStartWork');

    return RecentJobRequestStatusWidget(
      onTap: () => navigateToJobDetails(jobRequest),
      startWorkOnTap: isWorkStarted ? null : () => startWork(bookingId, index),
      isJobRequestAccpted: true,
      userImage: getImageUrl(profileImage),
      userName: userName,
      location: address,
      dateTime: formatDateTime(bookingDateTime),
      // Add the new parameters here
      isStartWorkLoading: isLoadingStartWork,
      isWorkStarted: isWorkStarted,
    );
  }
}

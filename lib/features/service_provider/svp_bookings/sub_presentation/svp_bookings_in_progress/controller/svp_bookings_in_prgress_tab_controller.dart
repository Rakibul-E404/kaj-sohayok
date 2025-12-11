import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

class SvpBookingsInProgressController extends GetxController {
  final jobRequests = <dynamic>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isFetchingFormData = false.obs; // For tracking form data loading

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    fetchInProgressBookings();
  }


  Future<void> fetchInProgressBookings() async {
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
        AppUrl.providerInProgressBookings,
        headers: {'Authorization': 'Bearer $token'},
      );

      log('In Progress Bookings API Response: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null &&
            responseData['data']['attributes']['results'] != null) {

          final results = List<dynamic>.from(responseData['data']['attributes']['results']);
          jobRequests.assignAll(results);

          // PRINT ALL SERVICE BOOKING IDs
          print('\n📋 SERVICE BOOKING IDs LIST:');
          print('===============================');
          for (int i = 0; i < results.length; i++) {
            final booking = results[i];
            final bookingId = booking['_ServiceBookingId'] as String? ?? 'N/A';
            print('${i + 1}. $bookingId');
          }
          print('===============================');
          print('Total: ${results.length} booking(s)');

          isLoading.value = false;
        } else {
          hasError.value = true;
          errorMessage.value = 'Unexpected response format';
          isLoading.value = false;
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to load in-progress bookings';

        hasError.value = true;
        errorMessage.value = errorMsg;
        isLoading.value = false;

        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }
      }
    } catch (e, stackTrace) {
      log('Error fetching in-progress bookings: $e', error: e, stackTrace: stackTrace);
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

  Future<void> navigateToSubmitWorkForm(Map<String, dynamic> jobRequest) async {
    try {
      final bookingId = jobRequest['_ServiceBookingId'] as String? ?? '';
      log("Fetching work form data for booking ID: $bookingId");

      // Show loading indicator
      isFetchingFormData.value = true;

      final token = await SecureStorageService().read(AppConstants.accessToken);
      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication required. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isFetchingFormData.value = false;
        return;
      }

      // Fetch the work submission form data using GET request
      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.providerWorkSubmitForm(bookingId),
        headers: {'Authorization': 'Bearer $token'},
      );

      log('Work Form API Response: ${response.statusCode}');

      if (response.jsonResponse != null) {
        log('Work Form API Response Body: ${jsonEncode(response.jsonResponse)}');
      }

      isFetchingFormData.value = false;

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['code'] == 200) {
          final formData = responseData['data']?['attributes'] ?? {};

          log("Navigating to submit work form with data for booking ID: $bookingId");

          // Navigate to submit work form with the fetched data
          Get.toNamed(
            Routes.svpSubmitWorkFormScreen,
            arguments: {
              "bookingId": bookingId,
              "jobRequest": jobRequest,
              "formData": formData, // Pass the fetched form data
              "serviceBooking": formData['serviceBooking'],
              "additionalCosts": formData['additionalCosts'] ?? [],
              "review": formData['review'],
            },
          );
        } else {
          final errorMsg = responseData['message'] ?? 'Failed to load work form data';
          Get.snackbar(
            'Error',
            errorMsg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to load work form data';

        Get.snackbar(
          'Error',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        // Handle authentication errors
        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }
      }
    } catch (e, stackTrace) {
      isFetchingFormData.value = false;
      log('Error fetching work form data: $e', error: e, stackTrace: stackTrace);
      Get.snackbar(
        'Network Error',
        'Failed to load work form. Please check your connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  RecentJobRequestStatusWidget buildInProgressBookingWidget(int index) {
    final jobRequest = jobRequests[index];
    final userData = jobRequest['userId'] as Map<String, dynamic>? ?? {};
    final address = getAddress(jobRequest['address'] as Map<String, dynamic>?);
    final bookingDateTime = jobRequest['bookingDateTime'] as String? ?? '';
    final bookingId = jobRequest['_ServiceBookingId'] as String? ?? '';
    final userName = userData['name'] as String? ?? 'Unknown User';
    final profileImage = userData['profileImage']?['imageUrl'] as String?;

    return RecentJobRequestStatusWidget(
      isJobInProgress: true,
      onTap: null, // No tap navigation for in-progress
      submitWorkButtonOnTap: () => navigateToSubmitWorkForm(jobRequest),
      messageButtonOnTap: () {
        log("Message button tapped for booking: $bookingId");
        // Add real messaging logic here if needed
      },
      userImage: getImageUrl(profileImage),
      userName: userName,
      location: address,
      dateTime: formatDateTime(bookingDateTime),
      // Optionally show loading on the button if needed
      // isSubmitWorkLoading: isFetchingFormData.value &&
      //     jobRequest['_ServiceBookingId'] == bookingId,
    );
  }
}



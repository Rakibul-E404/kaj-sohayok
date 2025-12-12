import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/utilities/logger_util.dart';
import '../../../../../../constants/app_enums.dart';
import '../../../../../../controllers/message_screen_controller.dart';
import '../../../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

class SvpAcceptedBookingsController extends GetxController {
  final jobRequests = <dynamic>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final processingStartWork = <String, bool>{}.obs; // Track loading per booking

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
      processingStartWork.clear();

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

      log('Accepted Bookings API Response: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null &&
            responseData['data']['attributes']['results'] != null) {
          jobRequests.assignAll(List<dynamic>.from(
              responseData['data']['attributes']['results']));
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
      log('Error fetching accepted bookings: $e',
          error: e, stackTrace: stackTrace);
      hasError.value = true;
      errorMessage.value = 'Network error. Please check your connection.';
      isLoading.value = false;
    }
  }

  String getImageUrl(String? imageUrl) {
    final trimmed = (imageUrl ?? '').trim();
    if (trimmed.isEmpty) return '';

    // Treat any full URL (including AWS) as absolute
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
      // Set loading state for this specific booking
      processingStartWork[bookingId] = true;

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication required. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        processingStartWork[bookingId] = false;
        return;
      }

      // Make PUT request to start work
      final NetworkResponse response = await _networkCaller.putRequest(
        AppUrl.providerStartWorkButton(bookingId),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: {}, // Empty body as requested
      );

      log('Start Work API Response: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['code'] == 200) {
          // Show success message
          Get.snackbar(
            'Success',
            'Work started successfully!',
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
          final errorMsg = responseData['message'] ?? 'Failed to start work';
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
            'Failed to start work';

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
      log('Error starting work: $e', error: e, stackTrace: stackTrace);
      Get.snackbar(
        'Network Error',
        'Failed to start work. Please check your connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Clear loading state for this booking
      processingStartWork[bookingId] = false;
    }
  }

  RecentJobRequestStatusWidget buildAcceptedBookingWidget(int index) {
    final jobRequest = jobRequests[index];
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
      messageOnTap: () {
        Get.find<MessageScreenController>().createMessage(
            participantId: userData['_userId'] ?? '',
            name: userName,
            imageUrl: getImageUrl(profileImage) ?? '');
      },
    );
  }
}

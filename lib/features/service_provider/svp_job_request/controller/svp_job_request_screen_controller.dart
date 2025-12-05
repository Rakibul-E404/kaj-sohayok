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
}
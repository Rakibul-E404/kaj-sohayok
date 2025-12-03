/**
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../constants/app_enums.dart';
import '../../../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

class SvpJobRequestTabController extends GetxController {
  // Rx variables for reactive state management
  var jobRequests = <dynamic>[].obs;
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    fetchJobRequests();
  }

  Future<void> fetchJobRequests() async {
    try {
      // Reset state
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Get token from secure storage
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        hasError.value = true;
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      // Make API call using NetworkCaller
      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.jobRequests,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      log('Job Requests API Response: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        // Check if the response structure matches your example
        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null &&
            responseData['data']['attributes']['results'] != null) {

          jobRequests.value = List<dynamic>.from(responseData['data']['attributes']['results']);
          isLoading.value = false;
        } else {
          // Handle unexpected response structure
          hasError.value = true;
          errorMessage.value = 'Unexpected response format';
          isLoading.value = false;
        }
      } else {
        // Handle API error
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to load job requests';

        hasError.value = true;
        errorMessage.value = errorMsg;
        isLoading.value = false;

        // Handle unauthorized access (401/403)
        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }
      }
    } catch (e) {
      log('Error fetching job requests: $e');
      hasError.value = true;
      errorMessage.value = 'Network error. Please check your connection.';
      isLoading.value = false;
    }
  }

  String getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ''; // Return empty string instead of null
    }

    // Check if image URL contains 'amazonaws' - if yes, use it directly
    if (imageUrl.contains('amazonaws')) {
      return imageUrl;
    }

    // For all other cases, prepend with AppUrl.imageBaseUrl
    // Remove leading slash if present to avoid double slashes
    final cleanPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
    return '${AppUrl.imageBaseUrl}/$cleanPath';
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
      log('Error formatting date: $e');
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
    if (address == null) return 'Address not available';

    // Try to get English address first, then Bengali, then any available
    return address['en'] ?? address['bn'] ?? 'Address not available';
  }

  Future<void> cancelJobRequest(String bookingId, String userName) async {
    try {
      // Show loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Error',
          'Authentication required',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Call your cancel API endpoint
      // Replace with your actual cancel endpoint
      final cancelUrl = '${AppUrl.jobRequests}/$bookingId/cancel';

      final NetworkResponse response = await _networkCaller.postRequest(
        cancelUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      Get.back(); // Close loading dialog

      if (response.isSuccess) {
        Get.snackbar(
          'Success',
          'Job request cancelled successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh the list
        fetchJobRequests();
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to cancel job request';

        Get.snackbar(
          'Error',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      log('Error cancelling job request: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel job request',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> acceptJobRequest(String bookingId, String userName) async {
    try {
      // Show loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Error',
          'Authentication required',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Call your accept API endpoint
      // Replace with your actual accept endpoint
      final acceptUrl = '${AppUrl.jobRequests}/$bookingId/accept';

      final NetworkResponse response = await _networkCaller.postRequest(
        acceptUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      Get.back(); // Close loading dialog

      if (response.isSuccess) {
        Get.snackbar(
          'Success',
          'Job request accepted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh the list
        fetchJobRequests();
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to accept job request';

        Get.snackbar(
          'Error',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      log('Error accepting job request: $e');
      Get.snackbar(
        'Error',
        'Failed to accept job request',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showCancelConfirmationDialog(String bookingId, String userName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Job Request'),
        content: Text('Are you sure you want to cancel the job request from $userName?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await cancelJobRequest(bookingId, userName);
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
  }

  // RecentJobRequestStatusWidget functionality in controller
  RecentJobRequestStatusWidget buildRecentJobRequestWidget(int index) {
    final jobRequest = jobRequests[index];
    final userData = jobRequest['userId'] ?? {};
    final address = getAddress(jobRequest['address']);
    final bookingDateTime = jobRequest['bookingDateTime'] ?? '';
    final bookingId = jobRequest['_ServiceBookingId'] ?? '';
    final userName = userData['name'] ?? 'Unknown User';
    final profileImage = userData['profileImage']?['imageUrl'];
    final userId = userData['_userId'] ?? '';

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
        showCancelConfirmationDialog(bookingId, userName);
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
}*/












import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../constants/app_enums.dart';
import '../../../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

class SvpJobRequestTabController extends GetxController {
  // Reactive state variables
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

      log('Job Requests API Response: ${response.statusCode}');

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
    if (imageUrl == null || imageUrl.isEmpty) {
      return ''; // Empty string avoids null issues in Image.network
    }

    // If URL already points to AWS, use it directly
    if (imageUrl.contains('amazonaws')) {
      return imageUrl;
    }

    // Otherwise, construct full URL using base path
    final cleanPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
    return '${AppUrl.imageBaseUrl}/$cleanPath';
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
      log('Error formatting date: $e');
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
    if (address == null) return 'Address not available';
    return address['en'] ?? address['bn'] ?? 'Address not available';
  }

  Future<void> cancelJobRequest(String bookingId, String userName) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final token = await SecureStorageService().read(AppConstants.accessToken);
      if (token == null) {
        Get.back();
        Get.snackbar('Error', 'Authentication required',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final cancelUrl = '${AppUrl.jobRequests}/$bookingId/cancel';
      final NetworkResponse response = await _networkCaller.postRequest(
        cancelUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      Get.back();

      if (response.isSuccess) {
        Get.snackbar('Success', 'Job request cancelled successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchJobRequests();
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to cancel job request';
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

  Future<void> acceptJobRequest(String bookingId, String userName) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final token = await SecureStorageService().read(AppConstants.accessToken);
      if (token == null) {
        Get.back();
        Get.snackbar('Error', 'Authentication required',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final acceptUrl = '${AppUrl.jobRequests}/$bookingId/accept';
      final NetworkResponse response = await _networkCaller.postRequest(
        acceptUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      Get.back();

      if (response.isSuccess) {
        Get.snackbar('Success', 'Job request accepted successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchJobRequests();
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to accept job request';
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

  void showCancelConfirmationDialog(String bookingId, String userName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Job Request'),
        content: Text('Are you sure you want to cancel the job request from $userName?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('No')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await cancelJobRequest(bookingId, userName);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  RecentJobRequestStatusWidget buildRecentJobRequestWidget(int index) {
    final jobRequest = jobRequests[index];
    final userData = jobRequest['userId'] as Map<String, dynamic>? ?? {};
    final address = getAddress(jobRequest['address'] as Map<String, dynamic>?);
    final bookingDateTime = jobRequest['bookingDateTime'] as String? ?? '';
    final bookingId = jobRequest['_ServiceBookingId'] as String? ?? '';
    final userName = userData['name'] as String? ?? 'Unknown User';
    final profileImage = userData['profileImage']?['imageUrl'] as String?;
    final userId = userData['_userId'] as String? ?? '';

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
        showCancelConfirmationDialog(bookingId, userName);
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
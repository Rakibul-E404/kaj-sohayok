// lib/.../controller/svp_accepted_bookings_screen_controller.dart

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
}
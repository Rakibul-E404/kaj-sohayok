// lib/.../controller/svp_payment_request_controller.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';
import '../widgets/svp_payment_request_tab_card.dart';

class SvpPaymentRequestController extends GetxController {
  final paymentRequests = <dynamic>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    fetchPaymentRequests();
  }

  Future<void> fetchPaymentRequests() async {
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
        AppUrl.providerPaymentRequests,
        headers: {'Authorization': 'Bearer $token'},
      );

      log('Payment Requests API Response: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null &&
            responseData['data']['attributes']['results'] != null) {
          paymentRequests.assignAll(List<dynamic>.from(responseData['data']['attributes']['results']));
          isLoading.value = false;
        } else {
          hasError.value = true;
          errorMessage.value = 'Unexpected response format';
          isLoading.value = false;
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to load payment requests';

        hasError.value = true;
        errorMessage.value = errorMsg;
        isLoading.value = false;

        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }
      }
    } catch (e, stackTrace) {
      log('Error fetching payment requests: $e', error: e, stackTrace: stackTrace);
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

  SvpPaymentRequestTabCard buildPaymentRequestCard(int index) {
    final request = paymentRequests[index];
    final userData = request['userId'] as Map<String, dynamic>? ?? {};
    final address = getAddress(request['address'] as Map<String, dynamic>?);
    final bookingDateTime = request['bookingDateTime'] as String? ?? '';
    final bookingId = request['_ServiceBookingId'] as String? ?? '';
    final userName = userData['name'] as String? ?? 'Unknown User';
    final profileImage = userData['profileImage']?['imageUrl'] as String?;

    return SvpPaymentRequestTabCard(
      cardOnTap: () {
        log("Tapped -> Payment Request Card for booking: $bookingId");
        Get.toNamed(
          Routes.svpPendingPaymentRequestDetailsScreen,
          arguments: {
            "bookingId": bookingId,
            "paymentRequest": request,
          },
        );
      },
      pendingPaymentButtonOnTap: () {
        log("Pending Payment button tapped for booking: $bookingId");
        // Add payment logic here if needed
      },
      userImage: getImageUrl(profileImage),
      userName: userName,
      location: address,
      dateTime: formatDateTime(bookingDateTime),
    );
  }
}
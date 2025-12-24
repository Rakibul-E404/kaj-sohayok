// lib/.../controller/svp_bookings_canceled_controller.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';
import '../widgets/svp_bookings_canceled_card.dart';

class SvpBookingsCanceledController extends GetxController {
  late ScrollController scrollController;

  final canceledBookings = <dynamic>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();

    scrollController = ScrollController();

    // Listen to scroll events
    scrollController.addListener(() {
      if (scrollController.position.pixels <= 0) {
        // At the top, auto-refresh
        fetchCanceledBookings();
      }
    });

    fetchCanceledBookings();
  }

  Future<void> fetchCanceledBookings() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        hasError.value = true;
        errorMessage.value = 'authentication_required_login_again'.tr;
        isLoading.value = false;
        return;
      }

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.providerCancelledBookings,
        headers: {'Authorization': 'Bearer $token'},
      );

      log('Canceled Bookings API Response: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null &&
            responseData['data']['attributes']['results'] != null) {
          canceledBookings.assignAll(List<dynamic>.from(
              responseData['data']['attributes']['results']));
          isLoading.value = false;
        } else {
          hasError.value = true;
          errorMessage.value = 'unexpected_response_format'.tr;
          isLoading.value = false;
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'failed_to_load_canceled_bookings'.tr;

        hasError.value = true;
        errorMessage.value = errorMsg;
        isLoading.value = false;

        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }
      }
    } catch (e, stackTrace) {
      log('Error fetching canceled bookings: $e',
          error: e, stackTrace: stackTrace);
      hasError.value = true;
      errorMessage.value = 'network_error_check_again'.tr;
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
    if (address == null) return 'address_not_available'.tr;
    return address['en'] ?? address['bn'] ?? 'address_not_available'.tr;
  }

  SvpBookingsCanceledCard buildCanceledBookingCard(int index) {
    final booking = canceledBookings[index];
    final userData = booking['userId'] as Map<String, dynamic>? ?? {};
    final address = getAddress(booking['address'] as Map<String, dynamic>?);
    final bookingDateTime = booking['bookingDateTime'] as String? ?? '';
    final bookingId = booking['_ServiceBookingId'] as String? ?? '';
    final userName = userData['name'] as String? ?? 'unknown_user'.tr;
    final profileImage = userData['profileImage']?['imageUrl'] as String?;

    return SvpBookingsCanceledCard(
      cancelButtonOnTap: () {
        log("Cancel button tapped for booking: $bookingId (already canceled)");
        // Optional: show info dialog or re-book option
      },
      userImage: getImageUrl(profileImage),
      userName: userName,
      location: address,
      dateTime: formatDateTime(bookingDateTime),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

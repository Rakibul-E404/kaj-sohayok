import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/service/network_caller.dart';
import 'package:kaz_bd/service/network_response.dart';
import 'package:kaz_bd/utilities/app_url.dart';

import '../features/normal_user/service_preview/model/confirm_service_bookings_model.dart';
import '../gen/colors.gen.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';

class NormalUserServicePreviewScreenController extends GetxController {
  final Rxn<ServiceBookingsModel> serviceBookingModel =
      Rxn<ServiceBookingsModel>();
  RxBool isCSBLoading = false.obs;

  // Observable variables
  var bookingDateTime = ''.obs;
  var address = ''.obs;
  var lat = 0.0.obs; // Changed to double
  var long = 0.0.obs; // Changed to double
  var providerId = ''.obs;
  var hasValidLat = false.obs; // Track if latitude is valid
  var hasValidLong = false.obs; // Track if longitude is valid

  /// Section: Set Provider ID
  void setProviderId({required String pid}) {
    providerId.value = pid;
  }

  /// Section: Set Value Of Booking Date And Time
  void setBookingDateTime({required String bDateTime}) {
    bookingDateTime.value = bDateTime;
  }

  /// Section: Set Value Of Address
  void setAddress({required String addr}) {
    address.value = addr;
  }

  /// Section: Set Value of lat
  void setLatValue({required double latValue, bool isValid = true}) {
    lat.value = latValue;
    hasValidLat.value = isValid;
  }

  /// Section: Set Value of long
  void setLongValue({required double longValue, bool isValid = true}) {
    long.value = longValue;
    hasValidLong.value = isValid;
  }

  Future<void> confirmServiceBooking() async {
    // Check if ProviderID is available
    if (providerId.value.isEmpty) {
      log('Service provider id is empty');
      Get.snackbar(
        'Error',
        'Service Provider ID is missing',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
      return;
    }

    // Check if lat/long are valid (not 0.0)
    if (!hasValidLong.value) {
      log("-----Long : Longitude Value Is Missing : ---------- ${long.value}");
      Get.snackbar(
        'Error',
        'Longitude is missing',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
      return;
    }

    if (!hasValidLat.value) {
      log("-----Lat : Latitude Value Is Missing : ---------- ${lat.value}");
      Get.snackbar(
        'Error',
        'Latitude is missing',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
      return;
    }

    if (address.value.isEmpty) {
      log(
        "-----Address : Address Value Is Empty : ---------- ${address.value}",
      );
      Get.snackbar(
        'Error',
        'Address is missing',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
      return;
    }

    if (bookingDateTime.value.isEmpty) {
      log(
        "-----Booking Date & Time  : Value Is Empty : ---------- ${bookingDateTime.value}",
      );
      Get.snackbar(
        'Error',
        'Booking Date & Time is missing',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
      return;
    }

    try {
      isCSBLoading.value = true;

      // Get authorization token
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      // Create request body - API expects lat/long as strings
      final Map<String, dynamic> requestBody = {
        "bookingDateTime":
            bookingDateTime.value, // Format: "2025-12-03T10:55:00"
        "address": address.value,
        "lat": lat.value.toString(), // Convert double to string for API
        "long": long.value.toString(), // Convert double to string for API
        "providerId": providerId.value,
      };

      log('Sending booking request: $requestBody');

      final NetworkResponse response = await NetworkCaller().postRequest(
        AppUrl.bookAService,
        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
        body: requestBody,
      );

      log(
        'Booking response: ${response.statusCode} - ${response.jsonResponse}',
      );

      if (response.isSuccess == true && response.jsonResponse != null) {
        final data = ServiceBookingsModel.fromJson(response.jsonResponse!);

        if (data.success == true && data.data?.attributes != null) {
          // Success - store the response model
          serviceBookingModel.value = data;

          Get.snackbar(
            'Success',
            data.message ?? 'Booking confirmed successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // You can navigate to next screen or show success message
          log(
            'Booking created successfully: ${data.data?.attributes?.serviceBookingId}',
          );
        } else {
          // API returned success: false
          Get.snackbar(
            'Error',
            data.message ?? 'Failed to create booking',
            backgroundColor: AppColors.cee3333,
            colorText: AppColors.cFFFFFF,
          );
        }
      } else {
        // Network error
        Get.snackbar(
          'Error',
          'Failed to create booking. Status: ${response.statusCode}',
          backgroundColor: AppColors.cee3333,
          colorText: AppColors.cFFFFFF,
        );
      }
    } catch (e) {
      log('Exception in confirmServiceBooking: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
    } finally {
      isCSBLoading.value = false;
    }
  }

  // Reset all values
  void reset() {
    bookingDateTime.value = '';
    address.value = '';
    setLatValue(latValue: 0.0, isValid: false); // Reset to 0.0 and mark as invalid
    setLongValue(longValue: 0.0, isValid: false); // Reset to 0.0 and mark as invalid
    providerId.value = '';
    serviceBookingModel.value = null;
  }
}

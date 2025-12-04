import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/service/network_caller.dart';
import 'package:kaz_bd/service/network_response.dart';
import 'package:kaz_bd/utilities/app_url.dart';

import '../features/normal_user/service_preview/model/confirm_service_bookings_model.dart';
import '../features/normal_user/service_preview/model/service_data_preview_model.dart';
import '../gen/colors.gen.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';

class NormalUserServicePreviewScreenController extends GetxController {
  ///-------------------------> Section : Common Api Segment <-----------------------///
  /// Section: Set Provider ID
  var providerId = ''.obs;
  void setProviderId({required String pid}) {
    providerId.value = pid;
  }

  ///-------------------------> Section : Service Data Preview Api Segment <-----------------------///

  RxBool isServicePreViewDataLoading = false.obs;
  Rxn<ServiceDataPreviewModel> serviceDataPreview =
      Rxn<ServiceDataPreviewModel>();

  Future<void> getServiceDataPreview() async {
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

    try {
      isServicePreViewDataLoading.value = true;
      // Get authorization token
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.getServiceDataPreview(userId: providerId.value),
        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = ServiceDataPreviewModel.fromJson(
          response.jsonResponse!,
        );

        if (responseData.code == 200 &&
            responseData.data?.attributes?.result?.isNotEmpty == true) {
          serviceDataPreview.value = responseData;
          log('😃😃Service data loaded successfully');
          log('😃😃Json Response Below');
          log('${serviceDataPreview.value = responseData}');
        } else {
          Get.snackbar(
            'Information',
            responseData.message ?? 'No Service Details Available!',
            backgroundColor: AppColors.cee3333,
            colorText: AppColors.cFFFFFF,
          );
        }
      } else {
        Get.snackbar(
          'Connection Error',
          response.errorMessage ?? 'Failed to connect to the server!',
          backgroundColor: AppColors.cee3333,
          colorText: AppColors.cFFFFFF,
        );
      }
    } catch (e) {
      // JSON parsing error
      log('🥸🥸JSON parsing error: $e');
      Get.snackbar(
        'Data Error',
        'Failed to process service information',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
    } finally {
      isServicePreViewDataLoading.value = false;
    }
  }

  ///-------------------------> Section : Service Data Getters <-----------------------///

  /// Get the first service image URL from attachmentsForGallery
  String? get serviceImage {
    log('serviceImage getter called');
    final result = serviceDataPreview.value?.data?.attributes?.result;
    if (result != null && result.isNotEmpty) {
      log('Service data is not empty, count: ${result.length}');
      final attachments = result.first.attachmentsForGallery;
      if (attachments != null && attachments.isNotEmpty) {
        log('Attachments found: ${attachments.length}');
        log('First attachment: ${attachments.first.attachment}');
        return attachments.first.attachment;
      } else {
        log('No attachments found or attachments is null');
      }
    } else {
      log('Service data is null or empty');
    }
    return null;
  }

  /// Get the English service name
  String? get serviceName {
    final result = serviceDataPreview.value?.data?.attributes?.result;
    if (result != null && result.isNotEmpty) {
      return result.first.serviceName?.en;
    }
    return null;
  }

  /// Get the Bengali service name
  String? get serviceNameBn {
    final result = serviceDataPreview.value?.data?.attributes?.result;
    if (result != null && result.isNotEmpty) {
      return result.first.serviceName?.bn;
    }
    return null;
  }

  /// Get the service starting price
  double? get serviceStartPrice {
    final result = serviceDataPreview.value?.data?.attributes?.result;
    if (result != null && result.isNotEmpty) {
      return result.first.startPrice;
    }
    return null;
  }

  List<Attachment>? get galleryAttachments {
    final result = serviceDataPreview.value?.data?.attributes?.result;
    if (result != null && result.isNotEmpty) {
      return result.first.attachmentsForGallery;
    }
    return null;
  }

  /////-------------------------> Section : Service Booking Api Code Segment <-----------------------///
  final Rxn<ServiceBookingsModel> serviceBookingModel =
      Rxn<ServiceBookingsModel>();
  RxBool isCSBLoading = false.obs;

  // Observable variables
  var bookingDateTime = ''.obs;
  var address = ''.obs;
  var lat = 0.0.obs; // Changed to double
  var long = 0.0.obs; // Changed to double

  var hasValidLat = false.obs; // Track if latitude is valid
  var hasValidLong = false.obs; // Track if longitude is valid

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
    setLatValue(
      latValue: 0.0,
      isValid: false,
    ); // Reset to 0.0 and mark as invalid
    setLongValue(
      longValue: 0.0,
      isValid: false,
    ); // Reset to 0.0 and mark as invalid
    providerId.value = '';
    serviceBookingModel.value = null;
  }
}

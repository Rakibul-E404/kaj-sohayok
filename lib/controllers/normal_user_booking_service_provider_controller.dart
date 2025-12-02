// import 'dart:developer';

// import 'package:get/get.dart';
// import 'package:kaz_bd/service/network_caller.dart';
// import 'package:kaz_bd/service/network_response.dart';
// import 'package:kaz_bd/utilities/app_url.dart';

// import '../gen/colors.gen.dart';
// import '../service/secured_storage.dart';
// import '../utilities/app_constants.dart';

// class NormalUserBookingServiceProviderController extends GetxController {
//   RxBool isLoading = false.obs;
//   ////Service Provider ID
//   var serviceProviderId = ''.obs;
//   void setServiceProviderId({required String svpId}) {
//     serviceProviderId.value = svpId;
//     getProviderBookingSlotAvailability();
//   }

//   Future<void> getProviderBookingSlotAvailability() async {
//     if (serviceProviderId.isEmpty) {
//       log('Service provider id is empty');
//       Get.snackbar(
//         'Error',
//         'Failed to get details of the service: Provider ID is missing',
//         backgroundColor: AppColors.cee3333,
//         colorText: AppColors.cFFFFFF,
//       );
//       return;
//     }

//     try {
//       isLoading.value = true;
//       // Create request body
//       final Map<String, dynamic> requestBody = {
//         "bookingDateTime": formattedDateTime,
//         "providerId": serviceProviderId.value,
//       };

//       // Get the authorization token
//       final String token =
//           await SecureStorageService().read(AppConstants.accessToken) ?? '';

//       NetworkResponse response = await NetworkCaller().postRequest(
//         AppUrl.checkProbiderScheduleAvailability,
//         headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
//         body: requestBody,
//       );
//     } catch (e) {
//       log('Exception in showSpecificServiceDetails: $e');
//       Get.snackbar(
//         'Error',
//         'Something went wrong: $e',
//         backgroundColor: AppColors.cee3333,
//         colorText: AppColors.cFFFFFF,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/calender_controller.dart';
import 'package:kaz_bd/service/network_caller.dart';
import 'package:kaz_bd/service/network_response.dart';
import 'package:kaz_bd/utilities/app_url.dart';

import '../features/normal_user/booking_date/model/provider_schedule_check_before_slot_booking_model.dart';
import '../gen/colors.gen.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';

class NormalUserBookingServiceProviderController extends GetxController {
  RxBool isLoading = false.obs;

  // Service Provider ID
  var serviceProviderId = ''.obs;

  // Store availability response
  Rx<ProviderSchedulCheckBeforeSlotBookingModel?> availabilityResponse =
      Rx<ProviderSchedulCheckBeforeSlotBookingModel?>(null);

  void setServiceProviderId({required String svpId}) {
    log('setServiceProviderId called with: $svpId');
    serviceProviderId.value = svpId;
    log('serviceProviderId after setting: ${serviceProviderId.value}');
  }

  // Main method to check availability using CalendarController
  Future<void> checkAvailabilityWithCalendarController() async {
    log(
      'checkAvailabilityWithCalendarController - serviceProviderId: ${serviceProviderId.value}',
    );

    if (serviceProviderId.isEmpty) {
      log('Service provider id is empty');
      Get.snackbar(
        'Error',
        'Provider ID is missing',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
      return;
    }

    try {
      isLoading.value = true;
      availabilityResponse.value = null;

      // Get CalendarController instance
      final CalendarController calendarController =
          Get.find<CalendarController>();

      // Get the formatted date/time from CalendarController
      final formattedDateTime = calendarController.apiFormattedDateTime;

      // Check if date/time is in future
      if (!calendarController.isFutureDateTime) {
        Get.snackbar(
          'Invalid Selection',
          'Please select a future date and time',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      log(
        'Checking availability with CalendarController date/time: $formattedDateTime',
      );
      log('Checking availability with providerId: ${serviceProviderId.value}');

      // Create request body
      final Map<String, dynamic> requestBody = {
        "bookingDateTime": formattedDateTime,
        "providerId": serviceProviderId.value,
      };

      log('Request body being sent: $requestBody');

      // Get the authorization token
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      NetworkResponse response = await NetworkCaller().postRequest(
        AppUrl.checkProbiderScheduleAvailability,

        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
        body: requestBody,
      );

      log(
        'Availability Check Response: ${response.statusCode} - ${response.jsonResponse}',
      );

      if (response.jsonResponse != null) {
        log('Full API response: ${response.jsonResponse}');
      } else {
        log('API response is null');
      }

      if (response.isSuccess && response.jsonResponse != null) {
        // Parse response using your model
        availabilityResponse.value =
            ProviderSchedulCheckBeforeSlotBookingModel.fromJson(
              response.jsonResponse!,
            );

        if (availabilityResponse.value?.success == true) {
          Get.snackbar(
            'Available',
            availabilityResponse.value?.message ??
                'Provider is available at this time',
            backgroundColor: Colors.green,
            colorText: AppColors.cFFFFFF,
            duration: Duration(seconds: 2),
          );
        } else {
          Get.snackbar(
            'Not Available',
            availabilityResponse.value?.message ??
                'Provider not available at this time',
            backgroundColor: AppColors.cee3333,
            colorText: AppColors.cFFFFFF,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to check availability',
          backgroundColor: AppColors.cee3333,
          colorText: AppColors.cFFFFFF,
        );
      }
    } catch (e) {
      log('Exception in checkAvailabilityWithCalendarController: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Reset availability status
  void resetAvailability() {
    availabilityResponse.value = null;
  }
}

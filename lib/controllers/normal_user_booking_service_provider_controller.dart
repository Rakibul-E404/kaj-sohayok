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
  var providerID = ''.obs;

  // Store availability response
  Rx<ProviderSchedulCheckBeforeSlotBookingModel?> availabilityResponse =
      Rx<ProviderSchedulCheckBeforeSlotBookingModel?>(null);

  void setProviderId({required String pvID}) {
    log('setProviderId called with: $pvID from Booking Date Screen');
    providerID.value = pvID;
    log('ProviderId after setting: ${providerID.value}');
  }

  // Main method to check availability using CalendarController
  Future<void> checkAvailabilityWithCalendarController() async {
    log(
      'checkAvailabilityWithCalendarController - serviceProviderId: ${providerID.value}',
    );

    if (providerID.isEmpty) {
      log('Service provider id is empty');
      _showSnackbar(
        title: 'Missing Information',
        message: 'Please select a service provider first',
        backgroundColor: Colors.orange,
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
        _showSnackbar(
          title: 'Invalid Time Selection',
          message: 'Please select a future date and time for booking',
          backgroundColor: Colors.orange,
        );
        return;
      }

      // Get the authorization token
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      log('📅 Checking availability with CalendarController date/time: $formattedDateTime');
      log('👤 Checking availability with providerId: ${providerID.value}');
      log('🔗 API URL being called: ${AppUrl.checkProbiderScheduleAvailability}');
      log('🔑 Token availability: ${token.isNotEmpty ? "YES" : "NO"}');

      // Create request body
      final Map<String, dynamic> requestBody = {
        "bookingDateTime": formattedDateTime,
        "providerId": providerID.value,
      };

      log('📤 Request body being sent: $requestBody');

      NetworkResponse response = await NetworkCaller().postRequest(
        AppUrl.checkProbiderScheduleAvailability,
        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
        body: requestBody,
      );

      log('📥 Availability Check Response Status: ${response.statusCode}');
      log('📥 Availability Check Response Body: ${response.jsonResponse}');

      if (response.jsonResponse != null) {
        log('✅ Full API response: ${response.jsonResponse}');
        log('📊 Response has "success": ${response.jsonResponse!.containsKey('success')}');
        log('📊 Response has "message": ${response.jsonResponse!.containsKey('message')}');
        log('📊 Response has "code": ${response.jsonResponse!.containsKey('code')}');
        log('📊 Response has "data": ${response.jsonResponse!.containsKey('data')}');
      } else {
        log('❌ API response is null');
      }

      if (response.isSuccess && response.jsonResponse != null) {
        // Parse response using your model
        availabilityResponse.value =
            ProviderSchedulCheckBeforeSlotBookingModel.fromJson(
          response.jsonResponse!,
        );

        // Get the message from API response
        final apiMessage = availabilityResponse.value?.message;
        final isAvailable = availabilityResponse.value?.success == true;

        if (isAvailable) {
          _showSnackbar(
            title: '✅ Available',
            message: apiMessage ?? 'This time slot is available for booking',
            backgroundColor: Colors.green,
            duration: 3,
          );
        } else {
          _showSnackbar(
            title: '⏰ Not Available',
            message:
                apiMessage ?? 'Provider is not available at the selected time',
            backgroundColor: AppColors.cee3333,
            duration: 3,
          );
        }
      } else {
        // Check if there's an error message in the response
        final errorMessage = _extractErrorMessage(response.jsonResponse);
        _showSnackbar(
          title: 'Provider Unavailable',
          message:
              errorMessage ?? 'Unable to check availability. Please try again',
          backgroundColor: AppColors.cee3333,
        );
      }
    } catch (e) {
      log('Exception in checkAvailabilityWithCalendarController: $e');
      _showSnackbar(
        title: 'Something Went Wrong',
        message: 'Please check your connection and try again',
        backgroundColor: AppColors.cee3333,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to extract error message from response
  String? _extractErrorMessage(Map<String, dynamic>? jsonResponse) {
    if (jsonResponse == null) return null;

    try {
      // Try to get message from response
      if (jsonResponse.containsKey('message')) {
        return jsonResponse['message'].toString();
      }

      // Try to get error from response
      if (jsonResponse.containsKey('error')) {
        return jsonResponse['error'].toString();
      }

      // Try to parse as ProviderSchedulCheckBeforeSlotBookingModel
      final model = ProviderSchedulCheckBeforeSlotBookingModel.fromJson(
        jsonResponse,
      );
      return model.message;
    } catch (e) {
      return null;
    }
  }

  // Helper method for consistent snackbar styling
  void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    int duration = 2,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: Duration(seconds: duration),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(10),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      icon: Icon(
        backgroundColor == Colors.green
            ? Icons.check_circle
            : backgroundColor == Colors.orange
                ? Icons.warning
                : Icons.error,
        color: Colors.white,
      ),
    );
  }

  // Reset availability status
  void resetAvailability() {
    availabilityResponse.value = null;
  }
}

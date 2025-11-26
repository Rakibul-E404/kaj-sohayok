import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/service/secured_storage.dart';
import 'package:kaz_bd/utilities/app_constants.dart';

import '../routes/routes.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';

class OtpValidationController extends GetxController {
  var pin = ''.obs;

  // Timer
  var secondsRemaining = 30.obs;
  Timer? _timer;
  RxBool isOtpExpired = false.obs;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }



  // Called when OTP completed
  void onCompleted(String value) {
    pin.value = value;
    print('Entered OTP: $value');
  }

  // Start countdown timer
  void startTimer() {
    _timer?.cancel();
    secondsRemaining.value = 30;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
        isOtpExpired.value = true;
      }
    });
  }

  /// ===========> Sign up ==============>
  final RxBool loader = false.obs;

  handleSendOtpSignUp({required String email}) async {
    try {
      loader.value = true;
      final String verificationToken =
          await SecureStorageService().read(AppConstants.verificationToken) ??
          '';
      final Map<String, dynamic> registrationOTPForm = <String, dynamic>{
        "email": "${email}",
        "otp": "${pin.value}",
        "token": verificationToken,
      };
       final NetworkResponse postResponse = await NetworkCaller().postRequest(
        AppUrl.registerUserEmailVerify,
        body: registrationOTPForm,
      );
       LoggerUtils.debug(postResponse.jsonResponse);
      if (postResponse.isSuccess) {
        // LoggerUtils.debug(registrationOTPForm);

        await SecureStorageService().write(
          AppConstants.accessToken,
          postResponse
                  .jsonResponse?['data']['attributes']['result']['tokens']['accessToken'] ??
              '',
        );
        await SecureStorageService().write(
          AppConstants.refreshToken,
          postResponse
                  .jsonResponse?['data']['attributes']['result']['tokens']['refreshToken'] ??
              '',
        );
        Get.offAllNamed(Routes.signInScreen);
        // Get.toNamed(
        //   Routes.verifyOtpScreen,
        //   arguments: <String, String>{'email': emailTEController.text},
        // );
      } else {
        // ToastManager.show(
        //   message: postResponse.jsonResponse?['message'] ?? 'Error Occurred !!!',
        //   backgroundColor: AppColors.red,
        //   textColor: AppColors.white,
        //   icon: const Icon(CupertinoIcons.info, color: AppColors.white),
        // );
        Get.snackbar(
          'title',
          postResponse.jsonResponse?['message'],
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      // ToastManager.show(
      //   message: e.toString(),
      //   backgroundColor: AppColors.red,
      //   textColor: AppColors.white,
      // );
      LoggerUtils.debug("Exception : ${e.toString()}");
    } finally {
      // clearTextFields();
      loader.value = false;
    }
  }
  handleSendOtpForgotPassword({required String email}) async {
    try {
      loader.value = true;
      final String verificationToken =
          await SecureStorageService().read(AppConstants.verificationToken) ??
          '';
      final Map<String, dynamic> registrationOTPForm = <String, dynamic>{
        "email": "${email}",
        "otp": "${pin.value}",
        "token": verificationToken,
      };
       final NetworkResponse postResponse = await NetworkCaller().postRequest(
        AppUrl.registerUserEmailVerify,
        body: registrationOTPForm,
      );
       LoggerUtils.debug(postResponse.jsonResponse);
      if (postResponse.isSuccess) {
        // LoggerUtils.debug(registrationOTPForm);

        await SecureStorageService().write(
          AppConstants.accessToken,
          postResponse
                  .jsonResponse?['data']['attributes']['result']['tokens']['accessToken'] ??
              '',
        );
        await SecureStorageService().write(
          AppConstants.refreshToken,
          postResponse
                  .jsonResponse?['data']['attributes']['result']['tokens']['refreshToken'] ??
              '',
        );
        Get.offAllNamed(Routes.signInScreen);
        // Get.toNamed(
        //   Routes.verifyOtpScreen,
        //   arguments: <String, String>{'email': emailTEController.text},
        // );
      } else {
        // ToastManager.show(
        //   message: postResponse.jsonResponse?['message'] ?? 'Error Occurred !!!',
        //   backgroundColor: AppColors.red,
        //   textColor: AppColors.white,
        //   icon: const Icon(CupertinoIcons.info, color: AppColors.white),
        // );
        Get.snackbar(
          'title',
          postResponse.jsonResponse?['message'],
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      // ToastManager.show(
      //   message: e.toString(),
      //   backgroundColor: AppColors.red,
      //   textColor: AppColors.white,
      // );
      LoggerUtils.debug("Exception : ${e.toString()}");
    } finally {
      // clearTextFields();
      loader.value = false;
    }
  }

  // Dispose timer
  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

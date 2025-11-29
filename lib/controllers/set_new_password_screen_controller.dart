import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../gen/colors.gen.dart';
import '../routes/routes.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';

class SetNewPasswordScreenController extends GetxController {
  TextEditingController newPaswordController = TextEditingController();
  TextEditingController confirmPaswordController = TextEditingController();

  ///Function To Set Password Visibility
  RxBool isVisible = false.obs;

  void setPasswrdVisibility() {
    isVisible.value = !isVisible.value;
  }

  ///Function To Set Confirm Password Visibility
  RxBool isConfirmPasswordVisible = false.obs;

  void setConfirmPasswrdVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// =========  TOKY ========= >
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool loader = false.obs;

  Future<void> handleResetPassword({
    required String email,
    required String otpCode,
  }) async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }
      loader.value = true;

      final Map<String, dynamic> loginForm = <String, dynamic>{
        "email": email,
        "otp": otpCode,
        "password": newPaswordController.text,
      };
      LoggerUtils.warning(loginForm);
      final NetworkResponse postResponse = await NetworkCaller().postRequest(
        AppUrl.resetPassword,
        body: loginForm,
      );
      if (postResponse.isSuccess) {
        LoggerUtils.debug(postResponse.jsonResponse);

        Get.snackbar(
          'Success',
          postResponse.jsonResponse?['message'],
          backgroundColor: AppColors.c778beb,
        );
        Get.offAllNamed(Routes.signInScreen);
      } else {
        LoggerUtils.debug(postResponse.jsonResponse?['message']);

        Get.snackbar(
          'Error',
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
}

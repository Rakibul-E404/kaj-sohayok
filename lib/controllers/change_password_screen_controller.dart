import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../gen/colors.gen.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';

class ChangePasswordScreenController extends GetxController {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  ///Function To Set Old Password Visibility
  RxBool isVisibleOldPassword = false.obs;

  void setOldPasswrdVisibility() {
    isVisibleOldPassword.value = !isVisibleOldPassword.value;
  }

  ///Function To Set Old Password Visibility
  RxBool isVisibleNewPassword = false.obs;

  void setNewPasswrdVisibility() {
    isVisibleNewPassword.value = !isVisibleNewPassword.value;
  }

  ///Function To Set Old Password Visibility
  RxBool isVisibleConfirmPassword = false.obs;

  void setConfirmPasswrdVisibility() {
    isVisibleConfirmPassword.value = !isVisibleConfirmPassword.value;
  }

  /// ============> USER CHANGE PASSWORD TOKY =============>
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool loader = false.obs;

  Future<void> handleChangePassword() async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }
      loader.value = true;
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';
      final Map<String, dynamic> loginForm = <String, dynamic>{
        "currentPassword": oldPasswordController.text,
        "newPassword": confirmPasswordController.text,
      };
      final NetworkResponse postResponse = await NetworkCaller().postRequest(
        AppUrl.changePassword,
        body: loginForm,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (postResponse.isSuccess) {
        LoggerUtils.debug(postResponse.jsonResponse);
        Get.snackbar(
          'Success',
          postResponse.jsonResponse?['message'],
          backgroundColor: AppColors.c778beb,
          colorText: Colors.white,
        );
        Navigator.pop(Get.context!);
      } else {
        LoggerUtils.debug(postResponse.jsonResponse?['message']);

        Get.snackbar(
          'Error',
          postResponse.jsonResponse?['message'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
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

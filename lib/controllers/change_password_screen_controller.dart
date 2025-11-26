import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

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

}

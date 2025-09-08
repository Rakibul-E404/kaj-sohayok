import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

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
}

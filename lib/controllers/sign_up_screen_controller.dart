import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kaz_bd/constants/appList.dart';

class SignUpScreenController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /// Function to pick date
  Future<void> pickDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dateOfBirthController.text = DateFormat('MM/dd/yyyy').format(picked);
    }
  }

  ///Function To Pick Gender
  String? selectedGender;

  void setGender(String? value) {
    selectedGender = value;
    if (value != null) {
      genderController.text = value;
    }
    update(); // triggers UI update
  }

  ///Function To Set Password Visibility
  RxBool isVisible = false.obs;

  void setPasswrdVisibility() {
    isVisible.value = !isVisible.value;
  }

  ///Function To Set CheckBox Value of Terms & Conditions
  RxBool isCheckboxTaped = false.obs;
  void setCheckboxValue(bool newValue) {
    isCheckboxTaped.value = newValue;
  }

  ///Function to Show IconFlag at MobileNumberFormField
  RxBool isMobileNumberEmpty = true.obs;
}

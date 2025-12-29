import 'package:get/get_utils/get_utils.dart';

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'please_enter_password'.tr;
  }
  if (value.length < 8) {
    return 'password_must_be_at_lease_eight_charecters'.tr;
  }
  return null;
}

// Confirm Password Validator
String? confirmPasswordValidator(String? value, String? originalPassword) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }
  if (value != originalPassword) {
    return 'Passwords do not match';
  }
  return null;
}

String? validatePhoneNumber(String? value) {
  // Regular expression for validating international phone numbers
  // String pattern = r'^\+?([0-9]{1,3})?[-.●\s]?([0-9]{1,4})[-.●\s]?([0-9]{1,4})[-.●\s]?([0-9]{1,9})$';
  // RegExp regExp = RegExp(pattern);

  // if (value == null || value.isEmpty) {
  //   return 'Please enter a phone number';
  // }
  // else if (!regExp.hasMatch(value)) {
  //   return 'Please enter a valid phone number';
  // }
  return null;
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kaz_bd/constants/appList.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/service/get_storage.dart';

import '../routes/routes.dart';
import '../service/location/location_controller.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';
import '../utilities/enum.dart';
import '../utilities/logger_util.dart';

class UserSignUpController extends GetxController {
  /// Function to pick date
  Future<void> pickDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dateOfBirthTEController.text = DateFormat('MM/dd/yyyy').format(picked);
    }
  }

  void setGender(String? value) {
    if (value != null) {
      userSelectedGender.value = value;
    }
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

  /// ===================> TOKY ===================>
  final RxBool loader = false.obs;
  final TextEditingController userNameTEController = TextEditingController();
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController phoneNumberTEController = TextEditingController();
  final TextEditingController dateOfBirthTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();
  final RxString userSelectedGender = ''.obs;
  LocationController locationController = Get.put(LocationController());

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> handleSignUp() async {
    try {
      if (isCheckboxTaped.value == false) {
        return;
      }
      if (!formKey.currentState!.validate()) {
        return;
      }
      if (userSelectedGender.value.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select the gender !!',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      loader.value = true;

      await locationController.fetchCurrentLocation();
      final String currentRole = await GetStorageModel().read(
        AppConstants.currentRole,
      );
      final Map<String, dynamic> registrationForm = <String, dynamic>{
        "name": "${userNameTEController.text.trim()}",
        "email": "${emailTEController.text.trim()}",
        "password": "${passwordTEController.text}",
        "role": currentRole.toLowerCase(), // user-provider
        "phoneNumber": "${phoneNumberTEController.text.trim()}",
        "location":
            '${(locationController.currentAddress.value?.street ?? '')},${(locationController.currentAddress.value?.subLocality ?? '')},${(locationController.currentAddress.value?.locality ?? '')},${(locationController.currentAddress.value?.country ?? '')} ',
        "lat": locationController.currentPosition.value?.latitude ?? 0,
        "lng": locationController.currentPosition.value?.longitude ?? 0,
        "gender": "${userSelectedGender.value.toLowerCase()}",
        "dob": "${dateOfBirthTEController.text.trim()}",
        "acceptTOC": true,
      };

      final NetworkResponse postResponse = await NetworkCaller().postRequest(
        AppUrl.registerUser,
        body: registrationForm,
      );
      LoggerUtils.debug(postResponse.jsonResponse);
      if (postResponse.isSuccess) {
        LoggerUtils.debug(postResponse.jsonResponse);
        final bool hasVerificationToken = await SecureStorageService()
            .containsKey(AppConstants.verificationToken);
        if (hasVerificationToken) {
          await SecureStorageService().delete(AppConstants.verificationToken);
        }
        await SecureStorageService().write(
          AppConstants.verificationToken,
          postResponse
                  .jsonResponse?['data']['attributes']['verificationToken'] ??
              '',
        );
        LoggerUtils.warning(registrationForm);

        final String currentRole = await GetStorageModel().read(
          AppConstants.currentRole,
        );
        if (currentRole == UserRole.user.name) {
          Get.toNamed(
            Routes.verifyOtpScreen,
            arguments: <String, String>{'email': emailTEController.text},
          );
        } else if (currentRole == UserRole.provider.name) {
          Get.offAllNamed(Routes.signInScreen);
          // Get.toNamed(
          //   Routes.verifyOtpScreen,
          //   arguments: <String, String>{'email': emailTEController.text},
          // );
        }
        Get.snackbar(
          'Success',
          postResponse.jsonResponse?['message'],
          backgroundColor: AppColors.c778beb,
        );
      } else {
        // ToastManager.show(
        //   message: postResponse.jsonResponse?['message'] ?? 'Error Occurred !!!',
        //   backgroundColor: AppColors.red,
        //   textColor: AppColors.white,
        //   icon: const Icon(CupertinoIcons.info, color: AppColors.white),
        // );
        LoggerUtils.debug(postResponse.jsonResponse?['message']);

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
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../routes/routes.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';

class SignInScreenController extends GetxController {
  final RxBool loader = false.obs;
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();
  final RxString userSelectedGender = ''.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> handleSignIn() async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }
      loader.value = true;

      final Map<String, dynamic> loginForm = <String, dynamic>{
        "email": "${emailTEController.text}",
        "password": "${passwordTEController.text}",
      };

      final NetworkResponse postResponse = await NetworkCaller().postRequest(
        AppUrl.userLogin,
        body: loginForm,
      );
      if (postResponse.isSuccess) {
        LoggerUtils.debug(postResponse.jsonResponse);

        await SecureStorageService().write(
          AppConstants.accessToken,
          postResponse
                  .jsonResponse?['data']['attributes']['tokens']['accessToken'] ??
              '',
        );
        await SecureStorageService().write(
          AppConstants.refreshToken,
          postResponse
                  .jsonResponse?['data']['attributes']['tokens']['refreshToken'] ??
              '',
        );
        Get.snackbar(
          'Success',
          postResponse.jsonResponse?['message'],
          backgroundColor: AppColors.c778beb,
        );
        Get.toNamed(Routes.navigationScreen);
      } else {
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

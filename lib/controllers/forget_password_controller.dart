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

class ForgetPasswordController extends GetxController {
  final RxBool loader = false.obs;
  final TextEditingController emailTEController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> handleForgetPassword({bool isResend = false}) async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }
      loader.value = true;

      final Map<String, dynamic> loginForm = <String, dynamic>{
        "email": "${emailTEController.text} ",
      };

      final NetworkResponse postResponse = await NetworkCaller().postRequest(
        AppUrl.forgetPassword,
        body: loginForm,
      );
      if (postResponse.isSuccess) {
        LoggerUtils.debug(postResponse.jsonResponse);

        Get.snackbar(
          'Success',
          postResponse.jsonResponse?['message'],
          backgroundColor: AppColors.c778beb,
        );
        if (isResend == false) {
          Get.toNamed(
            Routes.verifyOtpScreen,
            arguments: {
              'email': emailTEController.text,
              'forgetPassword': true
            },
          );
        }
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

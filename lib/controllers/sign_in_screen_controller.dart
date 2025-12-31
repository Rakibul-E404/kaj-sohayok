import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/message_screen_controller.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/models/sign_in_model.dart';
import 'package:kaz_bd/service/fcm_push_notification.dart';
import 'package:kaz_bd/service/get_storage.dart';
import 'package:kaz_bd/service/socket_service.dart';
import 'package:kaz_bd/utilities/enum.dart';

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
  RxBool isPasswordVisible = true.obs;

  void setPasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// ============>
  final Rxn<SignInProfileModel> signedProfile = Rxn<SignInProfileModel>();

  Future<void> handleSignIn() async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }
      loader.value = true;
      final String fcmToken = await FCMService.getToken();
      final Map<String, dynamic> loginForm = <String, dynamic>{
        "email": "${emailTEController.text}",
        "password": "${passwordTEController.text}",
        "fcmToken": fcmToken
      };

      final NetworkResponse postResponse = await NetworkCaller().postRequest(
        AppUrl.userLogin,
        body: loginForm,
        isLogin: true
      );
      if (postResponse.isSuccess) {
        LoggerUtils.debug(postResponse.jsonResponse);

        await SecureStorageService().write(
          AppConstants.accessToken,
          postResponse.jsonResponse?['data']['attributes']['tokens']
                  ['accessToken'] ??
              '',
        );
        await SecureStorageService().write(
          AppConstants.refreshToken,
          postResponse.jsonResponse?['data']['attributes']['tokens']
                  ['refreshToken'] ??
              '',
        );

        /// ===============> Sign In as role ===============>
        signedProfile.value = SignInProfileModel.fromJson(
          postResponse.jsonResponse?['data']['attributes'],
        );
        LoggerUtils.debug(postResponse.jsonResponse?['data']['attributes']);
        GetStorageModel().saveString(
          AppConstants.userId,
          signedProfile.value?.id ?? '',
        );

        // ///==================> Fix the Message Controller ====================>
        // await Get.find<MessageScreenController>().messagingInitialize();
        //
        // ///======================================>
        /// ======================= SOCKET =====================>
        SocketServices().disconnect();

        // Clear MessageScreenController if exists
        if (Get.isRegistered<MessageScreenController>()) {
          Get.find<MessageScreenController>().clearAllData();
        }
        await Future.delayed(Duration(milliseconds: 300));
        SocketServices().enable();

        LoggerUtils.debug('🔌 Initializing socket...');
        await SocketServices().init();

        /// ======================= SOCKET =====================>

        /// ===========================> Socket ==================>
        if (signedProfile.value != null &&
            signedProfile.value!.role == 'user') {
          GetStorageModel().saveString(
            AppConstants.currentRole,
            UserRole.user.name,
          );
          Get.offAllNamed(Routes.navigationScreen);
          return;
        } else if (signedProfile.value != null &&
            signedProfile.value!.role == 'provider') {
          GetStorageModel().saveString(
            AppConstants.currentRole,
            UserRole.provider.name,
          );

          /// ================> For Provider Email Verification =============>
          if (signedProfile.value!.isEmailVerified == false) {
            Get.toNamed(
              Routes.verifyOtpScreen,
              arguments: <String, String>{'email': emailTEController.text},
            );
            return;
          }

          if (signedProfile.value!.isServiceProviderDetailsFound == true) {
            /// Profile  completed ===========>
            GetStorageModel().saveBool(
              AppConstants.providerProfileIsComplete,
              true,
            );
            Get.offAllNamed(Routes.navigationScreen);
            return;
          } else {
            GetStorageModel().saveBool(
              AppConstants.providerProfileIsComplete,
              false,
            );

            Get.offAllNamed(Routes.moreInformationScreen);
            return;
          }
        }

        Get.snackbar('Success', postResponse.jsonResponse?['message']);
      } else {
        LoggerUtils.debug(postResponse.jsonResponse);
        // passwordTEController.clear();
        await SecureStorageService().clear();
        Get.snackbar(
          'Failed',
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

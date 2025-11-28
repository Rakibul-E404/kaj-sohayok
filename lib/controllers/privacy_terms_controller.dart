import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';

class PrivacyTermsController extends GetxController {
  /// ===============> Fetch the privacy Policy and terms and condition ===== >
  final RxString privacyPolicy = ''.obs;
  final RxString aboutUs = ''.obs;
  final RxString termsCondition = ''.obs;
  final RxString contactUs = ''.obs;

  Future<void> fetchPrivacyPolicy() async {
    try {
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      final NetworkResponse getResponse = await NetworkCaller().getRequest(
        AppUrl.userPrivacyPolicy,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );
      if (getResponse.isSuccess) {
        privacyPolicy.value =
            getResponse.jsonResponse?['data']['attributes'][0]['details'];
        LoggerUtils.debug(privacyPolicy.value);
      } else {
        // Get.snackbar(
        //   'Error',
        //   getResponse.jsonResponse?['message'],
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        // );
      }
    } catch (e) {
      LoggerUtils.debug("Exception : ${e.toString()}");
    } finally {}
  }

  Future<void> fetchAboutUs() async {
    try {
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      final NetworkResponse getResponse = await NetworkCaller().getRequest(
        AppUrl.userAboutUs,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );
      if (getResponse.isSuccess) {
        aboutUs.value =
            getResponse.jsonResponse?['data']['attributes'][0]['content'];
      } else {
        // Get.snackbar(
        //   'Error',
        //   getResponse.jsonResponse?['message'],
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        // );
      }
    } catch (e) {
      LoggerUtils.debug("Exception : ${e.toString()}");
    } finally {}
  }

  Future<void> fetchTermsCondition() async {
    try {
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      final NetworkResponse getResponse = await NetworkCaller().getRequest(
        AppUrl.userTermsAndConditions,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );
      if (getResponse.isSuccess) {
        termsCondition.value =
            getResponse.jsonResponse?['data']['attributes'][0]['content'];
      } else {
        // Get.snackbar(
        //   'Error',
        //   getResponse.jsonResponse?['message'],
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        // );
      }
    } catch (e) {
      LoggerUtils.debug("Exception : ${e.toString()}");
    } finally {}
  }

  Future<void> fetchContactUst() async {
    try {
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      final NetworkResponse getResponse = await NetworkCaller().getRequest(
        AppUrl.userContactUs,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );
      if (getResponse.isSuccess) {
        contactUs.value =
            getResponse.jsonResponse?['data']['attributes'][0]['content'];
      } else {
        // Get.snackbar(
        //   'Error',
        //   getResponse.jsonResponse?['message'],
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        // );
      }
    } catch (e) {
      LoggerUtils.debug("Exception : ${e.toString()}");
    } finally {}
  }

  @override
  Future<void> onInit() async {
    fetchPrivacyPolicy();
    fetchAboutUs();
    fetchTermsCondition();
    super.onInit();
  }
}

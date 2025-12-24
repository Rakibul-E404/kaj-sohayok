import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/service/get_storage.dart';
import 'package:kaz_bd/service/secured_storage.dart';
import 'package:kaz_bd/utilities/app_constants.dart';
import 'package:kaz_bd/utilities/enum.dart';
import 'package:kaz_bd/utilities/logger_util.dart';

import '../constants/app_constant_text.dart';
import '../helpers/di.dart';
import '../routes/routes.dart';
import '../service/socket_service.dart';
import 'message_screen_controller.dart';

class OnboardingController extends GetxController {
  // Reactive variable to track the selected tab index
  var tabIndex = appData.read(kKeyEnglish) ? 0.obs : 1.obs;

  // Change the tab index
  void changeTab(int index) {
    tabIndex.value = index;
    log('Switched To: $index');
    if (index == 0) {
      log('😊😊----------Selected Language : English ------------');
      appData.write(kKeyEnglish, true);
      appData.write(kKeyBangla, false);
      Get.updateLocale(Locale('en', 'US')); // Update the app locale
    } else if (index == 1) {
      log('😏😏----------Selected Language : Bangla ------------');
      appData.write(kKeyEnglish, false);
      appData.write(kKeyBangla, true);
      Get.updateLocale(Locale('bn', 'BD')); // Update the app locale
    } else {
      return;
    }
  }

  checkAuthNavigate() async {
    final bool hasToken = await SecureStorageService().containsKey(
      AppConstants.accessToken,
    );

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
    if (hasToken) {
      final String currentRole = GetStorageModel().read(
        AppConstants.currentRole,
      );

      final bool isProviderProfileComplete =
          GetStorageModel().read(AppConstants.providerProfileIsComplete) ??
              false;
      LoggerUtils.warning(
          GetStorageModel().exists(AppConstants.providerProfileIsComplete));
      LoggerUtils.warning(isProviderProfileComplete);
      if (currentRole == UserRole.provider.name &&
          isProviderProfileComplete == false) {
        Get.offAllNamed(Routes.moreInformationScreen);
        return;
      }
      Get.offNamed(Routes.navigationScreen);
    } else {
      Get.offNamed(Routes.chooseRoleScreen);
    }
  }
}

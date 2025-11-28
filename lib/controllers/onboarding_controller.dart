import 'package:get/get.dart';
import 'package:kaz_bd/service/get_storage.dart';
import 'package:kaz_bd/service/secured_storage.dart';
import 'package:kaz_bd/utilities/app_constants.dart';
import 'package:kaz_bd/utilities/enum.dart';
import 'package:kaz_bd/utilities/logger_util.dart';

import '../routes/routes.dart';

class OnboardingController extends GetxController {
  // Reactive variable to track the selected tab index
  var tabIndex = 0.obs;

  // Change the tab index
  void changeTab(int index) {
    tabIndex.value = index;
  }

  checkAuthNavigate() async {
    final bool hasToken = await SecureStorageService().containsKey(
      AppConstants.accessToken,
    );
    if (hasToken) {
      final String currentRole = GetStorageModel().read(
        AppConstants.currentRole,
      );
      final bool isProviderProfileComplete =
          GetStorageModel().read(AppConstants.providerProfileIsComplete) ??
          false;
      LoggerUtils.warning(GetStorageModel().exists(AppConstants.providerProfileIsComplete));
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

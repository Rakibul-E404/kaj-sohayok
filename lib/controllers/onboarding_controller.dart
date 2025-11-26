import 'package:get/get.dart';
import 'package:kaz_bd/service/secured_storage.dart';
import 'package:kaz_bd/utilities/app_constants.dart';

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
      Get.toNamed(Routes.navigationScreen);
    } else {
      Get.toNamed(Routes.chooseRoleScreen);
    }
  }
}

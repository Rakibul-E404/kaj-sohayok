import 'package:get/get.dart';

class OnboardingController extends GetxController {
  // Reactive variable to track the selected tab index
  var tabIndex = 0.obs;

  // Change the tab index
  void changeTab(int index) {
    tabIndex.value = index;
  }
}

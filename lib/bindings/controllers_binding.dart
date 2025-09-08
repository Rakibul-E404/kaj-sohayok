import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';
import '../controllers/otp_validation_controller.dart';
import '../controllers/set_new_password_screen_controller.dart';
import '../controllers/sign_in_screen_controller.dart';
import '../controllers/sign_up_screen_controller.dart';

class ControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OnboardingController());
    Get.lazyPut(() => SignInScreenController());
    Get.lazyPut(() => SignUpScreenController());
    Get.lazyPut(() => OtpValidationController());
    Get.lazyPut(() => SetNewPasswordScreenController());
  }
}

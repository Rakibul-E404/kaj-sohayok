import 'package:get/get.dart';

import '../controllers/change_password_screen_controller.dart';
import '../controllers/chat_inbox_screen_controller.dart';
import '../controllers/edit_profile_screen_controller.dart';
import '../controllers/home_page_controller.dart';
import '../controllers/message_screen_controller.dart';
import '../controllers/onboarding_controller.dart';
import '../controllers/otp_validation_controller.dart';
import '../controllers/set_new_password_screen_controller.dart';
import '../controllers/sign_in_screen_controller.dart';
import '../controllers/sign_up_screen_controller.dart';
import '../controllers/user_profile_screen_controller.dart';

class ControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OnboardingController());
    Get.lazyPut(() => SignInScreenController());
    Get.lazyPut(() => SignUpScreenController());
    Get.lazyPut(() => OtpValidationController());
    Get.lazyPut(() => SetNewPasswordScreenController());
    Get.lazyPut(() => HomePageController());
    Get.lazyPut(() => UserProfileScreenController());
    Get.lazyPut(() => ChangePasswordScreenController());
    Get.lazyPut(() => EditProfileScreenController());
    Get.lazyPut(() => MessageScreenController());
    Get.lazyPut(() => ChatInboxScreenController());
  }
}

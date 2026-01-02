import 'package:get/get.dart';
import 'package:kaz_bd/features/service_provider/svp_accepted_bookings/controller/svp_accepted_bookings_screen_controller.dart';
import 'package:kaz_bd/features/service_provider/svp_bookings/sub_presentation/svp_bookings_canceled/controller/svp_bookings_canceled_tab_controller.dart';
import 'package:kaz_bd/features/service_provider/svp_job_request/controller/svp_job_request_screen_controller.dart';

import '../controllers/change_password_screen_controller.dart';
import '../controllers/chat_inbox_screen_controller.dart';
import '../controllers/face_verification_controller.dart';
import '../controllers/home_page_controller.dart';
import '../controllers/message_screen_controller.dart';
import '../controllers/more_information_screen_controller.dart';
import '../controllers/all_categories_screen_controller.dart';
import '../controllers/onboarding_controller.dart';
import '../controllers/otp_validation_controller.dart';
import '../controllers/set_new_password_screen_controller.dart';
import '../controllers/sign_in_screen_controller.dart';
import '../controllers/sign_up_screen_controller.dart';
import '../controllers/svp_edit_profile_screen_controller.dart';
import '../controllers/svp_home_screen_controller.dart';
import '../controllers/svp_profile_screen_controller.dart';
import '../controllers/svp_profile_screen_documents_tab_controller.dart';
import '../controllers/user_edit_profile_controller.dart';
import '../controllers/user_profile_screen_controller.dart';
import '../controllers/svp_submit_work_form_screen_controller.dart';
import '../features/call/presentation/controller/call_controller.dart';
import '../features/service_provider/svp_work_completed_details/controller/svp_work_completed_details_screen_controller.dart';

class ControllerBindings extends Bindings {
  @override
  void dependencies() {
    /// ==============> Shahriar ==============>
    // Get.put(MessageScreenController());
    Get.lazyPut(() => MessageScreenController(), fenix: true);
    Get.put(CallController(), permanent: true);
    Get.lazyPut(() => OnboardingController());
    Get.lazyPut(() => SignInScreenController());
    Get.lazyPut(() => UserSignUpController());
    Get.lazyPut(() => OtpValidationController());
    Get.lazyPut(() => SetNewPasswordScreenController());
    Get.lazyPut(() => HomePageController());
    Get.lazyPut(() => UserProfileScreenController());
    Get.lazyPut(() => ChangePasswordScreenController());
    Get.lazyPut(() => UserEditProfileScreenController());
    // Get.lazyPut(() => MessageScreenController());
    Get.lazyPut(() => ChatInboxScreenController());
    Get.lazyPut(() => MoreInformationScreenController());
    Get.lazyPut(() => FaceVerificationController());
    Get.lazyPut(() => SvpSubmitWorkFormScreenController());
    Get.lazyPut(() => SvpProfileScreenController());
    Get.lazyPut(() => SvpEditProfileScreenController());
    Get.lazyPut(() => SvpProfileScreenDocumentsTabController());
    Get.lazyPut(() => SvpHomeScreenController());
    Get.lazyPut(() => SvpBookingsCanceledController(), fenix: true);
    Get.lazyPut(() => SvpJobRequestScreenController(), fenix: true);
    Get.lazyPut(() => SvpAcceptedBookingsScreenController(), fenix: true);
    Get.lazyPut(() => SvpWorkCompletedDetailsScreenController(), fenix: true);

    // Get.lazyPut(() => NormalUserAllCategoryScreenController());
  }
}

import 'dart:io';
import 'package:flutter/material.dart'; // 👈 Needed for BuildContext, Widget, FadeTransition
import 'package:get/get.dart';
import 'package:kaz_bd/features/auth/forgot_password/presentation/forgot_password_screen.dart';
import 'package:kaz_bd/features/auth/set_new_password/presentation/set_new_password_screen.dart';
import 'package:kaz_bd/features/auth/sign_in/presentation/sign_in_screen.dart';
import 'package:kaz_bd/features/auth/sign_up/presentation/sign_up_screen.dart';
import 'package:kaz_bd/features/common_screens/about_us/presentation/about_us_screen.dart';
import 'package:kaz_bd/features/common_screens/contact_us/presentation/contact_us_screen.dart';
import 'package:kaz_bd/features/common_screens/edit_profile/presentation/edit_profile_screen.dart';
import 'package:kaz_bd/features/common_screens/privacy_policy/presentation/privacy_policy_screen.dart';
import 'package:kaz_bd/features/common_screens/terms_and_conditions/presentation/terms_and_conditions_screen.dart';
import 'package:kaz_bd/features/normal_user/all_categories/presentation/all_categories_screen.dart';
import 'package:kaz_bd/features/common_screens/change_password/presentation/change_password_screen.dart';
import 'package:kaz_bd/features/normal_user/booking_date/presentation/booking_date_screen.dart';
import 'package:kaz_bd/features/normal_user/bookings_payments_request_details/presentation/bookings_payment_request_details_screen.dart';
import 'package:kaz_bd/features/normal_user/details/presentation/details_screen.dart';
import 'package:kaz_bd/features/normal_user/notification/presentation/notification_screen.dart';
import 'package:kaz_bd/features/normal_user/provider_profile_details/presentation/provider_profile_details_screen.dart';
import 'package:kaz_bd/features/normal_user/search_location/presentation/search_location_screen.dart';
import 'package:kaz_bd/features/normal_user/service_preview/presentation/service_preview_screen.dart';
import 'package:kaz_bd/features/normal_user/services_of_specific_category/presentation/services_of_specific_category_screen.dart';
import 'package:kaz_bd/features/normal_user/work_completed_details/presentation/work_completed_details_screen.dart';
import 'package:kaz_bd/features/service_provider/join_as_service_provider/presentation/join_as_service_provider_screen.dart';
import 'package:kaz_bd/features/service_provider/more_information/presentation/more_information_screen.dart';
import 'package:kaz_bd/features/welcome/choose_role/presentation/choose_role_screen.dart';
import 'package:kaz_bd/features/welcome/onboarding/presentation/onboarding_screen.dart';
import 'package:kaz_bd/features/welcome/splash/presentation/splash_screen.dart';
import 'package:kaz_bd/navigation_screen.dart';

import '../features/auth/verify_otp/verify_otp_screen.dart';
import '../features/service_provider/profile_under_review/presentation/profile_under_review_screen.dart';
import '../features/service_provider/face_verification/presentation/face_verification_screen.dart';

class Routes {
  ///Section : Common Screens Routing
  ///Section : Normal Users Routing

  static const String splashScreen = '/';
  static const String onboardingScreen = '/onboarding_screen';
  static const String chooseRoleScreen = '/choose_role_screen';
  static const String signInScreen = '/sign_in_screen';
  static const String signUpScreen = '/signup_screen';
  static const String forgotPasswordScreen = '/forgot_password_screen';
  static const String verifyOtpScreen = '/verify_otp_screen';
  static const String setNewPasswordScreen = '/set_newpassword_screen';
  static const String navigationScreen = '/navigation_screen';
  static const String notificationScreen = '/notification_screen';
  static const String allCategoriesScreen = '/allCategories_screen';
  static const String changePasswordScreen = '/change_password_screen';
  static const String privacyPolicyScreen = '/privacy_policy_screen';
  static const String termsAndConditionsScreen = '/terms_and_conditions_screen';
  static const String aboutUsScreen = '/about_us_screen';
  static const String contactUsScreen = '/contact_us_screen';
  static const String editProfileScreen = '/edit_profile_screen';
  static const String servicePreviewScreen = '/service_preview_screen';
  static const String bookingDateScreen = '/booking_date_screen';
  static const String searchLocationScreen = '/search_location_screen';
  static const String bookingsPaymentRequestDetailsScreen =
      '/bookings_payment_request_details_screen';
  static const String workCompletedDetailsScreen =
      '/work_completed_details_screen';
  static const String servicesOfSpecificCategoryScreen =
      '/services_of_specific_category_screen';
  static const String serviceDetailsScreen = '/service_details_screen';
  static const String serviceProviderProfileDetailsScreen =
      '/service_propvider_profile_details_screen';

  ///Section : Service Provider Routing
  static const String joinAsServiceProviderScreen =
      '/join_as_service_provider_screen';
  static const String moreInformationScreen = '/more_information_screen';
  static const String profileUnderReviewScreen = '/profile_under_screen';
  static const String faceVerificationScreen = '/face_verification_screen';

  static final appRoutes = [
    ///Section : Normal User Screens & Common Screens
    ///Splash Screen
    GetPage(
      name: splashScreen,
      page: () => SplashScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///Onboarding Screen
    GetPage(
      name: onboardingScreen,
      page: () => OnboardingScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///Chose Role Screen
    GetPage(
      name: chooseRoleScreen,
      page: () => ChooseRoleScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///Sign In Screen
    GetPage(
      name: signInScreen,
      page: () => SignInScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///Sign Up Screen
    GetPage(
      name: signUpScreen,
      page: () => SignUpScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///Forgot Password Screen
    GetPage(
      name: forgotPasswordScreen,
      page: () => ForgotPasswordScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///Forgot Password Screen
    GetPage(
      name: verifyOtpScreen,
      page: () => VerifyOtpScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///SetNew Password Screen
    GetPage(
      name: setNewPasswordScreen,
      page: () => SetNewPasswordScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///Navigation Screen
    GetPage(
      name: navigationScreen,
      page: () => NavigationScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///Notification Screen
    GetPage(
      name: notificationScreen,
      page: () => NotificationScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///Notification Screen
    GetPage(
      name: allCategoriesScreen,
      page: () => AllCategoriesScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///Services Of Specific Category Screen
    GetPage(
      name: servicesOfSpecificCategoryScreen,
      page: () => ServicesOfSpecificCategoryScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///service Details Screen
    GetPage(
      name: serviceDetailsScreen,
      page: () => DetailsScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///serviceProviderProfileDetailsScreen
    GetPage(
      name: serviceProviderProfileDetailsScreen,
      page: () => ProviderDetailsScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///changePasswordScreen
    GetPage(
      name: changePasswordScreen,
      page: () => ChangePasswordScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///privacyPolicyScreen
    GetPage(
      name: privacyPolicyScreen,
      page: () => PrivacyPolicyScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///termsAndConditionsScreen
    GetPage(
      name: termsAndConditionsScreen,
      page: () => TermsAndConditionsScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///aboutUsScreen
    GetPage(
      name: aboutUsScreen,
      page: () => AboutUsScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///contactUsScreen
    GetPage(
      name: contactUsScreen,
      page: () => ContactUsScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///editProfileScreen
    GetPage(
      name: editProfileScreen,
      page: () => EditProfileScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///workCompletedDetailsScreen
    GetPage(
      name: workCompletedDetailsScreen,
      page: () => WorkCompletedDetailsScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///servicePreviewScreen
    GetPage(
      name: servicePreviewScreen,
      page: () => ServicesPreviewScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///bookingDateScreen
    GetPage(
      name: bookingDateScreen,
      page: () => BookingDateScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///searchLocationScreen
    GetPage(
      name: searchLocationScreen,
      page: () => SearchLocationScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///bookingsPaymentRequestDetailsScreen
    GetPage(
      name: bookingsPaymentRequestDetailsScreen,
      page: () => BookingsPaymentRequestDetailsScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///Section : Service Provider Screen

    ///bookingsPaymentRequestDetailsScreen
    GetPage(
      name: joinAsServiceProviderScreen,
      page: () => JoinAsServiceProviderScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///bookingsPaymentRequestDetailsScreen
    GetPage(
      name: moreInformationScreen,
      page: () => MoreInformationScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///ProfileUnderReviewScreen
    GetPage(
      name: profileUnderReviewScreen,
      page: () => ProfileUnderReviewScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),

    ///SetUpFaceVerificationScreen
    GetPage(
      name: faceVerificationScreen,
      page: () => FaceVerificationScreen(),
      transition: _transition(),
      customTransition: _customTransition(),
      transitionDuration: _duration(),
    ),
  ];
}

/// Custom ultra-fast fade for Android
class FastFadeTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}

/// Utility method to apply platform-aware transitions
Transition _transition() =>
    Platform.isAndroid ? Transition.fade : Transition.cupertino;

CustomTransition? _customTransition() =>
    Platform.isAndroid ? FastFadeTransition() : null;

Duration _duration() => Platform.isAndroid
    ? const Duration(milliseconds: 1)
    : const Duration(milliseconds: 300);


// /// All GetPages in your app
// final List<GetPage> appRoutes = [
  
//   GetPage(
//     name: AppRoutes.notificationsScreen,
//     page: () => NotificationsScreen(),
//     transition: _transition(),
//     customTransition: _customTransition(),
//     transitionDuration: _duration(),
//   ),

//   /// 🟢 Example: Using typed arguments model
//   GetPage(
//     name: AppRoutes.editProfileScreen,
//     page: () {
//       final args = Get.arguments as EditProfileArgs;
//       return EditProfileScreen(
//         firstName: args.firstName,
//         lastName: args.lastName,
//         email: args.email,
//         phone: args.phone,
//         address: args.address,
//         profileImage: args.profileImage,
//         age: args.age,
//         city: args.city,
//         country: args.country,
//       );
//     },
//     transition: _transition(),
//     customTransition: _customTransition(),
//     transitionDuration: _duration(),
//   ),

  
// ];

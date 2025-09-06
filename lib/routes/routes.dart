import 'dart:io';
import 'package:flutter/material.dart'; // 👈 Needed for BuildContext, Widget, FadeTransition
import 'package:get/get.dart';
import 'package:kaz_bd/features/auth/sign_in/presentation/sign_in_screen.dart';
import 'package:kaz_bd/features/auth/sign_up/presentation/sign_up_screen.dart';
import 'package:kaz_bd/features/welcome/choose_role/presentation/choose_role_screen.dart';
import 'package:kaz_bd/features/welcome/onboarding/onboarding_screen.dart';
import 'package:kaz_bd/features/welcome/splash/presentation/splash_screen.dart';

class Routes {
  static const String splashScreen = '/';
  static const String onboardingScreen = '/onboarding_screen';
  static const String chooseRoleScreen = '/choose_role_screen';
  static const String signInScreen = '/signInscreen';
  static const String signUpScreen = '/signup_screen';

  static final appRoutes = [
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

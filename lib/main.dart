import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaz_bd/constants/app_constant_text.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/di.dart';
import 'package:kaz_bd/localization/presentation/languages.dart';
import 'package:kaz_bd/routes/routes.dart';
import 'package:kaz_bd/utilities/set_initial_value.dart';

import 'package:kaz_bd/service/fcm_push_notification.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'bindings/controllers_binding.dart';

import 'firebase_options.dart';

// List<CameraDescription>? cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set system UI overlay style immediately when the widget builds
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      // Status bar color (Android)
      statusBarColor: AppColors.cf1f3fd, // Specific status bar color
      statusBarIconBrightness:
          Brightness.light, // Light icons for dark background
      statusBarBrightness: Brightness.dark, // Brightness for iOS status bar
      systemNavigationBarColor:
          AppColors.scaffoldBackgroundColor, // Keep navigation bar consistent
      systemNavigationBarIconBrightness:
          Brightness.dark, // Navigation bar icons
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await diSetup();
  // cameras = await availableCameras();
  await GetStorage.init();
  setInitialLanguagePreference();
  // await dotenv.load(fileName: ".env");

  await FCMService.initialize();
  if (Platform.isAndroid) {
    final AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      final PermissionStatus status = await Permission.notification.request();
      debugPrint('Notification permission status: $status');
    }
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // designSize: const Size(375, 812),
      designSize: const Size(402, 874),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          // home: WorkCompletedDetailsScreen(),
          debugShowCheckedModeBanner: false,
          translations: Languages(),
          locale: appData.read(kKeyEnglish)
              ? Locale('en', 'US')
              : appData.read(kKeyBangla)
                  ? Locale('bn', 'BD')
                  : Locale('en', 'US'),

          initialRoute: Routes.onboardingScreen,
          // initialRoute: Routes.joinAsServiceProviderScreen,

          // initialRoute: Routes.onboardingScreen,
          // initialRoute: Routes.joinAsServiceProviderScreen,
          //initialRoute: Routes.navigationScreen,

          getPages: Routes.appRoutes,
          initialBinding: ControllerBindings(),
        );
      },
    );
  }
}

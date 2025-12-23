import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaz_bd/helpers/di.dart';
import 'package:kaz_bd/routes/routes.dart';
import 'package:kaz_bd/service/fcm_push_notification.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'bindings/controllers_binding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
// List<CameraDescription>? cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await diSetup();
  // cameras = await availableCameras();
  await GetStorage.init();
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

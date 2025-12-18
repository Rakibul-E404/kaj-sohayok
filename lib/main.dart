import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaz_bd/constants/app_constant_text.dart';
import 'package:kaz_bd/helpers/di.dart';
import 'package:kaz_bd/localization/presentation/languages.dart';
import 'package:kaz_bd/routes/routes.dart';
import 'package:kaz_bd/utilities/set_initial_value.dart';

import 'bindings/controllers_binding.dart';

// List<CameraDescription>? cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await diSetup();
  // cameras = await availableCameras();
  await GetStorage.init();
  setInitialLanguagePreference();
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

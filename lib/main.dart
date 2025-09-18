import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/routes/routes.dart';

import 'bindings/controllers_binding.dart';

void main() {
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
          // initialRoute: Routes.workCompletedDetailsScreen,
          getPages: Routes.appRoutes,
          initialBinding: ControllerBindings(),
        );
      },
    );
  }
}

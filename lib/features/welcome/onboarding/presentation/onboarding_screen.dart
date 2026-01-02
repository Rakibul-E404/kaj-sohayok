import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/select_language_widget.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/service/socket_service.dart';

import '../../../../controllers/onboarding_controller.dart';
import '../widgets/get_started_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OnboardingController onboardingController = Get.put(
    OnboardingController(),
  );

  @override
  void initState() {
    super.initState();
    SocketServices().disconnect();
    SocketServices().init();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: onboardingController.tabIndex.value,
    );
    _tabController.addListener(() {
      onboardingController.changeTab(_tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cFFFFFF,
      body: Container(
        width: 1.sw,
        height: 1.sh,
        padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,

            ///Section: Background Image
            image: AssetImage(Assets.images.onboardingImage.path),
          ),
        ),
        child: Column(
          children: [
            UIHelper.verticalSpace(68.h),

            // TabBar with custom indicator and styling
            ///Section : Button -> English, Bangla
            SelectLanguage(
              tabController: _tabController,
              tabIndex: onboardingController.tabIndex,
              onTabChange: onboardingController.changeTab,
              leftTabTitle: "English",
              rightTabTitle: "বাংলা",
            ),

            Spacer(),

            ///Section : Bottom Container
            Container(
              width: 1.sw,
              padding: EdgeInsets.all(24.sp),
              decoration: BoxDecoration(
                color: AppColors.c4b4d51.withAlpha(230),
                border: Border.all(color: AppColors.c778beb),
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ///Section : AppLogo
                  Image.asset(
                    Assets.images.appLogo.path,
                    width: 0.8.sw,
                    height: 90,
                    fit: BoxFit.contain,
                  ),

                  ///Section : Text -> Your home's Best Friend
                  Text(
                    // "Your Home's Best Friend",
                    'your_home_best_friend'.tr,
                    textAlign: TextAlign.center,
                    style: TextFontStyle.headline26w700cFFFFFFStyleSatoshi,
                  ),
                  UIHelper.verticalSpace(10.h),

                  Text(
                    'get_your_home_services_done'.tr,
                    textAlign: TextAlign.center,
                    style: TextFontStyle.headline14w500cFFFFFFStyleSatoshi,
                  ),
                  UIHelper.verticalSpace(16.h),

                  ///Section: Button -> GetStarted
                  GetStartedButton(
                    onTap: () {
                      onboardingController.checkAuthNavigate();
                    },
                    buttonTitle: 'get_started'.tr,
                  ),
                ],
              ),
            ),
            UIHelper.verticalSpace(20.h),
          ],
        ),
      ),
    );
  }
}

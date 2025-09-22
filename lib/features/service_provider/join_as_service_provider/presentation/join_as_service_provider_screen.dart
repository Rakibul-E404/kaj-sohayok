import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../welcome/onboarding/widgets/get_started_button.dart';
import '../widgets/service_provider_promoting_widget_tile.dart';

class JoinAsServiceProviderScreen extends StatelessWidget {
  const JoinAsServiceProviderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///Section : Initial Image
            Image.asset(
              width: 1.sw,
              height: 0.4.sh,
              fit: BoxFit.cover,
              Assets.images.serviceProviderImage.path,
            ),
            UIHelper.verticalSpace(24.h),

            ///Section : Text -> Join us as a service provider.
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: UIHelper.kDefaulutPadding(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///Section : Text -> Join us as a service provider.
                  ///Section : Text -> Register and make your dreams bigger!
                  Text(
                    "Join us as a service provider.",
                    style: TextFontStyle.headline20w700c202020StyleSatoshi,
                  ),
                  UIHelper.verticalSpace(8.h),

                  ///Section : Text -> Register and make your dreams bigger!
                  Text(
                    "Register and make your dreams bigger!",
                    style: TextFontStyle.headline14w400c4d4d4dStyleSatoshi,
                  ),
                  UIHelper.verticalSpace(24.h),

                  ///Section : Text -> Increased Job Opportunities
                  ServiceProviderPromotionWidgetTile(
                    imagePath: Assets.images.coloredClockImage.path,
                    title: "Increased Job Opportunities",
                    subTitle:
                        "Expand your client base and enjoy flexible working hours.",
                  ),

                  ///Section : Text -> Enhanced Professional Reputation
                  ServiceProviderPromotionWidgetTile(
                    imagePath: Assets.images.medalImage.path,
                    title: "Enhanced Professional Reputation",
                    subTitle:
                        "Build credibility through user reviews and showcase your work.",
                  ),

                  ///Section : Text -> Enhanced Professional Reputation
                  ServiceProviderPromotionWidgetTile(
                    isDividerVisible: false,
                    imagePath: Assets.images.walletImage.path,
                    title: "Enhanced Professional Reputation",
                    subTitle:
                        "Enjoy a hassle-free payment process, with secure and direct earnings deposited into your account.",
                  ),
                ],
              ),
            ),
            UIHelper.verticalSpace(46.h),

            ///Section : Button -> Continue
            Align(
              alignment: Alignment.center,
              child: GetStartedButton(
                onTap: () {
                  log("Continue Button Taped!");
                  Get.toNamed(Routes.moreInformationScreen);
                },
                buttonTitle: "Continue",
              ),
            ),
            UIHelper.verticalSpace(20.h),
          ],
        ),
      ),
    );
  }
}

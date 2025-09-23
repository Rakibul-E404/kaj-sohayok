import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/custom_widgets/custom_card.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../../constants/app_constant_text.dart';
import '../../../../constants/text_font_style.dart';

class ProfileUnderReviewScreen extends StatelessWidget {
  const ProfileUnderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: Center(
            child: CustomCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ///Section : App LOGO
                  InkWell(
                    onTap: () {
                      Get.toNamed(Routes.faceVerificationScreen);
                    },
                    child: Image.asset(Assets.images.appLogo.path, width: 1.sw),
                  ),

                  ///Section : Text -> Your Profile is under Review
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Chowdhury Md. Imtiazul Islam\n",

                          style:
                              TextFontStyle.headline18w700c778bebStyleSatoshi,
                        ),
                        TextSpan(
                          text:
                              "Your Profile is under review. We will get back to you soon.",
                          style:
                              TextFontStyle.headline12w400c494949StyleSatoshi,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

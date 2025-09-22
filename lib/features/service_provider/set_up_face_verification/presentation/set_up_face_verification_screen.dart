import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

class SetUpFaceVerificationScreen extends StatelessWidget {
  const SetUpFaceVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UIHelper.verticalSpace(140.h),

              ///Section : Text -> set up face verification
              Text(
                "Set Up Face Verification",
                style: TextFontStyle.headline20w700c000000StyleSatoshi,
              ),
              UIHelper.verticalSpace(100.h),

              Image.asset(
                Assets.images.faceVerificationImage.path,
                height: 150.h,
                width: 150.w,
                fit: BoxFit.cover,
              ),
              Spacer(),

              CustomElevatedButton(
                onTap: () {
                  log("Scan My Face Button Taped!");
                },
                buttonTitle: "Scan My Face",
              ),
              UIHelper.verticalSpace(20.h),
            ],
          ),
        ),
      ),
    );
  }
}

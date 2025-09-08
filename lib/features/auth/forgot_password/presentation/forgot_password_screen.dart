import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/custom_text_form_field.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../../gen/assets.gen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
              UIHelper.verticalSpace(68.h),

              ///AppLogo
              Container(
                width: 96.w,
                height: 96.h,
                decoration: BoxDecoration(
                  color: AppColors.cFFFFFF,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(Assets.images.appLogo.path),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ca4b1f2.withAlpha(80),
                      blurRadius: 12.r,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(32.h),

              ///Section : text -> Forgot Password
              Text(
                "Forgot Password",
                style: TextFontStyle.headline10w700c000000StyleSatoshi,
              ),
              UIHelper.verticalSpace(14.h),

              ///Section : Text -> Please Enter your phone...
              Text(
                "Please enter your phone email to reset password.",
                style: TextFontStyle.headline12w400c000000StyleSatoshi,
              ),
              UIHelper.verticalSpace(32.h),

              ///Section : Email Form field
              CustomFormField(
                labelText: "Your Email",
                hintText: "Enter Your Email",
                prefixIcon: Icon(Icons.mail, color: AppColors.c858c94),
              ),
              Spacer(),

              ///Section : Button -> Send OTP
              CustomElevatedButton(
                onTap: () {
                  log("Send OTP Button Pressed!");
                  Get.toNamed(Routes.verifyOtpScreen);
                },
                buttonTitle: "Send OTP",
              ),
              UIHelper.verticalSpace(32.h),
            ],
          ),
        ),
      ),
    );
  }
}

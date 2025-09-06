import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/controllers/sign_in_screen_controller.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/custom_text_form_field.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final SignInScreenController controller = Get.put(SignInScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UIHelper.verticalSpace(66.h),

                ///Section: AppLogo
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

                ///Section : Text -> sign in your account
                Text(
                  "Sign In Your Account",
                  style: TextFontStyle.headline20w700c000000StyleSatoshi,
                ),
                UIHelper.verticalSpace(14.h),

                ///Section : Text -> welcome Back! Please enter your details.
                Text(
                  "welcome Back! Please Enter Your Details.",
                  style: TextFontStyle.headline12w400c414141StyleSatoshi,
                ),
                UIHelper.verticalSpace(32.h),

                ///Section : Email Form Field
                CustomFormField(
                  controller: controller.emailController,
                  labelText: "Your Email",
                  hintText: "Enter Your Email",
                  // hintTextStyle: ,
                  prefixIcon: Icon(Icons.mail, color: AppColors.c858c94),
                ),
                UIHelper.verticalSpace(32.h),

                ///Section : Password Form Field
                CustomFormField(
                  controller: controller.passwordController,
                  labelText: "Password",
                  hintText: "Enter Password",
                  // hintTextStyle: ,
                  prefixIcon: Icon(Icons.lock, color: AppColors.c858c94),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Forgot Password
                InkWell(
                  onTap: () {
                    log("Forgot Password button Taped!");
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot Password?",
                      style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi
                          .copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                UIHelper.verticalSpace(32.h),

                ///Section : Button -> Sign In
                CustomElevatedButton(
                  onTap: () {
                    log("Sign In Button taped!");
                  },
                  buttonTitle: "Sign in",
                ),
                UIHelper.verticalSpace(32.h),

                ///Section : Text -> Don’t have an account?
                ///Section: TextButton -> Sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don’t have an account?",
                      style: TextFontStyle.headline14w500c606060StyleSatoshi,
                    ),
                    UIHelper.horizontalSpace(10.w),
                    InkWell(
                      onTap: () {
                        log("Sign Up Button Taped!");
                        Get.toNamed(Routes.chooseRoleScreen);
                      },
                      child: Text(
                        "Sign up",
                        style: TextFontStyle.headline14w700c000000StyleSatoshi,
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

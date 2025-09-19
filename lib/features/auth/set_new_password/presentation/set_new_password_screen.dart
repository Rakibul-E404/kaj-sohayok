import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kaz_bd/controllers/set_new_password_screen_controller.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../custom_widgets/custom_text_form_field.dart';

class SetNewPasswordScreen extends StatelessWidget {
  SetNewPasswordScreen({super.key});

  SetNewPasswordScreenController controller = Get.put(
    SetNewPasswordScreenController(),
  );

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

              ///Section : text -> set new password
              Text(
                "Set New Password",
                style: TextFontStyle.headline24w700c000000StyleSatoshi,
              ),
              UIHelper.verticalSpace(14.h),

              ///Section : text -> Please Enter Your Password & Confirm Password.
              Text(
                "Please Enter Your Password & Confirm Password.",
                style: TextFontStyle.headline12w400c414141StyleSatoshi,
              ),
              UIHelper.verticalSpace(32.h),

              ///Section : Passwrd Form Field
              Obx(() {
                return CustomFormField(
                  labelText: "Password",
                  hintText: "Enter Password",
                  isPass: true,

                  isObsecure: controller.isVisible.value,
                  prefixIcon: SvgPicture.asset(
                    fit: BoxFit.contain,
                    Assets.icons.lockIcon,
                  ),
                  suffixIcon: InkWell(
                    onTap: () {
                      log(
                        "Password visibility Icon taped! ${controller.isVisible.value}",
                      );
                      controller.setPasswrdVisibility();
                    },
                    child: Icon(
                      controller.isVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.c6b6b6b,
                    ),
                  ),
                );
              }),
              UIHelper.verticalSpace(16.h),

              ///Section : Confirm Passwrd Form Field
              Obx(() {
                return CustomFormField(
                  labelText: "Confirm Password",
                  hintText: "Enter Confirm Password",
                  isPass: true,

                  isObsecure: controller.isConfirmPasswordVisible.value,
                  prefixIcon: SvgPicture.asset(
                    fit: BoxFit.contain,
                    Assets.icons.lockIcon,
                  ),
                  suffixIcon: InkWell(
                    onTap: () {
                      log(
                        "Password visibility Icon taped! ${controller.isConfirmPasswordVisible.value}",
                      );
                      controller.setConfirmPasswrdVisibility();
                    },
                    child: Icon(
                      controller.isConfirmPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.c6b6b6b,
                    ),
                  ),
                );
              }),
              Spacer(),

              CustomElevatedButton(
                onTap: () {
                  log("Save Password button Taped!");
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        width: 1.sw,
                        height: 0.48.sh,
                        padding: EdgeInsets.symmetric(
                          horizontal: 44.w,
                          vertical: 30.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cFFFFFF,
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ///Section : Mini Bar section
                            Container(
                              width: 50.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: AppColors.cb5b5b5,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            UIHelper.verticalSpace(24.h),

                            ///Section : Image -> Done
                            Image.asset(
                              height: 90.h,
                              width: 90.w,
                              fit: BoxFit.contain,
                              Assets.images.resetDoneImage.path,
                            ),
                            UIHelper.verticalSpace(24.h),

                            ///Section : Text -> Password Update Successfully
                            Text(
                              "Password Update\n Successfully",
                              textAlign: TextAlign.center,
                              style: TextFontStyle
                                  .headline18w700c000000StyleSatoshi,
                            ),
                            UIHelper.verticalSpace(10.h),

                            ///Section : Text -> Return to the lgoin....
                            Text(
                              "Return to the login page to enter your account with your new password.",
                              textAlign: TextAlign.center,
                              style: TextFontStyle
                                  .headline12w400c494949StyleSatoshi,
                            ),
                            Spacer(),

                            ///Section : Button -> back to sign in
                            CustomElevatedButton(
                              onTap: () {
                                log("Back to Sign in button Taped");
                                Get.toNamed(Routes.signInScreen);
                              },
                              buttonTitle: "Back To Sign In",
                            ),
                            UIHelper.verticalSpace(30.h),
                          ],
                        ),
                      );
                    },
                  );
                },
                buttonTitle: "Save Password",
              ),
              UIHelper.verticalSpace(50.h),
            ],
          ),
        ),
      ),
    );
  }
}

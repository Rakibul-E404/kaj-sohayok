import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/controllers/sign_up_screen_controller.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../constants/text_font_style.dart';
import '../../../controllers/otp_validation_controller.dart';
import '../../../gen/assets.gen.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../helpers/waiting_widget.dart';
import 'widgets/pinput_widget.dart';

class VerifyOtpScreen extends StatelessWidget {
  VerifyOtpScreen({super.key});

  OtpValidationController otpValidationController = Get.put(
    OtpValidationController(),
  );

  @override
  Widget build(BuildContext context) {
    final String? email = Get.arguments['email'] ?? '';
    final bool forForgetPassword = Get.arguments['forgetPassword'] ?? false;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: SingleChildScrollView(
            child: Column(
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
                  'verify_otp'.tr,
                  style: TextFontStyle.headline24w700c000000StyleSatoshi,
                ),
                UIHelper.verticalSpace(14.h),

                ///Section : text -> Please check your phone number and enter the code
                Text(
                  'check_your_number_and_enter_the_code'.tr,
                  style: TextFontStyle.headline12w400c414141StyleSatoshi,
                ),
                UIHelper.verticalSpace(32.h),

                ///Section : OTP Form Field
                CustomPinInput(
                  resend: () {
                    // otpValidationController.handleSendOtpSignUp(
                    //   email: email ?? '',
                    // );
                    if (forForgetPassword == false) {
                      Get.find<UserSignUpController>().handleSignUp();
                    } else {
                      Get.toNamed(
                        Routes.setNewPasswordScreen,
                        arguments: {
                          'email': email ?? '',
                          'otpCode': otpValidationController.pin.value,
                        },
                      );
                    }
                  },
                ),
                UIHelper.verticalSpace(32.h),

                Obx(
                  () => Visibility(
                    visible: otpValidationController.loader.value == false,
                    replacement: WaitingWidget(),
                    child: CustomElevatedButton(
                      onTap: () {
                        if (forForgetPassword == false) {
                          otpValidationController.handleSendOtpSignUp(
                            email: email ?? '',
                          );
                        } else {
                          Get.toNamed(
                            Routes.setNewPasswordScreen,
                            arguments: {
                              'email': email ?? '',
                              'otpCode': otpValidationController.pin.value,
                            },
                          );
                        }
                      },
                      buttonTitle: 'verify_email'.tr,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../constants/text_font_style.dart';
import '../../../controllers/otp_validation_controller.dart';
import '../../../gen/assets.gen.dart';
import '../../../helpers/ui_helpers.dart';
import 'widgets/pinput_widget.dart';

class VerifyOtpScreen extends StatelessWidget {
  VerifyOtpScreen({super.key});

  OtpValidationController controller = Get.put(OtpValidationController());

  @override
  Widget build(BuildContext context) {
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
                  "Verify OTP",
                  style: TextFontStyle.headline24w700c000000StyleSatoshi,
                ),
                UIHelper.verticalSpace(14.h),

                ///Section : text -> Please check your phone number and enter the code
                Text(
                  "Please check your phone number and enter the code",
                  style: TextFontStyle.headline12w400c414141StyleSatoshi,
                ),
                UIHelper.verticalSpace(32.h),

                ///Section : OTP Form Field
                CustomPinInput(),
                UIHelper.verticalSpace(32.h),

                CustomElevatedButton(
                  onTap: () {
                    log("Verify Email button taped!");
                    Get.toNamed(Routes.setNewPasswordScreen);
                  },
                  buttonTitle: "Verify Email",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

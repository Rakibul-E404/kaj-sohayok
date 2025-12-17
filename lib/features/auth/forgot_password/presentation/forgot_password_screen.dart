import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/custom_widgets/custom_text_form_field.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/helpers/waiting_widget.dart';

import '../../../../controllers/forget_password_controller.dart';
import '../../../../gen/assets.gen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgetPasswordController forgetPasswordController = Get.put(
      ForgetPasswordController(),
    );
    forgetPasswordController.emailTEController.text =
        Get.arguments['email'] ?? '';
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: Form(
            key: forgetPasswordController.formKey,
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
                  'password_forgot'.tr,
                  style: TextFontStyle.headline10w700c000000StyleSatoshi,
                ),
                UIHelper.verticalSpace(14.h),

                ///Section : Text -> Please Enter your phone...
                Text(
                  'enter_your_email_to_reset_password'.tr,
                  style: TextFontStyle.headline12w400c000000StyleSatoshi,
                ),
                UIHelper.verticalSpace(32.h),

                ///Section : Email Form field
                CustomFormField(
                  labelText: 'your_email'.tr,
                  hintText: 'enter_your_email'.tr,
                  prefixIcon: Icon(Icons.mail, color: AppColors.c858c94),
                  controller: forgetPasswordController.emailTEController,
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) {
                      return 'please_enter_your_email'.tr;
                    }
                    return null;
                  },
                ),
                Spacer(),

                ///Section : Button -> Send OTP
                Obx(
                  () => Visibility(
                    visible: forgetPasswordController.loader.value == false,
                    replacement: WaitingWidget(),
                    child: CustomElevatedButton(
                      onTap: () {
                        forgetPasswordController.handleForgetPassword();
                      },
                      buttonTitle: 'send_otp'.tr,
                    ),
                  ),
                ),
                UIHelper.verticalSpace(32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

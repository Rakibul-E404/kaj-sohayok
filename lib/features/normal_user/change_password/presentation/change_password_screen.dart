import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../controllers/change_password_screen_controller.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../helpers/custom_text_form_field.dart';
import '../../../../helpers/ui_helpers.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  ChangePasswordScreenController controller = Get.put(
    ChangePasswordScreenController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        title: Text(
          "Change Password",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                return CustomFormField(
                  controller: controller.oldPasswordController,
                  labelText: "Old Password",
                  hintText: "Enter Password",
                  isPass: true,

                  isObsecure: controller.isVisibleOldPassword.value,
                  prefixIcon: SvgPicture.asset(
                    fit: BoxFit.contain,
                    Assets.icons.lockIcon,
                  ),
                  suffixIcon: InkWell(
                    onTap: () {
                      log(
                        "Old Password visibility Icon taped! ${controller.isVisibleOldPassword.value}",
                      );
                      controller.setOldPasswrdVisibility();
                    },
                    child: Icon(
                      controller.isVisibleOldPassword.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.c6b6b6b,
                    ),
                  ),
                );
              }),
              UIHelper.verticalSpace(16.h),

              ///Section : New Passwrd Form Field
              Obx(() {
                return CustomFormField(
                  controller: controller.newPasswordController,
                  labelText: "New Password",
                  hintText: "Enter Password",
                  isPass: true,

                  isObsecure: controller.isVisibleNewPassword.value,
                  prefixIcon: SvgPicture.asset(
                    fit: BoxFit.contain,
                    Assets.icons.lockIcon,
                  ),
                  suffixIcon: InkWell(
                    onTap: () {
                      log(
                        "Old Password visibility Icon taped! ${controller.isVisibleNewPassword.value}",
                      );
                      controller.setNewPasswrdVisibility();
                    },
                    child: Icon(
                      controller.isVisibleNewPassword.value
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
                  controller: controller.confirmPasswordController,
                  labelText: "Confirm Password",
                  hintText: "Enter Password",
                  isPass: true,

                  isObsecure: controller.isVisibleConfirmPassword.value,
                  prefixIcon: SvgPicture.asset(
                    fit: BoxFit.contain,
                    Assets.icons.lockIcon,
                  ),
                  suffixIcon: InkWell(
                    onTap: () {
                      log(
                        "Old Password visibility Icon taped! ${controller.isVisibleConfirmPassword.value}",
                      );
                      controller.setConfirmPasswrdVisibility();
                    },
                    child: Icon(
                      controller.isVisibleConfirmPassword.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.c6b6b6b,
                    ),
                  ),
                );
              }),
              UIHelper.verticalSpace(16.h),
              Spacer(),

              CustomElevatedButton(
                onTap: () {},
                buttonTitle: "Change Password",
              ),
              UIHelper.verticalSpace(16.h),
            ],
          ),
        ),
      ),
    );
  }
}

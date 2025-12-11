import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/waiting_widget.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../controllers/change_password_screen_controller.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../custom_widgets/custom_text_form_field.dart';
import '../../../../helpers/ui_helpers.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ChangePasswordScreenController controller = Get.put(
      ChangePasswordScreenController(),
    );
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Obx(
        () => Visibility(
          visible: controller.loader.value == false,
          replacement: WaitingWidget(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.9),
            child: CustomElevatedButton(
              onTap: () {
                controller.loader.value == true
                    ? () {}
                    : controller.handleChangePassword();
              },
              buttonTitle: "Change Password",
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Old Password !!';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter New Password !!';
                        }
              
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm password !!';
                        } else if (value !=
                            controller.newPasswordController.text) {
                          return "Passwords do not match !!";
                        }
                        return null;
                      },
                    );
                  }),
                  UIHelper.verticalSpace(16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

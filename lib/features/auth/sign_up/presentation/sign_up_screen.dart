import 'dart:developer';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/sign_up_screen_controller.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/features/auth/sign_up/widgets/gender_selection.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/loading_helper.dart';
import 'package:kaz_bd/service/location/location_controller.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../custom_widgets/custom_text_form_field.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../helpers/waiting_widget.dart';
import '../../../../routes/routes.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  UserSignUpController userSignUpController = Get.put(UserSignUpController());

  // LocationController locationController = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Form(
              key: userSignUpController.formKey,
              child: Column(
                children: [
                  ///Section : Button -> BackButton
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.c858c94,
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(22.h),

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
                    "Sign Up Your Account",
                    style: TextFontStyle.headline24w700c000000StyleSatoshi,
                  ),
                  UIHelper.verticalSpace(14.h),

                  ///Section : Text -> Please Fillup Your Details.
                  Text(
                    "Please Fill In Your Details.",
                    style: TextFontStyle.headline12w400c414141StyleSatoshi,
                  ),
                  UIHelper.verticalSpace(32.h),

                  ///Section : Name Form Field
                  CustomFormField(
                    labelText: "User Name",
                    hintText: "Enter username",
                    controller: userSignUpController.userNameTEController,
                    // hintTextStyle: ,
                    prefixIcon: SvgPicture.asset(Assets.icons.personIcon),
                    validator: (String? value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please Enter Your Username';
                      }
                      return null;
                    },
                  ),
                  UIHelper.verticalSpace(16.h),

                  ///Section : Email Form Field
                  CustomFormField(
                    controller: userSignUpController.emailTEController,

                    labelText: "Your Email",
                    hintText: "Enter Your Email",
                    // hintTextStyle: ,
                    prefixIcon: Icon(Icons.mail, color: AppColors.c8c8c8c),
                    validator: (String? value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please Enter Your Email';
                      }
                      return null;
                    },
                  ),
                  UIHelper.verticalSpace(16.h),

                  /// Section : Mobile Number Form Field
                  Obx(() {
                    return CustomFormField(
                      inputType: TextInputType.number,
                      labelText: "Your Number",
                      controller: userSignUpController.phoneNumberTEController,
                      hintText: "Enter Your Number",
                      gapBetweenPrefixIconAndDivider: 2.w,
                      onChanged: (value) {
                        userSignUpController.isMobileNumberEmpty.value =
                            value.isEmpty;
                      },
                      prefixIconPadding: 0.sp,
                      prefixIcon: CountryCodePicker(
                        padding: EdgeInsets.zero,
                        showFlag:
                            userSignUpController.isMobileNumberEmpty.value,
                        onChanged: (country) {
                          log(
                            "Selected country: ${country.name}, ${country.dialCode}",
                          );
                        },
                        initialSelection: 'BD',
                        favorite: ['+880', 'BD'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                      ),
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please Enter Your Phone Number';
                        }
                        return null;
                      },
                    );
                  }),

                  UIHelper.verticalSpace(16.h),

                  ///Section : Location Form Field

                  // ElevatedButton(
                  //   onPressed: () async {
                  //     print('popo');
                  //     await locationController.fetchCurrentLocation();
                  //     debugPrint(
                  //       // 'Lat: ${pos.latitude}, Lon: ${pos.longitude}'
                  //       // '${(locationController.currentAddress.value?.locality ?? '')},${(locationController.currentAddress.value?.country ?? '')} ', // Dhaka
                  //       '${(locationController.currentPosition.value?.latitude ?? '')},${(locationController.currentPosition.value?.longitude ?? '')} ', // Dhaka
                  //     );
                  //   },
                  //   child: Text('Lopp'),
                  // ),
                  UIHelper.verticalSpace(16.h),

                  ///Section : Date of Birth Form Field
                  InkWell(
                    onTap: () {
                      userSignUpController.pickDateOfBirth(context);
                    },
                    child: CustomFormField(
                      controller: userSignUpController.dateOfBirthTEController,
                      labelText: "Date of Birth",
                      hintText: "MM/DD/YYYY",
                      isEnabled: false,
                      prefixIcon: SvgPicture.asset(
                        fit: BoxFit.contain,
                        Assets.icons.calendarLogo,
                      ),
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please Enter Your Date Of Birth';
                        }
                        return null;
                      },
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  ///Section : Gender Form Field
                  GenderSelectionWidget(),
                  UIHelper.verticalSpace(16.h),

                  ///Section : Password Form Field
                  Obx(() {
                    return CustomFormField(
                      controller: userSignUpController.passwordTEController,
                      labelText: "Password",
                      hintText: "Enter Password",
                      isPass: true,

                      isObsecure: userSignUpController.isVisible.value,
                      prefixIcon: SvgPicture.asset(
                        fit: BoxFit.contain,
                        Assets.icons.lockIcon,
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          log(
                            "Password visibility Icon taped! ${userSignUpController.isVisible.value}",
                          );
                          userSignUpController.setPasswrdVisibility();
                        },
                        child: Icon(
                          userSignUpController.isVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.c6b6b6b,
                        ),
                      ),
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please Enter Your password ';
                        }
                        return null;
                      },
                    );
                  }),
                  UIHelper.verticalSpace(24.h),

                  ///Section : Button -> Check
                  ///Section : By creating an account, I accept the Terms & Conditions & Privacy Policy.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Obx(() {
                        return Checkbox(
                          value: userSignUpController.isCheckboxTaped.value,
                          onChanged: (value) {
                            log(
                              "Terms & Condition checkbox Taped! ${userSignUpController.isCheckboxTaped.value}",
                            );
                            userSignUpController.setCheckboxValue(value!);
                          },
                          activeColor: AppColors.c778beb,
                          side: BorderSide(color: AppColors.c8c8c8c),
                        );
                      }),
                      UIHelper.horizontalSpace(10.w),

                      Expanded(
                        child: InkWell(
                          onTap: () {
                            userSignUpController.setCheckboxValue(
                              !userSignUpController.isCheckboxTaped.value,
                            );
                          },
                          child: Text(
                            "By creating an account, I accept the Terms & Conditions & Privacy Policy.",
                            style:
                                TextFontStyle.headline12w400c000000StyleSatoshi,
                          ),
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(32.h),

                  ///Section : Button : Sign up
                  Obx(
                    () => Visibility(
                      visible: userSignUpController.loader.value == false,
                      replacement: WaitingWidget(),
                      child: CustomElevatedButton(
                        buttonColor: userSignUpController.isCheckboxTaped.value
                            ? AppColors.c778beb
                            : AppColors.c778beb.withValues(alpha: 0.4),
                        onTap: () async {
                          // Get.toNamed(Routes.signInScreen);

                          await userSignUpController.handleSignUp();
                        },
                        buttonTitle: "Sign Up",
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(32.h),

                  ///Section : Already have account...
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have account?",
                        style: TextFontStyle.headline14w500c606060StyleSatoshi,
                      ),
                      UIHelper.horizontalSpace(10.w),
                      InkWell(
                        onTap: () {
                          log("Sign Up Button Taped!");
                          Get.toNamed(Routes.signInScreen);
                        },
                        child: Text(
                          "Sign in",
                          style:
                              TextFontStyle.headline14w700c000000StyleSatoshi,
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(32.h),

                  /// Section : Text -> OR
                  Text(
                    "OR",
                    style: TextFontStyle.headline10w700c000000StyleSatoshi,
                  ),
                  UIHelper.verticalSpace(32.h),

                  ///Section : Button -> Sign Up with google
                  CustomElevatedButton(
                    onTap: () {
                      log("Sign Up with google button taped!");
                    },
                    buttonColor: AppColors.ce6e6e6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(Assets.icons.googleIcon),
                        UIHelper.horizontalSpace(10.w),
                        Text(
                          "Sign up with Google",
                          style:
                              TextFontStyle.headline12w500c000000StyleSatoshi,
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

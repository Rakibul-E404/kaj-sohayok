import 'dart:developer';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/sign_up_screen_controller.dart';
import 'package:kaz_bd/features/auth/sign_up/widgets/gender_selection.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../helpers/custom_text_form_field.dart';
import '../../../../helpers/ui_helpers.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  SignUpScreenController controller = Get.put(SignUpScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
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
                  style: TextFontStyle.headline20w700c000000StyleSatoshi,
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
                  // hintTextStyle: ,
                  prefixIcon: Container(
                    padding: EdgeInsets.all(4.sp),
                    decoration: BoxDecoration(
                      color: AppColors.c8c8c8c,
                      shape: BoxShape.circle,
                    ),

                    child: Icon(Icons.person, color: AppColors.cFFFFFF),
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Email Form Field
                CustomFormField(
                  labelText: "Your Email",
                  hintText: "Enter Your Email",
                  // hintTextStyle: ,
                  prefixIcon: Icon(Icons.mail, color: AppColors.c8c8c8c),
                ),
                UIHelper.verticalSpace(16.h),

                /// Section : Mobile Number Form Field
                CustomFormField(
                  labelText: "Your Number",
                  hintText: "Enter Your Number",
                  prefixIcon: CountryCodePicker(
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
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Location Form Field
                CustomFormField(
                  labelText: "Location",
                  hintText: "Enter Your Location",
                  // hintTextStyle: ,
                  prefixIcon: SvgPicture.asset(
                    fit: BoxFit.contain,
                    Assets.icons.locationLogo,
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Date of Birth Form Field
                InkWell(
                  onTap: () {
                    controller.pickDateOfBirth(context);
                  },
                  child: CustomFormField(
                    controller: controller.dateOfBirthController,
                    labelText: "Date of Birth",
                    hintText: "MM/DD/YYYY",
                    isEnabled: false,
                    prefixIcon: SvgPicture.asset(
                      fit: BoxFit.contain,
                      Assets.icons.calendarLogo,
                    ),
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Gender Form Field
                // InkWell(
                //   onTap: () {
                //     GenderSelectionWidget();
                //   },
                //   child: CustomFormField(
                //     controller: controller.genderController,
                //     labelText: "Gender",
                //     hintText: "Select gender ",
                //     isEnabled: false,
                //     prefixIcon: SvgPicture.asset(
                //       fit: BoxFit.contain,
                //       Assets.icons.genderLogo,
                //     ),
                //   ),
                // ),
                GenderSelectionWidget(),
                UIHelper.verticalSpace(16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

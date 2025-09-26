import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../controllers/svp_edit_profile_screen_controller.dart';
import '../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../gen/colors.gen.dart';
import '../widgets/edit_profile_formfield_widget.dart';

class SvpEditProfileScreen extends StatelessWidget {
  SvpEditProfileScreen({super.key});

  final SvpEditProfileScreenController controlelr = Get.put(
    SvpEditProfileScreenController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        title: Text(
          "Edit Profile",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              children: [
                Container(
                  width: 1.sw,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cFFFFFF,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ca4b1f2.withAlpha(80),
                        blurRadius: 12.r,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      ///Section : Name Form Field
                      EditProfileFormFieldWidget(
                        lableText: "Name",
                        hintText: "Enter Your Name",
                        controller: controlelr.nameController,
                      ),
                      UIHelper.verticalSpace(16.h),

                      ///Section : Email Form Field
                      EditProfileFormFieldWidget(
                        lableText: "Email",
                        hintText: "Enter Your Email",
                        controller: controlelr.emailController,
                      ),
                      UIHelper.verticalSpace(16.h),

                      ///Section : Phone Number Form Field
                      EditProfileFormFieldWidget(
                        lableText: "Phone Number",
                        hintText: "Enter Your Phone Number",
                        controller: controlelr.phoneNumberController,
                      ),
                      UIHelper.verticalSpace(16.h),

                      ///Section : Location Form Field
                      EditProfileFormFieldWidget(
                        lableText: "Location",
                        hintText: "Enter Your Location",
                        controller: controlelr.locationController,
                      ),
                      UIHelper.verticalSpace(16.h),

                      ///Section : Date of Birth Form Field
                      EditProfileFormFieldWidget(
                        lableText: "Date of Birth",
                        hintText: "Enter Your Location",
                        controller: controlelr.dateOfBirthController,
                      ),
                      UIHelper.verticalSpace(16.h),

                      ///Section : Gender Form Field
                      EditProfileFormFieldWidget(
                        lableText: "Gender",
                        hintText: "Enter Your Gender",
                        controller: controlelr.genderController,
                      ),
                    ],
                  ),
                ),
                UIHelper.verticalSpace(110.h),

                CustomElevatedButton(
                  onTap: () {
                    Get.back();
                  },
                  buttonTitle: "Update Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

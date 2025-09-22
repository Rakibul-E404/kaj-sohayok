import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../controllers/more_information_screen_controller.dart';
import '../widgets/more_info_screen_image_uploading_widget.dart';
import '../widgets/more_info_widget_tile.dart';

class MoreInformationScreen extends StatelessWidget {
  MoreInformationScreen({super.key});

  final MoreInformationScreenController controller = Get.put(
    MoreInformationScreenController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              children: [
                ///Section : Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.c858c94,
                      size: 24.sp,
                    ),
                  ),
                ),
                UIHelper.verticalSpace(22.h),

                ///Section : Work Type

                ///Section : Years Of Experience
                MoreInfoWidgetTile(
                  title: "Years of Experience*",
                  hintText: "Enter years of Experience",
                  controller: controller.yearsOfExperienceController,
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Start from Work Price*
                MoreInfoWidgetTile(
                  title: "Start from Work Price*",
                  hintText: "Type Now",
                  controller: controller.yearsOfExperienceController,
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : upload NID/driving license/passport(font side)*
                Obx(() {
                  return MoreInfoScreenImageUploadWidget(
                    onTap: () {
                      log("Front Image : Browse Button Tapede");
                      controller.showImageSourceDialog(isFront: true);
                    },
                    removeImageOnTap: () {
                      controller.removeImage(isFront: true);
                    },
                    imagePath: controller.imageFontSide.value,
                    title: "Upload NID/Driving License/Passport(Font Side)*",
                  );
                }),
                UIHelper.verticalSpace(16.h),

                ///Section : upload NID/driving license/passport(Back side)*
                Obx(() {
                  return MoreInfoScreenImageUploadWidget(
                    onTap: () {
                      log("Back Image : Browse Button Taped!");
                      controller.showImageSourceDialog(isFront: false);
                    },
                    removeImageOnTap: () {
                      controller.removeImage(isFront: false);
                    },
                    imagePath: controller.imageBackSide.value,
                    title: "Upload NID/Driving License/Passport(Font Side)*",
                  );
                }),
                UIHelper.verticalSpace(16.h),

                ///Section : Butto -> Back
                ///Section : Button -> Next
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ///Section : Button -> Back
                    CustomElevatedButton(
                      onTap: () {
                        log("Back Button Taped!");
                      },
                      buttonWidth: 150.w,
                      buttonTitle: "Back",
                      textStyle:
                          TextFontStyle.headline16w500c202020StyleSatoshi,
                      isButtonBorderUsed: true,
                      buttonColor: AppColors.cFFFFFF,
                    ),
                    UIHelper.horizontalSpace(12.w),

                    ///Section : Button -> Next
                    CustomElevatedButton(
                      onTap: () {
                        log("Next Button Taped!");
                      },
                      buttonWidth: 150.w,
                      buttonTitle: "Next",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

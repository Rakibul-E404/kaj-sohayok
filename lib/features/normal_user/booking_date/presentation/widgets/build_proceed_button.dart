import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../../routes/routes.dart';

class BuildProceedButton extends StatelessWidget {
  const BuildProceedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      onTap: () {
        Get.toNamed(Routes.searchLocationScreen);
        log("Proceed button pressed");
      },
      buttonTitle: "Proceed",
      textStyle: TextFontStyle.headline16w700cFFFFFFStyleSatoshi,
      buttonColor: AppColors.c778beb,
      borderRadius: 12.r,
    );
  }
}

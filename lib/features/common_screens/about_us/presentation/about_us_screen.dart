import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constant_text.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("About us"),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Section : Last Privacy Policy updated date
                Text(
                  "Last Update Feb 2025",
                  style: TextFontStyle.headline12w500c778bebStyleSatoshi,
                ),
                UIHelper.verticalSpace(6.h),

                ///Section : Text -> Privacy policy
                Text(
                  "About us",
                  style: TextFontStyle.headline18w700c000000StyleSatoshi,
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Privacy Policy text
                Text(
                  AppText.longDemoText,
                  style: TextFontStyle.headline14w400c111111StyleSatoshi,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

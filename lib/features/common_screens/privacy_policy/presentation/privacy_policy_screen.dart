import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kaz_bd/constants/app_constant_text.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../custom_widgets/html_wrapper.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String bodyText = Get.arguments['data'] ?? '';
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Privacy policy",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
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
                UIHelper.verticalSpace(6.h),

                ///Section : Text -> Privacy policy
                Text(
                  "Privacy policy",
                  style: TextFontStyle.headline18w700c000000StyleSatoshi,
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Privacy Policy text
                HtmlWrapper(htmlContent: bodyText)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

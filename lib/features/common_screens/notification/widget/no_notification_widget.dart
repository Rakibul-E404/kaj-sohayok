import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

class NoNotificationWidget extends StatelessWidget {
  const NoNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ///Section : Berll Icon
        Image.asset(
          height: 170.h,
          width: 178.w,
          fit: BoxFit.cover,
          Assets.images.bellImage.path,
        ),
        UIHelper.verticalSpace(24.h),

        Text(
          'no_notification_yet'.tr,
          style: TextFontStyle.headline20w700c202020StyleSatoshi,
        ),
        UIHelper.verticalSpace(8.h),

        ///Section : Text -> You have no notifications right now. Come back later.
        Text(
          'no_notification_right_now'.tr,
          textAlign: TextAlign.center,
          style: TextFontStyle.headline14w400c4d4d4dStyleSatoshi,
        ),
      ],
    );
  }
}

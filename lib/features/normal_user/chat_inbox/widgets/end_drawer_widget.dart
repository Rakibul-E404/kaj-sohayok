import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';

import '../../../../gen/colors.gen.dart';

class EndDrawerWidget extends StatelessWidget {
  const EndDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 0.55.sw,
            height: 0.15.sh,
            child: Drawer(
              backgroundColor: AppColors.cFFFFFF,
              child: SafeArea(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.delete, color: AppColors.c111111),
                      title: Text(
                        'delete_message'.tr,
                        style: TextFontStyle.headline14w500c111111StyleSatoshi,
                      ),
                      onTap: () {
                        // Handle mute notifications
                        Get.back();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.person, color: AppColors.c111111),
                      title: Text(
                        'profile_view'.tr,
                        style: TextFontStyle.headline14w500c111111StyleSatoshi,
                      ),
                      onTap: () {
                        // Handle block user
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

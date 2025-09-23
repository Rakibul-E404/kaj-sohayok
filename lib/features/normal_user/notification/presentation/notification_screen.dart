import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kaz_bd/constants/appList.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/features/normal_user/notification/widget/no_notification_widget.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../widget/notification_showing_widget.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Notification",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),

      body: Padding(
        padding: EdgeInsetsGeometry.all(UIHelper.kDefaulutPadding()),
        child: AppList.notificationList.isEmpty
            ? Center(child: NoNotificationWidget())
            : ListView.separated(
                // shrinkWrap: true,
                // physics: const NeverScrollableScrollPhysics(),
                itemCount: AppList.notificationList.length,
                separatorBuilder: (context, index) =>
                    UIHelper.verticalSpace(16.h),
                itemBuilder: (context, index) {
                  var data = AppList.notificationList[index];

                  log(
                    "Is Notification List Empty ? : ${AppList.notificationList.isEmpty}",
                  );
                  return NotificationShowingWidget(
                    notificationIcon: Assets.icons.bellIcon,
                    notificationTitle: data.title,
                    notificationTime: data.time.toString(),
                  );
                },
              ),
      ),
    );
  }
}

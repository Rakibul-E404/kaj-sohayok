import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
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

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(UIHelper.kDefaulutPadding()),
          child: ListView.separated(
            itemCount: 20,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
            itemBuilder: (context, index) {
              return NotificationShowingWidget(
                notificationIcon: Assets.icons.bellIcon,
                notificationTitle: "Your Password Updated Successfully!",
                notificationTime: "10",
              );
            },
          ),
        ),
      ),
    );
  }
}

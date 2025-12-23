import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class NotificationShowingWidget extends StatelessWidget {
  final String notificationIcon;
  final String notificationTitle;
  final String notificationTime;
  const NotificationShowingWidget({
    super.key,
    required this.notificationIcon,
    required this.notificationTitle,
    required this.notificationTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        border: Border.all(color: AppColors.cb5b5b5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          ///Section : Notification Icon
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.c92a2ef,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(notificationIcon),
          ),
          UIHelper.horizontalSpace(8.w),

          ///Section : Notification Title
          ///Section : Notification Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notificationTitle,
                  style: TextFontStyle.headline16w500c000000StyleSatoshi,
                ),
                UIHelper.verticalSpace(5.h),
                Text(
                  "$notificationTime ",
                  style: TextFontStyle.headline10w400c999999StyleSatoshi,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

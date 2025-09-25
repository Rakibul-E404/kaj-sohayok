import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/custom_widgets/date_and_time_widget_tile.dart';

import '../constants/text_font_style.dart';
import '../gen/colors.gen.dart';
import '../helpers/ui_helpers.dart';

class WorkAddressAndDateWidget extends StatelessWidget {
  final String address;
  final String dateTime;

  const WorkAddressAndDateWidget({
    super.key,
    required this.address,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        border: Border.all(color: AppColors.ce6e6e6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///Section : Working Address
          Container(
            width: 1.sw,
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: AppColors.cf1f3fd,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              "Working Address",
              style: TextFontStyle.headline16w500c000000StyleSatoshi,
            ),
          ),
          UIHelper.verticalSpace(14.h),

          ///Section : -> Address
          DateAndAddressWidgetTile(icon: Icons.location_on, title: address),
          UIHelper.verticalSpace(14.h),

          ///Section : Working Address
          Container(
            width: 1.sw,
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: AppColors.cf1f3fd,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              "Booking Order Date",
              style: TextFontStyle.headline16w500c000000StyleSatoshi,
            ),
          ),
          UIHelper.verticalSpace(14.h),

          ///Section : -> Order Date
          DateAndAddressWidgetTile(icon: Icons.watch_later, title: dateTime),
          UIHelper.verticalSpace(14.h),
        ],
      ),
    );
  }
}

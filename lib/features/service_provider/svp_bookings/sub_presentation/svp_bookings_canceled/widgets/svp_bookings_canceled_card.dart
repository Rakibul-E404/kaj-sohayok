/**
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/text_font_style.dart';
import '../../../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../../../custom_widgets/date_and_time_widget_tile.dart';
import '../../../../../../custom_widgets/dotted_line_divider_widget.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';

class SvpBookingsCanceledCard extends StatelessWidget {
  final String userImage;
  final String userName;
  final String location;
  final String dateTime;
  final void Function()? cancelButtonOnTap;
  const SvpBookingsCanceledCard({
    super.key,
    required this.userImage,
    required this.userName,
    required this.location,
    required this.dateTime,
    this.cancelButtonOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        border: Border.all(color: AppColors.ce6e6e6),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.ca4b1f2.withAlpha(80),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ///Section : User Image
          ///Section : User Name
          Container(
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: AppColors.cf1f3fd,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              children: [
                ///Section : User Profile Image
                CircleAvatar(
                  radius: 24.r,
                  backgroundImage: AssetImage(userImage),
                ),
                UIHelper.horizontalSpace(6.w),

                ///Section : User Name
                Expanded(
                  child: Text(
                    userName,
                    style: TextFontStyle.headline16w500c000000StyleSatoshi,
                  ),
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(14.h),

          ///Section : Divider
          DottedLineDividerWidget(),
          UIHelper.verticalSpace(12.h),

          ///Section : Location
          DateAndAddressWidgetTile(icon: Icons.location_on, title: location),

          UIHelper.verticalSpace(6.h),

          ///Section : Date And Time
          DateAndAddressWidgetTile(icon: Icons.watch_later, title: dateTime),

          UIHelper.verticalSpace(12.h),

          ///Section : Divider
          DottedLineDividerWidget(),
          UIHelper.verticalSpace(12.h),

          ///Section : PendingTab -> Button -> Cancel/Accept
          Align(
            alignment: Alignment.centerRight,
            child: CustomElevatedButton(
              onTap: cancelButtonOnTap,
              buttonWidth: 110.w,
              buttonHeight: 38.h,
              buttonColor: AppColors.cfce9e9,

              buttonTitle: "Cancel",
              textStyle: TextFontStyle.headline14w500ce73d3dStyleSatoshi,
            ),
          ),
        ],
      ),
    );
  }
}
*/

///
///
///
/// todo:: fetching from hte api
///
///
///
///

// lib/.../widgets/svp_bookings_canceled_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../custom_widgets/date_and_time_widget_tile.dart';
import '../../../../../../custom_widgets/dotted_line_divider_widget.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';

class SvpBookingsCanceledCard extends StatelessWidget {
  final String userImage; // This is a URL
  final String userName;
  final String location;
  final String dateTime;
  final void Function()? cancelButtonOnTap;

  const SvpBookingsCanceledCard({
    super.key,
    required this.userImage,
    required this.userName,
    required this.location,
    required this.dateTime,
    this.cancelButtonOnTap,
  });

  @override
  Widget build(BuildContext context) {
    final cleanImageUrl = userImage.trim();

    return Container(
      width: 1.sw,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        border: Border.all(color: AppColors.ce6e6e6),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.ca4b1f2.withAlpha(80),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// User Image & Name
          Container(
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: AppColors.cf1f3fd,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              children: [
                /// ✅ FIXED: Use NetworkImage for remote URLs
                CircleAvatar(
                  radius: 24.r,
                  backgroundImage: cleanImageUrl.isNotEmpty
                      ? NetworkImage(cleanImageUrl)
                      : const AssetImage('assets/images/default_profile.png'),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Fallback already handled by AssetImage
                  },
                ),
                UIHelper.horizontalSpace(6.w),

                Expanded(
                  child: Text(
                    userName,
                    style: TextFontStyle.headline16w500c000000StyleSatoshi,
                  ),
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(14.h),

          DottedLineDividerWidget(),
          UIHelper.verticalSpace(12.h),

          DateAndAddressWidgetTile(icon: Icons.location_on, title: location),
          UIHelper.verticalSpace(6.h),
          DateAndAddressWidgetTile(icon: Icons.watch_later, title: dateTime),
          UIHelper.verticalSpace(12.h),
        ],
      ),
    );
  }
}

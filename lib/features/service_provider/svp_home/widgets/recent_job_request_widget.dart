import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaz_bd/gen/assets.gen.dart';

import '../../../../constants/app_constant_text.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class RecentJobRequestWidget extends StatelessWidget {
  final String userImage;
  final String userName;
  final String location;
  final String dateTime;
  final bool isJobRequestAccpted;
  final void Function()? onTap;
  final void Function()? cancelOnTap;
  final void Function()? acceptOnTap;
  final void Function()? startWorkOnTap;
  final void Function()? messageOnTap;
  RecentJobRequestWidget({
    super.key,
    this.onTap,
    required this.userImage,
    required this.userName,
    required this.location,
    required this.dateTime,
    this.cancelOnTap,
    this.acceptOnTap,
    this.isJobRequestAccpted = false,
    this.startWorkOnTap,
    this.messageOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
            DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 1.sp,
              dashLength: 4.w,
              dashGapLength: 4.w,
              dashColor: AppColors.cb4b4b4,
            ),
            UIHelper.verticalSpace(12.h),

            ///Section : Location
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: AppColors.c92a2ef, size: 24.sp),
                UIHelper.horizontalSpace(4.w),
                Text(
                  location,
                  style: TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                ),
              ],
            ),
            UIHelper.verticalSpace(6.h),

            ///Section : Date And Time
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.watch_later, color: AppColors.c92a2ef, size: 24.sp),
                UIHelper.horizontalSpace(4.w),
                Text(
                  dateTime,
                  style: TextFontStyle.headline12w500c4d4d4dStyleSatoshi,
                ),
              ],
            ),
            UIHelper.verticalSpace(12.h),

            ///Section : Divider
            DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 1.sp,
              dashLength: 4.w,
              dashGapLength: 4.w,
              dashColor: AppColors.cb4b4b4,
            ),
            UIHelper.verticalSpace(12.h),

            ///Section : PendingTab -> Button -> Cancel/Accept
            isJobRequestAccpted
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomElevatedButton(
                        onTap: startWorkOnTap,
                        buttonWidth: 108.w,
                        buttonHeight: 38.h,
                        buttonTitle: "Start Work",
                      ),
                      UIHelper.horizontalSpace(12.w),
                      CustomElevatedButton(
                        onTap: messageOnTap,
                        buttonWidth: 108.w,
                        buttonHeight: 38.h,
                        isButtonBorderUsed: true,
                        buttonBorderWidth: 1.5.sp,
                        buttonBorderColor: AppColors.c778beb,
                        buttonTitle: "Message",
                        textStyle:
                            TextFontStyle.headline14w500c111111StyleSatoshi,
                        buttonColor: AppColors.cFFFFFF,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomElevatedButton(
                        onTap: cancelOnTap,
                        buttonTitle: "Cancel",
                        textStyle:
                            TextFontStyle.headline14w500ce73d3dStyleSatoshi,
                        buttonWidth: 108.w,
                        buttonHeight: 38.h,
                        buttonColor: AppColors.cfce9e9,
                      ),
                      UIHelper.horizontalSpace(12.w),
                      CustomElevatedButton(
                        onTap: acceptOnTap,
                        buttonTitle: "Accept",
                        buttonWidth: 108.w,
                        buttonHeight: 38.h,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

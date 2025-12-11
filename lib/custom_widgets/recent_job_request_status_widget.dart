/**
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/custom_widgets/date_and_time_widget_tile.dart';

import '../constants/text_font_style.dart';
import 'custom_elevated_button.dart';
import '../gen/colors.gen.dart';
import '../helpers/ui_helpers.dart';

class RecentJobRequestStatusWidget extends StatelessWidget {
  final String userImage;
  final String userName;
  final String location;
  final String dateTime;
  final bool isJobRequestAccpted;
  final bool isJobInProgress;
  final bool isJobStatusCompleted;
  final void Function()? onTap;
  final void Function()? cancelOnTap;
  final void Function()? acceptOnTap;
  final void Function()? startWorkOnTap;
  final void Function()? messageOnTap;
  final void Function()? submitWorkButtonOnTap;
  final void Function()? messageButtonOnTap;

  const RecentJobRequestStatusWidget({
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
    this.isJobInProgress = false,
    this.submitWorkButtonOnTap,
    this.messageButtonOnTap,
    this.isJobStatusCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    // Trim the image URL to remove accidental spaces
    final cleanImageUrl = userImage.trim();

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
            /// Section: User Image & Name
            Container(
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: AppColors.cf1f3fd,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                children: [
                  /// User Profile Image — FIXED: Use NetworkImage
                  CircleAvatar(
                    radius: 24.r,
                    backgroundImage: cleanImageUrl.isNotEmpty
                        ? NetworkImage(cleanImageUrl)
                        : const AssetImage('assets/images/default_profile.png'),
                    // Optional: Add error/fallback handling
                    onBackgroundImageError: (exception, stackTrace) {
                      // Fallback to default image if network fails
                    },
                  ),
                  UIHelper.horizontalSpace(6.w),

                  /// User Name
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

            /// Divider
            DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 1.sp,
              dashLength: 4.w,
              dashGapLength: 4.w,
              dashColor: AppColors.cb4b4b4,
            ),
            UIHelper.verticalSpace(12.h),

            /// Location
            DateAndAddressWidgetTile(icon: Icons.location_on, title: location),
            UIHelper.verticalSpace(6.h),

            /// Date & Time
            DateAndAddressWidgetTile(icon: Icons.watch_later, title: dateTime),
            UIHelper.verticalSpace(12.h),

            /// Divider
            DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 1.sp,
              dashLength: 4.w,
              dashGapLength: 4.w,
              dashColor: AppColors.cb4b4b4,
            ),
            UIHelper.verticalSpace(12.h),

            /// Action Buttons (Cancel/Accept, Start Work, Submit, etc.)
            if (isJobStatusCompleted)
              const SizedBox.shrink()
            else if (isJobRequestAccpted)
              Row(
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
                    textStyle: TextFontStyle.headline14w500c111111StyleSatoshi,
                    buttonColor: AppColors.cFFFFFF,
                  ),
                ],
              )
            else if (isJobInProgress)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomElevatedButton(
                      onTap: submitWorkButtonOnTap,
                      buttonWidth: 108.w,
                      buttonHeight: 38.h,
                      buttonTitle: "Submit Work",
                    ),
                    UIHelper.horizontalSpace(12.w),
                    CustomElevatedButton(
                      onTap: messageButtonOnTap,
                      buttonWidth: 108.w,
                      buttonHeight: 38.h,
                      isButtonBorderUsed: true,
                      buttonBorderWidth: 1.5.sp,
                      buttonBorderColor: AppColors.c778beb,
                      buttonTitle: "Message",
                      textStyle: TextFontStyle.headline14w500c111111StyleSatoshi,
                      buttonColor: AppColors.cFFFFFF,
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomElevatedButton(
                      onTap: cancelOnTap,
                      buttonTitle: "Cancel",
                      textStyle: TextFontStyle.headline14w500ce73d3dStyleSatoshi,
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
}*/











///
///
///
///
///
/// todo::: fix the issue
///
///
///
///
///



import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/custom_widgets/date_and_time_widget_tile.dart';

import '../constants/text_font_style.dart';
import 'custom_elevated_button.dart';
import '../gen/colors.gen.dart';
import '../helpers/ui_helpers.dart';

class RecentJobRequestStatusWidget extends StatelessWidget {
  final String userImage;
  final String userName;
  final String location;
  final String dateTime;
  final bool isJobRequestAccpted;
  final bool isJobInProgress;
  final bool isJobStatusCompleted;
  final void Function()? onTap;
  final void Function()? cancelOnTap;
  final void Function()? acceptOnTap;
  final void Function()? startWorkOnTap;
  final void Function()? messageOnTap;
  final void Function()? submitWorkButtonOnTap;
  final void Function()? messageButtonOnTap;
  final bool? isStartWorkLoading; // NEW parameter
  final bool? isWorkStarted; // NEW parameter

  const RecentJobRequestStatusWidget({
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
    this.isJobInProgress = false,
    this.submitWorkButtonOnTap,
    this.messageButtonOnTap,
    this.isJobStatusCompleted = false,
    this.isStartWorkLoading = false, // Default value
    this.isWorkStarted = false, // Default value
  });

  @override
  Widget build(BuildContext context) {
    // Trim the image URL to remove accidental spaces
    final cleanImageUrl = userImage.trim();

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
            /// Section: User Image & Name
            Container(
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: AppColors.cf1f3fd,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                children: [
                  /// User Profile Image — FIXED: Use NetworkImage
                  CircleAvatar(
                    radius: 24.r,
                    backgroundImage: cleanImageUrl.isNotEmpty
                        ? NetworkImage(cleanImageUrl)
                        : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                    // Optional: Add error/fallback handling
                    onBackgroundImageError: (exception, stackTrace) {
                      // Fallback to default image if network fails
                    },
                  ),
                  UIHelper.horizontalSpace(6.w),

                  /// User Name
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

            /// Divider
            DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 1.sp,
              dashLength: 4.w,
              dashGapLength: 4.w,
              dashColor: AppColors.cb4b4b4,
            ),
            UIHelper.verticalSpace(12.h),

            /// Location
            DateAndAddressWidgetTile(icon: Icons.location_on, title: location),
            UIHelper.verticalSpace(6.h),

            /// Date & Time
            DateAndAddressWidgetTile(icon: Icons.watch_later, title: dateTime),
            UIHelper.verticalSpace(12.h),

            /// Divider
            DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 1.sp,
              dashLength: 4.w,
              dashGapLength: 4.w,
              dashColor: AppColors.cb4b4b4,
            ),
            UIHelper.verticalSpace(12.h),

            /// Action Buttons (Cancel/Accept, Start Work, Submit, etc.)
            if (isJobStatusCompleted)
              const SizedBox.shrink()
            else if (isJobRequestAccpted)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Updated Start Work button with loading state
                  if (isStartWorkLoading == true)
                    Container(
                      width: 108.w,
                      height: 38.h,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Center(
                        child: SizedBox(
                          width: 20.h,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: AppColors.cFFFFFF,
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.c000e08,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    )
                  else if (isWorkStarted == true)
                    CustomElevatedButton(
                      onTap: null, // Disabled
                      buttonWidth: 108.w,
                      buttonHeight: 38.h,
                      buttonTitle: "Work Started",
                      buttonColor: AppColors.c000e08, // Green color for started
                    )
                  else
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
                    textStyle: TextFontStyle.headline14w500c111111StyleSatoshi,
                    buttonColor: AppColors.cFFFFFF,
                  ),
                ],
              )
            else if (isJobInProgress)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomElevatedButton(
                      onTap: submitWorkButtonOnTap,
                      buttonWidth: 108.w,
                      buttonHeight: 38.h,
                      buttonTitle: "Submit Work",
                    ),
                    UIHelper.horizontalSpace(12.w),
                    CustomElevatedButton(
                      onTap: messageButtonOnTap,
                      buttonWidth: 108.w,
                      buttonHeight: 38.h,
                      isButtonBorderUsed: true,
                      buttonBorderWidth: 1.5.sp,
                      buttonBorderColor: AppColors.c778beb,
                      buttonTitle: "Message",
                      textStyle: TextFontStyle.headline14w500c111111StyleSatoshi,
                      buttonColor: AppColors.cFFFFFF,
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomElevatedButton(
                      onTap: cancelOnTap,
                      buttonTitle: "Cancel",
                      textStyle: TextFontStyle.headline14w500ce73d3dStyleSatoshi,
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
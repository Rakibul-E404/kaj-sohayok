

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/app_constant_text.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../routes/routes.dart';

class BookingDetailsCardWidget extends StatelessWidget {
  final String title;
  final String location;
  final String dateTime;
  final String initialPayablePrice;
  final String serviceProviderProfileImage;
  final String serviceProviderName;
  final String serviceProviderDesignation;
  final void Function()? onTap;

  final bool isPendingTab;
  final void Function()? isPendingTabCancelOnTap;

  final bool isAcceptedBookingTab;
  final void Function()? isAcceptedBookingTabViewOnTap;
  final void Function()? isAcceptedBookingTabMessageOnTap;

  final bool isInProgressTab;
  final void Function()? isInProgressTabViewOnTap;
  final void Function()? isInProgressTabMessageOnTap;

  final bool isPaymentRequestTab;
  final void Function()? isPaymentRequestTabViewOnTap;
  final void Function()? isPaymentRequestTabPayOnTap;

  final bool isCanceledTab;
  final void Function()? isCanceledTabCancelOnTap;

  final bool isWorkCompletedTab;
  final void Function()? isWorkCompletedTabGiveReviewOnTap;
  final bool isReviewGiven;

  // NEW: Add this parameter to handle network images
  final bool isNetworkImage;

  const BookingDetailsCardWidget({
    Key? key,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.initialPayablePrice,
    required this.serviceProviderProfileImage,
    required this.serviceProviderName,
    required this.serviceProviderDesignation,
    this.onTap,
    this.isPendingTab = false,
    this.isAcceptedBookingTab = false,
    this.isInProgressTab = false,
    this.isPaymentRequestTab = false,
    this.isCanceledTab = false,
    this.isWorkCompletedTab = false,
    this.isPendingTabCancelOnTap,
    this.isAcceptedBookingTabViewOnTap,
    this.isAcceptedBookingTabMessageOnTap,
    this.isInProgressTabViewOnTap,
    this.isInProgressTabMessageOnTap,
    this.isPaymentRequestTabViewOnTap,
    this.isPaymentRequestTabPayOnTap,
    this.isCanceledTabCancelOnTap,
    this.isWorkCompletedTabGiveReviewOnTap,
    this.isReviewGiven = false,
    this.isNetworkImage = false, // NEW: Default to false (asset image)
  }) : super(key: key);

  // NEW: Method to build the profile image widget
  Widget _buildProfileImage() {
    if (isNetworkImage) {
      // Handle network image with error fallback
      return Image.network(
        serviceProviderProfileImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            Assets.images.userImage.path,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      // Handle asset image
      return Image.asset(
        serviceProviderProfileImage,
        fit: BoxFit.cover,
      );
    }
  }

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
            ///Section : Title
            ///Section : Initial Payable Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextFontStyle.headline16w700c4d4d4dStyleSatoshi,
                  ),
                ),
                Spacer(),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Start from ${AppText.bdTkSign}",
                        style: TextFontStyle.headline12w500c6a6a6aStyleSatoshi,
                      ),
                      TextSpan(
                        text: initialPayablePrice,
                        style: TextFontStyle.headline18w700c778bebStyleSatoshi,
                      ),
                    ],
                  ),
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

            ///Section : Service Provider
            Container(
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: AppColors.cf1f3fd,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                children: [
                  ///Section : Service Provider Profile Image
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 24.r,
                        // UPDATED: Use the new image builder method
                        backgroundImage: isNetworkImage
                            ? NetworkImage(serviceProviderProfileImage)
                            : AssetImage(serviceProviderProfileImage) as ImageProvider,
                      ),
                      Positioned(
                        top: 0.h,
                        right: 0.w,
                        child: SvgPicture.asset(Assets.icons.verifiedIcon),
                      ),
                    ],
                  ),
                  UIHelper.horizontalSpace(6.w),

                  ///Section : Service Provider Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///Section : Name
                        Text(
                          serviceProviderName,
                          style:
                          TextFontStyle.headline14w500c000000StyleSatoshi,
                        ),
                        UIHelper.verticalSpace(2.h),

                        ///Section : Service Provider Designation
                        Text(
                          serviceProviderDesignation,
                          style:
                          TextFontStyle.headline10w500c4d4d4dStyleSatoshi,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            UIHelper.verticalSpace(14.h),

            ///Section : PendingTab -> Button -> Cancel
            isPendingTab
                ? Align(
              alignment: Alignment.centerRight,
              child: CustomElevatedButton(
                onTap: isPendingTabCancelOnTap,
                buttonTitle: "Cancel",
                textStyle:
                TextFontStyle.headline14w500ce73d3dStyleSatoshi,
                buttonWidth: 108.w,
                buttonColor: AppColors.cfce9e9,
              ),
            )
                :
            ///Section : Accepted Booking Tab -> Button -> View/Message
            isAcceptedBookingTab
                ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomElevatedButton(
                  onTap: isAcceptedBookingTabViewOnTap,
                  buttonTitle: "View",
                  buttonWidth: 108.w,
                ),
                UIHelper.horizontalSpace(12.w),
                CustomElevatedButton(
                  onTap: isAcceptedBookingTabMessageOnTap,
                  buttonTitle: "Message",
                  textStyle:
                  TextFontStyle.headline14w500c111111StyleSatoshi,
                  buttonWidth: 108.w,
                  isButtonBorderUsed: true,
                  buttonBorderWidth: 1.5,
                  buttonBorderColor: AppColors.c778beb,
                  buttonColor: Colors.transparent,
                ),
              ],
            )
                :
            ///Section : In Progress Tab -> Button -> View/Message
            isInProgressTab
                ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomElevatedButton(
                  onTap: isInProgressTabViewOnTap,
                  buttonTitle: "View",
                  buttonWidth: 108.w,
                ),
                UIHelper.horizontalSpace(12.w),
                CustomElevatedButton(
                  onTap: isInProgressTabMessageOnTap,
                  buttonTitle: "Message",
                  textStyle:
                  TextFontStyle.headline14w500c111111StyleSatoshi,
                  buttonWidth: 108.w,
                  isButtonBorderUsed: true,
                  buttonBorderWidth: 1.5,
                  buttonBorderColor: AppColors.c778beb,
                  buttonColor: Colors.transparent,
                ),
              ],
            )
                :
            ///Section : Payment Request Tab -> Button -> View/Pay
            isPaymentRequestTab
                ? Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomElevatedButton(
                    onTap: isPaymentRequestTabViewOnTap,
                    buttonTitle: "View",
                    buttonWidth: 108.w,
                  ),
                  UIHelper.horizontalSpace(12.w),
                  CustomElevatedButton(
                    onTap: isPaymentRequestTabPayOnTap,
                    buttonTitle: "Pay",
                    textStyle:
                    TextFontStyle.headline14w500c111111StyleSatoshi,
                    buttonWidth: 108.w,
                    isButtonBorderUsed: true,
                    buttonBorderWidth: 1.5,
                    buttonBorderColor: AppColors.c778beb,
                    buttonColor: Colors.transparent,
                  ),
                ],
              ),
            )
                :
            ///Section : Canceled Tab -> Button -> Cancel
            isCanceledTab
                ? Align(
              alignment: Alignment.centerRight,
              child: CustomElevatedButton(
                onTap: isCanceledTabCancelOnTap,
                buttonTitle: "Cancel",
                textStyle:
                TextFontStyle.headline14w500ce73d3dStyleSatoshi,
                buttonWidth: 108.w,
                buttonColor: AppColors.cfce9e9,
              ),
            )
                :
            ///Section : Work Completed Tab -> Button -> Give a Review
            isWorkCompletedTab && isReviewGiven
                ? Align(
              alignment: Alignment.centerRight,
              child: CustomElevatedButton(
                onTap: isWorkCompletedTabGiveReviewOnTap,
                buttonTitle: "Give a Review",
                textStyle:
                TextFontStyle.headline14w500cFFFFFFStyleSatoshi,
                buttonWidth: 110.w,
              ),
            )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}


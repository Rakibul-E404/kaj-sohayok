import 'dart:developer';

import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/app_constant_text.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../gen/colors.gen.dart';
import '../../../../routes/routes.dart';
import '../widgets/address_and_order_date_tile.dart';
import '../widgets/proof_of_work_showing_widget.dart';
import '../widgets/workCompleteDateAndTimeWidget.dart';

class WorkCompletedDetailsScreen extends StatelessWidget {
  const WorkCompletedDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Complete Details",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Work Complete Information ",
                  style: TextFontStyle.headline16w700c000000StyleSatoshi,
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Work Completation Date
                WorkCompleteDateAndTimeWidget(
                  title: "Completion Date",
                  data: "11-08-25",
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Work Duration
                WorkCompleteDateAndTimeWidget(
                  title: "Duration Time",
                  data: "1 Day",
                  isIconVisible: false,
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Working Address
                ///Section : Booking Order Date
                Container(
                  width: 1.sw,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.ce6e6e6),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    children: [
                      ///Section : Working Address
                      AddressAndOrderDateTile(
                        title: "Working Address",
                        icon: Icons.location_on,
                        data: "Rampura Dhaka, Bangladesh",
                      ),
                      UIHelper.verticalSpace(14.h),

                      ///Section : Booking Order Date
                      AddressAndOrderDateTile(
                        title: "Booking Order Date",
                        icon: Icons.watch_later_rounded,
                        data: "Jun 17, 2025  09:31AM",
                      ),
                    ],
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Proof Of Work
                ///Section : Text -> Proof of image
                ///Section : Work Image
                ProofOfWorkShowingWidget(
                  title: "Proof of Image",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: Image.asset(
                      Assets.images.userImage.path,
                      width: 1.sw,
                      height: 200.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Proof Of Work
                ///Section : Text -> Proof of Video
                ///Section : Work Video
                ProofOfWorkShowingWidget(
                  title: "Proof of Video",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: Image.asset(
                      Assets.images.userImage.path,
                      width: 1.sw,
                      height: 200.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Service Provider Image
                ///Section : Service Provider Name
                ///Section : Service Provider
                ///Section : Message
                ///Section : Call
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.serviceProviderProfileDetailsScreen);
                  },
                  child: Container(
                    width: 1.sw,
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                      color: AppColors.cf7f8fd,
                      border: Border.all(color: AppColors.cb4b4b4),
                      borderRadius: BorderRadius.circular(8.r),

                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ca4b1f2.withAlpha(80),
                          blurRadius: 12.r,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        ///Section : Service Provider Image
                        CircleAvatar(
                          radius: 20.r,
                          backgroundImage: AssetImage(
                            Assets.images.userImage.path,
                          ),
                        ),
                        UIHelper.horizontalSpace(6.w),

                        ///Section : Service Provider Name
                        ///Section : Service Provider
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///Section : Service Provider Name
                            Text(
                              "Ripon Mia",
                              style: TextFontStyle
                                  .headline16w500c202020StyleSatoshi,
                            ),
                            UIHelper.verticalSpace(2.h),

                            ///Section : Service Provider
                            Text(
                              "Services Provider",
                              style: TextFontStyle
                                  .headline10w500c4d4d4dStyleSatoshi,
                            ),
                          ],
                        ),
                        Spacer(),

                        ///Section : Message
                        ///Section : Call
                        Row(
                          children: [
                            ///Section : Message
                            InkWell(
                              onTap: () {
                                log("Message Button Taped!");
                              },
                              child: Container(
                                padding: EdgeInsets.all(6.sp),
                                decoration: BoxDecoration(
                                  color: AppColors.c778beb,
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  Assets.icons.messageIcon,
                                ),
                              ),
                            ),
                            UIHelper.horizontalSpace(8.w),

                            ///Section : Call
                            InkWell(
                              onTap: () {
                                log("Call Button Taped!");
                              },
                              child: Container(
                                padding: EdgeInsets.all(6.sp),
                                decoration: BoxDecoration(
                                  color: AppColors.c778beb,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.call,
                                  color: AppColors.cFFFFFF,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Payment Summery
                Container(
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
                    children: [
                      ///Section : Text -> Payment Summary
                      Text(
                        "Payment Summary",
                        style: TextFontStyle.headline16w700c202020StyleSatoshi,
                      ),
                      UIHelper.verticalSpace(16.h),

                      ///Section : Initial Payment
                      Container(
                        width: 1.sw,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cf1f3fd,
                          border: Border(
                            top: BorderSide(color: AppColors.c778beb),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Initial Cost",
                              style: TextFontStyle
                                  .headline16w700c4d4d4dStyleSatoshi,
                            ),
                            Spacer(),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Start from ${AppText.bdTkSign}",
                                      style: TextFontStyle
                                          .headline12w500c6a6a6aStyleSatoshi,
                                    ),
                                    TextSpan(
                                      text: "${30.90}",
                                      style: TextFontStyle
                                          .headline18w700c778bebStyleSatoshi,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpace(25.h),

                      ///Section : Other Parts
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Other Parts",
                            style:
                                TextFontStyle.headline16w500c202020StyleSatoshi,
                          ),

                          Text(
                            "${AppText.bdTkSign}${300.50}",
                            style:
                                TextFontStyle.headline16w500c202020StyleSatoshi,
                          ),
                        ],
                      ),
                      UIHelper.verticalSpace(25.h),

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

                      ///Section : Total Payment
                      Container(
                        width: 1.sw,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cf1f3fd,
                          border: Border.all(color: AppColors.ce6e6e6),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            ///Section : Text-> Total Payment
                            Text(
                              "Total Payment",
                              style: TextFontStyle
                                  .headline16w700c202020StyleSatoshi,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

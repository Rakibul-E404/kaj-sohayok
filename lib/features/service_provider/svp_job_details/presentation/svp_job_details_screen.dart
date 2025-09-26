import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/appList.dart';
import 'package:kaz_bd/constants/app_enums.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/app_constant_text.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../custom_widgets/date_and_time_widget_tile.dart';
import '../../../../custom_widgets/dotted_line_divider_widget.dart';
import '../widgets/user_info_tile_widget.dart';

class SvpJobDetailsScreen extends StatefulWidget {
  const SvpJobDetailsScreen({super.key});

  @override
  State<SvpJobDetailsScreen> createState() => _SvpJobDetailsScreenState();
}

class _SvpJobDetailsScreenState extends State<SvpJobDetailsScreen> {
  late JobRequestStatusEnum? status;

  @override
  void initState() {
    super.initState();

    ///setting the accepted arguments initial value
    status = Get.arguments?["status"] as JobRequestStatusEnum?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Job Details",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: UIHelper.kDefaulutPadding(),
              right: UIHelper.kDefaulutPadding(),
              bottom: UIHelper.kDefaulutPadding(),
            ),
            child: Container(
              width: 1.sw,
              decoration: BoxDecoration(
                color: AppColors.cFFFFFF,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.c000000.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                    spreadRadius: 0,
                  ),
                ],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  ///Section : User Image
                  ///Section : User Name
                  ///Section : Button -> Cancel
                  ///Section : Button -> Accept
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        ///Section : User Image
                        CircleAvatar(
                          radius: 47.r,
                          backgroundImage: AssetImage(
                            Assets.images.userImage.path,
                          ),
                        ),
                        UIHelper.horizontalSpace(18.w),

                        ///Section : User Name
                        ///Section : Button -> Cancel
                        ///Section : Button -> Accept
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Chowhdury Md. Imtiazul Islam",
                                style: TextFontStyle
                                    .headline18w700c202020StyleSatoshi,
                              ),
                              UIHelper.verticalSpace(16.h),

                              /// ✅ FIXED BUTTON LOGIC
                              if (status == JobRequestStatusEnum.pending) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomElevatedButton(
                                      onTap: () {
                                        print("Cancel tapped");
                                      },
                                      buttonWidth: 100.w,
                                      buttonHeight: 38.h,
                                      buttonColor: AppColors.cfce9e9,
                                      buttonTitle: "Cancel",
                                      textStyle: TextFontStyle
                                          .headline14w500ce73d3dStyleSatoshi,
                                    ),
                                    UIHelper.horizontalSpace(12.w),
                                    CustomElevatedButton(
                                      onTap: () {
                                        print("Accept tapped");
                                      },
                                      buttonWidth: 100.w,
                                      buttonHeight: 38.h,
                                      buttonTitle: "Accept",
                                    ),
                                  ],
                                ),
                              ] else if (status ==
                                  JobRequestStatusEnum.accepted) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomElevatedButton(
                                      onTap: () {
                                        print("Start Work tapped");
                                      },
                                      buttonWidth: 100.w,
                                      buttonHeight: 38.h,

                                      buttonTitle: "Start Work",
                                    ),
                                    UIHelper.horizontalSpace(12.w),
                                    CustomElevatedButton(
                                      onTap: () {
                                        print("Message tapped");
                                      },
                                      buttonWidth: 100.w,
                                      buttonHeight: 38.h,
                                      buttonColor: Colors.transparent,
                                      buttonTitle: "Message",
                                      textStyle: TextFontStyle
                                          .headline14w500c000000StyleSatoshi,
                                      isButtonBorderUsed: true,
                                      buttonBorderColor: AppColors.c778beb,
                                      buttonBorderWidth: 1.5.sp,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  ///Section : Divider
                  Divider(thickness: 2.h, color: AppColors.cc0caf6),
                  UIHelper.verticalSpace(16.h),

                  ///Section : Job Address & Date
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Container(
                      width: 1.sw,
                      padding: EdgeInsets.all(14.sp),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.ce6e6e6),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///Section  : Text -> Job Address & Details
                          Container(
                            width: 1.sw,
                            padding: EdgeInsets.symmetric(
                              vertical: 4.h,
                              horizontal: 8.w,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cf1f3fd,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              "Job Address & Date",
                              style: TextFontStyle
                                  .headline16w700c202020StyleSatoshi,
                            ),
                          ),
                          UIHelper.verticalSpace(14.h),

                          ///Section : Divider
                          DottedLineDividerWidget(),
                          UIHelper.verticalSpace(12.h),

                          ///Section : Location
                          DateAndAddressWidgetTile(
                            icon: Icons.location_on,
                            title: "Rampura Dhaka, Bangladesh",
                          ),
                          UIHelper.verticalSpace(6.h),

                          ///Section : Date And Time
                          DateAndAddressWidgetTile(
                            icon: Icons.watch_later,
                            title: "Jun 17, 2025  09:31AM",
                          ),
                          UIHelper.verticalSpace(12.h),

                          ///Section : Divider
                          DottedLineDividerWidget(),
                        ],
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  ///Section : My Price
                  Container(
                    width: 1.sw,
                    color: AppColors.cf1f1f1,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 16.w,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "My Price",
                          style:
                              TextFontStyle.headline16w700c202020StyleSatoshi,
                        ),
                        Spacer(),

                        ///Section : Initial Payable Price
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Start from ${AppText.bdTkSign}",
                                style: TextFontStyle
                                    .headline12w500c6a6a6aStyleSatoshi,
                              ),
                              TextSpan(
                                text: "${30}",
                                style: TextFontStyle
                                    .headline18w700c778bebStyleSatoshi,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  ///Section : Text -> User Information
                  Container(
                    width: 1.sw,
                    color: AppColors.cf1f3fd,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 16.w,
                    ),
                    child: Text(
                      "User Information",
                      style: TextFontStyle.headline16w700c202020StyleSatoshi,
                    ),
                  ),
                  UIHelper.verticalSpace(10.h),

                  ///Section : Name
                  ///Section : Location
                  ///Section : Date of Birth
                  ///Section : Gender
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10.w,
                      right: 10.w,
                      bottom: 10.h,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: AppList.userInfoList.length,
                      separatorBuilder: (context, index) =>
                          UIHelper.verticalSpace(10.h),
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var data = AppList.userInfoList[index];
                        return UserInfoTileWidget(
                          fieldName: data.fieldName,
                          data: data.data,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

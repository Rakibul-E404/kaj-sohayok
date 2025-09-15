import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kaz_bd/constants/appList.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/profile_tile_widget.dart';

class ProviderDetailsScreen extends StatelessWidget {
  const ProviderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        title: Text(
          "Profile Details",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              children: [
                ///Section : Profile Image
                ///Section : Name
                ///Section : Ratings
                ///Section : Message
                ///Section : Call
                Card(
                  color: Colors.white,
                  elevation: 4.sp,
                  child: Container(
                    width: 1.sw,

                    decoration: BoxDecoration(
                      // color: Colors.amber,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///Section : Header
                        Padding(
                          padding: EdgeInsets.only(
                            left: 10.w,
                            top: 10.h,
                            right: 10.w,
                          ),
                          child: Row(
                            children: [
                              ///Profile Image
                              CircleAvatar(
                                radius: 50.r,
                                backgroundImage: AssetImage(
                                  Assets.images.userImage.path,
                                ),
                              ),
                              UIHelper.horizontalSpace(10.w),

                              ///Section : Name
                              ///Section : Ratings
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ///Section : Name
                                    Text(
                                      "Chowdhury Md. Imtiazul Islam",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextFontStyle
                                          .headline18w700c000000StyleSatoshi,
                                    ),
                                    UIHelper.verticalSpace(10.h),

                                    ///Section : Ratings
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 2.h,
                                        horizontal: 4.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.c778beb,
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ///Section : Ratings
                                          Text(
                                            "4.5",
                                            style: TextFontStyle
                                                .headline12w400cFFFFFFStyleSatoshi,
                                          ),
                                          UIHelper.horizontalSpace(4.w),

                                          Icon(
                                            Icons.star_rate_rounded,
                                            color: AppColors.cFFFFFF,
                                            size: 12.sp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              UIHelper.horizontalSpace(10.w),

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
                                        color: AppColors.cbababa,
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
                                        color: AppColors.cbababa,
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
                        Container(
                          width: 1.sw,
                          color: AppColors.cf1f3fd,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),

                          child: Text(
                            "Profile information",
                            style:
                                TextFontStyle.headline16w700c000000StyleSatoshi,
                          ),
                        ),
                        UIHelper.verticalSpace(10.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: AppList.profileTileList.length,
                            separatorBuilder: (context, index) =>
                                UIHelper.verticalSpace(10.h),
                            itemBuilder: (context, index) {
                              var data = AppList.profileTileList[index];
                              return ProfileTileWidget(
                                onTap: () {},
                                title: data.title,
                                data: data.data,
                              );
                            },
                          ),
                        ),
                        UIHelper.verticalSpace(10.h),
                      ],
                    ),
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

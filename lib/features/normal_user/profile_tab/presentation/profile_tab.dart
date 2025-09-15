import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants/appList.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/profile_tile_widget.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ///Section : Profile Image
            ///Section : Name
            ///Section : Ratings
            ///Section : Message
            ///Section : Call
            Container(
              width: 1.sw,

              decoration: BoxDecoration(
                // color: Colors.amber,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 1.sw,

                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cf1f3fd,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Profile information",
                          style:
                              TextFontStyle.headline16w700c000000StyleSatoshi,
                        ),

                        SvgPicture.asset(Assets.icons.penEditIcon),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(10.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: AppList.userProfileList.length,
                      separatorBuilder: (context, index) =>
                          UIHelper.verticalSpace(10.h),
                      itemBuilder: (context, index) {
                        var data = AppList.userProfileList[index];
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
          ],
        ),
      ),
    );
  }
}

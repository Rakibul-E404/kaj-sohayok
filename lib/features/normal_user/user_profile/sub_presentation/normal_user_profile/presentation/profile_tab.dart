import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/models/user_profile_model.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../../../../constants/appList.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../controllers/user_profile_screen_controller.dart';
import '../../../../../../custom_widgets/profile_tile_widget.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../provider_profile_details/model/profile_tile_model.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfileScreenController userProfileScreenController =
        Get.find<UserProfileScreenController>();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ///Section : Profile Image
            ///Section : Name
            ///Section : Ratings
            ///Section : Message
            ///Section : Call
            Card(
              child: Container(
                width: 1.sw,

                decoration: BoxDecoration(
                  color: AppColors.cFFFFFF,
                  borderRadius: BorderRadius.circular(16.r),
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

                          InkWell(
                            onTap: () {
                              Get.toNamed(Routes.editProfileScreen);
                            },
                            child: SvgPicture.asset(Assets.icons.penEditIcon),
                          ),
                        ],
                      ),
                    ),
                    UIHelper.verticalSpace(10.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Obx(() {
                        List<ProfileTileModel> userProfileList = [
                          ProfileTileModel(
                            title: "Name",
                            data:
                                "${userProfileScreenController.userProfileModel.value?.name ?? ''} ",
                          ),
                          ProfileTileModel(
                            title: "Email",
                            data:
                                "${userProfileScreenController.userProfileModel.value?.email ?? ''} ",
                          ),
                          ProfileTileModel(
                            title: "Phone number",
                            data:
                                "${userProfileScreenController.userProfileModel.value?.phoneNumber ?? '0000'} ",
                          ),
                          ProfileTileModel(
                            title: "Address",
                            data:
                                "${userProfileScreenController.userProfileModel.value?.location.en ?? ''} ",
                          ),
                          ProfileTileModel(
                            title: "Date of Birth",
                            data:
                                "${formatDateTime(userProfileScreenController.userProfileModel.value?.dob) ?? ''} ",
                          ),
                          ProfileTileModel(
                            title: "Gender",
                            data:
                                "${userProfileScreenController.userProfileModel.value?.gender.toUpperCase() ?? ''} ",
                          ),
                        ];
                        if (userProfileScreenController.loader.value == true) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: userProfileList.length,
                          separatorBuilder: (context, index) =>
                              UIHelper.verticalSpace(10.h),
                          itemBuilder: (context, index) {
                            var data = userProfileList[index];
                            return ProfileTileWidget(
                              onTap: () {},
                              title: data.title,
                              data: data.data,
                            );
                          },
                        );
                      }),
                    ),
                    UIHelper.verticalSpace(10.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

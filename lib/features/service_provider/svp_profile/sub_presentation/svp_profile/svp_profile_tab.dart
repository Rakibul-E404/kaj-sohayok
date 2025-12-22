import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/models/provider_profile_model.dart';

import '../../../../../constants/appList.dart';
import '../../../../../constants/text_font_style.dart';
import '../../../../../controllers/svp_profile_screen_controller.dart';
import '../../../../../custom_widgets/profile_tile_widget.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../gen/colors.gen.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../models/user_profile_model.dart';
import '../../../../../routes/routes.dart';
import '../../../../normal_user/provider_profile_details/model/profile_tile_model.dart';

class SvpProfileTab extends StatelessWidget {
  const SvpProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final SvpProfileScreenController svpProfileScreenController =
        Get.find<SvpProfileScreenController>();
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
                            'profile_information'.tr,
                            style:
                                TextFontStyle.headline16w700c000000StyleSatoshi,
                          ),
                          InkWell(
                            onTap: () {
                              log("Navigated to SVP Edit Profile Screen");
                              Get.toNamed(Routes.svpEditProfileScreen);
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
                            title: 'name'.tr,
                            data:
                                "${svpProfileScreenController.providerProfileModel.value?.name ?? ''} ",
                          ),
                          ProfileTileModel(
                            title: 'email'.tr,
                            data:
                                "${svpProfileScreenController.providerProfileModel.value?.email ?? ''} ",
                          ),
                          ProfileTileModel(
                            title: 'phone_number'.tr,
                            data:
                                "${svpProfileScreenController.providerProfileModel.value?.phoneNumber ?? ''} ",
                          ),
                          ProfileTileModel(
                            title: 'address'.tr,
                            data:
                                "${svpProfileScreenController.providerProfileModel.value?.location.en ?? ''} ",
                          ),
                          ProfileTileModel(
                            title: 'date_of_birth'.tr,
                            data:
                                "${formatDateTime(svpProfileScreenController.providerProfileModel.value?.dob)} ",
                          ),
                          ProfileTileModel(
                            title: 'gender'.tr,
                            data:
                                "${svpProfileScreenController.providerProfileModel.value?.gender.toUpperCase() ?? ''} ",
                          ),
                        ];
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: userProfileList.length,
                          separatorBuilder: (context, index) =>
                              UIHelper.verticalSpace(10.h),
                          itemBuilder: (context, index) {
                            var data = userProfileList[index];
                            return ProfileTileWidget(
                              onTap: null,
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

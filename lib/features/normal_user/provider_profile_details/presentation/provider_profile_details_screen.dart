import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/appList.dart';
import 'package:kaz_bd/features/normal_user/provider_profile_details/presentation/widget/provider_profile_details_shimmer_effect.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../controllers/get_nrm_user_service_provider_profile_info.dart';
import '../../../../controllers/message_screen_controller.dart';
import '../../../../custom_widgets/custom_shimmer_effect.dart';
import '../../../../custom_widgets/profile_tile_widget.dart';
import '../../../../utilities/app_url.dart';

class ProviderDetailsScreen extends StatelessWidget {
  const ProviderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    GetNrmUserServiceProviderProfileInfoController svpProfileDetailsController =
        Get.find<GetNrmUserServiceProviderProfileInfoController>();
    String? imageUrl;
    String? fullImageUrl;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        title: Text(
          'profile_details'.tr,
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
                Obx(() {
                  if (svpProfileDetailsController.isLoading.value == true) {
                    return ProviderProfileDetailsShimmerEffect();
                  } else {
                    return Card(
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
                                  // CircleAvatar(
                                  //   radius: 50.r,
                                  //   backgroundImage: AssetImage(
                                  //     Assets.images.userImage.path,
                                  //   ),
                                  // ),

                                  /// --- Service Image ---
                                  Obx(() {
                                    // Get the first gallery attachment from service details if available

                                    if (svpProfileDetailsController
                                            .profileImageUrl.isNotEmpty ==
                                        true) {
                                      imageUrl = svpProfileDetailsController
                                          .profileImageUrl;
                                    }

                                    // Show network image if URL is available, otherwise show placeholder
                                    if (imageUrl != null &&
                                        imageUrl!.isNotEmpty) {
                                      // Make sure the URL is properly formatted
                                      fullImageUrl = imageUrl;
                                      if (!imageUrl!.startsWith('http')) {
                                        // If it's a relative path, prepend the base URL
                                        fullImageUrl =
                                            '${AppUrl.imageBaseUrl}$imageUrl';
                                      }

                                      return ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: fullImageUrl ?? '',
                                          height: 94.h,
                                          width: 94.w,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    } else {
                                      // Show placeholder if no image is available
                                      return CustomShimmerEffect(
                                        height: 94.h,
                                        width: 94.w,
                                        isShapUsed: true,
                                        shapType: BoxShape.circle,
                                      );
                                    }
                                  }),

                                  UIHelper.horizontalSpace(10.w),

                                  ///Section : Name
                                  ///Section : Ratings
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ///Section : Name
                                        Text(
                                          svpProfileDetailsController
                                              .providerName,
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
                                                svpProfileDetailsController
                                                    .rating
                                                    .toString(),
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
                                          Get.find<MessageScreenController>()
                                              .createMessage(
                                                  participantId:
                                                      svpProfileDetailsController
                                                              .serviceProviderAttributes
                                                              .value
                                                              ?.id ??
                                                          '',
                                                  name:
                                                      svpProfileDetailsController
                                                          .providerName,
                                                  imageUrl: fullImageUrl ?? '');
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
                                'profile_information'.tr,
                                style: TextFontStyle
                                    .headline16w700c000000StyleSatoshi,
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
                                    data: index == 0
                                        ? svpProfileDetailsController
                                                .serviceNameEn
                                                ?.toString() ??
                                            ""
                                        : index == 1
                                            ? svpProfileDetailsController
                                                    .yearsOfExperience
                                                    ?.toString() ??
                                                ""
                                            : index == 2
                                                ? svpProfileDetailsController
                                                        .providerName
                                                        ?.toString() ??
                                                    ""
                                                : index == 3
                                                    ? svpProfileDetailsController
                                                            .phoneNumber
                                                            ?.toString() ??
                                                        ""
                                                    : index == 4
                                                        ? svpProfileDetailsController
                                                                .locationEn
                                                                ?.toString() ??
                                                            ""
                                                        : index == 5
                                                            ? svpProfileDetailsController
                                                                    .dateOfBirthShort
                                                                    ?.toString() ??
                                                                ""
                                                            : index == 6
                                                                ? svpProfileDetailsController
                                                                        .gender
                                                                        ?.toString() ??
                                                                    ""
                                                                : "",
                                  );
                                },
                              ),
                            ),
                            UIHelper.verticalSpace(10.h),
                          ],
                        ),
                      ),
                    );
                  }
                }),

                ///
              ],
            ),
          ),
        ),
      ),
    );
  }
}

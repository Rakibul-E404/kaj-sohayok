import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/features/normal_user/user_profile/sub_presentation/normal_user_payment_booking_history/presentation/payment_booking_history_tab.dart';
import 'package:kaz_bd/features/normal_user/user_profile/sub_presentation/normal_user_profile/presentation/profile_tab.dart';
import 'package:kaz_bd/features/normal_user/user_profile/sub_presentation/normal_user_settings/presentation/settings_tab.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../controllers/user_profile_screen_controller.dart';
import '../../../../custom_widgets/select_language_widget.dart';
import '../../../../custom_widgets/tab_showing_widget.dart';
import '../../details/widget/sliver_tab_bar_delegate_helper_widget.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfileScreenController controller = Get.put(
      UserProfileScreenController(),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'my_profile'.tr,
            style: TextFontStyle.headline18w700c000000StyleSatoshi,
          ),
          centerTitle: true,
          backgroundColor: AppColors.scaffoldBackgroundColor,
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Profile Image + Language Tabs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///Section : Svp Profile Iamge
                        // Obx(() {
                        //   return CustomProfileImageWidget(
                        //     imagePath: controller.profileImage.value,
                        //     defaultAsset: Assets.images.errorImage.path,
                        //     editIconAsset: Assets.icons.editIcon,
                        //     onEditTap: () {
                        //       controller.showImageSourceDialog();
                        //     },
                        //   );
                        // }),
                        /// ===================== PROFILE IMAGE =================>
                        Obx(() {
                          final imagePath = controller.profileImage.value;
                          final bool isNetworkImage = imagePath.isNotEmpty &&
                              imagePath.startsWith('http');
                          final bool isLocalImage = imagePath.isNotEmpty &&
                              !imagePath.startsWith('http');
                          final bool hasImage = imagePath.isNotEmpty;

                          return GestureDetector(
                            onTap: hasImage
                                ? () {
                                    showDialog(
                                      context: Get.context!,
                                      builder: (_) => Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding: EdgeInsets.all(16.w),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16.r),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxHeight: 500.h,
                                                maxWidth: 1.sw - 32.w,
                                              ),
                                              child: isNetworkImage
                                                  ? CachedNetworkImage(
                                                      imageUrl: imagePath,
                                                      fit: BoxFit.contain,
                                                      placeholder: (
                                                        context,
                                                        url,
                                                      ) =>
                                                          Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      errorWidget: (
                                                        context,
                                                        url,
                                                        error,
                                                      ) =>
                                                          Icon(
                                                        Icons.person,
                                                        color: Colors.white,
                                                        size: 48.sp,
                                                      ),
                                                    )
                                                  : Image.file(
                                                      File(imagePath),
                                                      fit: BoxFit.contain,
                                                    ),
                                            ),
                                          )),
                                    );
                                  }
                                : null,
                            child: Container(
                              width: 100.w,
                              height: 100.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.r),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50.r),
                                child: hasImage
                                    ? (isNetworkImage
                                        ? CachedNetworkImage(
                                            imageUrl: imagePath,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.person,
                                              size: 48.sp,
                                              color: Colors.grey[400],
                                            ),
                                          )
                                        : Image.file(
                                            File(imagePath),
                                            fit: BoxFit.cover,
                                          ))
                                    : Icon(
                                        Icons.person,
                                        size: 48.sp,
                                        color: Colors.grey[400],
                                      ),
                              ),
                            ),
                          );
                        }),

                        /// Language Selection
                        SelectLanguage(
                          tabController: controller.languageTabController,
                          tabIndex: controller.languageSelectionTabIndex,
                          onTabChange: controller.changeLanguageTab,
                          leftTabTitle: "English",
                          rightTabTitle: "বাংলা",
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(8.h),

                    Obx(
                      () => Text(
                        "  ${controller.userProfileModel.value?.name ?? ''} ",
                        style: TextFontStyle.headline18w700c000000StyleSatoshi,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Profile Options Tabs
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverTabBarDelegateHelper(
                minHeight: 40.h,
                maxHeight: 40.h,
                child: Container(
                  color: AppColors.scaffoldBackgroundColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: UIHelper.kDefaulutPadding(),
                  ),
                  child: TabBar(
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    controller: controller.profileOptionsTabController,
                    labelStyle: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                    unselectedLabelColor: AppColors.c4d4d4d,
                    indicatorColor: AppColors.c778beb,
                    dividerColor: AppColors.c778beb,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 4.h,
                    tabs: [
                      Tab(text: 'profile'.tr),
                      Tab(text: 'setting'.tr),
                      Tab(text: 'payment_history'.tr),
                    ],
                  ),
                ),
              ),
            ),
          ],

          /// Tab Views
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: UIHelper.kDefaulutPadding(),
            ),
            child: Column(
              children: [
                UIHelper.verticalSpace(24.h),
                Expanded(
                  child: TabShowingWidget(
                    tabController: controller.profileOptionsTabController,
                    controller: controller.profileSectionTabIndex,
                    tabViews: const [
                      ProfileTab(),
                      SettingsTab(),
                      PaymentBookingHistoryTab(),
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

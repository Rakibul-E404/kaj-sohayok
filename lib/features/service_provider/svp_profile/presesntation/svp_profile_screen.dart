import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../controllers/svp_profile_screen_controller.dart';
import '../../../../custom_widgets/custom_profile_image_widget.dart';
import '../../../../custom_widgets/select_language_widget.dart';
import '../../../../custom_widgets/tab_showing_widget.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../normal_user/details/widget/sliver_tab_bar_delegate_helper_widget.dart';
import '../sub_presentation/svp_documents/presentation/svp_documentation_tab.dart';
import '../sub_presentation/svp_profile/svp_profile_tab.dart';
import '../sub_presentation/svp_settings/presentation/svp_settings_tab.dart';
import '../sub_presentation/svp_wallet/SvpWalletTab.dart';

class SvpProfileScreen extends StatelessWidget {
  SvpProfileScreen({super.key});

  final SvpProfileScreenController controller = Get.put(
    SvpProfileScreenController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "My Profile",
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
                      //     imagePath: controller.svpPickedImagePath.value,
                      //     defaultAsset: Assets.images.errorImage.path,
                      //     editIconAsset: Assets.icons.editIcon,
                      //     onEditTap: () {
                      //       controller.showImageSourceDialog();
                      //     },
                      //   );
                      // }),
                      Obx(() {
                        final imagePath = controller.profileImage.value;
                        final bool isNetworkImage =
                            imagePath.isNotEmpty &&
                            imagePath.startsWith('http');
                        final bool isLocalImage =
                            imagePath.isNotEmpty &&
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
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxHeight: 500.h,
                                            maxWidth: 1.sw - 32.w,
                                          ),
                                          child: isNetworkImage
                                              ? CachedNetworkImage(
                                                  imageUrl: imagePath,
                                                  fit: BoxFit.contain,
                                                  placeholder: (context, url) =>
                                                      Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      ),
                                                  errorWidget:
                                                      (context, url, error) =>
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
                                      ),
                                    ),
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
                                                  child:
                                                      CircularProgressIndicator(
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
                      "  ${controller.providerProfileModel.value?.name ?? ''} ",
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
                  controller: controller.svpProfileOptionsTabController,
                  labelStyle: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                  unselectedLabelColor: AppColors.c4d4d4d,
                  indicatorColor: AppColors.c778beb,
                  dividerColor: AppColors.c778beb,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 4.h,
                  tabs: const [
                    Tab(text: "Profile"),
                    Tab(text: "Documents"),
                    Tab(text: "Setting"),
                    Tab(text: "Wallet"),
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
                  tabController: controller.svpProfileOptionsTabController,
                  controller: controller.svpProfileSectionTabIndex,
                  tabViews: [
                    SvpProfileTab(),
                    SvpDocumentationTab(),
                    SvpSettingsTab(),
                    SvpWalletTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

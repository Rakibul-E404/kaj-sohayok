import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/features/normal_user/payment_booking_history_tab/presentation/payment_booking_history_tab.dart';
import 'package:kaz_bd/features/normal_user/profile_tab/presentation/profile_tab.dart';
import 'package:kaz_bd/features/normal_user/settings_tab/presentation/settings_tab.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../controllers/user_profile_screen_controller.dart';
import '../../../../custom_widgets/select_language_widget.dart';
import '../../../../custom_widgets/tab_showing_widget.dart';
import '../../details/widget/sliver_tab_bar_delegate_helper_widget.dart';
import '../widgets/profile_image_show_and_select_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  late TabController _languageTabController;
  late TabController _profileOptionsTabController;
  final UserProfileScreenController controller = Get.put(
    UserProfileScreenController(),
  );

  @override
  void initState() {
    super.initState();

    ///Section : Language Selection
    _languageTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: controller.languageSelectionTabIndex.value,
    );
    _languageTabController.addListener(() {
      controller.changeLanguageTab(_languageTabController.index);
      log("Language Tab changed to index: ${_languageTabController.index}");
    });

    ///Section : Profile Options
    _profileOptionsTabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: controller.profileSectionTabIndex.value,
    );
    _profileOptionsTabController.addListener(() {
      controller.changeProfileOptionsTab(_profileOptionsTabController.index);
      log(
        "Profile Section Tab changed to index: ${_profileOptionsTabController.index}",
      );
    });
  }

  @override
  void dispose() {
    _languageTabController.dispose();
    _profileOptionsTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                    ///Section : Profile Image
                    ///Section : Language Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///Section : Profile Image
                        ProfileImageShowAndSelectWidget(),

                        ///Section : Select Language
                        // TabBar with custom indicator and styling
                        ///Section : Button -> English, Bangla
                        SelectLanguage(
                          tabController: _languageTabController,
                          tabIndex: controller.languageSelectionTabIndex,
                          onTabChange: controller.changeLanguageTab,
                          leftTabTitle: "English",
                          rightTabTitle: "বাংলা",
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(8.h),

                    Text(
                      "Bashar Islam",
                      style: TextFontStyle.headline18w700c000000StyleSatoshi,
                    ),
                  ],
                ),
              ),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: SliverTabBarDelegateHelper(
                minHeight: 23.h,
                maxHeight: 23.h,
                child: Container(
                  color: AppColors.scaffoldBackgroundColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: UIHelper.kDefaulutPadding(),
                  ),
                  child: TabBar(
                    controller: _profileOptionsTabController,
                    labelStyle: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                    unselectedLabelColor: AppColors.c4d4d4d,
                    indicatorColor: AppColors.c778beb,
                    dividerColor: AppColors.c778beb,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                    indicatorWeight: 4.h,
                    tabs: const [
                      Tab(text: "Profile"),
                      Tab(text: "Setting"),
                      Tab(text: "Payment History"),
                    ],
                  ),
                ),
              ),
            ),
          ],

          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: UIHelper.kDefaulutPadding(),
            ),
            child: Column(
              children: [
                UIHelper.verticalSpace(24.h),
                Expanded(
                  child: TabShowingWidget(
                    tabController: _profileOptionsTabController,
                    controller: controller.profileSectionTabIndex,
                    tabViews: [
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

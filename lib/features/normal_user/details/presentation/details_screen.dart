import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/app_constant_text.dart';
import 'package:kaz_bd/features/normal_user/details/widget/tab_showing_widget.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import '../../../../constants/text_font_style.dart';
import '../widget/sliver_tab_bar_delegate_helper_widget.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        title: Text(
          "Details",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// --- Service Image ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: Image.asset(
                      height: 220.h,
                      width: 1.sw,
                      fit: BoxFit.cover,
                      Assets.images.serviceImage.path,
                    ),
                  ),
                  UIHelper.verticalSpace(24.h),

                  /// --- Service Name + Rating ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Home Cleaning",
                        style: TextFontStyle.headline18w700c000000StyleSatoshi,
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.c778beb,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "4.5",
                              style: TextFontStyle
                                  .headline12w400cFFFFFFStyleSatoshi,
                            ),
                            UIHelper.horizontalSpace(4.w),
                            Icon(
                              Icons.star_rate_rounded,
                              size: 18.sp,
                              color: AppColors.cFFFFFF,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(8.h),

                  /// --- Price ---
                  RichText(
                    text: TextSpan(
                      style: TextFontStyle.headline12w500c6a6a6aStyleSatoshi,
                      children: [
                        const TextSpan(text: "Start from "),
                        TextSpan(
                          text: "${AppText.bdTkSign}30.56",
                          style:
                              TextFontStyle.headline18w700c778bebStyleSatoshi,
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(8.h),

                  /// --- Bio ---
                  Text(
                    "Expert home cleaning for a tidy, fresh and comfortable space.",
                    style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                  ),
                  UIHelper.verticalSpace(24.h),
                ],
              ),
            ),
          ),

          /// --- Sticky TabBar ---
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
                  controller: tabController,
                  labelStyle: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.c778beb,
                  dividerColor: AppColors.c778beb,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 4.h,
                  tabs: const [
                    Tab(text: "About"),
                    Tab(text: "Gallery"),
                    Tab(text: "Reviews"),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabShowingWidget(tabController: tabController),
      ),
    );
  }
}

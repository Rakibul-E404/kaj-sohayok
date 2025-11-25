import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/appList.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../../custom_widgets/home_section_applogo_and_notification.dart';
import '../../../../gen/assets.gen.dart';
import '../widgets/category_page_view_widget.dart' show CategoryPageViewWidget;
import '../widgets/section_declaration_widget.dart';
import '../widgets/service_showing_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ///Section : AppLogo & Notification Section
            HomeSectionAppLogoAndNotification(
              onTap: () {
                log("Notification Icon taped!");
                Get.toNamed(Routes.notificationScreen);
              },
            ),
            UIHelper.verticalSpace(16.h),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: UIHelper.kDefaulutPadding(),
              ),
              child: Column(
                children: [
                  ///Section : Hero Booking
                  Container(
                    height: 175.h,
                    width: 1.sw,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 24.h,
                    ),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        image: AssetImage(Assets.images.heroBannerImage.path),
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///Section : Discount section...
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style:
                                TextFontStyle.headline16w700c000000StyleSatoshi,
                            children: [
                              const TextSpan(text: 'Get Discount up to '),

                              TextSpan(
                                text: '${30}%',
                                style: TextFontStyle
                                    .headline16w700c778bebStyleSatoshi
                                    .copyWith(fontSize: 22.sp),
                              ),
                            ],
                          ),
                        ),
                        UIHelper.verticalSpace(8.h),

                        ///Section : Text -> one first home services
                        Text(
                          "One First Home Services",
                          style:
                              TextFontStyle.headline12w400c4d4d4dStyleSatoshi,
                        ),
                        UIHelper.verticalSpace(12.h),

                        ///Section : Button -> Book Now
                        CustomElevatedButton(
                          onTap: () {
                            log("Book Now Button Taped!");
                          },
                          buttonTitle: "Book Now",
                          textStyle:
                              TextFontStyle.headline14w500cFFFFFFStyleSatoshi,
                          buttonWidth: 120.w,
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(24.h),

                  ///Section : Select Category
                  SectionDeclarationWidget(
                    sectionTitle: "Select Category",
                    textButtonName: "See all",
                    onTap: () {
                      log("See all button taped at Select Category section!");
                      Get.toNamed(Routes.allCategoriesScreen);
                    },
                  ),
                  UIHelper.verticalSpace(16.h),

                  ///Section : Category Widget in pageView
                  CategoryPageViewWidget(myList: AppList.categories),
                  UIHelper.verticalSpace(24.h),

                  ///Section : Popular Provider
                  SectionDeclarationWidget(
                    sectionTitle: "Popular Provider",
                    textButtonName: "See all",
                    onTap: () {
                      log("See all button taped at Popular Provider section!");
                    },
                  ),
                  UIHelper.verticalSpace(24.h),

                  ///Section : Services
                  SizedBox(
                    height: 220.h,
                    child: ListView.separated(
                      itemCount: 10,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) =>
                          UIHelper.horizontalSpace(8.w),
                      itemBuilder: (context, index) {
                        return ServiceWidget(
                          onTap: () {
                            log("Taped Service Index : $index");
                            Get.toNamed(Routes.serviceDetailsScreen);
                          },
                          imagePath: Assets.images.serviceImage.path,
                          serviceTitle: 'Ac Cleaning At Home',
                          initialPayablePrice: 30.5,
                          userRating: 4.5,
                        );
                      },
                    ),
                  ),
                  UIHelper.verticalSpace(150.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

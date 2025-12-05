import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/features/normal_user/home/models/home_page_data_model.dart'
    as Model;
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';
import 'package:lottie/lottie.dart';

import '../../../../controllers/home_page_controller.dart';
import '../../../../custom_widgets/home_section_applogo_and_notification.dart';
import '../../../../gen/assets.gen.dart';
import '../widgets/banner_carosle_slider.dart';
import '../../../../custom_widgets/custom_shimmer_effect.dart';
import '../widgets/category_page_view_widget.dart' show CategoryViewWidget;
import '../widgets/section_declaration_widget.dart';
import '../widgets/service_showing_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomePageController controller = Get.put(HomePageController());

    // Set system UI overlay style immediately when the widget builds
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // Status bar color (Android)
        statusBarColor: AppColors.cf1f3fd, // Specific status bar color
        statusBarIconBrightness:
            Brightness.light, // Light icons for dark background
        statusBarBrightness: Brightness.dark, // Brightness for iOS status bar
        systemNavigationBarColor:
            AppColors.scaffoldBackgroundColor, // Keep navigation bar consistent
        systemNavigationBarIconBrightness:
            Brightness.dark, // Navigation bar icons
      ),
    );

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

            ///Section : Hero Booking
            Obx(() {
              log(
                '🏠------------ HOME SCREEN: Banners section - Loading: ${controller.isLoading.value}, Banner count: ${controller.banners.length}',
              );

              if (controller.isLoading.value) {
                log(
                  '⏳ ---------HOME SCREEN: Showing loading shimmer for banners',
                );
                return CustomShimmerEffect(height: 175, width: 1);
              }

              if (controller.banners.isNotEmpty) {
                log(
                  '✅ HOME SCREEN: Banners found, showing BannerCarosleSlider with ${controller.banners.length} banners',
                );
                return BannerCarosleSlider(controller: controller);
              } else {
                log('❌ HOME SCREEN: No banners available, showing placeholder');
                return Container(
                  height: 175,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.c778beb, // Background color
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Lottie.asset(
                          height: 80.h,
                          width: 80.w,
                          Assets.lottie.emptyScreen,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Flexible(
                        child: Text(
                          'Stay Tuned for Updates!',
                          style:
                              TextFontStyle.headline16w700cFFFFFFStyleSatoshi,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Flexible(
                        child: Text(
                          'Special offers coming soon',
                          style:
                              TextFontStyle.headline14w500cFFFFFFStyleSatoshi,
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: UIHelper.kDefaulutPadding(),
              ),
              child: Column(
                children: [
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
                  CategoryViewWidget(),
                  UIHelper.verticalSpace(24.h),

                  ///Section : Popular Provider
                  SectionDeclarationWidget(
                    sectionTitle: "Popular Provider",
                    textButtonName: "See all",
                    onTap: () {
                      log("See all button taped at Popular Provider section!");
                      Get.toNamed(Routes.normalUserSeePopularProviderScreen);
                    },
                  ),
                  UIHelper.verticalSpace(24.h),

                  ///Section : Popular Providers
                  SizedBox(
                    height: 230.h,
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return ListView.separated(
                          itemCount: 10,
                          separatorBuilder: (context, index) =>
                              UIHelper.horizontalSpace(8.w),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return CustomShimmerEffect(
                              height: 180.h,
                              width: 174.w,
                            );
                          },
                        );
                      }

                      if (controller.providers.isEmpty) {
                        return CustomShimmerEffect(
                          height: 100.h,
                          width: 1.sw,
                          child: Text(
                            "No providers available",
                            style:
                                TextFontStyle.headline14w500cFFFFFFStyleSatoshi,
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: controller.providers.length,
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (context, index) =>
                            UIHelper.horizontalSpace(8.w),
                        itemBuilder: (context, index) {
                          final provider = controller.providers[index];
                          final String serviceTitle = _getProviderName(
                            provider,
                          );
                          final String providerId = _getProviderId(provider);
                          final double rating = _getProviderRating(provider);
                          final int startPrice = _getProviderStartPrice(
                            provider,
                          );

                          // Get the first gallery image if available, or try for cover photo
                          String? imageUrl = _getProviderImageUrl(provider);

                          return ServiceWidget(
                            onTap: () {
                              log("-------Provider tapped: $serviceTitle");
                              log("-------------Provider ID : $providerId");
                              Get.toNamed(
                                Routes.serviceDetailsScreen,

                                // arguments: {'providerId': providerId},
                                arguments: {'providerId': providerId},
                              );
                            },
                            imagePath:
                                imageUrl ?? Assets.images.serviceImage.path,
                            serviceTitle: serviceTitle,
                            initialPayablePrice: startPrice.toDouble(),
                            userRating: rating,
                          );
                        },
                      );
                    }),
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

  // Helper methods to handle Provider model format
  String _getProviderName(Model.Provider provider) {
    // Access name from the Provider model
    if (provider.serviceName != null && provider.serviceName!.en != null) {
      return provider.serviceName!.en.toString();
    }
    return 'Provider';
  }

  String _getProviderId(Model.Provider provider) {
    log("😊😊😊Provider ID  : ${provider.serviceProviderId}");
    return provider.serviceProviderId ?? '';
  }

  double _getProviderRating(Model.Provider provider) {
    return (provider.rating ?? 0).toDouble();
  }

  int _getProviderStartPrice(Model.Provider provider) {
    return provider.startPrice ?? 0;
  }

  String? _getProviderImageUrl(Model.Provider provider) {
    // Try gallery images first, then cover photos
    if (provider.attachmentsForGallery != null &&
        provider.attachmentsForGallery!.isNotEmpty) {
      return provider.attachmentsForGallery![0].attachment;
    }
    // If no gallery images, try cover photos
    if (provider.attachmentsForCoverPhoto != null &&
        provider.attachmentsForCoverPhoto!.isNotEmpty) {
      // Assuming the API returns attachment data in a different format for cover photos
      // Access the attachment URL from the first cover photo
      dynamic firstCoverPhoto = provider.attachmentsForCoverPhoto![0];
      if (firstCoverPhoto is Map<String, dynamic>) {
        return firstCoverPhoto['attachment'];
      }
    }
    return null;
  }
}

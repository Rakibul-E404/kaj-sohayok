import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/normal_user_see_all_popular_providers.dart';
import 'package:kaz_bd/features/normal_user/see_all_popular_provider/presentation/widgets/all_popular_providers_showing_widget.dart';
import 'package:kaz_bd/features/normal_user/see_all_popular_provider/presentation/widgets/custom_loader_for_all_popular_provider.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../custom_widgets/home_section_applogo_and_notification.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../routes/routes.dart';

class SeeAllPopularProvidersScreen extends StatelessWidget {
  const SeeAllPopularProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    NormalUserSeeAllPopularProvidersController controller =
        Get.find<NormalUserSeeAllPopularProvidersController>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
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
                child: Obx(() {
                  final controller =
                      Get.find<NormalUserSeeAllPopularProvidersController>();

                  if (controller.isLoading.value) {
                    // Show loading state if needed
                    return GridView.builder(
                      itemCount: controller.providers.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16.h,
                        crossAxisSpacing: 16.w,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        return CustomLoaderForAllPopularProvider();
                      },
                    );
                  }

                  return GridView.builder(
                    itemCount: controller.providers.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.h,
                      crossAxisSpacing: 16.w,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      return AllPopularProvidersShowingWidget(
                        onTap: () {
                          log(
                            "All Popular Providers Showing Widget Taped at Index : $index",
                          );
                        },
                        imagePath: Assets.images.medalImage.path,
                        initialPayablePrice:
                            140.0 + index, // Different price for each item
                        serviceTitle:
                            "Service Title $index", // Added index for better identification
                        userRating: 5 - (index % 2), // Alternate ratings
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

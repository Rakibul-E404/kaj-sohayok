import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/controllers/normal_user_see_all_popular_providers.dart';
import 'package:kaz_bd/features/normal_user/see_all_popular_provider/presentation/widgets/all_popular_providers_showing_widget.dart';
import 'package:kaz_bd/features/normal_user/see_all_popular_provider/presentation/widgets/custom_loader_for_all_popular_provider.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../custom_widgets/home_section_applogo_and_notification.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../routes/routes.dart';

class SeeAllPopularProvidersScreen extends StatefulWidget {
  const SeeAllPopularProvidersScreen({super.key});

  @override
  State<SeeAllPopularProvidersScreen> createState() =>
      _SeeAllPopularProvidersScreenState();
}

class _SeeAllPopularProvidersScreenState
    extends State<SeeAllPopularProvidersScreen> {
  final NormalUserSeeAllPopularProvidersController controller =
      Get.find<NormalUserSeeAllPopularProvidersController>();

  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getAllPopularProviders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          "Popular Provider",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              children: [
                Obx(() {
                  if (controller.isLoading.value) {
                    // Show loading state
                    return GridView.builder(
                      itemCount: 6, // Show 6 shimmer items
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

                  // Check if we have providers
                  if (controller.providers.isEmpty) {
                    return Column(
                      children: [
                        UIHelper.verticalSpace(100.h),
                        Icon(
                          Icons.people_outline,
                          size: 80.sp,
                          color: AppColors.cbababa,
                        ),
                        UIHelper.verticalSpace(16.h),
                        Text(
                          'No Popular Providers Available',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.c6a6a6a,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }

                  // Show actual providers
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
                      // Get the actual provider data
                      final provider = controller.providers[index];

                      return AllPopularProvidersShowingWidget(
                        onTap: () {
                          log("Provider tapped: ${provider.serviceName?.en}");
                          log(
                            "Provider ID: ${controller.getProviderId(index)}",
                          );

                          // Navigate to provider details
                          Get.toNamed(
                            Routes.serviceDetailsScreen,
                            arguments: {
                              'providerId': controller.getProviderId(index),
                            },
                          );
                        },
                        imagePath: controller.getServiceImage(index).isNotEmpty
                            ? controller.getServiceImage(index)
                            : Assets.images.medalImage.path, // Fallback image
                        initialPayablePrice: controller
                            .getInitialPrice(index)
                            .toDouble(),
                        serviceTitle: controller.getServiceTitle(index),
                        userRating: controller.getRating(index),
                      );
                    },
                  );
                }),
                UIHelper.verticalSpace(20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

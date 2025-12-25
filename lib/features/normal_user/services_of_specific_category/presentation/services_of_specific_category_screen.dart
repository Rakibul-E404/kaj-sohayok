import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/routes/routes.dart';
import 'package:kaz_bd/utilities/logger_util.dart';
import 'package:lottie/lottie.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../controllers/service_of_specific_category_screen_controller.dart';
import '../../../../custom_widgets/custom_shimmer_effect.dart';
import '../../../../custom_widgets/custom_text_form_field.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../helpers/ui_helpers.dart';
import '../widget/specific_service_showing_widget.dart';

class ServicesOfSpecificCategoryScreen extends StatefulWidget {
  const ServicesOfSpecificCategoryScreen({super.key});

  @override
  State<ServicesOfSpecificCategoryScreen> createState() =>
      _ServicesOfSpecificCategoryScreenState();
}

class _ServicesOfSpecificCategoryScreenState
    extends State<ServicesOfSpecificCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ServiceOfSpecificCategoryScreenController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ServiceOfSpecificCategoryScreenController>();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                200 && // Trigger 200 pixels before end
        !controller.isLoadingMore.value && // Only if not already loading
        controller.hasMoreData.value) {
      // Only if there's more data
      controller.loadMoreServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;

    final categoryId = arguments?['categoryId'] ?? '';
    final latValue = arguments?['lat_value'] ?? '';
    final longValue = arguments?['long_value'] ?? '';
    final categoryName =
        arguments?['categoryName'] ?? 'failed_to_get_service_category_name'.tr;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      LoggerUtils.info(
          'Setting category data in ServicesOfSpecificCategoryScreen');
      LoggerUtils.info('Category ID: $categoryId');
      LoggerUtils.info('Category Name: $categoryName');
      LoggerUtils.info('Latitude: $latValue');
      LoggerUtils.info('Longitude: $longValue');

      controller.setCategoryData(
        id: categoryId,
        name: categoryName,
        latValue: latValue,
        longValue: longValue,
      );
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        title: Obx(() {
          return Text(
            controller.categoryName.value.isNotEmpty
                ? controller.categoryName.value
                : categoryName,
            style: TextFontStyle.headline18w700c000000StyleSatoshi,
          );
        }),
      ),
      body: Padding(
        padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
        child: Column(
          children: [
            ///Section : Search Bar
            CustomFormField(
              showVerticalDivider: false,
              controller: _searchController,
              prefixIcon: SvgPicture.asset(Assets.icons.searchIcon),
              hintText: "${'search'.tr} $categoryName ${'services'.tr}",
              onFieldSubmitted: (value) {
                controller.performSearch(value);
              },
            ),
            UIHelper.verticalSpace(16.h),

            ///Section : Available Services
            Expanded(
              child: Obx(() {
                LoggerUtils.debug(
                    'UI rebuild triggered. List length: ${controller.specificCategoryList.length}, Loading: ${controller.isLoading.value}');

                ///When Loading state is true
                if (controller.isLoading.value) {
                  LoggerUtils.debug('Showing loading state');
                  return ListView(
                    children: [
                      ...List.generate(
                        6,
                        (index) => Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: CustomShimmerEffect(
                            height: 320.h,
                            width: 1.sw,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                ///When There is no Data to Show
                if (controller.specificCategoryList.isEmpty) {
                  LoggerUtils.debug('Showing empty state');
                  return Center(
                    child: Lottie.asset(
                      Assets.lottie.emptyScreen,
                      fit: BoxFit.contain,
                    ),
                  );
                }

                LoggerUtils.debug(
                    'Showing list with ${controller.specificCategoryList.length} items');
                return RefreshIndicator(
                  onRefresh: () async {
                    controller.pageId.value = '1';
                    await controller.handleServiceFromSpecificCategory();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: controller.specificCategoryList.length +
                        (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Check if we're on the last item and need to show a loading indicator
                      if (index >= controller.specificCategoryList.length) {
                        LoggerUtils.debug(
                            'Showing loading indicator at index $index');
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final service = controller.specificCategoryList[index];
                      LoggerUtils.debug(
                          'Building item at index $index for service: ${controller.getServiceId(service)}');

                      // Extract data using controller helper methods
                      final serviceName = controller.getServiceName(service);
                      final providerName = controller.getProviderName(service);
                      final rating = controller.getServiceRating(service);
                      final price = controller.getServicePrice(service);
                      final imageUrl = controller.getServiceImage(service);
                      final providerImageUrl =
                          controller.getProviderImage(service);

                      LoggerUtils.debug(
                          'Service: $serviceName, Provider: $providerName, Image: $imageUrl, Provider Image: $providerImageUrl');

                      return Column(
                        children: [
                          SpecificServiceShowingWidget(
                            seeDetailsOnTap: () {
                              log("Specific Service Item tapped at index: $index");
                              LoggerUtils.debug(
                                  "🥶🥶🥶🥶🥶🥶🥶🥶🥶🥶🥶-----Service ID IS Required to see the details of the service!");
                              LoggerUtils.debug(
                                  "🥶🥶🥶🥶🥶🥶🥶-------Service ID : ${controller.getServiceId(service)}");
                              Get.toNamed(
                                Routes.serviceDetailsScreen,
                                arguments: {
                                  ///
                                  'serviceId': controller.getServiceId(service),
                                  'providerID':
                                      controller.getProviderId(service),
                                  'serviceProviderID':
                                      controller.getProviderId(service),
                                  'serviceName': serviceName,
                                  'providerName': providerName,
                                  'serviceImage': imageUrl,
                                  'providerImage': providerImageUrl,
                                  'rating': rating,
                                  'price': price,
                                  'experience':
                                      controller.getExperience(service),
                                },
                              );
                            },
                            goToBookingsOnTap: () {
                              log("Book Now Button Tapped at Index: $index");
                              Get.toNamed(
                                Routes.bookingDateScreen,
                                arguments: {
                                  'providerID':
                                      controller.getProviderId(service),
                                  'serviceId': controller.getServiceId(service),
                                  'serviceName': serviceName,
                                },
                              );
                            },
                            serviceImagePath: imageUrl.isNotEmpty
                                ? imageUrl
                                : Assets.images.serviceImage.path,
                            serviceName: serviceName,
                            initialPayablePrice: price,
                            serviceProviderImage: providerImageUrl.isNotEmpty
                                ? providerImageUrl
                                : Assets.images.userImage.path,
                            serviceProviderName: providerName,
                            serviceProviderRating: rating,
                          ),
                          UIHelper.verticalSpace(16.h),
                        ],
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

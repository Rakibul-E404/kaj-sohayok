import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../utilities/app_url.dart';
import '../features/normal_user/home/models/home_page_data_model.dart' as Model;

class HomePageController extends GetxController {
  var currentPage = 0.obs;
  RxBool isLoading = false.obs;

  // API Data
  RxList<Model.Category> categories = <Model.Category>[].obs;
  RxList<Model.Provider> providers = <Model.Provider>[].obs;
  RxList<Model.Banner> banners = <Model.Banner>[].obs;

  final PageController pageController = PageController();

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void disposeController() {
    pageController.dispose();
  }

  Future<void> handleHomePageData() async {
    try {
      log('🏠 HOME CONTROLLER: Starting to load home data');
      isLoading.value = true;

      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.getNormalUserHomeData,
      );

      log(
        '🏠 HOME CONTROLLER: Network response received - Success: ${response.isSuccess}, Status: ${response.statusCode}, Message: ${response.errorMessage}',
      );

      if (response.isSuccess && response.jsonResponse != null) {
        log('🏠 HOME CONTROLLER: Raw response from API: ${response.jsonResponse}');
        log('🏠 HOME CONTROLLER: Parsing home page data');
        final homePageDataModel = Model.HomePageDataModel.fromJson(
          response.jsonResponse!,
        );

        log('🏠 HOME CONTROLLER: Response parsed successfully');

        if (homePageDataModel.data?.attributes != null) {
          // Parse categories
          categories.value =
              homePageDataModel.data!.attributes!.categories ?? [];
          log('🏠 HOME CONTROLLER: Categories loaded: ${categories.length}');

          // Parse providers
          providers.value = homePageDataModel.data!.attributes!.providers ?? [];
          log('🏠 HOME CONTROLLER: Providers loaded: ${providers.length}');

          // Parse banners
          banners.value = homePageDataModel.data!.attributes!.banners ?? [];
          log('🏠 HOME CONTROLLER: Banners loaded: ${banners.length}');

          // Additional logging to see what's in the banners
          if (banners.isEmpty) {
            log('🏠 HOME CONTROLLER: Banners list is empty - checking if attribute exists in response');
            if (response.jsonResponse!['data'] != null &&
                response.jsonResponse!['data']['attributes'] != null) {
              dynamic bannerData = response.jsonResponse!['data']['attributes']['banners'];
              log('🏠 HOME CONTROLLER: Raw banner data from API: $bannerData');
              log('🏠 HOME CONTROLLER: Type of banner data: ${bannerData.runtimeType}');
            }
          }
        } else {
          log('🏠 HOME CONTROLLER: No attributes found in response');
        }
      } else {
        log(
          '🏠 HOME CONTROLLER: Failed to load home data - ${response.errorMessage}',
        );
        Get.snackbar(
          'Error',
          'Failed to load home data: ${response.errorMessage}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log('🏠 HOME CONTROLLER: Exception occurred - $e');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      log('🏠 HOME CONTROLLER: Loading finished - isLoading: $isLoading');
    }
  }

  @override
  void onInit() {
    handleHomePageData();
    super.onInit();
  }

  @override
  void onClose() {
    disposeController();
    super.onClose();
  }
}

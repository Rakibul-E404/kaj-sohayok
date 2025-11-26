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
      isLoading.value = true;

      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.getNormalUserHomeData,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final homePageDataModel = Model.HomePageDataModel.fromJson(response.jsonResponse!);

        if (homePageDataModel.data?.attributes != null) {
          // Parse categories
          categories.value = homePageDataModel.data!.attributes!.categories ?? [];

          // Parse providers
          providers.value = homePageDataModel.data!.attributes!.providers ?? [];

          // Parse banners
          banners.value = homePageDataModel.data!.attributes!.banners ?? [];
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load home data',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
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

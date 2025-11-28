import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/service/network_caller.dart';
import 'package:kaz_bd/service/network_response.dart';
import 'package:kaz_bd/utilities/app_url.dart';

import '../features/normal_user/services_of_specific_category/model/get_services_by_category.dart';

class ServiceOfSpecificCategoryScreenController extends GetxController {
  // var currentPage = 0.obs;
  RxBool isLoading = false.obs;
  RxList<Result> specificCategoryList =
      <Result>[].obs; // Changed to Result type
  var categoryId = ''.obs; // Add this to store categoryId
  var categoryName = ''.obs; // Add this to store categoryName
  var pageId = '1'.obs; // Add pagination
  var searchQuery = ''.obs; // Add search query variable

  final PageController pageController = PageController();

  // void onPageChanged(int index) {
  //   currentPage.value = index;
  // }

  void disposeController() {
    pageController.dispose();
  }

  // Method to set category data and fetch services
  void setCategoryData({required String id, required String name}) {
    categoryId.value = id;
    categoryName.value = name;
    handleServiceFromSpecificCategory();
  }

  Future<void> handleServiceFromSpecificCategory({String? searchQuery}) async {
    // Check if categoryId is available
    if (categoryId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Category ID is missing',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
      return;
    }

    // Update search query if provided
    if (searchQuery != null) {
      this.searchQuery.value = searchQuery;
    }

    try {
      isLoading.value = true;

      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.getSpecificServiceByCategory(
          categoryId: categoryId.value,
          pageId: pageId.value,
          serviceName: this.searchQuery.value.isNotEmpty ? this.searchQuery.value : null,
        ),
      );

      if (response.isSuccess) {
        // Parse the response
        final GetServicesByCategoriesModel responseModel =
            GetServicesByCategoriesModel.fromJson(response.jsonResponse!);

        if (responseModel.data?.attributes?.results != null) {
          specificCategoryList.assignAll(
            responseModel.data!.attributes!.results!,
          );
        } else {
          specificCategoryList.clear();
          Get.snackbar(
            'Info',
            'No services found for this category',
            backgroundColor: AppColors.cffb701,
            colorText: AppColors.cFFFFFF,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load services: ${response.errorMessage}',
          backgroundColor: AppColors.cee3333,
          colorText: AppColors.cFFFFFF,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method to perform search
  Future<void> performSearch(String query) async {
    searchQuery.value = query;
    pageId.value = '1'; // Reset to first page when searching
    await handleServiceFromSpecificCategory(searchQuery: query);
  }

  // Method to load more data for pagination
  Future<void> loadMoreServices() async {
    pageId.value = (int.parse(pageId.value) + 1).toString();
    await handleServiceFromSpecificCategory();
  }

  // @override
  // void onInit() {
  //   // Don't call handleServiceFromSpecificCategory here anymore
  //   // It will be called from setCategoryData
  //   super.onInit();
  // }

  @override
  void onClose() {
    disposeController();
    super.onClose();
  }
}

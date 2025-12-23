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
  RxBool isLoadingMore = false.obs; // For loading more indicator
  RxBool hasMoreData = true.obs; // Track if there's more data to load
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

  Future<void> handleServiceFromSpecificCategory(
      {String? searchQuery, bool isLoadMore = false}) async {
    // Check if categoryId is available
    if (categoryId.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'category_id_is_missing'.tr,
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
      // Set the appropriate loading indicator
      if (!isLoadMore) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.getSpecificServiceByCategory(
          categoryId: categoryId.value,
          pageId: pageId.value,
          serviceName:
              this.searchQuery.value.isNotEmpty ? this.searchQuery.value : null,
        ),
      );

      if (response.isSuccess) {
        // Parse the response
        final GetServicesByCategoriesModel responseModel =
            GetServicesByCategoriesModel.fromJson(response.jsonResponse!);

        if (responseModel.data?.attributes?.results != null) {
          if (!isLoadMore) {
            // Clear the list and assign new data for initial load
            specificCategoryList.assignAll(
              responseModel.data!.attributes!.results!,
            );
          } else {
            // Append new data for load more
            specificCategoryList.addAll(
              responseModel.data!.attributes!.results!,
            );
          }

          // Check if there are more pages available
          int currentPage = int.tryParse(pageId.value) ?? 1;
          int totalPages = responseModel.data?.attributes?.totalPages ?? 1;
          hasMoreData.value = currentPage < totalPages;
        } else {
          if (!isLoadMore) {
            specificCategoryList.clear();
            Get.snackbar(
              'info'.tr,
              'no_services_for_specific_category'.tr,
              backgroundColor: AppColors.cffb701,
              colorText: AppColors.cFFFFFF,
            );
          }
        }
      } else {
        Get.snackbar(
          'error'.tr,
          '${'failed_to_load_services'.tr}: ${response.errorMessage}',
          backgroundColor: AppColors.cee3333,
          colorText: AppColors.cFFFFFF,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'somthing_went_wrong'.tr}: $e',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
    } finally {
      if (!isLoadMore) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
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
    if (!hasMoreData.value || isLoadingMore.value)
      return; // Prevent multiple calls when loading or no more data

    pageId.value = (int.parse(pageId.value) + 1).toString();
    await handleServiceFromSpecificCategory(isLoadMore: true);
  }

  @override
  void onClose() {
    disposeController();
    super.onClose();
  }
}

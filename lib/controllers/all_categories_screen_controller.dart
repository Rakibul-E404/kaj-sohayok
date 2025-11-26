import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/features/normal_user/all_categories/models/normal_user_all_category_model.dart';

import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../utilities/app_url.dart';

class NormalUserAllCategoryScreenController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Result> categories = <Result>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllCategories();
  }

  Future<void> fetchAllCategories() async {
    try {
      isLoading.value = true;
      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.getNormalUserAllCategory,
      );
      if (response.isSuccess && response.jsonResponse != null) {
        final model = NormalUserAllCategoryModel.fromJson(
          response.jsonResponse!,
        );
        if (model.data?.attributes?.results != null) {
          categories.value = model.data!.attributes!.results!;
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load categories',
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
}

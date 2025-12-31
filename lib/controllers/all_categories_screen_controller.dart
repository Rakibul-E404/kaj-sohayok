import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/features/normal_user/all_categories/models/normal_user_all_category_model.dart';
import 'package:kaz_bd/utilities/logger_util.dart';

import '../service/location/location_controller.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../utilities/app_url.dart';

class NormalUserAllCategoryScreenController extends GetxController {
  LocationController locationController = Get.put(LocationController());
  String latitudeValue = '';
  String longitudeValue = '';
  RxBool isLoading = false.obs;
  RxList<Result> categories = <Result>[].obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllCategories();
  }

  Future<void> fetchAllCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.getNormalUserAllCategory,
      );
      if (response.isSuccess && response.jsonResponse != null) {
        ///Get Location Latitud And Longitude
        await locationController.fetchCurrentLocation();
        latitudeValue =
            locationController.currentPosition.value?.latitude.toString() ?? '';
        longitudeValue =
            locationController.currentPosition.value?.longitude.toString() ??
                '';

        final model = NormalUserAllCategoryModel.fromJson(
          response.jsonResponse!,
        );
        if (model.data?.attributes?.results != null) {
          categories.value = model.data!.attributes!.results!;
        }
      } else {
        String apiMessage =
            response.jsonResponse!['message'] ?? 'Failed to load Categories';
        errorMessage.value = apiMessage;
        LoggerUtils.error(
            '❌ [PENDING CONTROLLER] API returned error: $apiMessage');
        Get.snackbar(
          'error'.tr,
          apiMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // errorMessage.value =
      //     'Connection error: Please check your internet connection';
      LoggerUtils.error(
          '❌ [PENDING CONTROLLER] Exception in getPendingBookings: $e');

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

  Future<void> refreshData() async {
    await fetchAllCategories();
  }
}

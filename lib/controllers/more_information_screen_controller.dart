// controllers/service_category_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaz_bd/service/secured_storage.dart';
import 'package:kaz_bd/utilities/app_constants.dart';
import 'package:kaz_bd/utilities/logger_util.dart';

import '../models/service_signup_form_model.dart';
import '../service/network_caller.dart';
import '../utilities/app_url.dart';

class MoreInformationScreenController extends GetxController {
  // Form controllers
  final TextEditingController workTypeController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController yearsOfExperienceController =
      TextEditingController();
  final TextEditingController workPriceController = TextEditingController();
  final TextEditingController otherServiceController = TextEditingController();

  // State management
  final RxList<ServiceFormCategoryModel> categories =
      <ServiceFormCategoryModel>[].obs;
  final Rxn<ServiceFormCategoryModel> selectedCategory =
      Rxn<ServiceFormCategoryModel>();
  final RxBool isLoading = false.obs;
  final RxBool isOtherSelected = false.obs;

  // Image paths
  final RxString imageFrontSide = ''.obs;
  final RxString imageBackSide = ''.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchServiceCategories();
  }

  /// Fetch service categories from API
  Future<void> fetchServiceCategories() async {
    try {
      isLoading.value = true;

      // TODO: Replace with your actual API call
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';
      final response = await NetworkCaller().getRequest(
        AppUrl.serviceFormCategories,
        headers: {'Authorization': 'Bearer $token'},
      );

      // Mock data for demonstration
      await Future.delayed(const Duration(seconds: 1));

      // Parse response
      if (response.jsonResponse != null) {
        final ServiceCategoryResponse categoryResponse =
            ServiceCategoryResponse.fromJson(response.jsonResponse!);
        categories.value = categoryResponse.categories;

        LoggerUtils.debug(categories[0].id);
        LoggerUtils.debug(categories.length);
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch service categories ',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      // Will be populated from API
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load service categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Select a service category
  void selectCategory(ServiceFormCategoryModel category) {
    selectedCategory.value = category;
    isOtherSelected.value = false;
    otherServiceController.clear();
  }

  /// Select "Other" option
  void selectOther() {
    selectedCategory.value = null;
    isOtherSelected.value = true;
  }

  /// Pick image from camera or gallery
  Future<void> pickImage({
    required ImageSource source,
    required bool isFront,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        if (isFront) {
          imageFrontSide.value = image.path;
        } else {
          imageBackSide.value = image.path;
        }
      } else {
        Get.snackbar('Cancelled', 'No image selected');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  /// Show image source dialog
  void showImageSourceDialog({required bool isFront}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Get.back();
                  pickImage(source: ImageSource.camera, isFront: isFront);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery'),
                onTap: () {
                  Get.back();
                  pickImage(source: ImageSource.gallery, isFront: isFront);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Remove image
  void removeImage({required bool isFront}) {
    if (isFront) {
      imageFrontSide.value = '';
    } else {
      imageBackSide.value = '';
    }
  }

  /// Validate and proceed
  bool validateForm() {
    if (selectedCategory.value == null && !isOtherSelected.value) {
      Get.snackbar('Error', 'Please select a work type');
      return false;
    }

    if (isOtherSelected.value && otherServiceController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter other service name');
      return false;
    }

    if (businessNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter business name');
      return false;
    }

    if (yearsOfExperienceController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter years of experience');
      return false;
    }

    if (workPriceController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter starting work price');
      return false;
    }

    if (imageFrontSide.value.isEmpty || imageBackSide.value.isEmpty) {
      Get.snackbar('Error', 'Please upload both front and back side documents');
      return false;
    }

    return true;
  }

  /// Submit form
  Future<void> submitForm() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      // TODO: Implement API submission
      // final Map<String, dynamic> data = {
      //   'workType': selectedCategory.value?.nameEn ?? otherServiceController.text,
      //   'businessName': businessNameController.text,
      //   'yearsOfExperience': yearsOfExperienceController.text,
      //   'startingPrice': workPriceController.text,
      // };

      // final response = await NetworkCaller().multipartRequest(
      //   AppUrl.submitServiceInfo,
      //   body: data,
      //   files: {
      //     'frontImage': File(imageFrontSide.value),
      //     'backImage': File(imageBackSide.value),
      //   },
      // );

      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar('Success', 'Information submitted successfully');
      // Navigate to next screen
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    workTypeController.dispose();
    businessNameController.dispose();
    yearsOfExperienceController.dispose();
    workPriceController.dispose();
    otherServiceController.dispose();
    super.onClose();
  }
}

// controllers/more_information_screen_controller.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaz_bd/routes/routes.dart';
import 'package:kaz_bd/service/get_storage.dart';
import 'package:kaz_bd/service/secured_storage.dart';
import 'package:kaz_bd/utilities/app_constants.dart';
import 'package:kaz_bd/utilities/logger_util.dart';

import '../gen/colors.gen.dart';
import '../models/service_signup_form_model.dart';
import '../service/location/location_controller.dart';
import '../service/network_caller.dart';
import '../utilities/app_url.dart';

class MoreInformationScreenController extends GetxController {
  // Form controllers
  final TextEditingController workTypeController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController yearsOfExperienceController =
      TextEditingController();
  final TextEditingController workPriceController = TextEditingController();
  final TextEditingController nidNumberTEController = TextEditingController();
  final TextEditingController otherServiceController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
  final RxString imageSelfie = ''.obs; // 👈 New
  final RxString otherServiceText = ''.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchServiceCategories();
    otherServiceController.addListener(() {
      otherServiceText.value = otherServiceController.text;
    });
  }

  Future<void> fetchServiceCategories() async {
    try {
      isLoading.value = true;

      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';
      final response = await NetworkCaller().getRequest(
        AppUrl.serviceFormCategories,
        headers: {'Authorization': 'Bearer $token'},
      );
      LoggerUtils.debug(response.jsonResponse);
      await Future.delayed(const Duration(seconds: 1));

      if (response.jsonResponse != null) {
        final ServiceCategoryResponse categoryResponse =
            ServiceCategoryResponse.fromJson(response.jsonResponse!);
        categories.value = categoryResponse.categories;

        // LoggerUtils.debug(categories[0].id);
        // LoggerUtils.debug(categories.length);
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch service categories ',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
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

  void selectCategory(ServiceFormCategoryModel category) {
    selectedCategory.value = category;
    isOtherSelected.value = false;
    otherServiceController.clear();
  }

  void selectOther() {
    selectedCategory.value = null;
    isOtherSelected.value = true;
  }

  // For front/back ID images
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
        // Get.snackbar('Cancelled', 'No image selected');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  // 👇 NEW: Selfie with front camera only
  Future<void> captureSelfieWithFrontCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        imageSelfie.value = image.path;
      } else {}
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture selfie: $e');
    }
  }

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

  void removeImage({required bool isFront}) {
    if (isFront) {
      imageFrontSide.value = '';
    } else {
      imageBackSide.value = '';
    }
  }

  void removeSelfie() {
    imageSelfie.value = '';
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    if ((selectedCategory.value == null && !isOtherSelected.value)) {
      Get.snackbar(
        'Error',
        'Please select a work type !!!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (imageSelfie.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please take a selfie with your ID',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (imageFrontSide.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please upload the image !!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (imageBackSide.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please upload the image !!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      LocationController locationController = Get.put(LocationController());
      await locationController.fetchCurrentLocation();

      Map<String, String> fields;

      if (locationController.currentPosition.value == null ||
          locationController.currentPosition.value!.latitude
              .toString()
              .isEmpty ||
          (locationController.currentPosition.value == null ||
              locationController.currentPosition.value!.longitude
                  .toString()
                  .isEmpty)) {
        Get.snackbar(
          'Error',
          'Please ensure location access to submit the form',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      if (selectedCategory.value != null) {
        fields = {
          'serviceCategoryId': selectedCategory.value!.id.toString(),
          'serviceName': businessNameController.text.trim(),
          'yearsOfExperience': yearsOfExperienceController.text.trim(),
          'startPrice': workPriceController.text.trim(),
          "address":
              '${(locationController.currentAddress.value?.street ?? '')},${(locationController.currentAddress.value?.subLocality ?? '')},${(locationController.currentAddress.value?.locality ?? '')},${(locationController.currentAddress.value?.country ?? '')} ',
          "lat":
              locationController.currentPosition.value?.latitude.toString() ??
                  '',
          "lng":
              locationController.currentPosition.value?.longitude.toString() ??
                  '',
          "nidNumber": nidNumberTEController.text.trim() ?? ''
        };
      } else {
        fields = {
          'categoryCustomName': otherServiceController.text.trim(),
          'serviceName': businessNameController.text.trim(),
          'yearsOfExperience': yearsOfExperienceController.text.trim(),
          'startPrice': workPriceController.text.trim(),
          "address":
              '${(locationController.currentAddress.value?.street ?? '')},${(locationController.currentAddress.value?.subLocality ?? '')},${(locationController.currentAddress.value?.locality ?? '')},${(locationController.currentAddress.value?.country ?? '')} ',
          "lat":
              locationController.currentPosition.value?.latitude.toString() ??
                  '',
          "lng":
              locationController.currentPosition.value?.longitude.toString() ??
                  '',
          "nidNumber": nidNumberTEController.text.trim() ?? ''
        };
      }

      // ✅ Only include files that are actually selected
      final Map<String, File> files = {};

      if (imageFrontSide.value.isNotEmpty) {
        files['frontSideCertificateImage'] = File(imageFrontSide.value);
      }
      if (imageBackSide.value.isNotEmpty) {
        files['backSideCertificateImage'] = File(imageBackSide.value);
      }
      if (imageSelfie.value.isNotEmpty) {
        files['faceImageFromFrontCam'] = File(imageSelfie.value);
      }

      // ✅ Add auth header
      final String? token = await SecureStorageService().read(
        AppConstants.accessToken,
      );
      final Map<String, String> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      // LoggerUtils.debug(fields);
      // ✅ Call multipartRequest with 'fields' and 'files'
      final response = await NetworkCaller().multipartRequest(
        AppUrl.serviceProviderFormSubmit,
        fields: fields,
        files: files,
        headers: headers,
      );

      if (response.isSuccess) {
        Get.snackbar('Success', 'Information submitted successfully');
        // Optionally navigate to next screen:
        GetStorageModel().saveBool(
          AppConstants.providerProfileIsComplete,
          true,
        );
        // Get.offNamed(Routes.navigationScreen);
        await SecureStorageService().clear();
        Get.offAllNamed(Routes.chooseRoleScreen);
      } else if (response.statusCode == 409) {
        Get.snackbar(
          'Submission Failed',
          response.jsonResponse?['message'] ??
              response.errorMessage ??
              'Unknown error',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Submission Failed',
          response.jsonResponse?['message'] ??
              response.errorMessage ??
              'Unknown error',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
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

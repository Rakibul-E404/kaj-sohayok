import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/get_provider_document_details_model.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';

class SvpProfileScreenDocumentsTabController extends GetxController {
  TextEditingController workTypeController = TextEditingController();
  TextEditingController yearsOfExperienceController = TextEditingController();
  TextEditingController initialPayableController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  RxBool isWorkTypeFieldEnabled = false.obs;
  RxBool isYearsOfExperienceFieldEnabled = false.obs;
  RxBool isInitialPriceFormFieldEnabled = false.obs;
  RxBool isServiceDescriptionFormFieldEnabled = false.obs;
  final RxBool loader = false.obs;

  /// Images
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final int maxImages = 6;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImages() async {
    int remaining = maxImages - selectedImages.length;
    if (remaining <= 0) {
      Get.snackbar("Limit reached", "You can only upload $maxImages images.");
      return;
    }

    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      var toAdd = images.take(remaining).toList();
      selectedImages.addAll(toAdd);
    }
  }

  @override
  void onInit() {
    fetchProviderDocument();
    super.onInit();
  }

  /// ======================> Fetch the Documents ======================>
  final Rxn<ProviderDocumentDetailsModel> providerDocumentDetailsModel =
      Rxn<ProviderDocumentDetailsModel>();

  Future<void> fetchProviderDocument() async {
    try {
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';
      loader.value = true;
      final NetworkResponse getResponse = await NetworkCaller().getRequest(
        AppUrl.getProviderDocumentDetails,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );
      if (getResponse.isSuccess) {
        providerDocumentDetailsModel.value =
            ProviderDocumentDetailsModel.fromJson(
              getResponse.jsonResponse?['data']['attributes'],
            );
        workTypeController.text =
            providerDocumentDetailsModel.value?.serviceProvider.serviceName.en
                .toString() ??
            '';
        yearsOfExperienceController.text =
            providerDocumentDetailsModel
                .value
                ?.serviceProvider
                .yearsOfExperience
                .toString() ??
            '';
        initialPayableController.text =
            providerDocumentDetailsModel.value?.serviceProvider.startPrice
                .toString() ??
            '';
        descriptionController.text =
            providerDocumentDetailsModel.value?.serviceProvider.description.en
                .toString() ??
            '';

        /// =========== Image ==============>
        imageFrontSide.value =
            providerDocumentDetailsModel
                .value
                ?.userProfile
                .frontSideCertificateImage
                .firstOrNull
                ?.attachmentUrl ??
            '';
        imageBackSide.value =
            providerDocumentDetailsModel
                .value
                ?.userProfile
                .backSideCertificateImage
                .firstOrNull
                ?.attachmentUrl ??
            '';
        imageSelfie.value =
            providerDocumentDetailsModel
                .value
                ?.userProfile
                .faceImageFromFrontCam
                .firstOrNull
                ?.attachmentUrl ??
            '';
        LoggerUtils.warning(imageSelfie.value);
      } else {
        Get.snackbar(
          'Failed',
          getResponse.jsonResponse?['message'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      LoggerUtils.debug("Exception : ${e.toString()}");
    } finally {
      loader.value = false;
    }
  }

  /// ================> Image ================>
  final RxString imageFrontSide = ''.obs;
  final RxString imageBackSide = ''.obs;
  final RxString imageSelfie = ''.obs;
  final ImagePicker _picker = ImagePicker();

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

  /// ====================> Update the profile =================>

  // updateProviderProfile() {
  //   try {
  //     loader.value = true;
  //     Map<String, String> fields;
  //     if (selectedCategory.value != null) {
  //       fields = {
  //         'serviceCategoryId': selectedCategory.value!.id.toString(),
  //         'serviceName': businessNameController.text.trim(),
  //         'yearsOfExperience': yearsOfExperienceController.text.trim(),
  //         'startPrice': workPriceController.text.trim(),
  //       };
  //     } else {
  //       fields = {
  //         'categoryCustomName': otherServiceController.text.trim(),
  //         'serviceName': businessNameController.text.trim(),
  //         'yearsOfExperience': yearsOfExperienceController.text.trim(),
  //         'startPrice': workPriceController.text.trim(),
  //       };
  //     }
  //
  //     // ✅ Only include files that are actually selected
  //     final Map<String, File> files = {};
  //
  //     if (imageFrontSide.value.isNotEmpty) {
  //       files['frontSideCertificateImage'] = File(imageFrontSide.value);
  //     }
  //     if (imageBackSide.value.isNotEmpty) {
  //       files['backSideCertificateImage'] = File(imageBackSide.value);
  //     }
  //     if (imageSelfie.value.isNotEmpty) {
  //       files['faceImageFromFrontCam'] = File(imageSelfie.value);
  //     }
  //
  //     // ✅ Add auth header
  //     final String? token = await SecureStorageService().read(
  //       AppConstants.accessToken,
  //     );
  //     final Map<String, String> headers = {};
  //     if (token != null) {
  //       headers['Authorization'] = 'Bearer $token';
  //     }
  //     // LoggerUtils.debug(fields);
  //     // ✅ Call multipartRequest with 'fields' and 'files'
  //     final response = await NetworkCaller().multipartRequest(
  //       AppUrl.serviceProviderFormSubmit,
  //       fields: fields,
  //       files: files,
  //       headers: headers,
  //     );
  //
  //     if (response.isSuccess) {
  //       Get.snackbar('Success', 'Information submitted successfully');
  //       // Optionally navigate to next screen:
  //       GetStorageModel().saveBool(
  //         AppConstants.providerProfileIsComplete,
  //         true,
  //       );
  //       // Get.offNamed(Routes.navigationScreen);
  //       await SecureStorageService().clear();
  //       Get.offAllNamed(Routes.chooseRoleScreen);
  //     } else {
  //       Get.snackbar(
  //         'Submission Failed',
  //         response.jsonResponse?['message'] ??
  //             response.errorMessage ??
  //             'Unknown error',
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to submit: $e');
  //   } finally {
  //     loader.value = false;
  //   }
  // }

  void removeImage({required bool isFront}) {
    if (isFront) {
      imageFrontSide.value = '';
    } else {
      imageBackSide.value = '';
    }
  }
}

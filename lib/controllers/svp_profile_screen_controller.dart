import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../gen/colors.gen.dart';

class SvpProfileScreenController extends GetxController
    with GetTickerProviderStateMixin {
  /// Section : Profile Image Picker
  final ImagePicker _picker = ImagePicker();

  /// Instead of File, store path for efficiency
  RxString svpPickedImagePath = ''.obs;

  /// Pick image from given source (camera/gallery)
  Future<void> pickImage({required ImageSource imagePickerSourceType}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: imagePickerSourceType,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        svpPickedImagePath.value = image.path;
      } else {
        Get.snackbar("Cancelled", "No image selected");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
    }
  }

  /// Show Camera / Gallery selection
  void showImageSourceDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cFFFFFF,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Get.back();
                  pickImage(imagePickerSourceType: ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  Get.back();
                  pickImage(imagePickerSourceType: ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ------------------- Language Selection -------------------
  late TabController languageTabController;
  var languageSelectionTabIndex = 0.obs;

  void changeLanguageTab(int index) {
    languageSelectionTabIndex.value = index;
  }

  /// ------------------- Profile Options Tabs -------------------
  late TabController svpProfileOptionsTabController;
  var svpProfileSectionTabIndex = 0.obs;

  void changeProfileOptionsTab(int index) {
    svpProfileSectionTabIndex.value = index;
  }

  ///------------------ OnInit Load Function ---------------------
  @override
  void onInit() {
    super.onInit();

    /// Language Tab Controller
    languageTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: languageSelectionTabIndex.value,
    );
    languageTabController.addListener(() {
      changeLanguageTab(languageTabController.index);
    });

    /// Profile Options Tab Controller
    svpProfileOptionsTabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: svpProfileSectionTabIndex.value,
    );
    svpProfileOptionsTabController.addListener(() {
      changeProfileOptionsTab(svpProfileOptionsTabController.index);
    });
  }

  ///----------------------------- Dispost the controllers function --------------------------
  @override
  void onClose() {
    languageTabController.dispose();
    svpProfileOptionsTabController.dispose();
    super.onClose();
  }
}

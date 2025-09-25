import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../gen/colors.gen.dart';

class SvpSubmitWorkFormScreenController extends GetxController {
  TextEditingController completionDateController = TextEditingController();
  TextEditingController durationTimeController = TextEditingController();

  /// Section : Profile Image Picker
  final ImagePicker _picker = ImagePicker();

  /// Instead of File, store path for efficiency
  RxString selectedImage = ''.obs;

  /// Pick image from given source (camera/gallery)
  Future<void> pickImage({required ImageSource imagePickerSourceType}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: imagePickerSourceType,
        maxWidth: 1024, // resize for performance
        maxHeight: 1024,
        imageQuality: 85, // compress
      );

      if (image != null) {
        selectedImage.value = image.path;
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
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.cFFFFFF,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ///Section : Camera
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Get.back();
                  pickImage(imagePickerSourceType: ImageSource.camera);
                },
              ),

              ///Section : Gallery
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

  ///Remove Selected Image
  void removeImage() {
    selectedImage.value = '';
  }
}

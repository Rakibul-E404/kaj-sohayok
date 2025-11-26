import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SvpProfileScreenDocumentsTabController extends GetxController {
  TextEditingController workTypeController = TextEditingController();
  TextEditingController yearsOfExperienceController = TextEditingController();
  TextEditingController initialPayableController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  RxBool isWorkTypeFieldEnabled = false.obs;
  RxBool isYearsOfExperienceFieldEnabled = false.obs;
  RxBool isInitialPriceFormFieldEnabled = false.obs;
  RxBool isServiceDescriptionFormFieldEnabled = false.obs;

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

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }
}

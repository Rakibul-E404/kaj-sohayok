// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../gen/colors.gen.dart';

SnackbarController CustomToastMessage(String title, String description) {
  return Get.snackbar(
    title,
    description,
    snackPosition: SnackPosition.TOP,
    backgroundColor: Color(0xff444444),
    colorText: AppColors.cFFFFFF,
  );
}

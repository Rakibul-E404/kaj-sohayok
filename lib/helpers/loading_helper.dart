import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../custom_widgets/loading_indicators.dart';
import '../gen/assets.gen.dart';
import '../gen/colors.gen.dart';

extension Loader on Future {
  Future<dynamic> waitingForFuture() async {
    Get.dialog(loadingIndicatorCircle(), barrierColor: AppColors.cF4F4F4);

    try {
      dynamic result = await this;
      return result;
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  Future<dynamic> waitingAddToCart() async {
    Get.dialog(Center(child: shimmer(name: Assets.lottie.addToCart)));

    try {
      dynamic result = await this;
      return result;
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  Future<dynamic> waitingRemoveFromCart() async {
    Get.dialog(
      Center(
        child: shimmer(name: Assets.lottie.removeFromCart, size: 120.sp),
      ),
    );

    try {
      dynamic result = await this;
      return result;
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  Future<dynamic> waitingForFutureWithoutBg() async {
    Get.dialog(loadingIndicatorCircle());

    try {
      dynamic result = await this;
      return result;
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  Future<void> waitingForFuturewithTime() async {
    try {
      Get.dialog(loadingIndicatorCircle(), barrierColor: AppColors.cF4F4F4);

      bool result = await this;

      if (Get.isDialogOpen ?? false) Get.back();

      if (result) {
        Get.dialog(shimmer(name: Assets.lottie.success, size: 120.sp));
        await Future.delayed(const Duration(milliseconds: 800));
        if (Get.isDialogOpen ?? false) Get.back();
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      log(e.toString());
      rethrow;
    }
  }

  Future<void> waitingForSuccessShow() async {
    try {
      bool result = await this;
      if (result) {
        Get.dialog(shimmer(name: Assets.lottie.success, size: 120.sp));
        await Future.delayed(const Duration(milliseconds: 800));
        if (Get.isDialogOpen ?? false) Get.back();
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      log(e.toString());
    }
  }

  Future<bool> customeThen() async {
    bool retunValue = await then(
      (value) async {
        Get.dialog(shimmer(name: Assets.lottie.waiting, size: 120.sp));
        await Future.delayed(const Duration(milliseconds: 800));
        if (Get.isDialogOpen ?? false) Get.back();
        return true;
      },
      onError: (value) {
        return false;
      },
    );
    return retunValue;
  }
}

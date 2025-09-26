import 'dart:async';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../constants/app_enums.dart';

class FaceVerificationController extends GetxController {
  Rx<FaceVerificationStatus> status = FaceVerificationStatus.initial.obs;
  CameraController? cameraController;
  XFile? capturedImage;
  RxDouble progress = 0.0.obs;

  /// Initialize camera
  Future<void> initCamera() async {
    if (cameraController != null && cameraController!.value.isInitialized) {
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        log("No camera available");
        return;
      }

      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();

      // 🔑 Ensure image stream is not left running
      if (cameraController!.value.isStreamingImages) {
        await cameraController!.stopImageStream();
      }

      status.value = FaceVerificationStatus.capture;
    } catch (e) {
      log('Camera initialization error: $e');
    }
  }

  /// Capture image
  Future<void> captureImage() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    try {
      // 🔑 stop any image stream before capture
      if (cameraController!.value.isStreamingImages) {
        await cameraController!.stopImageStream();
      }

      capturedImage = await cameraController!.takePicture();
      status.value = FaceVerificationStatus.verifying;
      await _simulateVerification();
    } catch (e) {
      log('Capture failed: $e');
      status.value = FaceVerificationStatus.capture;
    }
  }

  /// Simulate verification progress
  Future<void> _simulateVerification() async {
    progress.value = 0.0;
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      progress.value = i / 100;
    }
    status.value = FaceVerificationStatus.done;
  }

  Future<void> onButtonTap(BuildContext context) async {
    switch (status.value) {
      case FaceVerificationStatus.initial:
        await initCamera();
        break;
      case FaceVerificationStatus.capture:
        await captureImage();
        break;
      case FaceVerificationStatus.verifying:
        // do nothing
        break;
      case FaceVerificationStatus.done:
        Get.offAllNamed(Routes.svpHomeScreen);
        break;
    }
  }

  @override
  void onClose() {
    if (cameraController != null) {
      if (cameraController!.value.isStreamingImages) {
        cameraController!.stopImageStream();
      }
      cameraController!.dispose();
      cameraController = null;
    }
    super.onClose();
  }
}

import 'dart:io';
import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import '../../../../controllers/face_verification_controller.dart';
import '../../../../constants/app_enums.dart';

class FaceVerificationScreen extends StatelessWidget {
  FaceVerificationScreen({super.key});

  final FaceVerificationController controller = Get.put(
    FaceVerificationController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UIHelper.verticalSpace(140.h),

              /// Section: Text -> Set Up Face Verification
              Text(
                "Set Up Face Verification",
                style: TextFontStyle.headline20w700c000000StyleSatoshi,
              ),
              UIHelper.verticalSpace(50.h),

              /// Section: Camera / Image Preview
              Obx(() {
                Widget displayWidget;

                if (controller.status.value == FaceVerificationStatus.capture &&
                    controller.cameraController != null &&
                    controller.cameraController!.value.isInitialized) {
                  // Show live camera preview
                  displayWidget = CameraPreview(controller.cameraController!);
                } else if ((controller.status.value ==
                            FaceVerificationStatus.verifying ||
                        controller.status.value ==
                            FaceVerificationStatus.done) &&
                    controller.capturedImage != null) {
                  // Show captured image
                  displayWidget = Image.file(
                    File(controller.capturedImage!.path),
                    fit: BoxFit.cover,
                  );
                } else {
                  // Initial placeholder
                  displayWidget = Image.asset(
                    Assets.images.faceVerificationImage.path,
                    fit: BoxFit.cover,
                  );
                }

                return ClipOval(
                  child: SizedBox(
                    height: 150.h,
                    width: 150.w,
                    child: displayWidget,
                  ),
                );
              }),

              Spacer(),

              /// Section: Progress Indicator + Button
              Obx(() {
                return Column(
                  children: [
                    if (controller.status.value ==
                        FaceVerificationStatus.verifying)
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: LinearProgressIndicator(
                          value: controller.progress.value,
                          minHeight: 5.h,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.amber,
                          ),
                        ),
                      ),
                    CustomElevatedButton(
                      onTap: () => controller.onButtonTap(context),
                      buttonTitle:
                          controller.status.value ==
                              FaceVerificationStatus.initial
                          ? "Scan My Face"
                          : controller.status.value ==
                                FaceVerificationStatus.capture
                          ? "Capture Image"
                          : controller.status.value ==
                                FaceVerificationStatus.verifying
                          ? "Verifying"
                          : "Done",
                    ),
                  ],
                );
              }),
              UIHelper.verticalSpace(20.h),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../../../controllers/svp_profile_screen_documents_tab_controller.dart';
import '../../../../../../gen/colors.gen.dart';
import '../widgets/svp_documents_tab_form_field.dart';
import '../widgets/svp_image_picker_grid_widget.dart';

class SvpDocumentationTab extends StatelessWidget {
  SvpDocumentationTab({super.key});

  final SvpProfileScreenDocumentsTabController controller = Get.put(
    SvpProfileScreenDocumentsTabController(),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        boxShadow: [
          BoxShadow(
            color: AppColors.ca4b1f2.withAlpha(80),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ///Section : Work Type
            Obx(() {
              return SvpDocumentsTabFormField(
                onTap: () {
                  controller.isWorkTypeFieldEnabled.value = true;
                },
                showEdit: false,
                controller: controller.workTypeController,
                isFormFieldEnabled: controller.isWorkTypeFieldEnabled.value,
                fieldName: "Work Type",
                hintText: "Enter Your Work Type",
              );
            }),
            UIHelper.verticalSpace(16.h),

            ///Section : Years of Experience
            Obx(() {
              return SvpDocumentsTabFormField(
                onTap: () {
                  controller.isYearsOfExperienceFieldEnabled.value = true;
                },
                controller: controller.yearsOfExperienceController,
                isFormFieldEnabled:
                    controller.isYearsOfExperienceFieldEnabled.value,
                fieldName: "Years of Experience",
                hintText: "Enter Your Work In Year",
              );
            }),
            UIHelper.verticalSpace(16.h),

            ///Section : Start from Work Price
            Obx(() {
              return SvpDocumentsTabFormField(
                onTap: () {
                  controller.isInitialPriceFormFieldEnabled.value = true;
                },
                controller: controller.initialPayableController,
                isFormFieldEnabled:
                    controller.isInitialPriceFormFieldEnabled.value,
                fieldName: "Start from Work Price",
                hintText: "Enter Initial Payable Fee",
              );
            }),
            UIHelper.verticalSpace(16.h),

            ///Section : Services Description
            Obx(() {
              return SvpDocumentsTabFormField(
                onTap: () {
                  controller.isServiceDescriptionFormFieldEnabled.value = true;
                },
                isDescriptionField: true,
                controller: controller.descriptionController,
                isFormFieldEnabled:
                    controller.isServiceDescriptionFormFieldEnabled.value,
                fieldName: "Services Description",
                hintText: "Write Something About Your Service",
              );
            }),
            UIHelper.verticalSpace(16.h),

            ///Section : Images ====>
            Stack(
              alignment: Alignment.center,
              children: [
                Obx(() {
                  final imagePath = controller.imageFrontSide.value;
                  final bool isNetworkImage = imagePath.startsWith('http');
                  final bool hasImage = imagePath.isNotEmpty;

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: hasImage
                          ? (isNetworkImage
                                ? CachedNetworkImage(
                                    imageUrl: imagePath,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.c778beb,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.file_copy,
                                      size: 60.sp,
                                      color: Colors.grey[400],
                                    ),
                                  )
                                : Image.file(
                                    File(imagePath),
                                    fit: BoxFit.cover,
                                  ))
                          : Container(
                              width: double.infinity,
                              constraints: BoxConstraints(minHeight: 250),
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.file_copy,
                                size: 60.sp,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),
                  );
                }),
                // Edit Icon
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      controller.showImageSourceDialog(isFront: true);
                    },
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: AppColors.c778beb,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpace(16.h),
            Stack(
              alignment: Alignment.center,
              children: [
                Obx(() {
                  final imagePath = controller.imageBackSide.value;
                  final bool isNetworkImage = imagePath.startsWith('http');
                  final bool hasImage = imagePath.isNotEmpty;

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: hasImage
                          ? (isNetworkImage
                                ? CachedNetworkImage(
                                    imageUrl: imagePath,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.c778beb,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.file_copy,
                                      size: 60.sp,
                                      color: Colors.grey[400],
                                    ),
                                  )
                                : Image.file(
                                    File(imagePath),
                                    fit: BoxFit.cover,
                                  ))
                          : Container(
                              width: double.infinity,
                              constraints: BoxConstraints(minHeight: 250),
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.file_copy,
                                size: 60.sp,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),
                  );
                }),
                // Edit Icon
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      controller.showImageSourceDialog(isFront: false);
                    },
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: AppColors.c778beb,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpace(16.h),
            Obx(
              () => _buildSelfieUploadWidget(
                imagePath: controller.imageSelfie.value,
                onCapture: () => controller.captureSelfieWithFrontCamera(),
                onRemove: () => controller.imageSelfie.value = '',
              ),
            ),

            UIHelper.verticalSpace(24.h),

            ///Section : Button -> Save the Changes
            CustomElevatedButton(
              onTap: () {
                controller.isWorkTypeFieldEnabled.value = false;
                controller.isYearsOfExperienceFieldEnabled.value = false;
                controller.isInitialPriceFormFieldEnabled.value = false;
                controller.isServiceDescriptionFormFieldEnabled.value = false;
              },
              buttonTitle: "Save the Changes",
            ),
            UIHelper.verticalSpace(100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSelfieUploadWidget({
    required String imagePath,
    required VoidCallback onCapture,
    required VoidCallback onRemove,
  }) {
    final bool hasImage = imagePath.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selfie with ID (Front Camera)',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        DottedBorder(
          options: RoundedRectDottedBorderOptions(
            dashPattern: [5, 5],
            strokeWidth: 1,
            color: AppColors.c778beb,
            radius: Radius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: hasImage
                ? Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 200.h,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: imagePath.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: imagePath,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.c778beb,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.person,
                                    size: 60.sp,
                                    color: Colors.grey[400],
                                  ),
                                )
                              : Image.file(File(imagePath), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 40.sp, color: AppColors.c778beb),
                      SizedBox(height: 12.h),
                      Text(
                        'Tap to Take a Selfie',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Make sure your face and ID are visible',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Color(0xFF6C606C),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: onCapture,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.c778beb,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 10.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Capture Selfie',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

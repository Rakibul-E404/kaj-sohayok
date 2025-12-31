// screens/more_information_screen.dart

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';

import '../../../../controllers/more_information_screen_controller.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../routes/routes.dart';

class MoreInformationScreen extends StatelessWidget {
  const MoreInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MoreInformationScreenController controller = Get.put(
      MoreInformationScreenController(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'more_information'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Work Type (Interactive)
                      _buildLabel('wrok_type'.tr),
                      SizedBox(height: 8.h),
                      Obx(
                        () => InkWell(
                          onTap: () => _showWorkTypePicker(context, controller),
                          child: _buildReadOnlyField(
                            controller.isOtherSelected.value
                                ? controller.otherServiceText.value.trim()
                                : controller.selectedCategory.value?.nameEn ??
                                    'select_work_type'.tr,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Business Name
                      _buildLabel('business_name'.tr),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: controller.businessNameController,
                        hintText: 'enter_business_name'.tr,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_enter_business_name'.tr;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),

                      // Years of Experience
                      _buildLabel('years_of_experiencee'.tr),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: controller.yearsOfExperienceController,
                        hintText: 'enter_ears_of_experience'.tr,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_enter_years_of_experience'.tr;
                          } else if (int.tryParse(value) == null) {
                            return 'please_enter_a_valid_number'.tr;
                          } else if (int.parse(value) < 0) {
                            return 'years_of_experience_cannot_be_negetive'.tr;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),

                      // Start from Work Price
                      _buildLabel('start_from_work_price*'.tr),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: controller.workPriceController,
                        hintText: 'type_now'.tr,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_enter_the_work_price'.tr;
                          } else if (int.tryParse(value) == null) {
                            return 'please_enter_a_work_price'.tr;
                          } else if (int.parse(value) < 0) {
                            return 'work_price_cannot_be_negetive'.tr;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h), // Start from Work Price
                      _buildLabel('nid_number'.tr),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: controller.nidNumberTEController,
                        hintText: 'type_now'.tr,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_enter_the_nid_number'.tr;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),

                      // Upload Front Side
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(2, 4),
                              blurRadius: 3,
                              color: Colors.grey.withValues(alpha: 0.7),
                            ),
                            BoxShadow(
                              offset: Offset(-4, -4),
                              blurRadius: 3,
                              color: Colors.grey.withValues(alpha: 0.4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildLabel(
                              'upload_driving_nid_documents_front_side'.tr,
                            ),
                            SizedBox(height: 16),
                            Obx(
                              () => _buildImageUploadWidget(
                                imagePath: controller.imageFrontSide.value,
                                onBrowse: () => controller
                                    .showImageSourceDialog(isFront: true),
                                onRemove: () =>
                                    controller.removeImage(isFront: true),
                                buttonText: 'choose_file'.tr,
                                showDragText: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Upload Back Side
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(2, 4),
                              blurRadius: 3,
                              color: Colors.grey.withValues(alpha: 0.7),
                            ),
                            BoxShadow(
                              offset: Offset(-4, -4),
                              blurRadius: 3,
                              color: Colors.grey.withValues(alpha: 0.4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildLabel(
                              'upload_nid_document_back_side'.tr,
                            ),
                            SizedBox(height: 16),
                            Obx(
                              () => _buildImageUploadWidget(
                                imagePath: controller.imageBackSide.value,
                                onBrowse: () => controller
                                    .showImageSourceDialog(isFront: false),
                                onRemove: () =>
                                    controller.removeImage(isFront: false),
                                buttonText: 'choose_file'.tr,
                                showDragText: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Upload Selfie — FRONT CAMERA ONLY
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(2, 4),
                              blurRadius: 3,
                              color: Colors.grey.withValues(alpha: 0.7),
                            ),
                            BoxShadow(
                              offset: Offset(-4, -4),
                              blurRadius: 3,
                              color: Colors.grey.withValues(alpha: 0.4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildLabel('take_selfi_with_nid'.tr),
                            SizedBox(height: 16),
                            Obx(
                              () => _buildImageUploadWidget(
                                imagePath: controller.imageSelfie.value,
                                onBrowse: () =>
                                    controller.captureSelfieWithFrontCamera(),
                                onRemove: () => controller.removeSelfie(),
                                buttonText: 'take_selfie'.tr,
                                showDragText: false, // 👈 hide "drag or choose"
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Buttons
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48.h,
                        child: OutlinedButton(
                          onPressed: () {
                            Get.offAllNamed(Routes.chooseRoleScreen);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            'back'.tr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 48.h,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.submitForm(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.c778beb,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'next'.tr,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showWorkTypePicker(
    BuildContext context,
    MoreInformationScreenController controller,
  ) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Obx(() {
              final isLoading = controller.isLoading.value;
              final isOther = controller.isOtherSelected.value;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 24.h, bottom: 12),
                    child: Center(
                      child: Text(
                        'select_work_type'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Category List
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.separated(
                            physics: BouncingScrollPhysics(),
                            itemCount: controller.categories.length + 1,
                            itemBuilder: (context, index) {
                              if (index == controller.categories.length) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RadioListTile<bool>(
                                      title: Text('other'.tr),
                                      value: true,
                                      groupValue: isOther,
                                      onChanged: (value) {
                                        if (value == true) {
                                          controller.selectOther();
                                        } else {
                                          controller.selectedCategory.value =
                                              null;
                                          controller.isOtherSelected.value =
                                              false;
                                          controller.otherServiceController
                                              .clear();
                                        }
                                      },
                                      activeColor: AppColors.c778beb,
                                      dense: true,
                                    ),
                                    if (isOther) ...[
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 44.w,
                                          top: 8.h,
                                          bottom: 16.h,
                                        ),
                                        child: TextField(
                                          controller:
                                              controller.otherServiceController,
                                          decoration: InputDecoration(
                                            hintText: 'enter_service_name'.tr,
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              borderSide: const BorderSide(
                                                color: AppColors.c778beb,
                                              ),
                                            ),
                                          ),
                                          onSubmitted: (_) => Get.back(),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              }

                              final category = controller.categories[index];
                              final isSelected =
                                  controller.selectedCategory.value?.id ==
                                      category.id;

                              return RadioListTile<String>(
                                title: Row(
                                  spacing: 10,
                                  children: [
                                    category.iconUrl.isNotEmpty
                                        ? ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: category.iconUrl,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                              errorWidget: (
                                                context,
                                                url,
                                                error,
                                              ) =>
                                                  SvgPicture.asset(
                                                Assets
                                                    .icons.serviceProviderLogo,
                                              ),
                                            ),
                                          )
                                        : SvgPicture.asset(
                                            Assets.icons.serviceProviderLogo,
                                          ),
                                    Text(category.nameEn),
                                  ],
                                ),
                                value: category.id,
                                groupValue:
                                    controller.selectedCategory.value?.id,
                                onChanged: (value) {
                                  controller.selectCategory(category);
                                  Get.back();
                                },
                                activeColor: AppColors.c778beb,
                                dense: true,
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Divider();
                            },
                          ),
                  ),

                  if (isOther)
                    CustomElevatedButton(
                      buttonTitle: 'done'.tr,
                      onTap: () {
                        Get.back();
                      },
                    ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildReadOnlyField(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.isEmpty ? 'select_work_type'.tr : text,
              style: TextStyle(
                fontSize: 14.sp,
                color: text.isEmpty ? Colors.grey[400] : Colors.black87,
              ),
            ),
          ),
          Icon(Icons.arrow_drop_down, color: Colors.grey[500], size: 24.sp),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.c778beb, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  Widget _buildImageUploadWidget({
    required String imagePath,
    required VoidCallback onBrowse,
    required VoidCallback onRemove,
    required String buttonText,
    required bool showDragText,
  }) {
    final bool hasImage = imagePath.isNotEmpty;

    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        dashPattern: [5, 5],
        strokeWidth: 1,
        color: AppColors.c778beb,
        radius: Radius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        width: MediaQuery.sizeOf(Get.context!).width,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: hasImage
            ? Stack(
                children: [
                  // ✅ FIX: Wrap in SizedBox or Container with explicit constraints
                  SizedBox(
                    width: double.infinity,
                    height: 200.h, // Set explicit height
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.file(File(imagePath), fit: BoxFit.cover),
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
                  Icon(
                    showDragText
                        ? Icons.cloud_upload_outlined
                        : Icons.camera_alt_outlined,
                    size: 40.sp,
                    color: const Color(0xFF6366F1),
                  ),
                  SizedBox(height: 12.h),
                  if (showDragText)
                    Text(
                      'browse'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  if (!showDragText)
                    Text(
                      'tap_to_take_a_selfie'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  Text(
                    showDragText
                        ? 'format_and_file_size_text'.tr
                        : 'make_sure_your_face_and_id_are_visible'.tr,
                    style: TextStyle(fontSize: 12.sp, color: Color(0xFF6C606C)),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: onBrowse,
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
                      buttonText,
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
    );
  }
}

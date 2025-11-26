// screens/more_information_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';

import '../../../../controllers/more_information_screen_controller.dart';

class MoreInformationScreen extends StatelessWidget {
  const MoreInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller here — only one instance needed
    final MoreInformationScreenController controller = Get.put(
      MoreInformationScreenController(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'More Information',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Work Type (Interactive)
                    _buildLabel('Work Type*'),
                    SizedBox(height: 8.h),
                    Obx(
                      () => InkWell(
                        onTap: () => _showWorkTypePicker(context, controller),
                        child: _buildReadOnlyField(
                          controller.isOtherSelected.value
                              ? controller.otherServiceController.text.trim()
                              : controller.selectedCategory.value?.nameEn ??
                                    'Select work type',
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Business Name
                    _buildLabel('Business Name*'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.businessNameController,
                      hintText: 'Enter business name',
                    ),
                    SizedBox(height: 20.h),

                    // Years of Experience
                    _buildLabel('Years of Experience*'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.yearsOfExperienceController,
                      hintText: 'Enter years of experience',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20.h),

                    // Start from Work Price
                    _buildLabel('Start from Work Price*'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.workPriceController,
                      hintText: 'Type now',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20.h),

                    // Upload Front Side
                    _buildLabel(
                      'Upload NID/Driving License/Passport (Front Side)*',
                    ),
                    SizedBox(height: 8.h),
                    Obx(
                      () => _buildImageUploadWidget(
                        imagePath: controller.imageFrontSide.value,
                        onBrowse: () =>
                            controller.showImageSourceDialog(isFront: true),
                        onRemove: () => controller.removeImage(isFront: true),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Upload Back Side
                    _buildLabel(
                      'Upload NID/Driving License/Passport (Back Side)*',
                    ),
                    SizedBox(height: 8.h),
                    Obx(
                      () => _buildImageUploadWidget(
                        imagePath: controller.imageBackSide.value,
                        onBrowse: () =>
                            controller.showImageSourceDialog(isFront: false),
                        onRemove: () => controller.removeImage(isFront: false),
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
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Back',
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
                            backgroundColor: const Color(0xFF6366F1),
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
                                  'Next',
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
              // This Obx now listens to all relevant reactive vars
              final isLoading = controller.isLoading.value;
              final isOther = controller.isOtherSelected.value;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      'Select Work Type',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Divider(),
                  SizedBox(height: 12.h),

                  // Category List
                  SizedBox(
                    height: 400.h,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: controller.categories.length + 1,
                            itemBuilder: (context, index) {
                              if (index == controller.categories.length) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RadioListTile<bool>(
                                      title: const Text('Other'),
                                      value: true,
                                      groupValue: isOther,
                                      onChanged: (value) {
                                        if (value == true) {
                                          controller.selectOther();
                                          // Sheet stays open
                                        } else {
                                          controller.selectedCategory.value =
                                              null;
                                          controller.isOtherSelected.value =
                                              false;
                                          controller.otherServiceController
                                              .clear();
                                        }
                                      },
                                      activeColor: const Color(0xFF6366F1),
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
                                            hintText: 'Enter service name',
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
                                                color: Color(0xFF6366F1),
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
                                  children: [
                                    Container(
                                      width: 32.w,
                                      height: 32.h,
                                      margin: EdgeInsets.only(right: 12.w),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF6366F1,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                      ),
                                      child: category.iconUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: category.iconUrl,
                                              width: 20.w,
                                              height: 20.h,
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                    Icons.handyman,
                                                    color: const Color(
                                                      0xFF6366F1,
                                                    ),
                                                    size: 20.sp,
                                                  ),
                                            )
                                          : Icon(
                                              Icons.handyman,
                                              color: const Color(0xFF6366F1),
                                              size: 20.sp,
                                            ),
                                    ),
                                    Text(category.nameEn),
                                  ],
                                ),
                                value: category.id,
                                groupValue:
                                    controller.selectedCategory.value?.id,
                                onChanged: (value) {
                                  controller.selectCategory(category);
                                  Get.back(); // Close immediately
                                },
                                activeColor: const Color(0xFF6366F1),
                                dense: true,
                              );
                            },
                          ),
                  ),

                  // ✅ Only show "Done" when "Other" is selected
                  if (isOther)
                    CustomElevatedButton(
                      buttonTitle: 'Done',
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.isEmpty ? 'Select work type' : text,
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  Widget _buildImageUploadWidget({
    required String imagePath,
    required VoidCallback onBrowse,
    required VoidCallback onRemove,
  }) {
    final bool hasImage = imagePath.isNotEmpty;

    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
      ),
      child: hasImage
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    File(imagePath),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
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
                  Icons.cloud_upload_outlined,
                  size: 40.sp,
                  color: const Color(0xFF6366F1),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Drag File Or Browse',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: onBrowse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
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
                    'Choose File',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

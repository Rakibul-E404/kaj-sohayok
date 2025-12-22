import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

class ImagePickerGridWidget extends StatelessWidget {
  final RxList<XFile> images;
  final int maxImages;
  final VoidCallback onPickImages;
  final Function(int index) onRemoveImage;

  const ImagePickerGridWidget({
    super.key,
    required this.images,
    required this.maxImages,
    required this.onPickImages,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canAddMore = images.length < maxImages;

      return Container(
        width: 1.sw,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.ce6e6e6),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: images.isEmpty
            ? Column(
                children: [
                  ///Section : Text -> Add Demo Image
                  Text(
                    'add_demo_image'.tr,
                    style: TextFontStyle.headline16w700c111111StyleSatoshi,
                  ),
                  UIHelper.verticalSpace(16.h),

                  ///Section : Upload Image Icon
                  Image.asset(
                    Assets.images.uploadIcon.path,
                    height: 32.h,
                    width: 32.w,
                    fit: BoxFit.cover,
                  ),
                  UIHelper.verticalSpace(8.h),

                  ///Section : Text -> Browse File From Here
                  Text(
                    'browse_files_from_there'.tr,
                    style: TextFontStyle.headline16w500c000000StyleSatoshi,
                  ),
                  UIHelper.verticalSpace(4.h),

                  ///Section : Image Format
                  Text(
                    "Format: .jpeg, .png & Max file size: 25 MB",
                    style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
                  ),
                  UIHelper.verticalSpace(4.h),

                  ///Section : Upload Limit
                  Text(
                    "${'image_max_uploading_limit'.tr} $maxImages",
                    style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
                  ),
                  UIHelper.verticalSpace(18.h),

                  ///Section : Button -> Upload Image
                  CustomElevatedButton(
                    onTap: onPickImages,
                    buttonWidth: 160.w,
                    buttonHeight: 40.h,
                    buttonTitle: 'upload_image'.tr,
                  ),
                ],
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: images.length + (canAddMore ? 1 : 0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  // Add More tile
                  if (canAddMore && index == images.length) {
                    return GestureDetector(
                      onTap: onPickImages,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.ce6e6e6),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: 32,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  }

                  // Normal image tile
                  final file = images[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          File(file.path),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => onRemoveImage(index),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      );
    });
  }
}

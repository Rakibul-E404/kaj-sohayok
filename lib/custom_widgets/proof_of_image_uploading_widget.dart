import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/text_font_style.dart';
import 'custom_card.dart';
import 'custom_elevated_button.dart';
import '../gen/assets.gen.dart';
import '../gen/colors.gen.dart';
import '../helpers/ui_helpers.dart';

class ProofOfImageUploadWidget extends StatelessWidget {
  final String title;
  final String? imagePath;
  final void Function()? onTap;
  final void Function()? removeImageOnTap;
  const ProofOfImageUploadWidget({
    super.key,
    required this.title,
    this.onTap,
    this.imagePath,
    this.removeImageOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///Section : Text -> upload NID/driving license/passport(font side)*
          Text(title, style: TextFontStyle.headline14w700c000000StyleSatoshi),
          UIHelper.verticalSpace(16.h),

          ///Section : File Browse
          DottedBorder(
            options: RectDottedBorderOptions(
              color: AppColors.c778beb,
              dashPattern: [4, 2],
              strokeCap: StrokeCap.round,
              strokeWidth: 1.w,
            ),
            child: imagePath == null || imagePath!.isEmpty
                ? Container(
                    width: 1.sw,
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    decoration: BoxDecoration(color: AppColors.cebeded),
                    child: Column(
                      children: [
                        ///Section : Upload Image
                        Image.asset(
                          Assets.images.uploadIcon.path,
                          height: 32.h,
                          width: 32.w,
                          fit: BoxFit.contain,
                        ),
                        UIHelper.verticalSpace(8.h),

                        Text(
                          "Drop file or browse",
                          style:
                              TextFontStyle.headline16w500c202020StyleSatoshi,
                        ),
                        Text(
                          "Format: .jpeg, .png & Max file size: 25 MB",
                          style:
                              TextFontStyle.headline10w400c6c606cStyleSatoshi,
                        ),
                        UIHelper.verticalSpace(17.h),

                        ///Section : Button -> Browse Files
                        CustomElevatedButton(
                          onTap: onTap,
                          buttonWidth: 150.w,
                          buttonHeight: 28.h,
                          buttonTitle: "Browse Files",

                          isButtonBorderUsed: true,
                          borderRadius: 6.r,
                          buttonBorderWidth: 1.5.sp,
                          buttonBorderColor: AppColors.c606060,
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      ///Selected Image
                      Image.file(
                        File(imagePath!),
                        height: 208.h,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),

                      Positioned(
                        bottom: 0.h,
                        right: 0.w,
                        child: CustomElevatedButton(
                          onTap: removeImageOnTap,
                          buttonWidth: 100.w,
                          buttonHeight: 30.h,
                          buttonColor: AppColors.ce73d3d,
                          borderRadius: 4.r,
                          buttonTitle: "Remove",
                          textStyle: TextFontStyle
                              .headline12w500c000000StyleSatoshi
                              .copyWith(color: AppColors.cFFFFFF),
                        ),
                      ),
                    ],
                  ),
          ),
          UIHelper.verticalSpace(16.h),
        ],
      ),
    );
  }
}




import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../gen/colors.gen.dart';

class CustomProfileImageWidget extends StatelessWidget {
  final String? imagePath; // picked image path (can be null/empty)
  final String defaultAsset; // fallback asset image
  final VoidCallback onEditTap; // callback when edit button pressed
  final double radius; // customizable size
  final String editIconAsset; // custom edit icon asset

  const CustomProfileImageWidget({
    super.key,
    required this.imagePath,
    required this.defaultAsset,
    required this.onEditTap,
    required this.editIconAsset,
    this.radius = 60, // default size
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 👇 Wrap with InkWell so user can preview image
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                insetPadding: EdgeInsets.all(16.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: InteractiveViewer(
                    child: imagePath != null && imagePath!.isNotEmpty
                        ? Image.file(File(imagePath!), fit: BoxFit.contain)
                        : Image.asset(
                            defaultAsset,
                            width: 1.sw,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cd5dbf9, width: 2.sp),
            ),
            child: CircleAvatar(
              radius: radius.r,
              backgroundImage: imagePath != null && imagePath!.isNotEmpty
                  ? FileImage(File(imagePath!))
                  : AssetImage(defaultAsset) as ImageProvider,
            ),
          ),
        ),

        /// 👇 Edit Icon
        Positioned(
          bottom: 8.h,
          right: 0.w,
          child: InkWell(
            onTap: onEditTap,
            child: SvgPicture.asset(editIconAsset),
          ),
        ),
      ],
    );
  }
}

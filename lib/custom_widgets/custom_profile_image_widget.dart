import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../gen/colors.gen.dart';
import '../gen/assets.gen.dart';

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
                  child: imagePath != null && imagePath!.isEmpty
                      ? Icon(Icons.person)
                      : CachedNetworkImage(
                          imageUrl: imagePath ?? '',
                          errorWidget: (context, url, error) =>
                              SvgPicture.asset(
                                Assets.icons.serviceProviderLogo,
                              ),
                        ),
                ),
              ),
            );
          },
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cd5dbf9, width: 2.sp),
            ),
            child: ClipOval(
              child: CachedNetworkImage(imageUrl: imagePath ?? ''),
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

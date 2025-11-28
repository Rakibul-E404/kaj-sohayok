// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../../constants/text_font_style.dart';
// import '../../../../gen/colors.gen.dart';
// import '../../../../helpers/ui_helpers.dart';

// class CategoryShowingWidget extends StatelessWidget {
//   final IconData categoryIcon;
//   final String categoryName;
//   final void Function()? onTap;
//   const CategoryShowingWidget({
//     super.key,
//     required this.categoryIcon,
//     required this.categoryName,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//         decoration: BoxDecoration(
//           border: Border.symmetric(
//             horizontal: BorderSide(color: AppColors.ca4b1f2, width: 2.w),
//             vertical: BorderSide(color: AppColors.ca4b1f2, width: 1.w),
//           ),
//           borderRadius: BorderRadius.circular(14.r),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ///Section : Icon
//             Icon(categoryIcon, size: 40.sp, color: AppColors.c778beb),

//             ///Section : Divider
//             UIHelper.verticalSpace(5.h),
//             Container(width: 1.sw, height: 1.h, color: AppColors.cd5dbf9),
//             UIHelper.verticalSpace(5.h),

//             ///Section : Category Name
//             Text(
//               categoryName,
//               textAlign: TextAlign.center,
//               style: TextFontStyle.headline14w500c000000StyleSatoshi,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class CategoryShowingWidget extends StatelessWidget {
  final IconData? categoryIcon; // Make optional since we'll use image when available
  final String categoryName;
  final String? imageUrl; // For API image URLs
  final void Function()? onTap;

  const CategoryShowingWidget({
    super.key,
    this.categoryIcon,
    required this.categoryName,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(color: AppColors.ca4b1f2, width: 2.w),
            vertical: BorderSide(color: AppColors.ca4b1f2, width: 1.w),
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///Section : Icon or Image
            if (imageUrl != null && imageUrl!.isNotEmpty)
              // Show network image for API data
              CachedNetworkImage(
                imageUrl: imageUrl!,
                height: 40.sp,
                width: 40.sp,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 40.sp,
                  width: 40.sp,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    categoryIcon ?? Icons.category,
                    size: 20.sp,
                    color: AppColors.c778beb,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 40.sp,
                  width: 40.sp,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    categoryIcon ?? Icons.category,
                    size: 20.sp,
                    color: AppColors.c778beb,
                  ),
                ),
              )
            else
              // Show icon for local data
              Icon(
                categoryIcon ?? Icons.category,
                size: 40.sp,
                color: AppColors.c778beb,
              ),

            ///Section : Divider
            UIHelper.verticalSpace(5.h),
            Container(width: 1.sw, height: 1.h, color: AppColors.cd5dbf9),
            UIHelper.verticalSpace(5.h),

            ///Section : Category Name
            Text(
              categoryName,
              textAlign: TextAlign.center,
              style: TextFontStyle.headline14w500c000000StyleSatoshi,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

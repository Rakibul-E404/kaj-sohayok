import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/app_constant_text.dart';
import '../../../../../constants/text_font_style.dart';
import '../../../../../gen/colors.gen.dart';
import '../../../../../helpers/ui_helpers.dart';

class AllPopularProvidersShowingWidget extends StatelessWidget {
  final String imagePath;
  final String serviceTitle;
  final double initialPayablePrice;
  final double userRating;
  final void Function()? onTap;
  const AllPopularProvidersShowingWidget({
    super.key,
    required this.imagePath,
    required this.serviceTitle,
    required this.initialPayablePrice,
    required this.userRating,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 174.w,
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.c778beb),
          borderRadius: BorderRadius.circular(24.r),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///Section : Service Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: imagePath.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: imagePath,
                      height: 112.h,
                      width: 153.w,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 112.h,
                        width: 153.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          Icons.image,
                          size: 40.sp,
                          color: AppColors.c6b6b6b,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 112.h,
                        width: 153.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40.sp,
                          color: AppColors.c6b6b6b,
                        ),
                      ),
                    )
                  : Image.asset(
                      imagePath,
                      height: 112.h,
                      width: 153.w,
                      fit: BoxFit.cover,
                    ),
            ),
            UIHelper.verticalSpace(6.h),

            ///Section : Service Name
            Text(
              serviceTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextFontStyle.headline14w700c000000StyleSatoshi,
            ),
            UIHelper.verticalSpace(6.h),

            ///Section : Initial Payable Balance
            RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                style: TextFontStyle.headline10w500c6a6a6aStyleSatoshi,
                children: [
                  const TextSpan(text: 'Start from '),
                  TextSpan(
                    text: '${AppText.bdTkSign}$initialPayablePrice',
                    style: TextFontStyle.headline16w700c778bebStyleSatoshi,
                  ),
                ],
              ),
            ),
            UIHelper.verticalSpace(6.h),

            ///Section : Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "$userRating",
                  style: TextFontStyle.headline10w500c4d4d4dStyleSatoshi,
                ),
                UIHelper.horizontalSpace(2.w),

                Icon(Icons.star_rate_rounded, color: AppColors.cffcd22),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/app_constant_text.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class SpecificServiceShowingWidget extends StatelessWidget {
  final String serviceImagePath;
  final String serviceName;
  final double initialPayablePrice;
  final String serviceProviderImage;
  final String serviceProviderName;
  final double serviceProviderRating;
  final void Function()? seeDetailsOnTap;
  final void Function()? goToBookingsOnTap;

  const SpecificServiceShowingWidget({
    super.key,
    required this.serviceImagePath,
    required this.serviceName,
    required this.initialPayablePrice,
    required this.serviceProviderImage,
    required this.serviceProviderName,
    required this.serviceProviderRating,
    this.seeDetailsOnTap,
    this.goToBookingsOnTap,
  });

  @override
  Widget build(BuildContext context) {
    // Check if service image is a network URL or asset path
    final bool isServiceNetworkImage = serviceImagePath.startsWith('http');

    return InkWell(
      onTap: seeDetailsOnTap,
      child: Container(
        width: 1.sw,
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          color: AppColors.cf1f3fd,
          border: Border.all(color: AppColors.c778beb),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          children: [
            ///Section: Service Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: isServiceNetworkImage
                  ? Image.network(
                      serviceImagePath,
                      height: 112.h,
                      width: 1.sw,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallbackServiceImage(),
                    )
                  : Image.asset(
                      serviceImagePath,
                      height: 112.h,
                      width: 1.sw,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallbackServiceImage(),
                    ),
            ),
            UIHelper.verticalSpace(14.h),

            ///Section : Service Name & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  serviceName,
                  style: TextFontStyle.headline14w700c000000StyleSatoshi,
                ),
                RichText(
                  text: TextSpan(
                    style: TextFontStyle.headline12w500c6a6a6aStyleSatoshi,
                    children: [
                      TextSpan(text: "${'start_from'.tr} "),
                      TextSpan(
                        text: "${AppText.bdTkSign}$initialPayablePrice",
                        style: TextFontStyle.headline16w700c778bebStyleSatoshi,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpace(8.h),

            ///Section : Dotted Divider
            DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 1.sp,
              dashLength: 4.w,
              dashGapLength: 4.w,
              dashColor: AppColors.cb4b4b4,
            ),
            UIHelper.verticalSpace(8.h),

            ///Section : User Image, Name, Rating & Book Now Button
            Row(
              children: [
                ///Section : User Image
                _buildProviderImage(),
                UIHelper.horizontalSpace(6.w),

                ///Section : User Name & Rating
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///Section : User Name
                    SizedBox(
                      width: 0.35.sw,
                      child: Text(
                        serviceProviderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextFontStyle.headline12w500c000000StyleSatoshi,
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),

                    ///Section : User Ratings
                    Row(
                      children: [
                        Icon(Icons.star_rate_rounded, color: AppColors.cffcd22),
                        UIHelper.horizontalSpace(2.w),
                        Text(
                          serviceProviderRating.toStringAsFixed(1),
                          style:
                              TextFontStyle.headline10w500c000000StyleSatoshi,
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),

                ///Section : Button -> Book Now
                CustomElevatedButton(
                  onTap: goToBookingsOnTap,
                  buttonTitle: 'book_now'.tr,
                  textStyle: TextFontStyle.headline14w500cFFFFFFStyleSatoshi,
                  buttonWidth: 109.w,
                  buttonHeight: 32.h,
                  borderRadius: 50.r,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderImage() {
    // Check if service provider image is a network URL or needs base URL
    final bool isNetworkImage = serviceProviderImage.startsWith('http');
    final bool needsBaseUrl = serviceProviderImage.startsWith('/uploads/') ||
        serviceProviderImage.startsWith('/images/');

    if (isNetworkImage || needsBaseUrl) {
      String imageUrl = serviceProviderImage;

      // Add base URL if it's a relative path that needs it
      if (needsBaseUrl) {
        imageUrl = 'https://newsheakh6737.sobhoy.com$serviceProviderImage';
      }

      // Load network image with proper fallback handling
      return CircleAvatar(
        radius: 20.r,
        child: ClipOval(
          child: Image.network(
            imageUrl,
            width: 40.r,
            height: 40.r,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40.r,
                height: 40.r,
                color: AppColors.cf1f3fd,
                child: const Icon(Icons.person, size: 20),
              );
            },
          ),
        ),
      );
    } else {
      // It's an asset image or empty, so use asset
      String assetPath = serviceProviderImage.isEmpty
          ? Assets.images.userImageBlank.path
          : serviceProviderImage;
      return CircleAvatar(
        radius: 20.r,
        child: ClipOval(
          child: Image.asset(
            assetPath,
            width: 40.r,
            height: 40.r,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40.r,
                height: 40.r,
                color: AppColors.cf1f3fd,
                child: const Icon(Icons.person, size: 20),
              );
            },
          ),
        ),
      );
    }
  }

  Widget _buildFallbackServiceImage() {
    return Container(
      height: 112.h,
      width: double.infinity,
      color: AppColors.cf1f3fd,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 40.r,
        color: AppColors.cb4b4b4,
      ),
    );
  }
}

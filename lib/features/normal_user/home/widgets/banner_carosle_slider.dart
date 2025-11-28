import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/home_page_controller.dart';
import 'package:kaz_bd/features/normal_user/home/widgets/banner_shimmer_effect.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';

class BannerCarosleSlider extends StatelessWidget {
  final HomePageController controller;
  const BannerCarosleSlider({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.banners.isNotEmpty
          ? CarouselSlider.builder(
              itemCount: controller.banners.length,
              options: CarouselOptions(
                aspectRatio: 16 / 6,
                viewportFraction: 0.8,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                enlargeFactor: 0.3,
                scrollDirection: Axis.horizontal,
              ),
              itemBuilder: (BuildContext context, int index, int pageViewIndex) {
                final banner = controller.banners[index];
                String imageUrl = '';

                // Extract image URL from banner attachments
                if (banner.attachments != null &&
                    banner.attachments!.isNotEmpty) {
                  final attachment = banner.attachments![0];
                  if (attachment != null) {
                    imageUrl = attachment.attachment ?? '';
                  }
                }

                // Show shimmer while image is loading, otherwise show the actual image
                return imageUrl.isEmpty
                    ? BannerShimmerEffectWidget(
                        height: 175,
                        width: 1,
                        child: Center(
                          child: Text(
                            'Loading Image...',
                            style:
                                TextFontStyle.headline14w500cFFFFFFStyleSatoshi,
                          ),
                        ),
                      )
                    : Container(
                        height: 175.h,
                        width: 1.sw,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 24.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.c000000.withValues(alpha: 0.5),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(imageUrl),
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      );
              },
            )
          : BannerShimmerEffectWidget(
              height: 175,
              width: 1,
              child: Center(
                child: Text(
                  'No banners available',
                  style: TextFontStyle.headline14w500cFFFFFFStyleSatoshi,
                ),
              ),
            ),
    );
  }
}

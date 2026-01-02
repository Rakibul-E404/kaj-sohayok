import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_shimmer_effect.dart';
import 'package:kaz_bd/features/normal_user/details/widget/image_preview_widget.dart';
import 'package:kaz_bd/utilities/app_url.dart';

import '../../../../controllers/details_screen_controller.dart';
import '../../../../helpers/ui_helpers.dart';

class GalleryTab extends StatefulWidget {
  const GalleryTab({super.key});

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  void showImageDialog(BuildContext context, int initialIndex) {
    DetailsScreenController detailsScreenController =
        Get.find<DetailsScreenController>();

    // Create a list of image URLs from the gallery images
    List<String> imageUrls = detailsScreenController.galleryImages
        .map((attachment) => attachment.attachment ?? '')
        .toList();

    showDialog(
      context: context,
      builder: (_) {
        return ImagePreviewDialog(
          initialIndex: initialIndex,
          images: imageUrls,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DetailsScreenController detailsScreenController =
        Get.find<DetailsScreenController>();
    return SingleChildScrollView(
      key: const PageStorageKey('gallery'),
      padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (detailsScreenController.isLoading.value == true) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  // var data = AppList.imageList[index];
                  return CustomShimmerEffect(height: 0.2.sh, width: 0.2.sw);
                },
              );
            } else if (detailsScreenController.galleryImages.isEmpty) {
              return Container(
                width: 1.sw,
                height: 0.3.sh,
                alignment: Alignment.center,
                child: Text(
                  "No Images Available At Gallery!",
                  textAlign: TextAlign.center,
                  style: TextFontStyle.headline12w500c000000StyleSatoshi,
                ),
              );
            } else {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: detailsScreenController.galleryImages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  var attachment = detailsScreenController.galleryImages[index];
                  String imageUrl = attachment.attachment ?? '';

                  // Ensure the URL is properly formatted
                  if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                    imageUrl = '${AppUrl.imageBaseUrl}$imageUrl';
                  }

                  return GestureDetector(
                    onTap: () {
                      return showImageDialog(context, index);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }),
          UIHelper.verticalSpace(30.h),
        ],
      ),
    );
  }
}

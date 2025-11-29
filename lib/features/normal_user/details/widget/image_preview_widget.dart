import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

class ImagePreviewDialog extends StatefulWidget {
  final int initialIndex;
  final List images;

  const ImagePreviewDialog({
    super.key,
    required this.initialIndex,
    required this.images,
  });

  @override
  State<ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<ImagePreviewDialog> {
  late PageController controller;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.initialIndex);
    currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 400.h,
            child: PageView.builder(
              controller: controller,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                String imageUrl = widget.images[index].toString();

                // Check if the image is a network URL or a local asset
                Widget imageWidget;
                if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
                  // It's a network image
                  imageWidget = Image.network(
                    imageUrl,
                    height: 350.h,
                    width: 1.sw,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 350.h,
                        width: 1.sw,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 350.h,
                        width: 1.sw,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  );
                } else {
                  // It's a local asset
                  imageWidget = Image.asset(
                    imageUrl,
                    height: 350.h,
                    width: 1.sw,
                    fit: BoxFit.cover,
                  );
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: imageWidget,
                );
              },
            ),
          ),
          UIHelper.verticalSpace(12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: currentIndex == index ? 20.w : 8.w,
                height: currentIndex == index ? 10.h : 8.h,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4.r),
                  color: currentIndex == index ? Colors.white : Colors.white54,
                ),
              ),
            ),
          ),
          UIHelper.verticalSpace(8.h),
        ],
      ),
    );
  }
}

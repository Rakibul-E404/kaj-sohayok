import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/appList.dart';
import 'package:kaz_bd/features/normal_user/details/widget/image_preview_widget.dart';
import '../../../../helpers/ui_helpers.dart';

class GalleryTab extends StatefulWidget {
  const GalleryTab({super.key});

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  void showImageDialog(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      builder: (_) {
        return ImagePreviewDialog(
          initialIndex: initialIndex,
          images: AppList.imageList,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('gallery'),
      padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AppList.imageList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              var data = AppList.imageList[index];
              return GestureDetector(
                onTap: () {
                  return showImageDialog(context, index);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(data, fit: BoxFit.cover),
                ),
              );
            },
          ),
          UIHelper.verticalSpace(30.h),
        ],
      ),
    );
  }
}

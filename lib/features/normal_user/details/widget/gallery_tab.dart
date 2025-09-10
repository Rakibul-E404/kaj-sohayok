import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class GalleryTab extends StatelessWidget {
  const GalleryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('gallery'),
      padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gallery",
            style: TextFontStyle.headline18w700c000000StyleSatoshi,
          ),
          UIHelper.verticalSpace(12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.asset(
                  Assets.images.serviceImage.path,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

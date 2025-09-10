import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../helpers/ui_helpers.dart';

class ReviewsTab extends StatelessWidget {
  const ReviewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('reviews'),
      padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Reviews",
            style: TextFontStyle.headline18w700c000000StyleSatoshi,
          ),
          UIHelper.verticalSpace(12.h),
          Card(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            child: ListTile(
              title: const Text("Jane Doe"),
              subtitle: const Text(
                "Great service, punctual and thorough! Highly recommended.",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("4.5"),
                  UIHelper.horizontalSpace(4.w),
                  Icon(Icons.star, size: 16.sp, color: Colors.amber),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

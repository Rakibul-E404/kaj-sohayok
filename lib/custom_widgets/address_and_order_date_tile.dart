import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/text_font_style.dart';
import '../gen/colors.gen.dart';
import '../helpers/ui_helpers.dart';

class AddressAndOrderDateTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String data;
  const AddressAndOrderDateTile({
    super.key,
    required this.title,
    required this.icon,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ///Section : Working Address
        Container(
          width: 1.sw,
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: AppColors.cf1f3fd,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            title,
            style: TextFontStyle.headline16w700c202020StyleSatoshi,
          ),
        ),
        UIHelper.verticalSpace(14.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.c92a2ef),
            UIHelper.horizontalSpace(4.w),

            Text(data, style: TextFontStyle.headline12w500c4d4d4dStyleSatoshi),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class ProfileTileWidget extends StatelessWidget {
  final String title;
  final String data;
  final void Function()? onTap;

  const ProfileTileWidget({
    super.key,
    required this.title,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 1.sw,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.cFFFFFF,
          border: Border.all(color: AppColors.ce6e6e6),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///Section : Title
            Text(title, style: TextFontStyle.headline14w700c989898StyleSatoshi),
            UIHelper.verticalSpace(12.h),

            ///Section : Data
            Text(data, style: TextFontStyle.headline16w700c000000StyleSatoshi),
          ],
        ),
      ),
    );
  }
}

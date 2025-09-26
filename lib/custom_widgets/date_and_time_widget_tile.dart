import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/text_font_style.dart';
import '../gen/colors.gen.dart';
import '../helpers/ui_helpers.dart';

class DateAndAddressWidgetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  const DateAndAddressWidgetTile({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.c92a2ef, size: 24.sp),
        UIHelper.horizontalSpace(4.w),
        Text(title, style: TextFontStyle.headline12w500c4d4d4dStyleSatoshi),
      ],
    );
  }
}

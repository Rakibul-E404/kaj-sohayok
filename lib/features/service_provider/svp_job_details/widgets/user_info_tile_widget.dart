import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class UserInfoTileWidget extends StatelessWidget {
  final String fieldName;
  final String data;
  const UserInfoTileWidget({
    super.key,
    required this.fieldName,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        border: Border.all(color: AppColors.ce6e6e6),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldName,
            style: TextFontStyle.headline14w700c989898StyleSatoshi,
          ),
          UIHelper.verticalSpace(12.h),
          Text(data, style: TextFontStyle.headline16w700c202020StyleSatoshi),
        ],
      ),
    );
  }
}

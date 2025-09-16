import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

class ContactTileWidget extends StatelessWidget {
  final IconData icon;
  final String data;
  final void Function()? onTap;
  const ContactTileWidget({
    super.key,
    required this.icon,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppColors.c778beb,
            child: Icon(icon, size: 24.sp, color: AppColors.cFFFFFF),
          ),
          UIHelper.verticalSpace(16.h),

          ///Section : contact data
          Text(data, style: TextFontStyle.headline16w500c000000StyleSatoshi),
        ],
      ),
    );
  }
}

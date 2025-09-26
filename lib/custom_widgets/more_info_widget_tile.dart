import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/text_font_style.dart';
import '../gen/colors.gen.dart';

class MoreInfoWidgetTile extends StatelessWidget {
  final String title;
  final String hintText;
  final bool isEnabled;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  const MoreInfoWidgetTile({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    this.isEnabled = true,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ce6e6e6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///Section : Title
          Padding(
            padding: EdgeInsets.only(left: 14.w),
            child: Text(
              title,
              style: TextFontStyle.headline14w500c202020StyleSatoshi,
            ),
          ),

          ///Section : Text Form Field
          TextFormField(
            controller: controller,
            keyboardType: keyboardType ?? TextInputType.text,
            decoration: InputDecoration(
              enabled: isEnabled,
              hintText: hintText,

              hintStyle: TextFontStyle.headline16w700cb4b4b4StyleSatoshi,
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}

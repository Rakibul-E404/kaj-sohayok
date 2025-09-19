import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';

import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController textController;
  final RxString searchText;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.textController,
    required this.searchText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        height: 54.h,
        decoration: BoxDecoration(
          color: AppColors.cFFFFFF,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.ca4b1f2.withAlpha(80),
              blurRadius: 12.r,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextFormField(
          controller: textController,
          cursorHeight: 20.h,
          style: TextStyle(fontSize: 16.sp),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search Connections',
            hintStyle: TextFontStyle.headline16w500cbababaStyleSatoshi,
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 14.w, top: 8.h, bottom: 8.h),
              child: SvgPicture.asset(Assets.icons.searchIconFat),
            ),
            suffixIcon: searchText.value.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(
                      right: 14.w,
                      top: 8.h,
                      bottom: 8.h,
                    ),
                    child: InkWell(
                      onTap: onClear,
                      child: SvgPicture.asset(Assets.icons.removeIcon),
                    ),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.ce6e6e6),
              borderRadius: BorderRadius.circular(12.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.ce6e6e6),
              borderRadius: BorderRadius.circular(12.r),
            ),
            isDense: false,
            contentPadding: EdgeInsets.symmetric(vertical: 16.h),
          ),
        ),
      );
    });
  }
}

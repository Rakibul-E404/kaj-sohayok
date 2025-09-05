import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../gen/colors.gen.dart';

class TextFontStyle {
  //Initialising Constractor
  TextFontStyle._();

  static final headline18w700c292E34StyleSatoshi = TextStyle(
    fontFamily: 'Satoshi',
    fontFamilyFallback: const [
      'Itern'
          'Satoshi',
    ],
    color: AppColors.c292E34,
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
  );
  static final headline14w500c698dadStyleSatoshi = TextStyle(
    fontFamily: 'Satoshi',
    fontFamilyFallback: const [
      'Itern'
          'Satoshi',
    ],
    color: AppColors.c698dad,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );
  static final headline16w500cFFFFFFStyleSatoshi = TextStyle(
    fontFamily: 'Satoshi',
    fontFamilyFallback: const [
      'Itern'
          'Satoshi',
    ],
    color: AppColors.cFFFFFF,
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
  );
}

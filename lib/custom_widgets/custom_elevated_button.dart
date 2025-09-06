import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/text_font_style.dart';
import '../gen/colors.gen.dart';

class CustomElevatedButton extends StatelessWidget {
  final String? buttonTitle;
  final Widget? child;
  final double? borderRadius;
  final double? buttonHeight;
  final double? buttonWidth;
  final Color? buttonBorderColor;
  final bool isButtonBorderUsed;
  final Color? buttonColor;
  final TextStyle? textStyle;

  final void Function()? onTap;

  const CustomElevatedButton({
    super.key,
    this.buttonTitle,
    this.child,
    this.borderRadius,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonBorderColor,
    this.isButtonBorderUsed = false,
    this.onTap,
    this.buttonColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: buttonWidth,
        height: buttonHeight ?? 50.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: buttonColor ?? AppColors.c778beb,
          border: isButtonBorderUsed
              ? Border.all(
                  color: buttonBorderColor ?? AppColors.c000000,
                  width: 1.sp,
                )
              : null,
          borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
        ),
        child: Center(
          child:
              child ??
              Text(
                buttonTitle ?? "",
                style:
                    textStyle ??
                    TextFontStyle.headline16w500cFFFFFFStyleSatoshi,
              ),
        ),
      ),
    );
  }
}

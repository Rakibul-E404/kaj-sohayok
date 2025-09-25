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
  final double? buttonBorderWidth;

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
    this.buttonBorderWidth,
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
                  width: buttonBorderWidth ?? 1.sp,
                )
              : null,
          borderRadius: BorderRadius.circular(borderRadius ?? 6.r),
        ),
        child: Center(
          child:
              child ??
              Text(
                buttonTitle ?? "",
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    textStyle ??
                    TextFontStyle.headline14w500cFFFFFFStyleSatoshi,
              ),
        ),
      ),
    );
  }
}

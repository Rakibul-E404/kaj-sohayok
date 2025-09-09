// ///Null Used on,
// ///isObSecure
// ///isPrefixIconUsed
// ///isSuffixIconUsed
// ///isFormFieldNameUsed!

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import '../constants/text_font_style.dart';
import '../gen/colors.gen.dart';

final class CustomFormField extends StatelessWidget {
  final String? hintText;
  final double? hintFontSize;
  final String? labelText;
  final TextEditingController? controller;
  final TextInputType? inputType;
  final double? fieldHeight;
  final int? maxline;
  final String? Function(String?)? validator;
  final bool? validation;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final double? prefixIconPadding;
  final double? gapBetweenPrefixIconAndDivider;
  final bool isObsecure;
  final bool isPass;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? labelStyle;
  // final TextStyle? style;
  final bool? isEnabled;
  final double? cursorHeight;
  final Color? disableColor;
  final bool isRead;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintTextStyle;
  final Color? borderColor;
  final Widget? child;
  final bool? showVerticalDivider;

  const CustomFormField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.inputType,
    this.fieldHeight,
    this.maxline,
    this.validator,
    this.validation = false,
    this.suffixIcon,
    this.prefixIcon,
    this.prefixIconPadding,
    this.gapBetweenPrefixIconAndDivider,
    this.isObsecure = false,
    this.isPass = false,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.onChanged,
    this.inputFormatters,
    this.labelStyle,
    this.isEnabled,
    // this.style,
    this.cursorHeight,
    this.disableColor,
    this.isRead = false,
    this.borderRadius,
    this.padding,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 20,
    ),
    this.hintFontSize,
    this.hintTextStyle,
    this.borderColor,
    this.showVerticalDivider = true,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.zero,
      height: fieldHeight,
      child: TextFormField(
        readOnly: isRead,
        cursorHeight: cursorHeight ?? 20.h,
        cursorColor: AppColors.c38686A,
        focusNode: focusNode,
        obscureText: isPass ? isObsecure : false,
        textInputAction: textInputAction,
        autovalidateMode: validation!
            ? AutovalidateMode.always
            : AutovalidateMode.onUserInteraction,
        validator: validator,
        maxLines: maxline ?? 1,
        controller: controller,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        enabled: isEnabled,
        // obscuringCharacter: ".",
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.cFFFFFF,
          suffixIcon: suffixIcon != null
              ? Padding(padding: EdgeInsets.all(12.sp), child: suffixIcon)
              : null,
          // prefixIcon: prefixIcon != null
          //     ? Padding(
          //         padding: prefixIconPadding == null
          //             ? EdgeInsets.all(12.sp)
          //             : EdgeInsets.all(prefixIconPadding ?? 12.sp),
          //         child: prefixIcon,
          //       )
          //     : null,
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: prefixIconPadding == null
                      ? EdgeInsets.all(12.sp)
                      : EdgeInsets.all(prefixIconPadding ?? 12.sp),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      prefixIcon!,
                      if (showVerticalDivider ?? true) ...[
                        UIHelper.horizontalSpace(
                          gapBetweenPrefixIconAndDivider ?? 16.w,
                        ),
                        Container(
                          height: 24.h,
                          width: 2.sp,
                          color: AppColors.cd9d9d9,
                        ),
                        UIHelper.horizontalSpace(8.w),
                      ],
                    ],
                  ),
                )
              : null,

          contentPadding: contentPadding ?? EdgeInsets.zero,
          hintText: hintText,
          hintStyle:
              hintTextStyle ?? TextFontStyle.headline14w500c8c8c8cStyleSatoshi,
          labelText: labelText,
          labelStyle:
              labelStyle ?? TextFontStyle.headline14w500c292E34StyleSatoshi,
          errorStyle: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            // color: AppColors.cD12E34,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor ?? AppColors.ce7e5df),
            borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor ?? AppColors.c778beb),
            borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor ?? AppColors.cb4b4b4),
            borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor ?? AppColors.cb4b4b4),
            borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          ),
        ),
        // style: style ?? TextFontStyle.headline16w400C161C24,
        keyboardType: inputType,
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

class SvpDocumentsTabFormField extends StatelessWidget {
  final String fieldName;
  final String hintText;
  final bool showEdit;
  bool isFormFieldEnabled;

  final void Function()? onTap;
  final bool isDescriptionField;
  final TextEditingController controller;

  SvpDocumentsTabFormField({
    super.key,
    this.onTap,
    required this.fieldName,
    required this.hintText,
    required this.controller,
    required this.isFormFieldEnabled,
    this.isDescriptionField = false,
    this.showEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ce6e6e6),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 14.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ///Section : Field Name
                Text(
                  fieldName,
                  style: TextFontStyle.headline14w700c989898StyleSatoshi,
                ),

                ///Section : Button -> Pen Icon
                Visibility(
                  visible: showEdit == true,
                  replacement: SizedBox.shrink(),
                  child: InkWell(
                    onTap: onTap,
                    child: SvgPicture.asset(Assets.icons.pencilEditIcon),
                  ),
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(5.h),
          TextFormField(
            controller: controller,
            enabled: isFormFieldEnabled,
            minLines: isDescriptionField ? 5 : 1,
            maxLines: isDescriptionField ? 8 : 1,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}

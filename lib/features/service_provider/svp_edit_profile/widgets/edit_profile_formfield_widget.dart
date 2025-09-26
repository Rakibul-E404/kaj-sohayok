import 'package:flutter/material.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';

class EditProfileFormFieldWidget extends StatelessWidget {
  final String hintText;
  final String lableText;
  final TextEditingController? controller;
  const EditProfileFormFieldWidget({
    super.key,
    required this.hintText,
    required this.lableText,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cFFFFFF,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          enabled: true,
          labelText: lableText,
          labelStyle: TextFontStyle.headline14w700c989898StyleSatoshi,
          hintText: hintText,
          hintStyle: TextFontStyle.headline14w500c8c8c8cStyleSatoshi,
          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

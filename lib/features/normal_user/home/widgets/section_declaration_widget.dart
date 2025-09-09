import 'package:flutter/material.dart';

import '../../../../constants/text_font_style.dart';

class SectionDeclarationWidget extends StatelessWidget {
  final String sectionTitle;
  final String textButtonName;
  final void Function()? onTap;

  const SectionDeclarationWidget({
    super.key,
    required this.sectionTitle,
    this.onTap,
    required this.textButtonName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ///Section : Text -> Select Category
        Text(
          sectionTitle,
          style: TextFontStyle.headline20w700c000000StyleSatoshi,
        ),

        ///Section : TextButton -> See all
        InkWell(
          onTap: onTap,
          child: Text(
            textButtonName,
            style: TextFontStyle.headline12w500c000000StyleSatoshi.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

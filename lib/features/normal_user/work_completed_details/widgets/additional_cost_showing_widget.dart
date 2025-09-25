import 'package:flutter/material.dart';

import '../../../../constants/app_constant_text.dart';
import '../../../../constants/text_font_style.dart';

class AdditionalCostShowingWidget extends StatelessWidget {
  final String label;
  final double amount;
  const AdditionalCostShowingWidget({
    super.key,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextFontStyle.headline16w700c202020StyleSatoshi),
        Text(
          "${AppText.bdTkSign}$amount",
          style: TextFontStyle.headline16w700c202020StyleSatoshi,
        ),
      ],
    );
  }
}

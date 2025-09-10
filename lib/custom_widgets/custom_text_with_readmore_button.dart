import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';

import '../controllers/read_more_controller.dart';

class CustomTextWidgetWithReadMoreButton extends StatelessWidget {
  final String text;
  final int trimLines;

  const CustomTextWidgetWithReadMoreButton({
    super.key,
    required this.text,
    this.trimLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    // Each widget gets its own controller
    final controller = Get.put(
      ReadMoreController(),
      tag: UniqueKey().toString(),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          text: text,
          style: TextFontStyle.headline14w400c4d4d4dStyleSatoshi,
        );

        final tp = TextPainter(
          text: span,
          maxLines: trimLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflow = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Text(
                text,
                style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                maxLines: controller.isExpanded.value ? null : trimLines,
                overflow: controller.isExpanded.value
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ),
            if (isOverflow)
              GestureDetector(
                onTap: controller.toggle,
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Obx(
                    () => Text(
                      controller.isExpanded.value
                          ? "Read less"
                          : "Read more...",
                      style: TextFontStyle.headline14w700c989898StyleSatoshi,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

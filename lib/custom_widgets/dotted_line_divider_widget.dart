import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../gen/colors.gen.dart';

class DottedLineDividerWidget extends StatelessWidget {
  const DottedLineDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DottedLine(
      direction: Axis.horizontal,
      lineLength: double.infinity,
      lineThickness: 1.sp,
      dashLength: 4.w,
      dashGapLength: 4.w,
      dashColor: AppColors.cb4b4b4,
    );
  }
}

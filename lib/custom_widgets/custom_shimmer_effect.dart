import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmerEffect extends StatelessWidget {
  final double height;
  final double width;
  final Widget? child;
  final bool isEnabled;
  final bool isShapUsed;
  final BoxShape shapType;

  const CustomShimmerEffect({
    super.key,
    required this.height,
    required this.width,
    this.child,
    this.isEnabled = true,
    this.isShapUsed = false,
    this.shapType = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.c000000.withValues(alpha: 0.4),
      highlightColor: AppColors.c000000.withValues(alpha: 0.04),
      enabled: isEnabled,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.c000000.withValues(
            alpha: 0.2,
          ), // Slightly darker base color
          borderRadius: isShapUsed ? null : BorderRadius.circular(10.r),
          shape: isShapUsed ? shapType : BoxShape.rectangle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

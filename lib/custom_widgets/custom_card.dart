import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../gen/colors.gen.dart';

// ignore: must_be_immutable
class CustomCard extends StatelessWidget {
  final Widget child;
  double? width;
  double? height;

  CustomCard({super.key, required this.child, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 1.sw,
      // height: height ?? 114.h,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        boxShadow: [
          BoxShadow(
            color: AppColors.c000000.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: child,
    );
  }
}

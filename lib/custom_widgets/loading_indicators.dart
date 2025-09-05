import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../gen/assets.gen.dart';

/// Ultra-fast loading indicator using .lottie file
Widget loadingIndicatorCircle({double? size}) {
  double loaderSize = size ?? 200.sp;
  return DotLottieLoader.fromAsset(
    Assets.lottie.waiting,
    frameBuilder: (BuildContext ctx, DotLottie? dotlottie) {
      if (dotlottie != null) {
        return Center(
          child: SizedBox(
            width: loaderSize,
            height: loaderSize,
            child: Lottie.memory(dotlottie.animations.values.first),
          ),
        );
      } else {
        return const SizedBox();
      }
    },
  );
}

/// Generic shimmer animation loader
Widget shimmer({String? name, double? size}) {
  double loaderSize = size ?? 120.sp;
  return Center(
    child: SizedBox(
      width: loaderSize,
      height: loaderSize,
      child: Lottie.asset(name ?? Assets.lottie.hamburger),
    ),
  );
}

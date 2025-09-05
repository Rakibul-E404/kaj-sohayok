import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../custom_widgets/loading_indicators.dart';
import '../gen/assets.gen.dart';

class NotFoundWidget extends StatelessWidget {
  const NotFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: shimmer(name: Assets.lottie.notFound, size: 220.sp),
    );
  }
}

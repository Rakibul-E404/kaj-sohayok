import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../gen/assets.gen.dart';
import '../gen/colors.gen.dart';

class HomeSectionAppLogoAndNotification extends StatelessWidget {
  final void Function()? onTap;
  const HomeSectionAppLogoAndNotification({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cf1f3fd,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ///AppLogo
          Image.asset(
            Assets.images.appLogo.path,
            fit: BoxFit.contain,
            width: 0.4.sw,
            height: 54.h,
          ),

          ///Section : Notification
          InkWell(
            onTap: onTap,
            child: Container(
              width: 48.w,
              height: 48.h,
              padding: EdgeInsets.all(12.sp),
              decoration: BoxDecoration(
                color: AppColors.c778beb,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(Assets.icons.bellIcon),
            ),
          ),
        ],
      ),
    );
  }
}

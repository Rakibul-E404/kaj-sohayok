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
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: AppColors.cFFFFFF,
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(Assets.images.appLogo.path),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ca4b1f2.withAlpha(80),
                  blurRadius: 12.r,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../presentation/choose_role_screen.dart';

class RoleSelectingCard extends StatelessWidget {
  final String? userTypeIcon;
  final appUserType? userType;
  final String? cardTitle;
  final bool showBorder;
  final void Function()? onTap;
  const RoleSelectingCard({
    super.key,
    this.userTypeIcon,
    this.userType,
    this.showBorder = false,
    this.onTap,
    this.cardTitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 1.sw,
        padding: EdgeInsets.all(24.sp),
        decoration: BoxDecoration(
          color: AppColors.cFFFFFF,
          border: showBorder
              ? Border(
                  bottom: BorderSide(color: AppColors.c778beb, width: 3.sp),
                  right: BorderSide(color: AppColors.c778beb, width: 3.sp),
                )
              : null,
          borderRadius: BorderRadius.circular(16.r),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // soft shadow
              blurRadius: 12.r, // spread of shadow
              offset: const Offset(0, 6), // moves shadow downward
            ),
          ],
        ),
        child: Column(
          children: [
            ///Section : Role Icon
            Container(
              padding: EdgeInsets.all(20.sp),
              decoration: BoxDecoration(
                color: AppColors.c778beb,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(fit: BoxFit.cover, userTypeIcon ?? ""),
            ),

            ///Section : Divider
            UIHelper.verticalSpace(20.h),
            Divider(color: AppColors.ca4b1f2),
            UIHelper.verticalSpace(20.h),

            ///Section : Text : Join As a User
            Text(
              cardTitle ?? "",
              style: TextFontStyle.headline16w700c000000StyleSatoshi,
            ),
          ],
        ),
      ),
    );
  }
}

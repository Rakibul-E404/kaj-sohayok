import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/text_font_style.dart';
import '../../../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../../../custom_widgets/date_and_time_widget_tile.dart';
import '../../../../../../custom_widgets/dotted_line_divider_widget.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';

class SvpPaymentRequestTabCard extends StatelessWidget {
  final String userImage;
  final String userName;
  final String dateTime;
  final String location;
  final void Function()? cardOnTap;
  final void Function()? pendingPaymentButtonOnTap;

  const SvpPaymentRequestTabCard({
    super.key,
    required this.userImage,
    required this.userName,
    required this.dateTime,
    required this.location,
    this.cardOnTap,
    this.pendingPaymentButtonOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: cardOnTap,
      child: Container(
        width: 1.sw,
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.cFFFFFF,
          border: Border.all(color: AppColors.ce6e6e6),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.ca4b1f2.withAlpha(80),
              blurRadius: 12.r,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ///Section : User Image
            ///Section : User Name
            Container(
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: AppColors.cf1f3fd,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                children: [
                  ///Section : User Profile Image
                  CircleAvatar(
                    radius: 24.r,
                    backgroundImage: AssetImage(userImage),
                  ),
                  UIHelper.horizontalSpace(6.w),

                  ///Section : User Name
                  Expanded(
                    child: Text(
                      userName,
                      style: TextFontStyle.headline16w500c000000StyleSatoshi,
                    ),
                  ),
                ],
              ),
            ),
            UIHelper.verticalSpace(14.h),

            ///Section : Divider
            DottedLineDividerWidget(),
            UIHelper.verticalSpace(12.h),

            ///Section : Location
            DateAndAddressWidgetTile(icon: Icons.location_on, title: location),

            UIHelper.verticalSpace(6.h),

            ///Section : Date And Time
            DateAndAddressWidgetTile(icon: Icons.watch_later, title: dateTime),

            UIHelper.verticalSpace(12.h),

            ///Section : Divider
            DottedLineDividerWidget(),
            UIHelper.verticalSpace(12.h),

            ///Section : PendingTab -> Button -> Cancel/Accept
            Align(
              alignment: Alignment.centerRight,
              child: CustomElevatedButton(
                onTap: pendingPaymentButtonOnTap,
                buttonWidth: 140.w,
                buttonHeight: 38.h,
                buttonColor: AppColors.cd5dbf9,
                buttonTitle: "Pending Payment",
                textStyle: TextFontStyle.headline14w500c6a6a6aStyleSatoshi,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

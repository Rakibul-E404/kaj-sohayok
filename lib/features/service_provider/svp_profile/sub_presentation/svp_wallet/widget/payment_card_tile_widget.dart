import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/text_font_style.dart';
import '../../../../../../custom_widgets/dotted_line_divider_widget.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';

class WalletCardTileWidget extends StatelessWidget {
  final String title;
  final String amount;
  final bool isWithdrawlCard;
  const WalletCardTileWidget({
    super.key,
    required this.title,
    required this.amount,
    this.isWithdrawlCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 19.h),
      decoration: BoxDecoration(
        color: AppColors.cf1f3fd,
        border: Border.all(color: AppColors.ce6e6e6, width: 1.5.sp),
        boxShadow: [
          BoxShadow(
            color: AppColors.ca4b1f2.withAlpha(80),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///Section : Text -> total balance
          Text(title, style: TextFontStyle.headline18w700c4d4d4dStyleSatoshi),
          UIHelper.verticalSpace(14.h),

          ///Section : Divider
          DottedLineDividerWidget(),
          UIHelper.verticalSpace(14.h),

          ///Section : Total Available Amount
          Text(
            "\$$amount",
            style: isWithdrawlCard
                ? TextFontStyle.headline24w700cff6b6bStyleSatoshi
                : TextFontStyle.headline24w700c778bebStyleSatoshi,
          ),
        ],
      ),
    );
  }
}

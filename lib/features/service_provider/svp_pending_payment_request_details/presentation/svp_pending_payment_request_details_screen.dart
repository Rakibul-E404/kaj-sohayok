import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../constants/appList.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/payment_summery_widget.dart';
import '../../../../custom_widgets/proof_of_work_showing_widget.dart';
import '../../../../custom_widgets/ratings_showing_widget.dart';
import '../../../../custom_widgets/work_address_and_date_widget.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class SvpPendingPaymentRequestDetailsScreen extends StatelessWidget {
  const SvpPendingPaymentRequestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Details",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: UIHelper.kDefaulutPadding(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Section : Working Address
                ///Section : Booking Order Date
                WorkAddressAndDateWidget(
                  address: "Rampura Dhaka, Bangladesh",
                  dateTime: "Jun 17, 2025  09:31AM",
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Text -> work complete information
                Text(
                  "Proof Of Work Complete Information",
                  style: TextFontStyle.headline16w700c202020StyleSatoshi,
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Completion Date
                Container(
                  width: 1.sw,
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 27.w,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.ce6e6e6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Completion Date",
                        style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                      ),
                      UIHelper.verticalSpace(20.h),
                      Row(
                        children: [
                          Text(
                            "11-08-25",
                            style:
                                TextFontStyle.headline16w700c202020StyleSatoshi,
                          ),
                          Spacer(),
                          Icon(Icons.date_range, color: AppColors.c858c94),
                        ],
                      ),
                    ],
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Duration Time Section
                Container(
                  width: 1.sw,
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 27.w,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.ce6e6e6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Duration Time",
                        style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                      ),
                      UIHelper.verticalSpace(20.h),
                      Text(
                        "${1} Day",
                        style: TextFontStyle.headline16w700c202020StyleSatoshi,
                      ),
                    ],
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Proof Of Work
                ///Section : Text -> Proof of image
                ///Section : Work Image
                ProofOfWorkShowingWidget(
                  title: "Proof of Image",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: Image.asset(
                      Assets.images.userImage.path,
                      width: 1.sw,
                      height: 200.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Payment Summery
                PaymentSummeryWidget(
                  initialCost: 30,
                  additionalCostList: AppList.additionalCosts,
                  totalPayment:
                      30 +
                      AppList.additionalCosts.fold(
                        0,
                        (sum, item) => sum + item.price,
                      ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Review Section
                CustomElevatedButton(
                  onTap: () {
                    log("Pending Payment Button Taped!");
                  },
                  buttonColor: AppColors.cd5dbf9,
                  buttonTitle: "Pending Payment",
                  textStyle: TextFontStyle.headline16w700c989898StyleSatoshi,
                ),
                UIHelper.verticalSpace(24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

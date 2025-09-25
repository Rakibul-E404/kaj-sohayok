import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../constants/appList.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/more_info_widget_tile.dart';
import '../../../../custom_widgets/payment_summery_widget.dart';
import '../../../../custom_widgets/proof_of_work_showing_widget.dart';
import '../../../../custom_widgets/ratings_showing_widget.dart';
import '../../../../custom_widgets/work_address_and_date_widget.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class SvpWorkCompletedDetailsScreen extends StatelessWidget {
  const SvpWorkCompletedDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Details of Completed Work",
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
                  "Work Complete Information",
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
                        style: TextFontStyle.headline14w500c202020StyleSatoshi,
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
                          Icon(Icons.date_range),
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
                        style: TextFontStyle.headline14w500c202020StyleSatoshi,
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
                Container(
                  width: 1.sw,
                  padding: EdgeInsets.symmetric(
                    vertical: 9.h,
                    horizontal: 14.w,
                  ),
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
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: RatingsShowingWidget(
                    userImage: Assets.images.userImage.path,
                    userName: "Chowdhury Md. Imtiazul Islam",
                    givenRatings: 4,
                    timeFrame: "2 Weeks ago",
                    comment:
                        "Lorem ipsum dolor sit amet consectetur. Dolor volutpat "
                        "tellus nunc nulla enim sit. Nunc ut pellentesque aliquet et. "
                        " Nunc mattis molestie elit malesuada.",
                  ),
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

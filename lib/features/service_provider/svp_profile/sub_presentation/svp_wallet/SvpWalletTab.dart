import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/custom_widgets/dotted_line_divider_widget.dart';
import 'package:kaz_bd/features/service_provider/svp_profile/sub_presentation/svp_wallet/widget/payment_card_tile_widget.dart';
import 'package:kaz_bd/features/service_provider/svp_profile/sub_presentation/svp_wallet/widget/transection_history_card.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../../gen/colors.gen.dart';

class SvpWalletTab extends StatelessWidget {
  const SvpWalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///Section : Total Balance Card
          WalletCardTileWidget(title: "Total Balance", amount: 19.500),
          UIHelper.verticalSpace(16.h),

          ///Section : Total Withdrawl Card
          WalletCardTileWidget(
            isWithdrawlCard: true,
            title: "Total Withdrawal Balance",
            amount: 19.500,
          ),
          UIHelper.verticalSpace(24.h),

          ///Section : Transactions History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Transactions History",
                style: TextFontStyle.headline18w700c202020StyleSatoshi,
              ),

              InkWell(
                onTap: () {
                  log("See All button Taped!");
                },
                child: Text(
                  "See all",
                  style: TextFontStyle.headline10w400c6c606cStyleSatoshi
                      .copyWith(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(24.h),

          ///Section : Transection  History Card
          TransectionHistoryCard(),
          UIHelper.verticalSpace(32.h),

          ///Section : Button -> Withdraw Balance
          CustomElevatedButton(
            onTap: () {
              log("Button -> Withdraw Balance -> Tapped!");
            },
            borderRadius: 12.r,
            buttonTitle: "Withdraw Balance",
          ),
          UIHelper.verticalSpace(32.h),
        ],
      ),
    );
  }
}

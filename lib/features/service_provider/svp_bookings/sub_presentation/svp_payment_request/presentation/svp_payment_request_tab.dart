import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/custom_widgets/dotted_line_divider_widget.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../../../constants/app_enums.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../../../custom_widgets/date_and_time_widget_tile.dart';
import '../../../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';
import '../widgets/svp_payment_request_tab_card.dart';

class SvpPaymentRequestTab extends StatelessWidget {
  const SvpPaymentRequestTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
          child: ListView.separated(
            itemCount: 20,
            separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
            itemBuilder: (context, index) {
              return SvpPaymentRequestTabCard(
                cardOnTap: () {
                  log("Taped -> Pending Request Card");
                  Get.toNamed(Routes.svpPendingPaymentRequestDetailsScreen);
                },
                pendingPaymentButtonOnTap: () {
                  log("Taped -> Pending Payment Button!");
                },
                userImage: Assets.images.userImage.path,
                userName: "Chowdhury Md. Imtiazul Islam",
                location: "Rampura Dhaka, Bangladesh",
                dateTime: "Jun 17, 2025  09:31AM",
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../constants/app_enums.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';
import '../../../widgets/bookings_details_card_widget.dart';

class PaymentRequestTab extends StatelessWidget {
  const PaymentRequestTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
      itemBuilder: (context, index) {
        return BookingDetailsCardWidget(
          onTap: null,
          isPaymentRequestTab: true,
          isPaymentRequestTabPayOnTap: () {
            log("My Bookings Screen Payment Request Tab Pay Button Taped!");
          },
          isPaymentRequestTabViewOnTap: () {
            log("My Bookings Screen Payment Request Tab View Button Taped!");
            Get.toNamed(
              Routes.bookingsPaymentRequestDetailsScreen,
              arguments: {"status": BookingStatusEnum.paymentRequest},
            );
          },
          title: "Jfdlskfjkl",
          initialPayablePrice: "54",
          location: "sdkfjsldk",
          dateTime: "sdfjlkasd",
          serviceProviderProfileImage: Assets.images.userImage.path,
          serviceProviderName: "Chowdhury Md. Imtiazul Islam",
          serviceProviderDesignation: "Service Provider",
        );
      },
    );
  }
}

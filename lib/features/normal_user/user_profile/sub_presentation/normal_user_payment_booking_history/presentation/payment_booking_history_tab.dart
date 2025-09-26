import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/features/normal_user/user_profile/sub_presentation/normal_user_payment_booking_history/widget/payment_history_showing_card.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';

class PaymentBookingHistoryTab extends StatelessWidget {
  const PaymentBookingHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (context, index) => UIHelper.verticalSpace(20.h),
      itemBuilder: (context, index) {
        return PaymentHistoryShowingCard(
          onTap: () {
            Get.toNamed(Routes.workCompletedDetailsScreen);
          },
          serviceName: "Home Cleaning",
          initialPayablePrice: 30.50,
          address: "Rampura Dhaka, Bangladesh",
          dateAndTime: "Jun 17, 2025  09:31AM",
          serviceProviderProfileImage: Assets.images.userImage.path,
          serviceProviderName: "Ripon Mia",
          serviceProviderDesignation: "Services Provider",
        );
      },
    );
  }
}

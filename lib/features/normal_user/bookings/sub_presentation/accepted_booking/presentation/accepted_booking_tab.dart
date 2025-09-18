import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/app_enums.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../widgets/bookings_details_card_widget.dart';

class AcceptedBookingTab extends StatelessWidget {
  const AcceptedBookingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
      itemBuilder: (context, index) {
        return BookingDetailsCardWidget(
          onTap: null,
          isAcceptedBookingTab: true,

          ///Button OnTap : View
          isAcceptedBookingTabViewOnTap: () {
            Get.toNamed(
              Routes.serviceDetailsScreen,
              arguments: {"status": BookingStatusEnum.acceptedBooking},
            );
          },

          ///Button OnTap : Message
          isAcceptedBookingTabMessageOnTap: () {
            log("Accepted Tab Message Button Taped!");
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

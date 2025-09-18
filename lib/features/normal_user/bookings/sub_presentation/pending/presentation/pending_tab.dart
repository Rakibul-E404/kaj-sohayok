import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/features/normal_user/bookings/widgets/bookings_details_card_widget.dart';

import '../../../../../../constants/app_enums.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';
import '../widget/show_cancel_booking_bottom_sheet.dart';

class PendingTab extends StatelessWidget {
  const PendingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
      itemBuilder: (context, index) {
        return BookingDetailsCardWidget(
          onTap: () {
            Get.toNamed(
              Routes.serviceDetailsScreen,
              arguments: {"status": BookingStatusEnum.pending},
            );
          },
          isPendingTab: true,
          isPendingTabCancelOnTap: () {
            showCancelBookingBottomSheet();
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

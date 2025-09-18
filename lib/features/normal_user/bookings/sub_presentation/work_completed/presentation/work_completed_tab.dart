import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/features/normal_user/bookings/widgets/bookings_details_card_widget.dart';

import '../../../../../../constants/app_enums.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';
import '../widgets/show_review_giving_alert_dialog.dart';

class WorkCompletedTab extends StatelessWidget {
  const WorkCompletedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
      itemBuilder: (context, index) {
        return BookingDetailsCardWidget(
          onTap: () {
            Get.toNamed(
              Routes.workCompletedDetailsScreen,
              arguments: {"status": BookingStatusEnum.workCompleted},
            );
          },
          isWorkCompletedTab: true,
          isReviewGiven: index % 2 == 0 ? true : false,
          isWorkCompletedTabGiveReviewOnTap: () {
            showReviewGivingAlertDialog();
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

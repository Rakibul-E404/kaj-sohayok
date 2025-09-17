import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/features/normal_user/bookings/widgets/bookings_details_card_widget.dart';

import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';

class WorkCompletedTab extends StatelessWidget {
  const WorkCompletedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
      itemBuilder: (context, index) {
        return BookingDetailsCardWidget(
          isWorkCompletedTab: true,
          isWorkCompletedTabGiveReviewOnTap: () {},
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

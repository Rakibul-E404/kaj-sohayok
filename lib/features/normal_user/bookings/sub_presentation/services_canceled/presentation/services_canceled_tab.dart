import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../gen/assets.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../widgets/bookings_details_card_widget.dart';

class ServicesCanceledTab extends StatelessWidget {
  const ServicesCanceledTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
      itemBuilder: (context, index) {
        return BookingDetailsCardWidget(
          isCanceledTab: true,
          isCanceledTabCancelOnTap: () {},
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

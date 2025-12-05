import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/features/normal_user/user_profile/sub_presentation/normal_user_payment_booking_history/widget/payment_history_showing_card.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';
import 'package:kaz_bd/service/date_extensions.dart';
import 'package:kaz_bd/utilities/app_url.dart';

import '../../../../../../controllers/user_payment_history_controller.dart';
import '../../../../../../models/user_payment_history_model.dart';

class PaymentBookingHistoryTab extends StatelessWidget {
  const PaymentBookingHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final UserPaymentHistoryController userPaymentHistoryController = Get.put(
      UserPaymentHistoryController(),
    );
    userPaymentHistoryController.fetchPaymentHistory();
    return Obx(
      () => ListView.separated(
        itemCount: userPaymentHistoryController.userPaymentHistories.length,
        separatorBuilder: (context, index) => UIHelper.verticalSpace(20.h),
        itemBuilder: (context, index) {
          final UserPaymentHistoryModel singlePayment =
              userPaymentHistoryController.userPaymentHistories[index];

          return PaymentHistoryShowingCard(
            onTap: () {
              userPaymentHistoryController.fetchPaymentHistoryDetails(
                id: singlePayment.serviceBookingId ?? '',
              );

            },
            serviceName:
                "${singlePayment.providerDetailsId?.serviceName?.en ?? ''} ",
            initialPayablePrice: singlePayment.startPrice ?? 0.0,
            address: "${singlePayment.address?.en ?? ''} ",
            dateAndTime: "${formatDateTime(singlePayment.bookingDateTime)}",
            serviceProviderProfileImage:
                "${AppUrl.imageBaseUrl}${singlePayment.providerId?.profileImage?.imageUrl}",
            serviceProviderName: "${singlePayment.providerId?.name ?? ''} ",
            serviceProviderDesignation: "Service Provider",
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/custom_widgets/dotted_line_divider_widget.dart';

import '../constants/text_font_style.dart';
import '../features/normal_user/work_completed_details/model/additional_cost_model.dart';
import '../features/normal_user/work_completed_details/widgets/additional_cost_showing_widget.dart';
import '../features/normal_user/work_completed_details/widgets/initial_cost_Widget.dart';
import '../features/normal_user/work_completed_details/widgets/total_payment_showing_widget.dart';
import '../features/normal_user/work_completed_details/widgets/transaction_id_widget.dart';
import '../gen/colors.gen.dart';
import '../helpers/ui_helpers.dart';

class PaymentSummeryWidget extends StatelessWidget {
  final double initialCost;
  final double totalPayment;
  final String? transactionID;
  final bool isAddAdditionalCostButtonVisible;
  final bool isTransactionIdCardVisible;
  final List<AdditionalCostModel> additionalCostList;
  final void Function()? onTap;

  const PaymentSummeryWidget({
    super.key,
    this.onTap,
    required this.initialCost,
    required this.additionalCostList,
    required this.totalPayment,
    this.transactionID,
    this.isAddAdditionalCostButtonVisible = false,
    this.isTransactionIdCardVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        border: Border.all(color: AppColors.ce6e6e6),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.ca4b1f2.withAlpha(80),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///Section : Text -> Payment Summery
          Text(
            "Payment Summary",
            style: TextFontStyle.headline16w700c202020StyleSatoshi,
          ),
          UIHelper.verticalSpace(16.h),

          /// Initial Cost
          InitialCostWIdget(initialCost: initialCost),

          UIHelper.verticalSpace(25.h),

          /// Additional Costs (loop)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: additionalCostList.length,
            separatorBuilder: (_, __) => UIHelper.verticalSpace(12.h),
            itemBuilder: (context, index) {
              final item = additionalCostList[index];
              return AdditionalCostShowingWidget(
                label: item.title,
                amount: item.price,
              );
            },
          ),
          UIHelper.verticalSpace(25.h),

          ///Section : Divider
          DottedLineDividerWidget(),
          UIHelper.verticalSpace(25.h),

          /// Section Button -> Add Additional Cost Button
          isAddAdditionalCostButtonVisible
              ? Align(
                  alignment: Alignment.centerRight,
                  child: CustomElevatedButton(
                    onTap: onTap,
                    buttonWidth: 180.w,
                    buttonTitle: "Add Additional Cost",
                  ),
                )
              : SizedBox.shrink(),

          isAddAdditionalCostButtonVisible
              ? UIHelper.verticalSpace(25.h)
              : SizedBox.shrink(),

          ///Section : Total Payment
          TotalPaymentShowingWidget(totalPayment: totalPayment),
          UIHelper.verticalSpace(12.h),

          /// Transaction ID
          isTransactionIdCardVisible
              ? TransactionIdWidget(transactionID: transactionID)
              : SizedBox.shrink(),
          isTransactionIdCardVisible
              ? UIHelper.verticalSpace(12.h)
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}

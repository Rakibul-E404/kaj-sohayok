import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/features/service_provider/svp_profile/sub_presentation/svp_wallet/widget/payment_card_tile_widget.dart';
import 'package:kaz_bd/features/service_provider/svp_profile/sub_presentation/svp_wallet/widget/transection_history_card.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/helpers/waiting_widget.dart';

import '../../../../../controllers/svp_wallet_controller.dart';
import '../../../../../models/service_wallet_transaction_model.dart';

class SvpWalletTab extends StatelessWidget {
  const SvpWalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    final SvpWalletController svpWalletController = Get.put(
      SvpWalletController(),
    );
    svpWalletController.fetchProviderWallet();
    return SingleChildScrollView(
      child: Obx(() {
        if (svpWalletController.loader.value == true) {
          return WaitingWidget();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///Section : Total Balance Card
            WalletCardTileWidget(
              title: 'total_balance'.tr,
              amount:
                  "${svpWalletController.serviceWalletAccount.value?.totalBalance.toStringAsFixed(2)}",
            ),
            UIHelper.verticalSpace(16.h),

            ///Section : Total Withdrawl Card
            WalletCardTileWidget(
              isWithdrawlCard: true,
              title: 'total_withdrawl_balance'.tr,
              amount:
                  "${svpWalletController.serviceWalletAccount.value?.amount.toStringAsFixed(2)}",
            ),
            UIHelper.verticalSpace(24.h),

            ///Section : Transactions History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'transection_history'.tr,
                  style: TextFontStyle.headline18w700c202020StyleSatoshi,
                ),
                Obx(
                  () => Visibility(
                    visible: svpWalletController
                        .serviceWalletTransactions.isNotEmpty,
                    replacement: SizedBox.shrink(),
                    child: InkWell(
                      onTap: () {
                        /// all the transactions ====>
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.r),
                            ),
                          ),
                          builder: (context) {
                            final screenHeight = MediaQuery.of(
                              context,
                            ).size.height;
                            final maxContentHeight =
                                screenHeight * 0.6; // 60% of screen height

                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: maxContentHeight,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(top: 40),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    // physics: const NeverScrollableScrollPhysics(),
                                    itemCount: svpWalletController
                                        .serviceWalletTransactions.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final ServiceWalletTransactionModel item =
                                          svpWalletController
                                              .serviceWalletTransactions[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: TransectionHistoryCard(
                                          transactionType:
                                              '${item.type.toUpperCase()} ',
                                          totalAmount: '${item.amount}',
                                          paymentDate:
                                              '${formatDate(item.createdAt)}',
                                          // Replace with real date
                                          currency: ' ${item.currency}',
                                          transactionStatus:
                                              '${item.status.toUpperCase()} ',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        'see_all'.tr,
                        style: TextFontStyle.headline10w400c6c606cStyleSatoshi
                            .copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpace(24.h),

            Obx(
              () => Visibility(
                visible:
                    svpWalletController.serviceWalletTransactions.isNotEmpty,
                replacement: Text('${'no_transaction_history_available'.tr} '),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      svpWalletController.serviceWalletTransactions.length <= 2
                          ? svpWalletController.serviceWalletTransactions.length
                          : 2,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ServiceWalletTransactionModel item =
                        svpWalletController.serviceWalletTransactions[index];
                    return TransectionHistoryCard(
                      transactionType: '${item.type.toUpperCase()}',
                      totalAmount: '${item.amount}',
                      paymentDate: '${formatDate(item.createdAt)}',
                      currency: ' ${item.currency}',
                      transactionStatus: '${item.status.toUpperCase()}',
                    );
                  },
                ),
              ),
            ),
            UIHelper.verticalSpace(32.h),

            ///Section : Button -> Withdraw Balance
            Obx(
              () => Visibility(
                visible:
                    svpWalletController.serviceWalletAccount.value?.amount !=
                        0.0,
                replacement: SizedBox.shrink(),
                child: CustomElevatedButton(
                  onTap: () {
                    showWithdrawalBottomSheet(context);
                  },
                  borderRadius: 12.r,
                  buttonTitle: 'withdraw_balance'.tr,
                ),
              ),
            ),
            SizedBox(height: 120),
          ],
        );
      }),
    );
  }

  void showWithdrawalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        final SvpWalletController svpWalletController =
            Get.find<SvpWalletController>();
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: svpWalletController.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    UIHelper.verticalSpace(16.h),

                    Text(
                      'provide_information_for_withdrawl'.tr,
                      style: TextFontStyle.headline18w700c202020StyleSatoshi,
                    ),
                    UIHelper.verticalSpace(24.h),

                    // Bank Name Field
                    _buildTextField(
                      controller: svpWalletController.bankNameController,
                      label: 'bank_name'.tr,
                      icon: Icons.account_balance,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_enter_bank_name'.tr;
                        }
                        return null;
                      },
                      context: context,
                    ),
                    UIHelper.verticalSpace(16.h),
                    _buildTextField(
                      controller: svpWalletController.bankBranchController,
                      label: 'bank_branch_name'.tr,
                      icon: Icons.account_balance,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_enter_bank_branch_name'.tr;
                        }
                        return null;
                      },
                      context: context,
                    ),
                    UIHelper.verticalSpace(16.h),

                    _buildTextField(
                      controller:
                          svpWalletController.bankRoutingNumberController,
                      label: 'bank_routing_number'.tr,
                      icon: Icons.account_balance,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_enter_account_holder_number'.tr;
                        }
                        if (double.tryParse(value) == null) {
                          return 'please_enter_valid_amount'.tr;
                        }
                        return null;
                      },
                      context: context,
                    ),
                    UIHelper.verticalSpace(16.h),
                    _buildTextField(
                      controller:
                          svpWalletController.accountHolderNameController,
                      label: 'account_holder_name'.tr,
                      icon: Icons.account_balance,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_enter_account_holder_name'.tr;
                        }
                        return null;
                      },
                      context: context,
                    ),
                    UIHelper.verticalSpace(16.h),

                    // Account Type Field
                    // Account Type Dropdown
                    DropdownButtonFormField<String>(
                      value:
                          svpWalletController.accountTypeController.text.isEmpty
                              ? null
                              : svpWalletController.accountTypeController.text,
                      items: [
                        DropdownMenuItem(
                          value: 'savings',
                          child: Text('svings'.tr),
                        ),
                        DropdownMenuItem(
                          value: 'current',
                          child: Text('current'.tr),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        svpWalletController.accountTypeController.text =
                            newValue ?? '';
                        svpWalletController.accountHolderNameController.text
                            .toLowerCase();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_select_account_type'.tr;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'account_type'.tr,
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                    UIHelper.verticalSpace(16.h),

                    // Account Number Field
                    _buildTextField(
                      controller: svpWalletController.accountNumberController,
                      label: 'account_number'.tr,
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_enter_account_number'.tr;
                        }
                        return null;
                      },
                      context: context,
                    ),
                    UIHelper.verticalSpace(16.h),

                    // Withdrawal Amount Field
                    _buildTextField(
                      controller: svpWalletController.amountController,
                      label: 'withdrawl_amount'.tr,
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_enter_amount'.tr;
                        }
                        if (double.tryParse(value) == null) {
                          return 'please_enter_valid_amount'.tr;
                        }
                        return null;
                      },
                      context: context,
                    ),
                    UIHelper.verticalSpace(32.h),

                    // Submit Button
                    CustomElevatedButton(
                      onTap: () {
                        svpWalletController.handleWithdraw();
                      },
                      borderRadius: 12.r,
                      buttonTitle: svpWalletController.loader.value
                          ? 'confirming'.tr
                          : 'confirming_withdrawl'.tr,
                    ),

                    UIHelper.verticalSpace(16.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}

String formatDate(String createdAt) {
  // Parse the incoming date string into a DateTime object
  DateTime dateTime = DateTime.parse(createdAt);

  // Format the date as "12 Jan 25, 8:00 AM"
  String formattedDate = DateFormat('d MMM yy, h:mm a').format(dateTime);

  return formattedDate;
}

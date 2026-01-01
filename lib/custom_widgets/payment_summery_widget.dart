import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import '../constants/app_constant_text.dart';
import '../constants/text_font_style.dart';
import '../features/normal_user/work_completed_details/model/additional_cost_model.dart';
import '../features/normal_user/work_completed_details/widgets/initial_cost_Widget.dart';
import '../features/normal_user/work_completed_details/widgets/total_payment_showing_widget.dart';
import '../features/normal_user/work_completed_details/widgets/transaction_id_widget.dart';
import '../custom_widgets/custom_elevated_button.dart';
import '../custom_widgets/dotted_line_divider_widget.dart';
import '../gen/colors.gen.dart';
import '../helpers/ui_helpers.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';

class PaymentSummeryWidget extends StatefulWidget {
  final double initialCost;
  final double totalPayment;
  final String? transactionID;
  final String? bookingId;
  final bool isAddAdditionalCostButtonVisible;
  final bool isTransactionIdCardVisible;
  final bool enableDelete;
  final List<AdditionalCostModel> additionalCostList;
  final void Function()? onTap;
  final VoidCallback? onDelete;

  const PaymentSummeryWidget({
    super.key,
    this.onTap,
    required this.initialCost,
    required this.additionalCostList,
    required this.totalPayment,
    this.transactionID,
    this.bookingId,
    this.isAddAdditionalCostButtonVisible = false,
    this.isTransactionIdCardVisible = false,
    this.enableDelete = false,
    this.onDelete,
  });

  @override
  State<PaymentSummeryWidget> createState() => _PaymentSummeryWidgetState();
}

class _PaymentSummeryWidgetState extends State<PaymentSummeryWidget> {
  final NetworkCaller _networkCaller = NetworkCaller();
  int? _activeDeleteIndex;
  bool _isDeleting = false;

  void _toggleDeleteButton(int index) {
    setState(() {
      if (_activeDeleteIndex == index) {
        _activeDeleteIndex = null;
        log('Hiding delete button for index: $index');
      } else {
        _activeDeleteIndex = index;
        log('Showing delete button for index: $index');
      }
    });
  }

  void _confirmDelete(int index) {
    final item = widget.additionalCostList[index];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this item?'),
            const SizedBox(height: 12),
            Text(
              'Title: ${item.title}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Amount: ${AppText.bdTkSign}${item.price}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              if (item.id != null) {
                _deleteAdditionalCost(item.id!, index);
              } else {
                setState(() {
                  widget.additionalCostList.removeAt(index);
                  _activeDeleteIndex = null;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item deleted locally')),
                );

                widget.onDelete?.call();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAdditionalCost(String additionalCostId, int index) async {
    if (_isDeleting) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        _showSnackBar('Authentication required. Please login again.', isError: true);
        setState(() {
          _isDeleting = false;
        });
        return;
      }

      final url = AppUrl.deleteAdditionalCost(additionalCostId);

      log('Deleting additional cost: $additionalCostId');
      log('DELETE URL: $url');

      final NetworkResponse response = await _networkCaller.deleteRequest(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      log('Delete Response: ${response.statusCode}');
      log('Delete Response Body: ${response.jsonResponse}');

      if (response.isSuccess) {
        setState(() {
          widget.additionalCostList.removeAt(index);
          _activeDeleteIndex = null;
          _isDeleting = false;
        });

        _showSnackBar('Item deleted successfully');

        widget.onDelete?.call();
      } else {
        setState(() {
          _isDeleting = false;
        });

        final errorMsg = response.jsonResponse?['message'] ??
            'Failed to delete item';
        _showSnackBar(errorMsg, isError: true);
      }
    } catch (e, stackTrace) {
      log('Error deleting additional cost: $e', error: e, stackTrace: stackTrace);

      setState(() {
        _isDeleting = false;
      });

      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
          Text(
            'payment_summery'.tr,
            style: TextFontStyle.headline16w700c202020StyleSatoshi,
          ),
          UIHelper.verticalSpace(16.h),

          InitialCostWIdget(initialCost: widget.initialCost),
          UIHelper.verticalSpace(25.h),

          widget.additionalCostList.isEmpty
              ? Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'no_additional_costs'.tr,
                style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi
                    .copyWith(color: Colors.grey),
              ),
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.additionalCostList.length,
            separatorBuilder: (_, __) => UIHelper.verticalSpace(12.h),
            itemBuilder: (context, index) {
              final item = widget.additionalCostList[index];
              print("===================================");
              print(item.title);
              print(item.id);
              final isDeleteActive = _activeDeleteIndex == index;

              return InkWell(
                onTap: () {

                  if (widget.enableDelete) {
                    _toggleDeleteButton(index);
                  }
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 8.h,
                  ),
                  decoration: isDeleteActive && widget.enableDelete
                      ? BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  )
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextFontStyle.headline16w700c202020StyleSatoshi,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${AppText.bdTkSign}${item.price}",
                            style: TextFontStyle.headline16w700c202020StyleSatoshi,
                          ),
                    
                          if (widget.enableDelete)
                            Padding(
                              padding: EdgeInsets.only(left: 8.w),
                              child: _isDeleting && _activeDeleteIndex == index
                                  ? SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                                  : IconButton(
                                icon: Icon(
                                  Icons.delete_forever_outlined,
                                  color: Colors.red,
                                  size: 24.sp,
                                ),
                                onPressed: () {
                                  _confirmDelete(index);
                                },
                              ),
                            ),



                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          UIHelper.verticalSpace(25.h),

          DottedLineDividerWidget(),
          UIHelper.verticalSpace(25.h),

          if (widget.isAddAdditionalCostButtonVisible)
            Align(
              alignment: Alignment.centerRight,
              child: CustomElevatedButton(
                onTap: widget.onTap,
                buttonWidth: 180.w,
                buttonTitle: 'add_additional_cost'.tr,
              ),
            ),
          if (widget.isAddAdditionalCostButtonVisible)
            UIHelper.verticalSpace(25.h),

          TotalPaymentShowingWidget(totalPayment: widget.totalPayment),
          UIHelper.verticalSpace(12.h),

          if (widget.isTransactionIdCardVisible)
            TransactionIdWidget(transactionID: widget.transactionID),
          if (widget.isTransactionIdCardVisible)
            UIHelper.verticalSpace(12.h),
        ],
      ),
    );
  }
}


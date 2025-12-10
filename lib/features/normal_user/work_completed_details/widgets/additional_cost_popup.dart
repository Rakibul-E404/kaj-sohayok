import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import '../../../../gen/colors.gen.dart';

Future<void> showAdditionalCostDialog({
  required BuildContext context,
  required void Function(String name, double price) additionlCostSubmitOnTap,
}) {
  // Create controllers for the dialog
  final TextEditingController additionalCostTitle = TextEditingController();
  final TextEditingController additionalCost = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.cFFFFFF,
      title: Text(
        "Add Additional Cost",
        style: TextFontStyle.headline16w500c000000StyleSatoshi,
      ),
      content: Form(
        key: formKey,
        child: Container(
          width: 1.sw,
          decoration: BoxDecoration(color: AppColors.cFFFFFF),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Section: Additional Cost Title Field
              TextFormField(
                controller: additionalCostTitle,
                decoration: InputDecoration(
                  hintText: "Enter cost title",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.ce6e6e6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter cost title';
                  }
                  return null;
                },
              ),
              UIHelper.verticalSpace(10.h),

              /// Section: Additional Cost Field
              TextFormField(
                controller: additionalCost,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: "Enter cost amount",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.ce6e6e6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter cost amount';
                  }
                  final price = double.tryParse(value.trim());
                  if (price == null || price <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              UIHelper.verticalSpace(10.h),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            CustomElevatedButton(
              onTap: () {
                // Validate the form
                if (formKey.currentState!.validate()) {
                  final name = additionalCostTitle.text.trim();
                  final price = double.parse(additionalCost.text.trim());

                  // Call the callback with name and price
                  additionlCostSubmitOnTap(name, price);

                  // Close the dialog
                  Navigator.of(context).pop();

                  // Show success message
                  Get.snackbar(
                    'Success',
                    'Additional cost added',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(seconds: 2),
                  );
                }
              },
              buttonWidth: 107.w,
              buttonHeight: 38.h,
              buttonTitle: "Save",
            ),
          ],
        ),
      ],
    ),
  );
}
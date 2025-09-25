// dialog_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../gen/colors.gen.dart';

Future<void> showAdditionalCostDialog({
  required BuildContext context,
  // required TextEditingController additionalCostTitle,
  // required TextEditingController additionalCost,
  void Function()? additionlCostSubmitOnTap,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.cFFFFFF,

      title: Text(
        "Add Additional Cost",
        style: TextFontStyle.headline16w500c000000StyleSatoshi,
      ),
      content: Container(
        width: 1.sw,
        decoration: BoxDecoration(color: AppColors.cFFFFFF),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ fix
          children: [
            /// Section: Additional Cost Title Field
            TextFormField(
              // controller: additionalCostTitle,
              decoration: InputDecoration(
                hintText: "Enter cost title",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.ce6e6e6),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            UIHelper.verticalSpace(10.h),

            /// Section: Additional Cost Field
            TextFormField(
              // controller: additionalCost,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter cost amount",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.ce6e6e6),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            UIHelper.verticalSpace(10.h),
          ],
        ),
      ),
      actions: [
        Align(
          alignment: Alignment.centerRight,
          child: CustomElevatedButton(
            onTap: additionlCostSubmitOnTap,
            buttonWidth: 107.w,
            buttonHeight: 38.h,
            buttonTitle: "Save",
          ),
        ),
      ],
    ),
  );
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:pinput/pinput.dart';
import 'package:get/get.dart';
import '../../../../controllers/otp_validation_controller.dart';
import '../../../../helpers/ui_helpers.dart';

class CustomPinInput extends StatelessWidget {
  final VoidCallback resend;
  final OtpValidationController controller = Get.put(OtpValidationController());
  final TextEditingController _pinController = TextEditingController();

  CustomPinInput({super.key, required this.resend});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 55.w,
      height: 55.h,
      textStyle: TextFontStyle.headline16w700c000000StyleSatoshi,
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.ce4dfdf),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.c778beb),
      borderRadius: BorderRadius.circular(12.r),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.cFFFFFF,
      ),
    );

    return Column(
      children: [
        Pinput(
          controller: _pinController,
          length: 6,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
          showCursor: true,
          cursor: Container(width: 20.w, height: 2.h, color: AppColors.c778beb),
          onCompleted: controller.onCompleted,
        ),
        UIHelper.verticalSpace(32.h),
        Obx(() {
          final totalSeconds = controller.secondsRemaining.value;

          // Format as MM:SS (e.g., 120s → "02:00", 90s → "01:30")
          final minutes = (totalSeconds ~/ 60).clamp(0, 99);
          final seconds = (totalSeconds % 60).clamp(0, 59);
          final formattedTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

          return controller.isOtpExpired.value
              ? RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'didn\'t_receive_code'.tr,
                  style: TextFontStyle.headline14w500c606060StyleSatoshi,
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: InkWell(
                    onTap: (){
                      _pinController.clear();
                      controller.pin.value = ''; // Also clear the controller's pin
                      resend();
                    },
                    child: Text(
                      'resend_code'.tr,
                      style: TextFontStyle
                          .headline14w500c000000StyleSatoshi
                          .copyWith(color: AppColors.cea464a),
                    ),
                  ),
                ),
              ],
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16.sp,
                color: AppColors.c606060,
              ),
              SizedBox(width: 6.w),
              Text(
                formattedTime,
                style: TextFontStyle.headline14w500c606060StyleSatoshi, // or adjust size/color as needed
              ),
            ],
          );
        })
      ],
    );
  }
}

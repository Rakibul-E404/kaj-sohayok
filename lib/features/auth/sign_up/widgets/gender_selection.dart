import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/appList.dart';
import '../../../../controllers/sign_up_screen_controller.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';

class GenderSelectionWidget extends StatelessWidget {
  const GenderSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignUpScreenController>(
      builder: (controller) {
        return InputDecorator(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10.sp),
            labelText: "Gender",
            hintText: "Select gender",
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: SvgPicture.asset(
                fit: BoxFit.contain,
                Assets.icons.genderLogo,
              ),
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: 40.w,
              minHeight: 40.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cb4b4b4),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text("Select gender"),
              value: controller.selectedGender,
              items: AppList.genderList
                  .map(
                    (gender) => DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                controller.setGender(value);
              },
            ),
          ),
        );
      },
    );
  }
}

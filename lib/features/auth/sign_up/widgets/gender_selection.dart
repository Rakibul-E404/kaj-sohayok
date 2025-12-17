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
    return GetBuilder<UserSignUpController>(
      builder: (controller) {
        return InputDecorator(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10.sp),
            labelText: 'gender'.tr,
            hintText: 'select_gender'.tr,
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                left: 12.w,
                right: 0.w,
              ), // No right padding
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    fit: BoxFit.contain,
                    Assets.icons.genderLogo,
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    height: 24.h,
                    width: 2.sp,
                    color: AppColors.cd9d9d9,
                  ),
                ],
              ),
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: 24.w,
              minHeight: 40.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cb4b4b4),
            ),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text('select_gender'.tr),
                value: controller.userSelectedGender.value.isEmpty
                    ? null
                    : controller.userSelectedGender.value,
                items: AppList.genderList
                    .where(
                      (gender) => gender.isNotEmpty,
                    ) // ✅ Filter out empty strings
                    .map(
                      (gender) => DropdownMenuItem<String>(
                        value: gender,
                        child: Text(
                          gender,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.setGender(value);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

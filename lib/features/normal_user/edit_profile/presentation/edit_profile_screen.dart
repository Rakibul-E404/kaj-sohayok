import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../controllers/user_edit_profile_controller.dart';
import '../../../../controllers/user_profile_screen_controller.dart';
import '../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../gen/colors.gen.dart';
import '../widgets/edit_profile_formfield_widget.dart';

class UserEditProfileScreen extends StatelessWidget {
  UserEditProfileScreen({super.key});

  final UserEditProfileScreenController controller = Get.put(
    UserEditProfileScreenController(),
  );
  final UserProfileScreenController userProfileController =
      Get.find<UserProfileScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        title: Text(
          'edit_profile'.tr,
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              children: [
                // Profile Image Section
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Obx(() {
                      final imagePath =
                          userProfileController.profileImage.value;
                      final bool isNetworkImage = imagePath.startsWith('http');
                      final bool hasImage = imagePath.isNotEmpty;

                      return Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.c778beb,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ca4b1f2.withAlpha(80),
                              blurRadius: 12.r,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: hasImage
                              ? (isNetworkImage
                                  ? CachedNetworkImage(
                                      imageUrl: imagePath,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.c778beb,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                        Icons.person,
                                        size: 60.sp,
                                        color: Colors.grey[400],
                                      ),
                                    )
                                  : Image.file(
                                      File(imagePath),
                                      fit: BoxFit.cover,
                                    ))
                              : Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.person,
                                    size: 60.sp,
                                    color: Colors.grey[400],
                                  ),
                                ),
                        ),
                      );
                    }),
                    // Edit Icon
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          userProfileController.showImageSourceDialog();
                        },
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: AppColors.c778beb,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(24.h),

                // Form Fields Container
                Container(
                  width: 1.sw,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cFFFFFF,
                    borderRadius: BorderRadius.circular(16),
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
                      /// Name Form Field
                      EditProfileFormFieldWidget(
                        lableText: 'name'.tr,
                        hintText: 'enter_your_name'.tr,
                        controller: controller.nameController,
                      ),
                      UIHelper.verticalSpace(16.h),

                      /// Phone Number Form Field
                      EditProfileFormFieldWidget(
                        lableText: 'phone_number'.tr,
                        hintText: 'enter_your_phone_number'.tr,
                        controller: controller.phoneNumberController,
                        keyboardType: TextInputType.phone,
                      ),
                      UIHelper.verticalSpace(16.h),

                /*      /// ============>  Location Removed =====================>
                      /// Location Form Field
                      EditProfileFormFieldWidget(
                        lableText: 'location'.tr,
                        hintText: 'enter_your_location'.tr,
                        controller: controller.locationController,
                      ),
                      UIHelper.verticalSpace(16.h),*/

                      /// Date of Birth Form Field
                      GestureDetector(
                        /// In EditProfileScreen — Date of Birth GestureDetector
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate:
                                controller.dateOfBirthController.text.isEmpty
                                    ? DateTime.now()
                                    : _parseDate(
                                          controller.dateOfBirthController.text,
                                        ) ??
                                        DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColors.c778beb,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null) {
                            // ✅ Format as YYYY-MM-DD (standard, unambiguous, backend-friendly)
                            controller.dateOfBirthController.text =
                                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          }
                        },
                        child: AbsorbPointer(
                          child: EditProfileFormFieldWidget(
                            lableText: 'date_of_birth'.tr,
                            hintText: 'select_date_of_birth'.tr,
                            controller: controller.dateOfBirthController,
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: AppColors.c778beb,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ),
                      UIHelper.verticalSpace(16.h),

                      /// Gender Form Field
                      // Text('Gender'),
                      Text(
                        'gender'.tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: controller.genderController.text.isEmpty
                            ? null
                            : controller.genderController.text.toLowerCase(),
                        // Convert to lowercase to match
                        items: [
                          DropdownMenuItem(
                              value: 'male', child: Text('male'.tr)),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('female'.tr),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          // Ensure value is converted to lowercase when setting
                          controller.genderController.text =
                              newValue?.toLowerCase() ?? '';
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_select_your_gender_type'.tr;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14.sp,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(color: AppColors.ce6e6e6),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(color: AppColors.ce6e6e6),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                              color: AppColors.c778beb,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                UIHelper.verticalSpace(30.h),

                // Update Button
                Obx(
                  () => CustomElevatedButton(
                    onTap: controller.isLoading.value
                        ? null
                        : () {
                            controller.updateProfile();
                          },
                    buttonTitle: controller.isLoading.value
                        ? 'updating'.tr
                        : 'update_profile'.tr,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    // Only accept YYYY-MM-DD
    final parts = dateString.split('-');
    if (parts.length == 3) {
      final year = int.tryParse(parts[0]) ?? 0;
      final month = int.tryParse(parts[1]) ?? 0;
      final day = int.tryParse(parts[2]) ?? 0;

      if (year > 0 && month > 0 && month <= 12 && day > 0 && day <= 31) {
        // ✅ Create LOCAL DateTime (no timezone)
        return DateTime(year, month, day);
      }
    }
    return null;
  }
}

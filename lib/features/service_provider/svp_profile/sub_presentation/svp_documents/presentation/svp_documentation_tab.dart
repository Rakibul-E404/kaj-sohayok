import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../../../controllers/svp_profile_screen_documents_tab_controller.dart';
import '../../../../../../gen/colors.gen.dart';
import '../widgets/svp_documents_tab_form_field.dart';
import '../widgets/svp_image_picker_grid_widget.dart';

class SvpDocumentationTab extends StatelessWidget {
  SvpDocumentationTab({super.key});

  final SvpProfileScreenDocumentsTabController controller = Get.put(
    SvpProfileScreenDocumentsTabController(),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        boxShadow: [
          BoxShadow(
            color: AppColors.ca4b1f2.withAlpha(80),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ///Section : Work Type
            Obx(() {
              return SvpDocumentsTabFormField(
                onTap: () {
                  controller.isWorkTypeFieldEnabled.value = true;
                },
                controller: controller.workTypeController,
                isFormFieldEnabled: controller.isWorkTypeFieldEnabled.value,
                fieldName: "Work Type",
                hintText: "Enter Your Work Type",
              );
            }),
            UIHelper.verticalSpace(16.h),

            ///Section : Years of Experience
            Obx(() {
              return SvpDocumentsTabFormField(
                onTap: () {
                  controller.isYearsOfExperienceFieldEnabled.value = true;
                },
                controller: controller.yearsOfExperienceController,
                isFormFieldEnabled:
                    controller.isYearsOfExperienceFieldEnabled.value,
                fieldName: "Years of Experience",
                hintText: "Enter Your Work In Year",
              );
            }),
            UIHelper.verticalSpace(16.h),

            ///Section : Start from Work Price
            Obx(() {
              return SvpDocumentsTabFormField(
                onTap: () {
                  controller.isInitialPriceFormFieldEnabled.value = true;
                },
                controller: controller.initialPayableController,
                isFormFieldEnabled:
                    controller.isInitialPriceFormFieldEnabled.value,
                fieldName: "Start from Work Price",
                hintText: "Enter Initial Payable Fee",
              );
            }),
            UIHelper.verticalSpace(16.h),

            ///Section : Services Description
            Obx(() {
              return SvpDocumentsTabFormField(
                onTap: () {
                  controller.isServiceDescriptionFormFieldEnabled.value = true;
                },
                isDescriptionField: true,
                controller: controller.descriptionController,
                isFormFieldEnabled:
                    controller.isServiceDescriptionFormFieldEnabled.value,
                fieldName: "Services Description",
                hintText: "Write Something About Your Service",
              );
            }),
            UIHelper.verticalSpace(16.h),

            ///Section : Upload Service Demo Images
            ImagePickerGridWidget(
              images: controller.selectedImages,
              maxImages: controller.maxImages,
              onPickImages: controller.pickImages,
              onRemoveImage: controller.removeImage,
            ),

            UIHelper.verticalSpace(24.h),

            ///Section : Button -> Save the Changes
            CustomElevatedButton(
              onTap: () {
                controller.isWorkTypeFieldEnabled.value = false;
                controller.isYearsOfExperienceFieldEnabled.value = false;
                controller.isInitialPriceFormFieldEnabled.value = false;
                controller.isServiceDescriptionFormFieldEnabled.value = false;
              },
              buttonTitle: "Save the Chagnes",
            ),
            UIHelper.verticalSpace(100.h),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/custom_widgets/custom_card.dart';

import '../../../../../../custom_widgets/svp_documents_tab_controller.dart';
import '../../../../../../gen/colors.gen.dart';
import '../widgets/svp_documents_tab_form_field.dart';

class SvpDocumentationTab extends StatelessWidget {
  SvpDocumentationTab({super.key});

  SvpDocumentsTabController controller = Get.put(SvpDocumentsTabController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      // height: height ?? 114.h,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        boxShadow: [
          BoxShadow(
            color: AppColors.c000000.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ///Section : Work Type
            SvpDocumentsTabFormField(
              controller: controller.workTypeController,
              fieldName: "Work Type",
              hintText: "Enter Your Work Type",
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../helpers/custom_text_form_field.dart';
import '../../../../helpers/ui_helpers.dart';
import '../widget/specific_service_showing_widget.dart';

class ServicesOfSpecificCategoryScreen extends StatelessWidget {
  const ServicesOfSpecificCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        title: Text(
          "Services Of Specific Category",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              children: [
                ///Section : Search Bar
                CustomFormField(
                  showVerticalDivider: false,

                  prefixIcon: SvgPicture.asset(Assets.icons.searchIcon),
                  hintText: "Services Of Specific Category",
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Available Services
                ListView.separated(
                  itemCount: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      UIHelper.verticalSpace(16.h),
                  itemBuilder: (contexxt, index) {
                    return SpecificServiceShowingWidget(
                      onTap: () {
                        log("Specific Service Item taped at index : $index");
                        Get.toNamed(Routes.serviceDetailsScreen);
                      },
                      serviceImagePath: Assets.images.serviceImage.path,
                      serviceName: "Home Cleaning",
                      initialPayablePrice: 30.5,
                      serviceProviderImage: Assets.images.userImage.path,
                      serviceProviderName: "Chowdhury Md. Imtiazul Islam",
                      serviceProviderRating: 4.5,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

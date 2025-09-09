import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/appList.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/custom_text_form_field.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../home/widgets/category_showing_widget.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        title: Text(
          "All Category",
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
                  hintText: "Search services",
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : All Categories
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1,
                  ),
                  itemCount: AppList.allCategoryList.length,
                  itemBuilder: (context, index) {
                    final category = AppList.allCategoryList[index];
                    return CategoryShowingWidget(
                      onTap: () {
                        log("Taped Category Name : ${category.categoryName}");
                        Get.toNamed(Routes.servicesOfSpecificCategoryScreen);
                      },
                      categoryIcon: category.categoryIcon,
                      categoryName: category.categoryName,
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

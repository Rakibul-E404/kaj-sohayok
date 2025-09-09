import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/controllers/home_page_controller.dart';
import 'package:kaz_bd/features/normal_user/home/widgets/category_showing_widget.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../routes/routes.dart';

class CategoryPageViewWidget extends StatelessWidget {
  final List myList;

  const CategoryPageViewWidget({super.key, required this.myList});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomePageController());

    // Layout constants (scaled with ScreenUtil)
    const int crossAxisCount = 3;
    final double crossAxisSpacing = 6.w;
    final double mainAxisSpacing = 6.h;
    final double paddingLeft = 16.w;
    final double paddingRight = 16.w;
    final double paddingTop = 16.h;
    final double paddingBottom = 10.h;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth -
            paddingLeft -
            paddingRight -
            (crossAxisSpacing * (crossAxisCount - 1));
        final cellWidth = availableWidth / crossAxisCount;

        final maxRows = myList
            .map((page) => (page.length / crossAxisCount).ceil())
            .reduce((a, b) => a > b ? a : b);

        final gridHeight =
            paddingTop +
            paddingBottom +
            (cellWidth * maxRows) +
            (mainAxisSpacing * (maxRows - 1));

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: gridHeight,
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: myList.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, pageIndex) {
                  final pageCategories = myList[pageIndex];
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      childAspectRatio: 1,
                    ),
                    itemCount: pageCategories.length,
                    itemBuilder: (context, index) {
                      final category = pageCategories[index];
                      return CategoryShowingWidget(
                        onTap: () {
                          Get.toNamed(Routes.servicesOfSpecificCategoryScreen);
                        },
                        categoryIcon: category.categoryIcon,
                        categoryName: category.categoryName,
                      );
                    },
                  );
                },
              ),
            ),

            // Page Indicator
            Obx(
              () => Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    myList.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      height: 6.h,
                      width: controller.currentPage.value == index ? 12.w : 6.w,
                      decoration: BoxDecoration(
                        color: controller.currentPage.value == index
                            ? Colors.blue
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

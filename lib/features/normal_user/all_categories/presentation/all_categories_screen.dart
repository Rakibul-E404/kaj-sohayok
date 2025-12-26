import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/all_categories_screen_controller.dart';
import 'package:kaz_bd/features/normal_user/home/widgets/category_showing_widget.dart';
import 'package:kaz_bd/routes/routes.dart';
import 'package:kaz_bd/utilities/logger_util.dart';

import '../../../../custom_widgets/reusable_appbar.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    NormalUserAllCategoryScreenController controller =
        Get.find<NormalUserAllCategoryScreenController>();

    return Scaffold(
      appBar: ReusableAppBar(title: 'all_categories'.tr),
      body: GetBuilder<NormalUserAllCategoryScreenController>(
        builder: (controller) {
          return Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.categories.isEmpty) {
              return Center(child: Text('no_categories_found'.tr));
            }

            return GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 1,
              ),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                final String categoryName = category.name?.en ?? 'category'.tr;
                final String? imageUrl = (category.attachments != null &&
                        category.attachments!.isNotEmpty)
                    ? category.attachments![0].attachment
                    : null;
                final String categoryId = category.serviceCategoryId ?? '';

                return CategoryShowingWidget(
                  onTap: () {
                    Get.toNamed(
                      Routes.servicesOfSpecificCategoryScreen,
                      arguments: {
                        'categoryId': categoryId,
                        'categoryName': categoryName,
                        'lat_value': controller.latitudeValue,
                        'long_value': controller.longitudeValue,
                      },
                    );

                    LoggerUtils.info("👽👽-----Category ID : $categoryId");
                    LoggerUtils.info("👽👽------Category Name : $categoryName");
                  },
                  categoryName: categoryName,
                  imageUrl: imageUrl,
                );
              },
            );
          });
        },
      ),
    );
  }
}

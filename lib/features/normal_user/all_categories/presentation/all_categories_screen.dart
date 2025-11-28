import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/all_categories_screen_controller.dart';
import 'package:kaz_bd/features/normal_user/home/widgets/category_showing_widget.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../../custom_widgets/reusable_appbar.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    NormalUserAllCategoryScreenController controller =
        Get.find<NormalUserAllCategoryScreenController>();

    return Scaffold(
      appBar: const ReusableAppBar(title: 'All Categories'),
      body: GetBuilder<NormalUserAllCategoryScreenController>(
        builder: (controller) {
          return Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.categories.isEmpty) {
              return const Center(child: Text('No categories found.'));
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
                final String categoryName = category.name?.en ?? 'Category';
                final String? imageUrl =
                    (category.attachments != null &&
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
                      },
                    );
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

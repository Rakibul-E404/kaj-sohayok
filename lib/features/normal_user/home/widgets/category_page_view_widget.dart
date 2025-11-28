import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/home_page_controller.dart';
import 'package:kaz_bd/features/normal_user/home/models/home_page_data_model.dart'
    as Model;
import 'package:kaz_bd/features/normal_user/home/widgets/category_showing_widget.dart';

import '../../../../routes/routes.dart';

class CategoryPageViewWidget extends StatelessWidget {
  const CategoryPageViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final HomePageController controller = Get.find<HomePageController>();

    // Layout constants (scaled with ScreenUtil)
    const int crossAxisCount = 3;
    final double crossAxisSpacing = 6.w;
    final double mainAxisSpacing = 6.h;
    final double paddingValue = 16.w;

    return Obx(() {
      // Check if data is loaded and has categories
      if (controller.isLoading.value || controller.categories.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      // Get only the first 6 categories
      final categoriesToShow = controller.categories.length > 6
          ? controller.categories.take(6).toList()
          : controller.categories;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(paddingValue),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: 1,
        ),
        itemCount: categoriesToShow.length,
        itemBuilder: (context, index) {
          final category = categoriesToShow[index];

          // Handle Category model format
          final String categoryName = _getCategoryName(category);
          final String? imageUrl = _getCategoryImageUrl(category);
          final String categoryId = _getCategoryId(category);

          return CategoryShowingWidget(
            onTap: () {
              log("Category tapped: $categoryName");
              Get.toNamed(
                Routes.servicesOfSpecificCategoryScreen,
                arguments: {
                  'categoryId': categoryId,
                  'categoryName': categoryName,
                },
              );
            },
            categoryIcon: Icons.category, // Default icon for API data
            categoryName: categoryName,
            imageUrl: imageUrl,
          );
        },
      );
    });
  }

  // Helper methods to handle Category model format
  String _getCategoryName(Model.Category category) {
    // Access name from the Category model
    if (category.name != null && category.name!.en != null) {
      return category.name!.en.toString();
    }
    return 'Category';
  }

  String? _getCategoryImageUrl(Model.Category category) {
    // Access image from attachments in the Category model
    if (category.attachments != null && category.attachments!.isNotEmpty) {
      return category.attachments![0].attachment;
    }
    return null;
  }

  String _getCategoryId(Model.Category category) {
    return category.serviceCategoryId ?? '';
  }
}

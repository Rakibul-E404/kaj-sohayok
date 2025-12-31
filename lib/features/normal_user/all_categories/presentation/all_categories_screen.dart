import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/all_categories_screen_controller.dart';
import 'package:kaz_bd/features/normal_user/home/widgets/category_showing_widget.dart';
import 'package:kaz_bd/routes/routes.dart';
import 'package:kaz_bd/utilities/logger_util.dart';

import '../../../../custom_widgets/reusable_appbar.dart';
import '../../../../helpers/ui_helpers.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    NormalUserAllCategoryScreenController controller =
        Get.find<NormalUserAllCategoryScreenController>();

    return Scaffold(
      appBar: ReusableAppBar(title: 'all_categories'.tr),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        child: GetBuilder<NormalUserAllCategoryScreenController>(
          builder: (controller) {
            return Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // CircularProgressIndicator(),
                      UIHelper.verticalSpace(16.h),
                      Text(
                        'loading_all_categories...'.tr,
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.sp),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: Colors.red,
                        ),
                        UIHelper.verticalSpace(16.h),
                        Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        UIHelper.verticalSpace(20.h),
                        ElevatedButton(
                          onPressed: () => controller.refreshData(),
                          child: Text('retry'.tr),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.categories.isEmpty) {
                return SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 64.sp,
                          color: Colors.grey,
                        ),
                        UIHelper.verticalSpace(16.h),
                        Text(
                          'no_categories_found'.tr,
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
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
                  final String categoryName =
                      category.name?.en ?? 'category'.tr;
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
                      LoggerUtils.info(
                          "👽👽------Category Name : $categoryName");
                    },
                    categoryName: categoryName,
                    imageUrl: imageUrl,
                  );
                },
              );
            });
          },
        ),
      ),
    );
  }
}

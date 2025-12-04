import 'package:get/get.dart';

import '../../controllers/all_categories_screen_controller.dart';

class NormalUserAllCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NormalUserAllCategoryScreenController>(
      () => NormalUserAllCategoryScreenController(),
    );
  }
}

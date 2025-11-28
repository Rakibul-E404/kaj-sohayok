import 'package:get/get.dart';

import '../../controllers/service_of_specific_category_screen_controller.dart';

class ServiceOfSpecificCategoryScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceOfSpecificCategoryScreenController>(
      () => ServiceOfSpecificCategoryScreenController(),
    );
  }
}

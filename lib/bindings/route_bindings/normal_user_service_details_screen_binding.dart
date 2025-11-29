import 'package:get/get.dart';

import '../../controllers/details_screen_controller.dart';

class NormalUserServiceDetailsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailsScreenController>(() => DetailsScreenController());
  }
}

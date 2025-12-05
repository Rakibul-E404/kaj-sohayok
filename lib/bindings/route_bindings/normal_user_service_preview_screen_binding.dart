import 'package:get/get.dart';
import 'package:kaz_bd/controllers/normal_user_service_preview_screen_controller.dart';

class NormalUserServicePreviewScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NormalUserServicePreviewScreenController>(
      () => NormalUserServicePreviewScreenController(),
    );
  }
}

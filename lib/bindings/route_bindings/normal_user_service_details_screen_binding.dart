import 'package:get/get.dart';

import '../../controllers/details_screen_controller.dart';
import '../../controllers/get_nrm_user_service_provider_profile_info.dart';

class NormalUserServiceDetailsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailsScreenController>(() => DetailsScreenController());
    Get.lazyPut<GetNrmUserServiceProviderProfileInfoController>(
      () => GetNrmUserServiceProviderProfileInfoController(),
    );
  }
}

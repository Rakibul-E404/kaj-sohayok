import 'package:get/get.dart';

import '../../controllers/normal_user_see_all_popular_providers.dart';

class NormalUserSeeAllPopularProviderScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NormalUserSeeAllPopularProvidersController>(
      () => NormalUserSeeAllPopularProvidersController(),
    );
  }
}

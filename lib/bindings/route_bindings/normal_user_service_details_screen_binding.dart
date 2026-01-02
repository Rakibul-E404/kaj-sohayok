import 'package:get/get.dart';

import '../../controllers/calender_controller.dart';
import '../../controllers/details_screen_controller.dart';
import '../../controllers/get_nrm_user_service_provider_profile_info.dart';
import '../../controllers/normal_user_booking_service_provider_controller.dart';

class NormalUserServiceDetailsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailsScreenController>(() => DetailsScreenController());
    Get.lazyPut<GetNrmUserServiceProviderProfileInfoController>(() => GetNrmUserServiceProviderProfileInfoController());
    Get.lazyPut<CalendarController>(() => CalendarController());
    Get.lazyPut<NormalUserBookingServiceProviderController>(
      () => NormalUserBookingServiceProviderController(),
    );
  }
}

import 'package:get/get.dart';
import '../../controllers/calender_controller.dart';
import '../../controllers/normal_user_booking_service_provider_controller.dart';

class NormalUserBookingDateScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CalendarController());
    Get.lazyPut(() => NormalUserBookingServiceProviderController());
  }
}
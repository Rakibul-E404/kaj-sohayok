import 'package:get/get.dart';
import 'package:kaz_bd/controllers/svp_home_screen_controller.dart';
import 'package:kaz_bd/features/service_provider/svp_bookings/sub_presentation/svp_bookings_canceled/controller/svp_bookings_canceled_tab_controller.dart';
import 'package:kaz_bd/features/service_provider/svp_job_request/controller/svp_job_request_screen_controller.dart';

class SvpPendingJobRequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SvpHomeScreenController>(() => SvpHomeScreenController());
    Get.lazyPut<SvpBookingsCanceledController>(
        () => SvpBookingsCanceledController());
    Get.lazyPut<SvpJobRequestScreenController>(
        () => SvpJobRequestScreenController());
  }
}

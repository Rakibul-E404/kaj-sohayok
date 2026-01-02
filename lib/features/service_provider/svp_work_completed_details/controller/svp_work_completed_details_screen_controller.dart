import 'package:get/get.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:logger/logger.dart';

import '../../../../service/network_caller.dart';
import '../../../../service/network_response.dart';
import '../../../../service/secured_storage.dart';
import '../../../../utilities/app_constants.dart';
import '../../../../utilities/app_url.dart';
import '../../../../utilities/logger_util.dart';
import '../model/model_of_svp_work_completed_details_screen.dart';

class SvpWorkCompletedDetailsScreenController extends GetxController {
  RxBool isUserDetailsLoading = false.obs;
  RxString errorMessage = ''.obs;
  Rxn<ModelOfSvpWorkCompletedDetails> modelOfSvpWorkCompletedDetails =
      Rxn<ModelOfSvpWorkCompletedDetails>();
  RxString srvBookingId = ''.obs;
  void setSrvBookingId({required String srvBookingID}) {
    srvBookingId.value = srvBookingID;
  }

  Future<void> getCompletedWorksDetailsApi() async {
    try {
      isUserDetailsLoading.value = true;
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      NetworkResponse response = await NetworkCaller().postRequest(
        AppUrl.getCompletedWorksDetails(srvBookingId: srvBookingId.value),
        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.statusCode == 200 && response.isSuccess == true) {
        final responseData =
            ModelOfSvpWorkCompletedDetails.fromJson(response.jsonResponse!);
        LoggerUtils.debug("Completed Work Details : $responseData");
        if (response.jsonResponse!.isNotEmpty) {
          modelOfSvpWorkCompletedDetails.value = responseData;

          LoggerUtils.debug(
              "Completed Work Details : ${modelOfSvpWorkCompletedDetails.value}");
        } else {
          LoggerUtils.error("Failed To Load Data of Completed Work Details!");
        }
      } else {
        errorMessage.value = 'Network error: ${response.errorMessage}';
        LoggerUtils.debug('Network error: ${response.errorMessage}');
      }
    } catch (e) {
      isUserDetailsLoading.value = false;
      errorMessage.value = 'Exception: $e';
      isUserDetailsLoading.value = false;
      LoggerUtils.debug('Exception in getServiceProviderHomeData: $e');
      LoggerUtils.debug('Check Imtiaz Bhai issue');
      LoggerUtils.debug('Exception in getServiceProviderHomeData: $e');
    } finally {
      isUserDetailsLoading.value = false; // Changed to match error
    }
  }

  ServiceBooking? get serviceBooking =>
      modelOfSvpWorkCompletedDetails.value?.data.attributes.serviceBooking;
  String get workAddress => serviceBooking?.address.en ?? "Address not found!";
  String get bookingOrderDate =>
      serviceBooking?.bookingDateTime.toIso8601String() ??
      'Booking date time not found!';
  String get workCompletationDate =>
      serviceBooking?.completionDate?.toIso8601String() ??
      'Work completation date not found!';
  String get workDuration =>
      serviceBooking?.duration ?? 'Work duration not found';
  String get workInitialCost =>
      serviceBooking?.startPrice.toString() ?? 'Initial cost not found!';
  String get workTotalPayment =>
      serviceBooking?.totalCost.toString() ?? 'Total paid cost not found!';
  String get userProfileImage =>
      serviceBooking?.providerId.profileImage.imageUrl ??
      Assets.images.errorImage.path;
  String get userName =>
      serviceBooking?.providerId.name ?? 'User name not found!';
  double get ratingsGivenByUser =>
      modelOfSvpWorkCompletedDetails.value?.data.attributes.review ?? 0;
}

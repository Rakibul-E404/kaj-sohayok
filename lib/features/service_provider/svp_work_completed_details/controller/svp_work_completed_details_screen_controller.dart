import 'package:get/get.dart';
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

  // String get address =>modelOfSvpWorkCompletedDetails.value.data.attributes
}

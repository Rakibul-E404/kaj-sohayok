import 'dart:developer';
import 'package:get/get.dart';
import 'package:kaz_bd/service/network_caller.dart';
import 'package:kaz_bd/service/network_response.dart';
import 'package:kaz_bd/service/secured_storage.dart';
import 'package:kaz_bd/utilities/app_constants.dart';
import 'package:kaz_bd/utilities/app_url.dart';
import 'package:kaz_bd/models/user_payment_history_details_model.dart';

class WorkCompletedDetailsController extends GetxController {
  final Rx<UserPaymentHistoryDetailsModel?> paymentDetails = Rx<UserPaymentHistoryDetailsModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString bookingId = ''.obs;

  Future<void> fetchWorkCompletedDetails(String bookingId) async {
    try {
      this.bookingId.value = bookingId;
      isLoading.value = true;
      errorMessage.value = '';

      log('🚀 [WORK COMPLETED DETAILS CONTROLLER] Fetching details for booking: $bookingId');

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        errorMessage.value = 'Authentication token not found. Please login again.';
        isLoading.value = false;
        return;
      }

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final url = AppUrl.workCompletedDetailsApi(bookingId);
      log('🌐 [WORK COMPLETED DETAILS CONTROLLER] API URL: $url');

      NetworkResponse response = await NetworkCaller().getRequest(
        url,
        headers: headers,
      );

      log('📥 [WORK COMPLETED DETAILS CONTROLLER] Status Code: ${response.statusCode}');
      log('📊 [WORK COMPLETED DETAILS CONTROLLER] Full Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final json = response.jsonResponse!;
        final statusCode = json['code'] ?? 0;

        if (statusCode == 200) {
          log('✅ [WORK COMPLETED DETAILS CONTROLLER] API call successful');

          // Extract data from the nested structure
          final data = json['data']['attributes'];

          // Create the model using fromMap
          final details = UserPaymentHistoryDetailsModel.fromMap(data);

          paymentDetails.value = details;
          log('✅ [WORK COMPLETED DETAILS CONTROLLER] Data parsed successfully');
          log('📊 [WORK COMPLETED DETAILS CONTROLLER] Booking ID: ${details.bookingId}');
          log('📊 [WORK COMPLETED DETAILS CONTROLLER] Service Provider ID: ${details.serviceProviderID}');

        } else {
          String apiMessage = json['message'] ?? 'Failed to load details';
          errorMessage.value = apiMessage;
          log('❌ [WORK COMPLETED DETAILS CONTROLLER] API returned error: $apiMessage');
        }
      } else {
        String error = response.errorMessage ?? 'Something went wrong';
        errorMessage.value = error;
        log('❌ [WORK COMPLETED DETAILS CONTROLLER] Network error: $error');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Connection error: Please check your internet connection';
      log('❌ [WORK COMPLETED DETAILS CONTROLLER] Exception: $e');
      log('❌ [WORK COMPLETED DETAILS CONTROLLER] Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
      log('🏁 [WORK COMPLETED DETAILS CONTROLLER] Loading completed');
    }
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    log('📥 [WORK COMPLETED DETAILS CONTROLLER] Received arguments: $args');
    log('📥 [WORK COMPLETED DETAILS CONTROLLER] Arguments type: ${args.runtimeType}');

    if (args is String && args.isNotEmpty) {
      fetchWorkCompletedDetails(args);
    } else {
      errorMessage.value = 'Invalid or missing booking ID';
      isLoading.value = false;
      log('❌ [WORK COMPLETED DETAILS CONTROLLER] Invalid arguments: $args');
    }
  }

  void retry() {
    if (bookingId.value.isNotEmpty) {
      fetchWorkCompletedDetails(bookingId.value);
    }
  }
}



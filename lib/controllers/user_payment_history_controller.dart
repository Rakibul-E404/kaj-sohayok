import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_payment_history_details_model.dart';
import '../models/user_payment_history_model.dart';
import '../routes/routes.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';

class UserPaymentHistoryController extends GetxController {
  final RxBool loader = false.obs;

  final RxList<UserPaymentHistoryModel> userPaymentHistories =
      <UserPaymentHistoryModel>[].obs;
  final Rxn<UserPaymentHistoryDetailsModel> userPaymentHistoryDetails =
  Rxn<UserPaymentHistoryDetailsModel>();

  Future<void> fetchPaymentHistory() async {
    try {
      loader.value = true;
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';
      final NetworkResponse getResponse = await NetworkCaller().getRequest(
        AppUrl.userPaymentHistory,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );
      if (getResponse.isSuccess) {
        userPaymentHistories.clear();
        List<dynamic> resultsList =
        getResponse.jsonResponse?['data']['attributes']['results'];
        final List<dynamic> paymentHistoryList = resultsList
            .map((dynamic baby) => UserPaymentHistoryModel.fromMap(baby))
            .toList();

        for (final UserPaymentHistoryModel userPaymentHistory
        in paymentHistoryList) {
          userPaymentHistories.add(userPaymentHistory);
        }

        LoggerUtils.debug(
          "${AppUrl.imageBaseUrl}${userPaymentHistories[0].providerId?.profileImage?.imageUrl} ",
        );
      } else {
        Get.snackbar(
          'Failed',
          getResponse.jsonResponse?['message'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      LoggerUtils.debug("Exception : ${e.toString()}");
    } finally {
      loader.value = false;
    }
  }

  Future<void> fetchPaymentHistoryDetails({required String id}) async {
    try {
      loader.value = true;
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';
      final NetworkResponse getResponse = await NetworkCaller().getRequest(
        AppUrl.userPaymentHistoryDetails(id: id),
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );
      if (getResponse.isSuccess) {
        final paymentHistoryResponse =
        getResponse.jsonResponse?['data']['attributes'];
        final UserPaymentHistoryDetailsModel userPaymentHistoryDetails =
        UserPaymentHistoryDetailsModel.fromMap(paymentHistoryResponse);

        LoggerUtils.debug("Payment History Details Fetched:");
        LoggerUtils.debug("  Booking ID: ${userPaymentHistoryDetails.bookingId}");
        LoggerUtils.debug("  Service Provider ID: ${userPaymentHistoryDetails.serviceProviderID}");
        LoggerUtils.debug("  Provider ID: ${userPaymentHistoryDetails.providerID}");

        // ✅ FIXED: Navigate with proper Map structure
        Get.toNamed(
          Routes.workCompletedDetailsScreen,
          arguments: {
            'bookingId': userPaymentHistoryDetails.bookingId,
            'serviceProviderID': userPaymentHistoryDetails.serviceProviderID,
            'providerID': userPaymentHistoryDetails.providerID,
            'paymentHistoryDetails': userPaymentHistoryDetails, // Include full model
          },
        );
      } else {
        Get.snackbar(
          'Failed',
          getResponse.jsonResponse?['message'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      LoggerUtils.debug("Exception : ${e.toString()}");
    } finally {
      loader.value = false;
    }
  }

  @override
  void onInit() {
    fetchPaymentHistory();
    super.onInit();
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../gen/colors.gen.dart';
import '../models/service_wallet_transaction_model.dart';
import '../routes/routes.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';

class SvpWalletController extends GetxController {
  final RxBool loader = false.obs;
  final RxList<ServiceWalletTransactionModel> serviceWalletTransactions =
      <ServiceWalletTransactionModel>[].obs;
  final Rxn<ServiceWalletAccount> serviceWalletAccount =
  Rxn<ServiceWalletAccount>();

  // Withdrawal method selection
  final RxString withdrawalMethod = 'bank'.obs; // 'bank' or 'mobile'

  // Bank fields
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountTypeController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController bankBranchController = TextEditingController();
  final TextEditingController accountHolderNameController =
  TextEditingController();
  final TextEditingController bankAccountHolderNameController =
  TextEditingController();
  final TextEditingController bankRoutingNumberController =
  TextEditingController();

  // Mobile banking fields
  final TextEditingController mobileTypeController = TextEditingController(); // bkash, nagad, rocket
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController mobileAccountTypeController = TextEditingController(); // personal, merchant

  final formKey = GlobalKey<FormState>();

  Future<void> fetchProviderWallet() async {
    try {
      loader.value = true;
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';
      final NetworkResponse getResponse = await NetworkCaller().getRequest(
        AppUrl.getProviderTransactionDetails,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );
      if (getResponse.isSuccess) {
        List<dynamic> resultsList = getResponse
            .jsonResponse?['data']['attributes']['result']['results'];

        final List<dynamic> walletTransactionList = resultsList
            .map((dynamic baby) => ServiceWalletTransactionModel.fromMap(baby))
            .toList();

        serviceWalletTransactions.clear();
        for (final ServiceWalletTransactionModel transaction
        in walletTransactionList) {
          serviceWalletTransactions.add(transaction);
        }
        serviceWalletAccount.value = ServiceWalletAccount.fromJson(
          getResponse.jsonResponse?['data']['attributes']['wallet'],
        );
        LoggerUtils.debug(
          getResponse.jsonResponse?['data']['attributes']['wallet'],
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

  Future<void> handleWithdraw() async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }
      loader.value = true;
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      Map<String, dynamic> loginForm = <String, dynamic>{
        "requestedAmount": int.parse(amountController.text),
      };

      // Add fields based on withdrawal method
      if (withdrawalMethod.value == 'bank') {
        loginForm.addAll({
          "type": "bank",
          "bankAccountNumber": accountNumberController.text.trim(),
          "bankRoutingNumber": bankRoutingNumberController.text.trim(),
          "bankAccountHolderName": accountHolderNameController.text.trim(),
          "bankAccountType": accountTypeController.text.trim(),
          "bankBranch": bankBranchController.text.trim(),
          "bankName": bankNameController.text.trim(),
        });
      } else {
        // Mobile banking
        loginForm.addAll({
          "type": mobileTypeController.text.trim(), // bkash, nagad, rocket
          "mobileNo": mobileNoController.text.trim(),
          "accountType": mobileAccountTypeController.text.trim(), // personal, merchant
        });
      }

      LoggerUtils.debug(loginForm);
      final NetworkResponse postResponse = await NetworkCaller().postRequest(
        AppUrl.serviceProviderWithdrawalRequest,
        body: loginForm,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (postResponse.isSuccess) {
        LoggerUtils.debug(postResponse.jsonResponse);

        Get.snackbar(
          'Success',
          postResponse.jsonResponse?['message'],
          backgroundColor: AppColors.c778beb,
          colorText: Colors.white,
        );

        Navigator.pop(Get.context!);
        clearControllers();
      } else {
        LoggerUtils.debug(postResponse.jsonResponse?['message']);

        Get.snackbar(
          'Error',
          postResponse.jsonResponse?['message'],
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      LoggerUtils.debug("Exception : ${e.toString()}");
    } finally {
      loader.value = false;
    }
  }

  void clearControllers() {
    bankNameController.clear();
    accountTypeController.clear();
    accountNumberController.clear();
    amountController.clear();
    bankBranchController.clear();
    accountHolderNameController.clear();
    bankAccountHolderNameController.clear();
    bankRoutingNumberController.clear();
    mobileTypeController.clear();
    mobileNoController.clear();
    mobileAccountTypeController.clear();
    withdrawalMethod.value = 'bank'; // Reset to default
  }
}
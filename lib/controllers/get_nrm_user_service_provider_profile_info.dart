import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:kaz_bd/service/network_caller.dart';
import 'package:kaz_bd/service/network_response.dart';
import 'package:kaz_bd/utilities/app_url.dart';

import '../features/normal_user/details/model/get_service_provider_profile_info.dart';
import '../gen/colors.gen.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';

class GetNrmUserServiceProviderProfileInfoController extends GetxController {
  RxBool isLoading = false.obs;
  var serviceProviderId = ''.obs;

  // Change from RxList to Rx and store the single profile object
  // Rx<GetServiceProviderProfileDetailsModel?> getServiceProviderProfileInfo =
  //     Rx<GetServiceProviderProfileDetailsModel?>(null);

  // Alternative: If you want to store just the attributes
  Rx<Attributes?> serviceProviderAttributes = Rx<Attributes?>(null);

  void setServiceProviderId({required String svpId}) {
    log('🔧 setServiceProviderId called From Service Provider Profile Screen');
    log('   Previous ID: ${serviceProviderId.value}');
    log('   New ID: $svpId');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    serviceProviderId.value = svpId;
  }

  Future<void> getServiceProviderProfileInfoData() async {
    // Check if categoryId is available
    if (serviceProviderId.value.isEmpty) {
      log('Service provider id is empty');
      Get.snackbar(
        'Error',
        'Service Provider ID is missing',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Get the authorization token
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      // Clear previous data
      // getServiceProviderProfileInfo.value = null;
      serviceProviderAttributes.value = null;

      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.getNrmUserServiceProviderProfileDetailsInfo(
          svpId: serviceProviderId.value,
        ),
        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final serviceProviderProfileInfoModel =
            GetServiceProviderProfileDetailsModel.fromJson(
          response.jsonResponse!,
        );

        // Store the complete model
        // getServiceProviderProfileInfo.value = serviceProviderProfileInfoModel;

        // Also store just the attributes for easier access
        if (serviceProviderProfileInfoModel.data?.attributes != null) {
          serviceProviderAttributes.value =
              serviceProviderProfileInfoModel.data!.attributes;
        }
      } else {
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to load profile data',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Exception occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper getters for easy access to common properties
  String get serviceNameEn =>
      serviceProviderAttributes.value?.serviceName?.en ?? 'N/A';

  String get serviceNameBn =>
      serviceProviderAttributes.value?.serviceName?.bn ?? 'N/A';

  String get providerName => serviceProviderAttributes.value?.name ?? 'N/A';

  int get startPrice => serviceProviderAttributes.value?.startPrice ?? 0;

  double get rating =>
      (serviceProviderAttributes.value?.rating ?? 0).toDouble();

  String get profileImageUrl =>
      serviceProviderAttributes.value?.profileImage?.imageUrl ?? '';

  String get phoneNumber =>
      serviceProviderAttributes.value?.phoneNumber ?? 'N/A';

  String get descriptionEn =>
      serviceProviderAttributes.value?.description?.en ??
      'No description available';

  String get introBioEn =>
      serviceProviderAttributes.value?.introOrBio?.en ?? 'No bio available';

  int get yearsOfExperience =>
      serviceProviderAttributes.value?.yearsOfExperience ?? 0;

  String get locationEn =>
      serviceProviderAttributes.value?.location?.en ?? 'N/A';

  String get gender => serviceProviderAttributes.value?.gender ?? 'N/A';

  String get dateOfBirthShort {
    final dob = serviceProviderAttributes.value?.dob;
    if (dob != null) {
      try {
        // Format: "10/03/2025"
        return "${dob.month.toString().padLeft(2, '0')}/${dob.day.toString().padLeft(2, '0')}/${dob.year}";
      } catch (e) {
        return 'N/A';
      }
    }
    return 'N/A';
  }

  // Clear data when needed
  void clearData() {
    // getServiceProviderProfileInfo.value = null;
    serviceProviderAttributes.value = null;
    serviceProviderId.value = '';
  }
}

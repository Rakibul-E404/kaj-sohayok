import 'dart:developer';

import 'package:get/get.dart';
import 'package:kaz_bd/service/network_caller.dart';
import 'package:kaz_bd/service/network_response.dart';
import 'package:kaz_bd/utilities/app_url.dart';

import '../features/normal_user/details/model/get_specific_service_model.dart';
import '../gen/colors.gen.dart';

class DetailsScreenController extends GetxController {
  RxBool isLoading = false.obs;

  // Rx variables to store the service details
  Rx<Result?> serviceDetails = Rx<Result?>(null);
  RxList<Review> serviceReviews = <Review>[].obs;
  RxList<FullResult> ratingSummary = <FullResult>[].obs;

  ////Service Provider ID
  var serviceProviderId = ''.obs;
  void setServiceProviderId({required String svpId}) {
    serviceProviderId.value = svpId;
    showSpecificServiceDetails();
  }

  // Reactive variable to track the selected tab index
  var tabIndex = 0.obs;

  // Change the tab index
  void changeTab(int index) {
    tabIndex.value = index;
  }

  Future<void> showSpecificServiceDetails() async {
    if (serviceProviderId.isNotEmpty) {
      log('Service provider id $serviceProviderId');
      Get.snackbar(
        'Error',
        'Failed to get details of the service',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
      return;
    }

    try {
      isLoading.value = true;
      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.getSpecificServiceDetails(svpId: serviceProviderId.value),
      );

      if (response.isSuccess) {
        GetSpecificServiceDetailsModel responseModel =
            GetSpecificServiceDetailsModel.fromJson(response.jsonResponse!);

        if (responseModel.data?.attributes != null) {
          // Store the main service details
          serviceDetails.value = responseModel.data!.attributes!.result;

          // Store reviews list
          if (responseModel.data!.attributes!.reviews != null) {
            serviceReviews.assignAll(responseModel.data!.attributes!.reviews!);
          }

          // Store rating summary
          if (responseModel.data!.attributes!.fullResult != null) {
            ratingSummary.assignAll(
              responseModel.data!.attributes!.fullResult!,
            );
          }

          // Print for debugging
          log(
            'Service Details Loaded: ${serviceDetails.value?.serviceName?.en}',
          );
          log('Reviews Count: ${serviceReviews.length}');
          log('Rating Summary Count: ${ratingSummary.length}');
        } else {
          Get.snackbar(
            'Info',
            'No service details found',
            backgroundColor: AppColors.cffb701,
            colorText: AppColors.cFFFFFF,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load service details: ${response.errorMessage}',
          backgroundColor: AppColors.cee3333,
          colorText: AppColors.cFFFFFF,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods to access service details easily
  String get serviceName =>
      serviceDetails.value?.serviceName?.en ?? 'Unknown Service';
  String get serviceDescription =>
      serviceDetails.value?.description?.en ?? 'No description available';
  String get serviceBio =>
      serviceDetails.value?.introOrBio?.en ?? 'No bio available';
  int get serviceRating => serviceDetails.value?.rating ?? 0;
  int get startPrice => serviceDetails.value?.startPrice ?? 0;
  int get yearsOfExperience => serviceDetails.value?.yearsOfExperience ?? 0;
  String? get providerName => serviceDetails.value?.providerId?.name;
  String? get providerProfileImage =>
      serviceDetails.value?.providerId?.profileImage?.imageUrl;

  // Get gallery images
  List<AttachmentsForGallery> get galleryImages =>
      serviceDetails.value?.attachmentsForGallery ?? [];

  // Get cover photos
  List<dynamic> get coverPhotos =>
      serviceDetails.value?.attachmentsForCoverPhoto ?? [];

  // Clear all data when needed
  void clearData() {
    serviceDetails.value = null;
    serviceReviews.clear();
    ratingSummary.clear();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/service/network_caller.dart';
import 'package:kaz_bd/service/network_response.dart';
import 'package:kaz_bd/utilities/app_url.dart';

import '../features/normal_user/see_all_popular_provider/model/see_all_popular_providers_model.dart';

class NormalUserSeeAllPopularProvidersController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Provider> providers = <Provider>[].obs;

  Future<void> getAllPopularProviders() async {
    try {
      isLoading.value = true;

      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.getAllPopularProviders,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        // Parse the complete response model
        final modelData = SeeAllPopularProvidersModel.fromJson(
          response.jsonResponse!,
        );

        // Access the providers list through the correct path
        if (modelData.data?.attributes?.providers != null) {
          providers.value = modelData.data!.attributes!.providers!;
        } else {
          providers.clear();
          Get.snackbar(
            'Info',
            'No popular providers available',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to load popular providers',
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

  // Getter for service image at specific index
  String getServiceImage(int index) {
    if (index >= 0 && index < providers.length) {
      final provider = providers[index];
      if (provider.attachmentsForGallery != null &&
          provider.attachmentsForGallery!.isNotEmpty) {
        return provider.attachmentsForGallery!.first.attachment ?? '';
      }
    }
    return '';
  }

  // Getter for service title at specific index
  String getServiceTitle(int index) {
    if (index >= 0 && index < providers.length) {
      final provider = providers[index];
      return provider.serviceName?.en ?? 'N/A';
    }
    return 'N/A';
  }

  // Getter for initial price at specific index
  int getInitialPrice(int index) {
    if (index >= 0 && index < providers.length) {
      final provider = providers[index];
      return provider.startPrice ?? 0;
    }
    return 0;
  }

  // Getter for rating at specific index
  double getRating(int index) {
    if (index >= 0 && index < providers.length) {
      final provider = providers[index];
      return (provider.rating ?? 0).toDouble();
    }
    return 0.0;
  }

  // Getter for provider ID at specific index
  String getProviderId(int index) {
    if (index >= 0 && index < providers.length) {
      final provider = providers[index];
      return provider.serviceProviderId ?? provider.providerId ?? '';
    }
    return '';
  }

  // Getter for service description at specific index
  String getServiceDescription(int index) {
    if (index >= 0 && index < providers.length) {
      final provider = providers[index];
      return provider.description?.en ?? 'No description available';
    }
    return 'No description available';
  }

  // Getter for years of experience at specific index
  int getYearsOfExperience(int index) {
    if (index >= 0 && index < providers.length) {
      final provider = providers[index];
      return provider.yearsOfExperience ?? 0;
    }
    return 0;
  }

  // Get all gallery images for a provider
  List<String> getGalleryImages(int index) {
    if (index >= 0 && index < providers.length) {
      final provider = providers[index];
      if (provider.attachmentsForGallery != null) {
        return provider.attachmentsForGallery!
            .map((attachment) => attachment.attachment ?? '')
            .where((url) => url.isNotEmpty)
            .toList();
      }
    }
    return [];
  }
}

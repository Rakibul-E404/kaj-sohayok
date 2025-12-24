import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/features/normal_user/services_of_specific_category/model/services_of_specific_category.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/service/network_caller.dart';
import 'package:kaz_bd/service/network_response.dart';
import 'package:kaz_bd/utilities/app_url.dart';
import 'package:kaz_bd/utilities/logger_util.dart';

class ServiceOfSpecificCategoryScreenController extends GetxController {
  // var currentPage = 0.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs; // For loading more indicator
  RxBool hasMoreData = true.obs; // Track if there's more data to load
  RxList<Result> specificCategoryList =
      <Result>[].obs; // Changed to Result type
  var categoryId = ''.obs; // Add this to store categoryId
  var categoryName = ''.obs; // Add this to store categoryName
  var pageId = '1'.obs; // Add pagination
  var searchQuery = ''.obs; // Add search query variable
  String latitudeValue = '';
  String longiTudeValue = '';

  final PageController pageController = PageController();

  // void onPageChanged(int index) {
  //   currentPage.value = index;
  // }

  void disposeController() {
    pageController.dispose();
  }

  // Method to set category data and fetch services
  void setCategoryData(
      {required String id,
      required String name,
      required latValue,
      required longValue}) {
    LoggerUtils.info(
        'setCategoryData called with ID: $id, Name: $name, Lat: $latValue, Long: $longValue');
    categoryId.value = id;
    categoryName.value = name;
    latitudeValue = latValue;
    longiTudeValue = longValue;

    handleServiceFromSpecificCategory();
  }

  Future<void> handleServiceFromSpecificCategory(
      {String? searchQuery, bool isLoadMore = false}) async {
    // Check if categoryId is available
    if (categoryId.value.isEmpty) {
      LoggerUtils.error('Category ID is missing');
      Get.snackbar(
        'error'.tr,
        'category_id_is_missing'.tr,
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
      return;
    }

    LoggerUtils.info('Starting API call for category: ${categoryId.value}');
    LoggerUtils.info('Latitude: $latitudeValue, Longitude: $longiTudeValue');
    LoggerUtils.info('Page ID: ${pageId.value}');

    // Update search query if provided
    if (searchQuery != null) {
      this.searchQuery.value = searchQuery;
      LoggerUtils.info('Search query: ${this.searchQuery.value}');
    }

    try {
      // Set the appropriate loading indicator
      if (!isLoadMore) {
        isLoading.value = true;
        LoggerUtils.info('Setting initial loading state to true');
      } else {
        isLoadingMore.value = true;
        LoggerUtils.info('Setting loading more state to true');
      }

      final String apiUrl = AppUrl.getSpecificServiceByCategory(
        categoryId: categoryId.value,
        latValue: latitudeValue,
        longValue: longiTudeValue,
        pageId: pageId.value,
        serviceName:
            this.searchQuery.value.isNotEmpty ? this.searchQuery.value : null,
      );

      LoggerUtils.info('API URL: $apiUrl');

      final NetworkResponse response = await NetworkCaller().getRequest(apiUrl);

      LoggerUtils.info('API Response Status: ${response.statusCode}');
      LoggerUtils.info('API Response Success: ${response.isSuccess}');
      LoggerUtils.info('API Response Error: ${response.errorMessage ?? 'No error'}');

      if (response.isSuccess) {
        // Parse the response
        final ServicesOfSpecificCategory responseModel =
            ServicesOfSpecificCategory.fromJson(response.jsonResponse!);

        LoggerUtils.info('Response parsed successfully');
        LoggerUtils.info('Response code: ${responseModel.code}');
        LoggerUtils.info('Response message: ${responseModel.message}');
        LoggerUtils.info('Response success: ${responseModel.success}');

        if (responseModel.data?.attributes?.results != null) {
          LoggerUtils.info(
              'Number of results: ${responseModel.data!.attributes!.results!.length}');

          if (!isLoadMore) {
            // Clear the list and assign new data for initial load
            specificCategoryList.assignAll(
              responseModel.data!.attributes!.results!,
            );
            LoggerUtils.info(
                'Assigned ${responseModel.data!.attributes!.results!.length} items to the list');
          } else {
            // Append new data for load more
            specificCategoryList.addAll(
              responseModel.data!.attributes!.results!,
            );
            LoggerUtils.info(
                'Added ${responseModel.data!.attributes!.results!.length} items to the existing list. Total: ${specificCategoryList.length}');
          }

          // Check if there are more pages available
          int currentPage = int.tryParse(pageId.value) ?? 1;
          int totalPages = responseModel.data?.attributes?.totalPages ?? 1;
          hasMoreData.value = currentPage < totalPages;
          LoggerUtils.info(
              'Current page: $currentPage, Total pages: $totalPages, Has more data: ${hasMoreData.value}');
        } else {
          LoggerUtils.info('No results in response');
          if (!isLoadMore) {
            specificCategoryList.clear();
            Get.snackbar(
              'info'.tr,
              'no_services_for_specific_category'.tr,
              backgroundColor: AppColors.cffb701,
              colorText: AppColors.cFFFFFF,
            );
          }
        }
      } else {
        LoggerUtils.error('API call failed: ${response.errorMessage ?? 'Unknown error'}');
        Get.snackbar(
          'error'.tr,
          '${'failed_to_load_services'.tr}: ${response.errorMessage ?? 'Unknown error'}',
          backgroundColor: AppColors.cee3333,
          colorText: AppColors.cFFFFFF,
        );
      }
    } catch (e) {
      LoggerUtils.error('Exception occurred: $e');
      Get.snackbar(
        'error'.tr,
        '${'somthing_went_wrong'.tr}: $e',
        backgroundColor: AppColors.cee3333,
        colorText: AppColors.cFFFFFF,
      );
    } finally {
      if (!isLoadMore) {
        isLoading.value = false;
        LoggerUtils.info('Setting initial loading state to false');
      } else {
        isLoadingMore.value = false;
        LoggerUtils.info('Setting loading more state to false');
      }
    }
  }

  // Method to perform search
  Future<void> performSearch(String query) async {
    searchQuery.value = query;
    pageId.value = '1'; // Reset to first page when searching
    await handleServiceFromSpecificCategory(searchQuery: query);
  }

  // Method to load more data for pagination
  Future<void> loadMoreServices() async {
    if (!hasMoreData.value || isLoadingMore.value)
      return; // Prevent multiple calls when loading or no more data

    pageId.value = (int.parse(pageId.value) + 1).toString();
    await handleServiceFromSpecificCategory(isLoadMore: true);
  }

  @override
  void onClose() {
    disposeController();
    super.onClose();
  }

  // ============== HELPER GETTERS ==============

  // 1. Get service name (Title)
  String getServiceName(Result service) {
    return service.serviceName?.en ?? service.serviceName?.bn ?? 'service'.tr;
  }

  // 2. Get service name in English
  String getServiceNameEn(Result service) {
    return service.serviceName?.en ?? 'service'.tr;
  }

  // 3. Get service name in Bangla
  String getServiceNameBn(Result service) {
    return service.serviceName?.bn ?? 'service'.tr;
  }

  // 4. Get provider name
  String getProviderName(Result service) {
    return service.providerName ?? 'provider'.tr;
  }

  // 5. Get service image (CoverImage)
  String getServiceImage(Result service) {
    LoggerUtils.debug('Getting service image for service: ${service.id}');

    // First check attachmentsForGallery
    if (service.attachmentsForGallery != null &&
        service.attachmentsForGallery!.isNotEmpty) {
      final firstAttachment = service.attachmentsForGallery![0];
      LoggerUtils.debug('Found attachmentsForGallery: $firstAttachment');

      // Check if it's a String URL
      if (firstAttachment is String && firstAttachment.isNotEmpty) {
        LoggerUtils.debug('Attachment is a string URL: $firstAttachment');
        String imageUrl = _ensureFullImageUrl(firstAttachment);
        LoggerUtils.debug('Processed image URL: $imageUrl');
        return imageUrl;
      }

      // Check if it's a Map with imageUrl/attachment field
      if (firstAttachment is Map<String, dynamic>) {
        final imageUrl = firstAttachment['imageUrl']?.toString() ??
            firstAttachment['attachment']?.toString();
        if (imageUrl != null && imageUrl.isNotEmpty) {
          LoggerUtils.debug('Attachment from map: $imageUrl');
          String processedUrl = _ensureFullImageUrl(imageUrl);
          LoggerUtils.debug('Processed image URL: $processedUrl');
          return processedUrl;
        }
      }
    } else {
      LoggerUtils.debug(
          'No attachmentsForGallery found, checking profile image');
    }

    // Fallback to profile image
    if (service.profileImage?.imageUrl != null &&
        service.profileImage!.imageUrl!.isNotEmpty) {
      LoggerUtils.debug(
          'Using profile image: ${service.profileImage!.imageUrl!}');
      String imageUrl = _ensureFullImageUrl(service.profileImage!.imageUrl!);
      LoggerUtils.debug('Processed profile image URL: $imageUrl');
      return imageUrl;
    } else {
      LoggerUtils.debug('No profile image found');
    }

    // Return empty string
    LoggerUtils.debug('Returning empty string for service image');
    return '';
  }

  // 6. Check if service has cover image
  bool hasServiceImage(Result service) {
    return getServiceImage(service).isNotEmpty;
  }

  // 7. Get provider profile image
  String getProviderImage(Result service) {
    final imageUrl = service.profileImage?.imageUrl ?? '';
    return imageUrl.isNotEmpty ? _ensureFullImageUrl(imageUrl) : '';
  }

  // Helper method to ensure image URLs are absolute
  String _ensureFullImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    } else if (imageUrl.startsWith('/')) {
      // Add the base URL for relative paths
      String fullUrl = 'https://newsheakh6737.sobhoy.com$imageUrl';
      LoggerUtils.debug(
          'Converted relative URL to absolute: $imageUrl -> $fullUrl');
      return fullUrl;
    }
    return imageUrl;
  }

  // 8. Get start price as double
  double getServicePrice(Result service) {
    return (service.startPrice ?? 0).toDouble();
  }

  // 9. Get start price as integer
  int getServicePriceInt(Result service) {
    return service.startPrice ?? 0;
  }

  // 10. Get rating as double
  double getServiceRating(Result service) {
    return (service.rating ?? 0).toDouble();
  }

  // 11. Get rating as integer
  int getServiceRatingInt(Result service) {
    return service.rating ?? 0;
  }

  // 12. Get formatted price with currency
  String getFormattedPrice(Result service) {
    final price = service.startPrice ?? 0;
    return '৳$price';
  }

  // 13. Get years of experience
  String getExperience(Result service) {
    final years = service.yearsOfExperience ?? 0;
    return years > 0 ? '$years ${'years_experience'.tr}' : 'Fresh';
  }

  // 14. Get service description (intro/bio)
  String getServiceDescription(Result service) {
    final introOrBio = service.introOrBio;
    if (introOrBio?.en != null && introOrBio!.en!.isNotEmpty) {
      return introOrBio.en!;
    } else if (introOrBio?.bn != null && introOrBio!.bn!.isNotEmpty) {
      return introOrBio.bn!;
    }

    return '';
  }

  // 15. Get full description
  String getFullDescription(Result service) {
    final description = service.description;
    if (description?.en != null && description!.en!.isNotEmpty) {
      return description.en!;
    } else if (description?.bn != null && description!.bn!.isNotEmpty) {
      return description.bn!;
    }

    return getServiceDescription(service);
  }

  // 16. Get service ID
  String getServiceId(Result service) {
    return service.id ?? '';
  }

  // 17. Get provider ID
  String getProviderId(Result service) {
    return service.providerId ?? '';
  }

  // 18. Get location ID
  String getLocationId(Result service) {
    return service.locationId ?? '';
  }

  // 19. Get service category ID
  String getServiceCategoryId(Result service) {
    return service.serviceCategoryId ?? '';
  }

  // 20. Get all service details as a map for easy access
  Map<String, dynamic> getServiceDetails(Result service) {
    return {
      'id': service.id,
      'serviceName': getServiceName(service),
      'serviceNameEn': getServiceNameEn(service),
      'serviceNameBn': getServiceNameBn(service),
      'providerName': getProviderName(service),
      'providerId': getProviderId(service),
      'serviceImage': getServiceImage(service),
      'providerImage': getProviderImage(service),
      'price': getServicePrice(service),
      'priceInt': getServicePriceInt(service),
      'formattedPrice': getFormattedPrice(service),
      'rating': getServiceRating(service),
      'ratingInt': getServiceRatingInt(service),
      'experience': getExperience(service),
      'description': getServiceDescription(service),
      'fullDescription': getFullDescription(service),
      'yearsOfExperience': service.yearsOfExperience ?? 0,
      'locationId': getLocationId(service),
      'serviceCategoryId': getServiceCategoryId(service),
      'createdAt': service.createdAt,
      'providerApprovalStatus': service.providerApprovalStatus,
    };
  }

  // 21. Get service by index with safety checks
  Result? getServiceByIndex(int index) {
    if (specificCategoryList.length > index) {
      return specificCategoryList[index];
    }
    return null;
  }

  // 22. Get service details by index
  Map<String, dynamic>? getServiceDetailsByIndex(int index) {
    final service = getServiceByIndex(index);
    if (service != null) {
      return getServiceDetails(service);
    }
    return null;
  }

  // 23. Get all services count
  int get servicesCount => specificCategoryList.length;

  // 24. Check if list is empty
  bool get hasServices => specificCategoryList.isNotEmpty;

  // 25. Get first service image (for backward compatibility)
  String get serviceCoverImageFromGallery {
    if (specificCategoryList.isEmpty) {
      return '';
    }
    return getServiceImage(specificCategoryList[0]);
  }
}

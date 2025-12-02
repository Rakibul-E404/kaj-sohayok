import 'dart:developer';

import 'package:get/get.dart';
import 'package:kaz_bd/service/network_caller.dart';
import 'package:kaz_bd/service/network_response.dart';
import 'package:kaz_bd/utilities/app_url.dart';
import 'package:kaz_bd/utilities/app_constants.dart';
import 'package:kaz_bd/service/secured_storage.dart';
import 'package:kaz_bd/gen/assets.gen.dart';

import '../features/normal_user/details/model/get_specific_service_model.dart';
import '../gen/colors.gen.dart';

class DetailsScreenController extends GetxController {
  RxBool isLoading = false.obs;

  // Rx variables to store the service details
  Rx<Result?> serviceDetails = Rx<Result?>(null);
  RxList<Review> serviceReviews = <Review>[].obs;
  RxList<FullResult> ratingSummary = <FullResult>[].obs;

  // Store raw review data to access full user information
  List<Map<String, dynamic>> _rawReviewsData = [];

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
    if (serviceProviderId.isEmpty) {
      log('Service provider id is empty');
      Get.snackbar(
        'Error',
        'Failed to get details of the service: Provider ID is missing',
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

      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.getSpecificServiceDetails(svpId: serviceProviderId.value),
        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.isSuccess) {
        if (response.jsonResponse != null) {
          // Verify that the response structure is correct before parsing
          if (response.jsonResponse!['data'] != null &&
              response.jsonResponse!['data']['attributes'] != null &&
              response.jsonResponse!['data']['attributes']['result'] != null) {
            // Manually parse the response to avoid the auto-generated model issue
            // Start by extracting the data from the response
            final dataMap =
                response.jsonResponse!['data'] as Map<String, dynamic>;
            final attributesMap = dataMap['attributes'] as Map<String, dynamic>;
            final resultData = attributesMap['result'] as Map<String, dynamic>?;

            if (resultData != null) {
              // Create Result object manually
              final result = _parseResult(resultData);
              serviceDetails.value = result;

              // Parse reviews
              final reviewsList = attributesMap['reviews'] as List<dynamic>?;
              if (reviewsList != null) {
                final parsedReviews = <Review>[];
                _rawReviewsData = []; // Clear previous data
                for (final reviewItem in reviewsList) {
                  if (reviewItem is Map<String, dynamic>) {
                    parsedReviews.add(_parseReview(reviewItem));
                    _rawReviewsData.add(
                      reviewItem,
                    ); // Store raw data to access user info
                  }
                }
                serviceReviews.assignAll(parsedReviews);
              } else {
                serviceReviews.clear();
                _rawReviewsData = [];
              }

              // Parse rating summary (fullResult)
              final fullResultList =
                  attributesMap['fullResult'] as List<dynamic>?;
              if (fullResultList != null) {
                final parsedFullResults = <FullResult>[];
                for (final item in fullResultList) {
                  if (item is Map<String, dynamic>) {
                    parsedFullResults.add(_parseFullResult(item));
                  }
                }
                ratingSummary.assignAll(parsedFullResults);
              } else {
                ratingSummary.clear();
              }
            } else {
              Get.snackbar(
                'Info',
                'No service details found in response',
                backgroundColor: AppColors.cffb701,
                colorText: AppColors.cFFFFFF,
              );
            }
          } else {
            Get.snackbar(
              'Error',
              'Incomplete response structure',
              backgroundColor: AppColors.cee3333,
              colorText: AppColors.cFFFFFF,
            );
          }
        } else {
          Get.snackbar(
            'Error',
            'Invalid response from server',
            backgroundColor: AppColors.cee3333,
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
      log('Exception in showSpecificServiceDetails: $e');
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

  String? get userId => serviceDetails.value?.providerId?.userId;

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
    _rawReviewsData.clear();
  }

  // Helper method to get user profile image from raw review data
  String getUserProfileImage(int index) {
    if (index >= 0 && index < _rawReviewsData.length) {
      final reviewData = _rawReviewsData[index];
      final userIdData = reviewData['userId'] as Map<String, dynamic>?;
      if (userIdData != null) {
        final profileImageData =
            userIdData['profileImage'] as Map<String, dynamic>?;
        if (profileImageData != null) {
          String? imageUrl = profileImageData['imageUrl'] as String?;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            if (!imageUrl.startsWith('http')) {
              imageUrl = '${AppUrl.imageBaseUrl}$imageUrl';
            }
            return imageUrl;
          }
        }
      }
    }
    return Assets.images.userImage.path; // Fallback to default image
  }

  // Helper method to get user name from raw review data
  String getUserName(int index) {
    if (index >= 0 && index < _rawReviewsData.length) {
      final reviewData = _rawReviewsData[index];
      final userIdData = reviewData['userId'] as Map<String, dynamic>?;
      if (userIdData != null) {
        String? name = userIdData['name'] as String?;
        if (name != null && name.isNotEmpty) {
          return name;
        }
      }
    }
    return 'User ${index + 1}'; // Fallback to default name
  }

  // Helper methods for manual parsing to avoid type conversion issues
  Result _parseResult(Map<String, dynamic> data) {
    return Result(
      serviceName: _parseDescription(data['serviceName']),
      introOrBio: _parseDescription(data['introOrBio']),
      description: _parseDescription(data['description']),
      providerId: _parseProviderId(data['providerId']),
      serviceCategoryId: data['serviceCategoryId'] as String?,
      providerApprovalStatus: data['providerApprovalStatus'] as String?,
      startPrice: data['startPrice'] as int?,
      rating: data['rating'] as int?,
      attachmentsForGallery: _parseAttachmentsForGallery(
        data['attachmentsForGallery'],
      ),
      attachmentsForCoverPhoto:
          data['attachmentsForCoverPhoto'] as List<dynamic>?,
      yearsOfExperience: data['yearsOfExperience'] as int?,
      serviceProviderId: data['_ServiceProviderId'] as String?,
    );
  }

  Description? _parseDescription(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      return Description(en: data['en'] as String?, bn: data['bn'] as String?);
    }
    return null;
  }

  ProviderId? _parseProviderId(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      return ProviderId(
        name: data['name'] as String?,
        profileImage: _parseProfileImage(data['profileImage']),
        userId: data['_userId'] as String?,
      );
    }
    return null;
  }

  ProfileImage? _parseProfileImage(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      return ProfileImage(
        imageUrl: data['imageUrl'] as String?,
        id: data['_id'] as String?,
      );
    }
    return null;
  }

  List<AttachmentsForGallery>? _parseAttachmentsForGallery(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      final result = <AttachmentsForGallery>[];
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          result.add(
            AttachmentsForGallery(
              attachment: item['attachment'] as String?,
              attachmentId: item['_attachmentId'] as String?,
            ),
          );
        }
      }
      return result;
    }
    return null;
  }

  Review _parseReview(Map<String, dynamic> data) {
    // Get the full userId object
    final userIdData = data['userId'] as Map<String, dynamic>?;

    return Review(
      review: _parseDescription(data['review']),
      originalLanguage: data['originalLanguage'] as String?,
      rating: data['rating'] as int?,
      userId:
          userIdData?['_userId']
              as String?, // Extract _userId from the nested object for the ID field
      serviceProviderDetailsId: data['serviceProviderDetailsId'] as String?,
      serviceBookingId: data['serviceBookingId'] as String?,
      isDeleted: data['isDeleted'] as bool?,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.tryParse(data['updatedAt'] as String)
          : null,
      v: data['__v'] as int?,
      reviewId: data['_ReviewId'] as String?,
    );
  }

  FullResult _parseFullResult(Map<String, dynamic> data) {
    return FullResult(
      rating: data['rating'] as int?,
      count: data['count'] as int?,
    );
  }
}

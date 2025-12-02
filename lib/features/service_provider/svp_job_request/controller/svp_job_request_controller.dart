import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../../service/network_caller.dart';
import '../../../../../../service/network_response.dart';
import '../../../../../../service/secured_storage.dart';
import '../../../../../../utilities/app_constants.dart';
import '../../../../../../utilities/app_url.dart';

class SvpJobRequestController extends GetxController {
  final RxList<dynamic> jobRequests = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, String> userImageUrls = <String, String>{}.obs;
  final RxMap<String, bool> imageLoadStatus = <String, bool>{}.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  Future<void> getJobRequests({bool loadMore = false, bool forceRefresh = false}) async {
    try {
      if (!loadMore || forceRefresh) {
        isLoading.value = true;
        errorMessage.value = '';
        if (forceRefresh || !loadMore) {
          jobRequests.clear();
          userImageUrls.clear();
          imageLoadStatus.clear();
          currentPage.value = 1;
          hasMoreData.value = true;
        }
        log('🚀 ${forceRefresh ? 'Force refreshing' : loadMore ? 'Loading more' : 'Starting to fetch'} job requests...');
      }

      final token = await SecureStorageService().read(AppConstants.accessToken);
      log('🔑 Token retrieved: ${token != null ? 'Yes' : 'No'}');

      if (token == null) {
        errorMessage.value = 'Authentication token not found. Please login again.';
        isLoading.value = false;
        log('❌ No token found');
        return;
      }

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Construct URL with pagination
      String url = '${AppUrl.jobRequests}?page=${currentPage.value}&limit=10';
      log('📡 Making API call to: $url');

      NetworkResponse response = await NetworkCaller().getRequest(
        url,
        headers: headers,
      );

      log('📊 API Response - Status Code: ${response.statusCode}');
      log('📊 API Response - Is Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;

        // Log the response structure for debugging
        log('📋 Response structure:');
        log('   success: ${jsonResponse['success']}');
        log('   code: ${jsonResponse['code']}');
        log('   message: ${jsonResponse['message']}');
        log('   has data: ${jsonResponse['data'] != null}');

        if (jsonResponse['success'] == true) {
          // Handle the API response structure
          if (jsonResponse['data'] != null) {
            final data = jsonResponse['data'];

            if (data['attributes'] != null) {
              final attributes = data['attributes'];

              // Update pagination info
              if (attributes['totalPages'] != null) {
                totalPages.value = attributes['totalPages'] is int
                    ? attributes['totalPages']
                    : int.tryParse(attributes['totalPages'].toString()) ?? 1;
              }

              if (attributes['page'] != null) {
                currentPage.value = attributes['page'] is int
                    ? attributes['page']
                    : int.tryParse(attributes['page'].toString()) ?? 1;
              }

              // Check if results exist
              if (attributes['results'] != null) {
                List<dynamic> results = attributes['results'];
                log('✅ Found ${results.length} job requests on page ${currentPage.value}');

                if (results.isNotEmpty) {
                  // Add new results
                  jobRequests.addAll(results);

                  // Log first item for debugging
                  final firstItem = results[0];
                  log('📋 First item structure:');
                  log('   ID: ${firstItem['_ServiceBookingId']}');
                  log('   Booking Date: ${firstItem['bookingDateTime']}');
                  log('   Has address: ${firstItem['address'] != null}');
                  log('   Has userId: ${firstItem['userId'] != null}');

                  // Process user images for new results
                  await _processUserImages(results);

                  // Check if there's more data
                  hasMoreData.value = currentPage.value < totalPages.value;
                  log('📄 Pagination: Page ${currentPage.value}/${totalPages.value}, Has more: ${hasMoreData.value}');
                } else {
                  log('ℹ️ Results array is empty on page ${currentPage.value}');
                  if (!loadMore) {
                    errorMessage.value = 'No job requests found';
                  }
                }
              } else {
                if (!loadMore) {
                  errorMessage.value = 'No job requests data available';
                }
                log('❌ No results found in attributes');
              }
            } else {
              if (!loadMore) {
                errorMessage.value = 'Invalid response format';
              }
              log('❌ No attributes in data');
            }
          } else {
            if (!loadMore) {
              errorMessage.value = 'No data received from server';
            }
            log('❌ No data in response');
          }
        } else {
          String apiMessage = jsonResponse['message'] ?? 'Failed to load job requests';
          if (!loadMore) {
            errorMessage.value = apiMessage;
          }
          log('❌ API returned error: $apiMessage');
        }
      } else {
        if (!loadMore) {
          errorMessage.value = response.errorMessage ?? 'Network request failed';
        }
        log('❌ Network error: ${response.errorMessage}');
      }
    } catch (e) {
      if (!loadMore) {
        errorMessage.value = 'Connection error: Please check your internet connection';
      }
      log('❌ Exception in getJobRequests: $e');
      log('❌ Stack trace: ${StackTrace.current}');
    } finally {
      isLoading.value = false;
      log('🏁 Loading completed. Total job requests: ${jobRequests.length}');
    }
  }

  Future<void> loadMoreData() async {
    if (hasMoreData.value && !isLoading.value) {
      currentPage.value++;
      log('⬇️ Loading more data for page ${currentPage.value}');
      await getJobRequests(loadMore: true);
    }
  }

  Future<void> refreshData() async {
    log('🔄 Refreshing data...');
    await getJobRequests(forceRefresh: true);
  }

  Future<void> _processUserImages(List<dynamic> newJobRequests) async {
    log('🖼️ Processing user images for ${newJobRequests.length} new jobs');

    for (final job in newJobRequests) {
      try {
        final jobId = job['_ServiceBookingId']?.toString() ?? 'NO_ID_${DateTime.now().millisecondsSinceEpoch}';
        log('🖼️ Processing image for job: $jobId');

        final userId = job['userId'];

        if (userId != null && userId is Map) {
          final profileImage = userId['profileImage'];

          if (profileImage != null && profileImage is Map) {
            final imageUrl = profileImage['imageUrl']?.toString();

            if (imageUrl != null && imageUrl.isNotEmpty) {
              log('🖼️ Raw image URL found: $imageUrl');

              String fullImageUrl = _constructImageUrl(imageUrl);
              userImageUrls[jobId] = fullImageUrl;

              // Verify image accessibility in background
              _verifyImageAccessibility(jobId, fullImageUrl);

              log('✅ Image URL stored for job $jobId');
            } else {
              userImageUrls[jobId] = '';
              imageLoadStatus[jobId] = false;
              log('ℹ️ No image URL for job $jobId');
            }
          } else {
            userImageUrls[jobId] = '';
            imageLoadStatus[jobId] = false;
            log('ℹ️ No profileImage for job $jobId');
          }
        } else {
          userImageUrls[jobId] = '';
          imageLoadStatus[jobId] = false;
          log('ℹ️ No userId for job $jobId');
        }
      } catch (e) {
        log('❌ Error processing image for job: $e');
      }
    }
  }

  String _constructImageUrl(String imageUrl) {
    log('🔗 Constructing image URL from: $imageUrl');

    // If it's already a full URL, return it as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      log('✅ Already a full URL: $imageUrl');
      return imageUrl;
    }

    // Handle relative URLs
    String cleanImageUrl = imageUrl;

    // Remove leading slash if present to avoid double slashes
    while (cleanImageUrl.startsWith('/')) {
      cleanImageUrl = cleanImageUrl.substring(1);
    }

    // Construct full URL using AppUrl.imageBaseUrl
    String fullUrl = '${AppUrl.imageBaseUrl}/$cleanImageUrl';

    // Remove any double slashes
    fullUrl = fullUrl.replaceAll(RegExp(r'(?<!:)//'), '/');

    log('🔗 Constructed full URL: $fullUrl');

    return fullUrl;
  }

  Future<void> _verifyImageAccessibility(String jobId, String imageUrl) async {
    try {
      log('🔍 Verifying image accessibility for job $jobId: $imageUrl');

      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(Duration(seconds: 10));

      log('🔍 Image verification for job $jobId - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        imageLoadStatus[jobId] = true;
        log('✅ Image accessible for job $jobId');
      } else {
        imageLoadStatus[jobId] = false;
        log('❌ Image not accessible for job $jobId. Status: ${response.statusCode}');
      }
    } catch (e) {
      imageLoadStatus[jobId] = false;
      log('❌ Error verifying image for job $jobId: $e');
    }
  }

  // Helper methods to extract data
  String getUserName(String jobId) {
    try {
      final job = _findJobById(jobId);
      if (job == null) return 'Unknown User';

      final userId = job['userId'];
      if (userId == null || userId is! Map) return 'Unknown User';

      return userId['name']?.toString() ?? 'Unknown User';
    } catch (e) {
      log('❌ Error getting user name: $e');
      return 'Unknown User';
    }
  }

  String getUserLocation(String jobId) {
    try {
      final job = _findJobById(jobId);
      if (job == null) return 'Unknown Location';

      final address = job['address'];
      if (address == null || address is! Map) return 'Unknown Location';

      return address['en']?.toString() ??
          address['bn']?.toString() ??
          'Unknown Location';
    } catch (e) {
      log('❌ Error getting user location: $e');
      return 'Unknown Location';
    }
  }

  String getUserImageUrl(String jobId) {
    return userImageUrls[jobId] ?? '';
  }

  bool hasUserImage(String jobId) {
    return userImageUrls.containsKey(jobId) &&
        userImageUrls[jobId]!.isNotEmpty &&
        (imageLoadStatus[jobId] ?? false);
  }

  String getBookingDateTime(String jobId) {
    try {
      final job = _findJobById(jobId);
      return job?['bookingDateTime']?.toString() ?? '';
    } catch (e) {
      log('❌ Error getting booking date time: $e');
      return '';
    }
  }

  String getUserId(String jobId) {
    try {
      final job = _findJobById(jobId);
      if (job == null) return '';

      final userId = job['userId'];
      if (userId == null || userId is! Map) return '';

      return userId['_userId']?.toString() ?? '';
    } catch (e) {
      log('❌ Error getting user ID: $e');
      return '';
    }
  }

  // Find job by ID
  dynamic _findJobById(String jobId) {
    try {
      return jobRequests.firstWhere(
            (job) => (job['_ServiceBookingId']?.toString() ?? '') == jobId,
        orElse: () => null,
      );
    } catch (e) {
      log('❌ Error finding job by ID $jobId: $e');
      return null;
    }
  }

  // Clear all data
  void clearData() {
    jobRequests.clear();
    userImageUrls.clear();
    imageLoadStatus.clear();
    currentPage.value = 1;
    totalPages.value = 1;
    hasMoreData.value = true;
    errorMessage.value = '';
  }

  @override
  void onInit() {
    log('🎬 SvpJobRequestController initialized');
    getJobRequests();
    super.onInit();
  }

  @override
  void onClose() {
    log('🛑 SvpJobRequestController disposed');
    clearData();
    super.onClose();
  }
}
// lib/.../controller/svp_work_completed_screen_controller.dart

import 'dart:developer';
import 'package:get/get.dart';
import '../../../../constants/app_enums.dart';
import '../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../../../../routes/routes.dart';
import '../../../../service/network_caller.dart';
import '../../../../service/network_response.dart';
import '../../../../service/secured_storage.dart';
import '../../../../utilities/app_constants.dart';
import '../../../../utilities/app_url.dart';
import '../../../../utilities/logger_util.dart';

class SvpWorkCompletedScreenController extends GetxController {
  final completedBookings = <dynamic>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    fetchCompletedBookings();
  }

  Future<void> fetchCompletedBookings() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        hasError.value = true;
        errorMessage.value = 'authentication_required_login_again'.tr;
        isLoading.value = false;
        return;
      }

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.providerCompletedBookings,
        headers: {'Authorization': 'Bearer $token'},
      );

      log('Completed Work Screen API Response: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null &&
            responseData['data']['attributes']['results'] != null) {
          completedBookings.assignAll(List<dynamic>.from(
              responseData['data']['attributes']['results']));
          isLoading.value = false;
        } else {
          hasError.value = true;
          errorMessage.value = 'unexpected_response_format'.tr;
          isLoading.value = false;
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'failed_to_load_complete_work'.tr;

        hasError.value = true;
        errorMessage.value = errorMsg;
        isLoading.value = false;

        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }
      }
    } catch (e, stackTrace) {
      log('Error fetching completed work: $e',
          error: e, stackTrace: stackTrace);
      hasError.value = true;
      errorMessage.value = 'network_error_check_again'.tr;
      isLoading.value = false;
    }
  }

  String getImageUrl(String? imageUrl) {
    final trimmed = (imageUrl ?? '').trim();
    if (trimmed.isEmpty) return '';

    if (trimmed.startsWith('http')) {
      return trimmed;
    }

    final cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    return '${AppUrl.imageBaseUrl}/$cleanPath';
  }

  String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final month = months[dateTime.month - 1];
      final day = dateTime.day;
      final year = dateTime.year;
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour < 12 ? 'AM' : 'PM';
      return '$month $day, $year  ${hour.toString().padLeft(2, '0')}:$minute$period';
    } catch (e) {
      log('Error formatting date: $e');
      return dateTimeString;
    }
  }

  String getAddress(Map<String, dynamic>? address) {
    if (address == null) return 'address_not_available'.tr;
    return address['en'] ?? address['bn'] ?? 'address_not_available'.tr;
  }

  void navigateToCompletedDetails(Map<String, dynamic> booking) {
    final bookingId = booking['_ServiceBookingId'] as String? ?? '';
    final userId =
        (booking['userId'] as Map<String, dynamic>?)?['_userId'] as String? ??
            '';
    log("Navigating to completed work details: $bookingId");
    LoggerUtils.debug(
        "Service Booking ID From Svp Work Completed Tab : $bookingId");

    Get.toNamed(
      Routes.svpWorkCompletedDetailsScreen,
      arguments: {
        "status": JobRequestStatusEnum.completed,
        "bookingId": bookingId,
        "jobRequest": booking,
        "userId": userId,
      },
    );
  }

  RecentJobRequestStatusWidget buildCompletedBookingWidget(int index) {
    final booking = completedBookings[index];
    final userData = booking['userId'] as Map<String, dynamic>? ?? {};
    final address = getAddress(booking['address'] as Map<String, dynamic>?);
    final bookingDateTime = booking['bookingDateTime'] as String? ?? '';
    final userName = userData['name'] as String? ?? 'Unknown User';
    final profileImage = userData['profileImage']?['imageUrl'] as String?;

    return RecentJobRequestStatusWidget(
      isJobStatusCompleted: true,
      onTap: () => navigateToCompletedDetails(booking),
      userImage: getImageUrl(profileImage),
      userName: userName,
      location: address,
      dateTime: formatDateTime(bookingDateTime),
    );
  }
}

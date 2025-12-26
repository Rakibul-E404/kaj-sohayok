/**

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/appList.dart';
import 'package:kaz_bd/constants/app_enums.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/app_constant_text.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../custom_widgets/date_and_time_widget_tile.dart';
import '../../../../custom_widgets/dotted_line_divider_widget.dart';
import '../../../../service/network_caller.dart';
import '../../../../service/network_response.dart';
import '../../../../service/secured_storage.dart';
import '../../../../utilities/app_constants.dart';
import '../../../../utilities/app_url.dart';
import '../../svp_bookings/sub_presentation/svp_accepted_bookings/controller/svp_accepted_bookings_tab_controller.dart';
import '../../svp_bookings/sub_presentation/svp_job_request/controller/svp_job_request_tab_controller.dart';
import '../widgets/user_info_tile_widget.dart';

class SvpJobDetailsScreen extends StatefulWidget {
  const SvpJobDetailsScreen({super.key});

  @override
  State<SvpJobDetailsScreen> createState() => _SvpJobDetailsScreenState();
}

class _SvpJobDetailsScreenState extends State<SvpJobDetailsScreen> {
  late JobRequestStatusEnum? status;
  late String bookingId;
  late Map<String, dynamic> jobRequest;
  late String userId;
  final NetworkCaller _networkCaller = NetworkCaller();
  bool isStartingWork = false;
  bool isWorkStarted = false;
  bool isCancelling = false;
  bool isAccepting = false;

  @override
  void initState() {
    super.initState();

    // Get arguments from navigation
    final arguments = Get.arguments as Map<String, dynamic>?;

    // Setting the accepted arguments initial value
    status = arguments?["status"] as JobRequestStatusEnum?;
    bookingId = arguments?["bookingId"] as String? ?? '';
    jobRequest = arguments?["jobRequest"] as Map<String, dynamic>? ?? {};
    userId = arguments?["userId"] as String? ?? '';

    // Check if work is already started (for accepted jobs)
    isWorkStarted = jobRequest['status'] == 'inProgress' ||
        jobRequest['status'] == 'completed';
  }

  // ====================== CANCEL JOB REQUEST ======================
  Future<void> cancelJobRequest() async {
    if (isCancelling) return;

    setState(() {
      isCancelling = true;
    });

    try {
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication required. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          isCancelling = false;
        });
        return;
      }

      // Make PUT request to cancel job
      final NetworkResponse response = await _networkCaller.putRequest(
        AppUrl.providerJobRequestCancelButton(bookingId),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: {}, // Empty body as requested
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['code'] == 200 || response.isSuccess) {
          // Show success message
          Get.snackbar(
            'Success',
            'Job request cancelled successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Update local state
          setState(() {
            isCancelling = false;
          });

          // Fetch job requests in the tab (if it exists)
          _fetchJobRequestsInTab();

          // Go back to previous screen after cancellation
          Get.back();
        } else {
          final errorMsg = responseData['message'] ?? 'Failed to cancel job request';
          Get.snackbar(
            'Error',
            errorMsg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          setState(() {
            isCancelling = false;
          });
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to cancel job request';

        Get.snackbar(
          'Error',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        // Handle authentication errors
        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }

        setState(() {
          isCancelling = false;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Network Error',
        'Failed to cancel job request. Please check your connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isCancelling = false;
      });
    }
  }

  // ====================== ACCEPT JOB REQUEST ======================
  Future<void> acceptJobRequest() async {
    if (isAccepting) return;

    setState(() {
      isAccepting = true;
    });

    try {
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication required. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          isAccepting = false;
        });
        return;
      }

      // Make PUT request to accept job
      final NetworkResponse response = await _networkCaller.putRequest(
        AppUrl.providerJobRequestAcceptButton(bookingId),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: {}, // Empty body as requested
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['code'] == 200 || response.isSuccess) {
          // Show success message
          Get.snackbar(
            'Success',
            'Job request accepted successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Update local state
          setState(() {
            isAccepting = false;
          });

          // Update the status to accepted
          status = JobRequestStatusEnum.accepted;

          // Fetch job requests in the tab (if it exists)
          _fetchJobRequestsInTab();

          // Also fetch accepted bookings to update that tab
          _fetchAcceptedBookingsInTab();

          // Update the buttons to show "Start Work" instead of "Cancel/Accept"
          setState(() {});
        } else {
          final errorMsg = responseData['message'] ?? 'Failed to accept job request';
          Get.snackbar(
            'Error',
            errorMsg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          setState(() {
            isAccepting = false;
          });
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to accept job request';

        Get.snackbar(
          'Error',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        // Handle authentication errors
        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }

        setState(() {
          isAccepting = false;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Network Error',
        'Failed to accept job request. Please check your connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isAccepting = false;
      });
    }
  }

  // ====================== START WORK ======================
  Future<void> startWork() async {
    if (isStartingWork || isWorkStarted) return;

    setState(() {
      isStartingWork = true;
    });

    try {
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication required. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          isStartingWork = false;
        });
        return;
      }

      // Make PUT request to start work
      final NetworkResponse response = await _networkCaller.putRequest(
        AppUrl.providerStartWorkButton(bookingId),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: {}, // Empty body as requested
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['code'] == 200) {
          // Show success message
          Get.snackbar(
            'Success',
            'Work started successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Update local state
          setState(() {
            isWorkStarted = true;
            isStartingWork = false;
          });

          // Update the jobRequest status
          jobRequest['status'] = 'inProgress';

          // Fetch accepted bookings in the tab (if it exists)
          _fetchAcceptedBookingsInTab();
        } else {
          final errorMsg = responseData['message'] ?? 'Failed to start work';
          Get.snackbar(
            'Error',
            errorMsg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          setState(() {
            isStartingWork = false;
          });
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to start work';

        Get.snackbar(
          'Error',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        // Handle authentication errors
        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }

        setState(() {
          isStartingWork = false;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Network Error',
        'Failed to start work. Please check your connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isStartingWork = false;
      });
    }
  }

  // Method to fetch job requests in the pending tab screen
  void _fetchJobRequestsInTab() {
    try {
      // Get the controller instance if it exists
      final jobRequestsController = Get.find<SvpJobRequestTabController>();
      jobRequestsController.fetchJobRequests();
    } catch (e) {
      // Controller might not be initialized yet, that's okay
      print('Job requests controller not found: $e');
    }
  }

  // Method to fetch accepted bookings in the accepted tab screen
  void _fetchAcceptedBookingsInTab() {
    try {
      // Get the controller instance if it exists
      final acceptedBookingsController = Get.find<SvpAcceptedBookingsController>();
      acceptedBookingsController.fetchAcceptedBookings();
    } catch (e) {
      // Controller might not be initialized yet, that's okay
      print('Accepted bookings controller not found: $e');
    }
  }

  // Helper methods to extract data from jobRequest
  String getUserName() {
    final userData = jobRequest['userId'] as Map<String, dynamic>? ?? {};
    return userData['name'] as String? ?? 'Unknown User';
  }

  String getLocation() {
    final address = jobRequest['address'] as Map<String, dynamic>?;
    if (address == null) return 'Address not available';
    return address['en'] ?? address['bn'] ?? 'Address not available';
  }

  String getDateTime() {
    final bookingDateTime = jobRequest['bookingDateTime'] as String? ?? '';
    if (bookingDateTime.isEmpty) return 'Date not available';

    try {
      final dateTime = DateTime.parse(bookingDateTime).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[dateTime.month - 1];
      final day = dateTime.day;
      final year = dateTime.year;
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour < 12 ? 'AM' : 'PM';
      return '$month $day, $year  ${hour.toString().padLeft(2, '0')}:$minute$period';
    } catch (e) {
      return bookingDateTime;
    }
  }

  double getStartPrice() {
    return (jobRequest['startPrice'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Job Details",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: UIHelper.kDefaulutPadding(),
              right: UIHelper.kDefaulutPadding(),
              bottom: UIHelper.kDefaulutPadding(),
            ),
            child: Container(
              width: 1.sw,
              decoration: BoxDecoration(
                color: AppColors.cFFFFFF,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.c000000.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                    spreadRadius: 0,
                  ),
                ],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  /// Section : User Image, User Name, and Action Buttons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        /// Section : User Image
                        CircleAvatar(
                          radius: 47.r,
                          backgroundImage: AssetImage(
                            Assets.images.userImage.path,
                          ),
                        ),
                        UIHelper.horizontalSpace(18.w),

                        /// Section : User Name and Action Buttons
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getUserName(),
                                style: TextFontStyle.headline18w700c202020StyleSatoshi,
                              ),
                              UIHelper.verticalSpace(16.h),

                              /// ✅ FIXED BUTTON LOGIC - Updated with loading states
                              if (status == JobRequestStatusEnum.pending) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Cancel Button with loading state
                                    if (isCancelling)
                                      Container(
                                        width: 100.w,
                                        height: 38.h,
                                        padding: EdgeInsets.symmetric(vertical: 8.h),
                                        child: Center(
                                          child: SizedBox(
                                            width: 20.h,
                                            height: 20.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              color: AppColors.ce73d3d,
                                            ),
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.cfce9e9,
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                      )
                                    else
                                      CustomElevatedButton(
                                        onTap: cancelJobRequest,
                                        buttonWidth: 100.w,
                                        buttonHeight: 38.h,
                                        buttonColor: AppColors.cfce9e9,
                                        buttonTitle: "Cancel",
                                        textStyle: TextFontStyle.headline14w500ce73d3dStyleSatoshi,
                                      ),

                                    UIHelper.horizontalSpace(12.w),

                                    // Accept Button with loading state
                                    if (isAccepting)
                                      Container(
                                        width: 100.w,
                                        height: 38.h,
                                        padding: EdgeInsets.symmetric(vertical: 8.h),
                                        child: Center(
                                          child: SizedBox(
                                            width: 20.h,
                                            height: 20.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              color: AppColors.cFFFFFF,
                                            ),
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.c000e08,
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                      )
                                    else
                                      CustomElevatedButton(
                                        onTap: acceptJobRequest,
                                        buttonWidth: 100.w,
                                        buttonHeight: 38.h,
                                        buttonTitle: "Accept",
                                      ),
                                  ],
                                ),
                              ] else if (status == JobRequestStatusEnum.accepted) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Start Work Button with loading state
                                    if (isStartingWork)
                                      Container(
                                        width: 100.w,
                                        height: 38.h,
                                        padding: EdgeInsets.symmetric(vertical: 8.h),
                                        child: Center(
                                          child: SizedBox(
                                            width: 20.h,
                                            height: 20.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              color: AppColors.cFFFFFF,
                                            ),
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.c000e08,
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                      )
                                    else if (isWorkStarted)
                                      CustomElevatedButton(
                                        onTap: null, // Disabled
                                        buttonWidth: 100.w,
                                        buttonHeight: 38.h,
                                        buttonTitle: "Work Started",
                                        buttonColor: AppColors.c000e08,
                                      )
                                    else
                                      CustomElevatedButton(
                                        onTap: startWork,
                                        buttonWidth: 100.w,
                                        buttonHeight: 38.h,
                                        buttonTitle: "Start Work",
                                      ),

                                    UIHelper.horizontalSpace(12.w),
                                    CustomElevatedButton(
                                      onTap: () {
                                        print("Message tapped");
                                        // Add message functionality here
                                      },
                                      buttonWidth: 100.w,
                                      buttonHeight: 38.h,
                                      buttonColor: Colors.transparent,
                                      buttonTitle: "Message",
                                      textStyle: TextFontStyle.headline14w500c000000StyleSatoshi,
                                      isButtonBorderUsed: true,
                                      buttonBorderColor: AppColors.c778beb,
                                      buttonBorderWidth: 1.5.sp,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  /// Section : Divider
                  Divider(thickness: 2.h, color: AppColors.cc0caf6),
                  UIHelper.verticalSpace(16.h),

                  /// Section : Job Address & Date
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Container(
                      width: 1.sw,
                      padding: EdgeInsets.all(14.sp),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.ce6e6e6),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Section : Text -> Job Address & Details
                          Container(
                            width: 1.sw,
                            padding: EdgeInsets.symmetric(
                              vertical: 4.h,
                              horizontal: 8.w,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cf1f3fd,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              "Job Address & Date",
                              style: TextFontStyle.headline16w700c202020StyleSatoshi,
                            ),
                          ),
                          UIHelper.verticalSpace(14.h),

                          /// Section : Divider
                          DottedLineDividerWidget(),
                          UIHelper.verticalSpace(12.h),

                          /// Section : Location
                          DateAndAddressWidgetTile(
                            icon: Icons.location_on,
                            title: getLocation(),
                          ),
                          UIHelper.verticalSpace(6.h),

                          /// Section : Date And Time
                          DateAndAddressWidgetTile(
                            icon: Icons.watch_later,
                            title: getDateTime(),
                          ),
                          UIHelper.verticalSpace(12.h),

                          /// Section : Divider
                          DottedLineDividerWidget(),
                        ],
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  /// Section : My Price
                  Container(
                    width: 1.sw,
                    color: AppColors.cf1f1f1,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 16.w,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "My Price",
                          style: TextFontStyle.headline16w700c202020StyleSatoshi,
                        ),
                        Spacer(),

                        /// Section : Initial Payable Price
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Start from ${AppText.bdTkSign}",
                                style: TextFontStyle.headline12w500c6a6a6aStyleSatoshi,
                              ),
                              TextSpan(
                                text: "${getStartPrice()}",
                                style: TextFontStyle.headline18w700c778bebStyleSatoshi,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  /// Section : Text -> User Information
                  Container(
                    width: 1.sw,
                    color: AppColors.cf1f3fd,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 16.w,
                    ),
                    child: Text(
                      "User Information",
                      style: TextFontStyle.headline16w700c202020StyleSatoshi,
                    ),
                  ),
                  UIHelper.verticalSpace(10.h),

                  /// Section : Name, Location, Date of Birth, Gender
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10.w,
                      right: 10.w,
                      bottom: 10.h,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: AppList.userInfoList.length,
                      separatorBuilder: (context, index) =>
                          UIHelper.verticalSpace(10.h),
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var data = AppList.userInfoList[index];
                        return UserInfoTileWidget(
                          fieldName: data.fieldName,
                          data: data.data,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}*/

///
///
///
///
/// todo:: the button is working ,,,and now i'm fetching the data from the api
///
///
///
///

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/app_enums.dart';
import 'package:kaz_bd/controllers/svp_home_screen_controller.dart';
import 'package:kaz_bd/features/service_provider/svp_bookings/sub_presentation/svp_bookings_canceled/controller/svp_bookings_canceled_tab_controller.dart';
import 'package:kaz_bd/features/service_provider/svp_job_request/controller/svp_job_request_screen_controller.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/utilities/logger_util.dart';

import '../../../../constants/app_constant_text.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../controllers/message_screen_controller.dart';
import '../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../custom_widgets/date_and_time_widget_tile.dart';
import '../../../../custom_widgets/dotted_line_divider_widget.dart';
import '../../../../service/network_caller.dart';
import '../../../../service/network_response.dart';
import '../../../../service/secured_storage.dart';
import '../../../../utilities/app_constants.dart';
import '../../../../utilities/app_url.dart';
import '../../svp_bookings/sub_presentation/svp_accepted_bookings/controller/svp_accepted_bookings_tab_controller.dart';
import '../../svp_bookings/sub_presentation/svp_job_request/controller/svp_job_request_tab_controller.dart';
import '../widgets/user_info_tile_widget.dart';

class SvpJobDetailsScreen extends StatefulWidget {
  const SvpJobDetailsScreen({super.key});

  @override
  State<SvpJobDetailsScreen> createState() => _SvpJobDetailsScreenState();
}

class _SvpJobDetailsScreenState extends State<SvpJobDetailsScreen> {
  late JobRequestStatusEnum? status;
  late String bookingId;
  late String userId;
  late Map<String, dynamic> jobDetails;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  String requestedJobID = '';

  final NetworkCaller _networkCaller = NetworkCaller();
  SvpHomeScreenController svpHomeScreenController =
      Get.find<SvpHomeScreenController>();
  SvpBookingsCanceledController svpBookingsCanceledController =
      Get.find<SvpBookingsCanceledController>();
  SvpJobRequestScreenController svpJobRequestScreenController =
      Get.find<SvpJobRequestScreenController>();
  // SvpAcceptedBookingsController svpAcceptedBookingsController =
  //     Get.find<SvpAcceptedBookingsController>();

  SvpAcceptedBookingsController svpAcceptedBookingsController =
      Get.put(SvpAcceptedBookingsController());
  bool isStartingWork = false;
  bool isWorkStarted = false;
  bool isCancelling = false;
  bool isAccepting = false;

  @override
  void initState() {
    super.initState();

    // Get arguments from navigation
    final arguments = Get.arguments as Map<String, dynamic>?;

    // Setting the accepted arguments initial value
    status = arguments?["status"] as JobRequestStatusEnum?;
    bookingId = arguments?["bookingId"] as String? ?? '';
    userId = arguments?["userId"] as String? ?? '';
    requestedJobID = arguments?['requestedJobID'] ?? '';

    // Initialize jobDetails with empty map
    jobDetails = {};

    // Fetch job details from API
    fetchJobDetails();
  }

  // ====================== FETCH JOB DETAILS ======================
  Future<void> fetchJobDetails() async {
    // if (bookingId.isEmpty) {
    //   setState(() {
    //     isLoading = false;
    //     hasError = true;
    //     errorMessage = 'booking_id_not_found'.tr;
    //   });
    //   return;
    // }

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'authentication_required_login_again'.tr;
        });
        return;
      }

      // Make GET request to fetch job details
      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.providerJobDetailsApi(
            bookingId.isNotEmpty ? bookingId : requestedJobID),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['code'] == 200 && responseData['data'] != null) {
          final data =
              responseData['data']['attributes'] as Map<String, dynamic>? ?? {};
          LoggerUtils.debug("Svp Job Details Data : $data");

          setState(() {
            jobDetails = data;
            isLoading = false;

            // Check if work is already started (for accepted jobs)
            final currentStatus = jobDetails['status'] as String? ?? '';
            isWorkStarted =
                currentStatus == 'inProgress' || currentStatus == 'completed';
          });
        } else {
          setState(() {
            isLoading = false;
            hasError = true;
            errorMessage =
                responseData['message'] ?? 'failed_to_load_job_details'.tr;
          });
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'failed_to_load_job_details'.tr;

        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = errorMsg;
        });

        // Handle authentication errors
        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'network_error_check_again'.tr;
      });
    }
  }

  // ====================== CANCEL JOB REQUEST ======================
  Future<void> cancelJobRequest() async {
    if (isCancelling) return;

    setState(() {
      isCancelling = true;
    });

    try {
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        Get.snackbar(
          'error'.tr,
          'authentication_required_login_again'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          isCancelling = false;
        });
        return;
      }

      // Make PUT request to cancel job
      final NetworkResponse response = await _networkCaller.putRequest(
        AppUrl.providerJobRequestCancelButton(bookingId),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: {}, // Empty body as requested
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        LoggerUtils.info(
            "Job Request Canceled Button Taped : ${responseData['code']} Api Response : ${response.isSuccess}");

        if (responseData['code'] == 200 || response.isSuccess) {
          await svpBookingsCanceledController.fetchCanceledBookings();
          await svpHomeScreenController.getServiceProviderHomeData();
          await svpJobRequestScreenController.fetchJobRequests();
          Get.back();
          // Show success message
          Get.snackbar(
            'success'.tr,
            'job_request_cancelled_successfully'.tr,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Update local state
          setState(() {
            isCancelling = false;
          });

          // Fetch job requests in the tab (if it exists)
          _fetchJobRequestsInTab();

          // Go back to previous screen after cancellation
          Get.back();
        } else {
          final errorMsg =
              responseData['message'] ?? 'failed_to_cancel_job_request'.tr;
          Get.snackbar(
            'error'.tr,
            errorMsg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          setState(() {
            isCancelling = false;
          });
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'failed_to_cancel_job_request'.tr;

        Get.snackbar(
          'error'.tr,
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        // Handle authentication errors
        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }

        setState(() {
          isCancelling = false;
        });
      }
    } catch (e) {
      Get.snackbar(
        'network_error'.tr,
        'failed_to_cancel_job_request_check_internet_connection'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isCancelling = false;
      });
    }
  }

  // ====================== ACCEPT JOB REQUEST ======================
  Future<void> acceptJobRequest() async {
    if (isAccepting) return;

    setState(() {
      isAccepting = true;
    });

    try {
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        Get.snackbar(
          'error'.tr,
          'authentication_required_login_again'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          isAccepting = false;
        });
        return;
      }

      // Make PUT request to accept job
      final NetworkResponse response = await _networkCaller.putRequest(
        AppUrl.providerJobRequestAcceptButton(bookingId),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: {}, // Empty body as requested
      );

      if (response.isSuccess && response.jsonResponse != null) {
        await svpHomeScreenController.getServiceProviderHomeData();
        final responseData = response.jsonResponse!;

        if (responseData['code'] == 200 || response.isSuccess) {
          // Show success message
          Get.snackbar(
            'success'.tr,
            'job_request_accepted_successfully'.tr,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Update local state
          setState(() {
            isAccepting = false;
          });

          // Update the status to accepted
          status = JobRequestStatusEnum.accepted;

          // Refresh job details to get updated status
          await fetchJobDetails();

          // Fetch job requests in the tab (if it exists)
          _fetchJobRequestsInTab();

          // Also fetch accepted bookings to update that tab
          _fetchAcceptedBookingsInTab();
        } else {
          final errorMsg =
              responseData['message'] ?? 'failed_to_accept_job_request'.tr;
          Get.snackbar(
            'error'.tr,
            errorMsg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          setState(() {
            isAccepting = false;
          });
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'failed_to_accept_job_request'.tr;

        Get.snackbar(
          'error'.tr,
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        // Handle authentication errors
        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }

        setState(() {
          isAccepting = false;
        });
      }
    } catch (e) {
      Get.snackbar(
        'network_error'.tr,
        'failed_to_accept_job_request_check_internet_connection'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isAccepting = false;
      });
    }
  }

  // ====================== START WORK ======================
  Future<void> startWork() async {
    if (isStartingWork || isWorkStarted) return;

    setState(() {
      isStartingWork = true;
    });

    try {
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        Get.snackbar(
          'error'.tr,
          'authentication_required_login_again'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          isStartingWork = false;
        });
        return;
      }

      // Make PUT request to start work
      final NetworkResponse response = await _networkCaller.putRequest(
        AppUrl.providerStartWorkButton(bookingId),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: {}, // Empty body as requested
      );

      if (response.isSuccess && response.jsonResponse != null) {
        await svpAcceptedBookingsController.fetchAcceptedBookings();
        await svpHomeScreenController.getServiceProviderHomeData();
        final responseData = response.jsonResponse!;

        if (responseData['code'] == 200) {
          // Show success message
          Get.snackbar(
            'success'.tr,
            'work_started_successfully'.tr,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Update local state
          setState(() {
            isWorkStarted = true;
            isStartingWork = false;
          });

          // Refresh job details to get updated status
          await fetchJobDetails();

          // Fetch accepted bookings in the tab (if it exists)
          _fetchAcceptedBookingsInTab();
        } else {
          final errorMsg = responseData['message'] ?? 'failed_to_start_work'.tr;
          Get.snackbar(
            'error'.tr,
            errorMsg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          setState(() {
            isStartingWork = false;
          });
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'failed_to_start_work'.tr;

        Get.snackbar(
          'error'.tr,
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        // Handle authentication errors
        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
        }

        setState(() {
          isStartingWork = false;
        });
      }
    } catch (e) {
      Get.snackbar(
        'network_error'.tr,
        'failed_to_start_work_check_your_connection'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isStartingWork = false;
      });
    }
  }

  // Method to fetch job requests in the pending tab screen
  void _fetchJobRequestsInTab() {
    try {
      // Get the controller instance if it exists
      final jobRequestsController = Get.find<SvpJobRequestTabController>();
      jobRequestsController.fetchJobRequests();
    } catch (e) {
      // Controller might not be initialized yet, that's okay
      print('Job requests controller not found: $e');
    }
  }

  // Helper methods to extract data from jobDetails
  String getUserName() {
    final userData = jobDetails['userId'] as Map<String, dynamic>? ?? {};
    return userData['name'] as String? ?? 'unknown_user'.tr;
  }

  // Method to fetch accepted bookings in the accepted tab screen
  void _fetchAcceptedBookingsInTab() {
    try {
      // Get the controller instance if it exists
      final acceptedBookingsController =
          Get.find<SvpAcceptedBookingsController>();
      acceptedBookingsController.fetchAcceptedBookings();
    } catch (e) {
      // Controller might not be initialized yet, that's okay
      print('Accepted bookings controller not found: $e');
    }
  }

  String getUserProfileImage() {
    final userData = jobDetails['userId'] as Map<String, dynamic>? ?? {};
    final profileImage =
        userData['profileImage'] as Map<String, dynamic>? ?? {};
    final imageUrl = profileImage['imageUrl'] as String? ?? '';

    if (imageUrl.isEmpty) return '';

    // Construct full URL if needed
    if (!imageUrl.startsWith('http')) {
      return '${AppUrl.imageBaseUrl}${imageUrl.startsWith('/') ? imageUrl : '/$imageUrl'}';
    }

    return imageUrl;
  }

  String getLocation() {
    final address = jobDetails['address'] as Map<String, dynamic>?;
    if (address == null) return 'address_not_available'.tr;
    return address['en'] ?? address['bn'] ?? 'address_not_available'.tr;
  }

  String getDateTime() {
    final bookingDateTime = jobDetails['bookingDateTime'] as String? ?? '';
    if (bookingDateTime.isEmpty) return 'date_not_valid'.tr;

    try {
      final dateTime = DateTime.parse(bookingDateTime).toLocal();
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
      return bookingDateTime;
    }
  }

  double getStartPrice() {
    return (jobDetails['startPrice'] as num?)?.toDouble() ?? 0.0;
  }

  // Get user profile information for the UserInfoTileWidget
  List<UserInfoData> getUserInfoList() {
    final userData = jobDetails['userId'] as Map<String, dynamic>? ?? {};
    final profileId = userData['profileId'] as Map<String, dynamic>? ?? {};
    final location = profileId['location'] as Map<String, dynamic>? ?? {};
    final gender = profileId['gender'] as String? ?? 'not_specified'.tr;

    return [
      UserInfoData(fieldName: 'name'.tr, data: getUserName()),
      UserInfoData(
          fieldName: 'location'.tr,
          data: location['en'] ?? location['bn'] ?? 'not_specified'.tr),
      UserInfoData(fieldName: 'gender'.tr, data: gender),
    ];
  }

  // Loading widget
  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.c000e08),
            UIHelper.verticalSpace(16.h),
            Text(
              'loading_job_details'.tr,
              style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
            ),
          ],
        ),
      ),
    );
  }

  // Error widget
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50.h, color: Colors.red),
            UIHelper.verticalSpace(16.h),
            Text(
              errorMessage,
              style: TextFontStyle.headline10w400c6c606cStyleSatoshi
                  .copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            UIHelper.verticalSpace(16.h),
            ElevatedButton(
              onPressed: fetchJobDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.c000e08,
                foregroundColor: Colors.white,
              ),
              child: Text('retry'.tr),
            ),
          ],
        ),
      ),
    );
  }

  // Main content widget
  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: UIHelper.kDefaulutPadding(),
          right: UIHelper.kDefaulutPadding(),
          bottom: UIHelper.kDefaulutPadding(),
        ),
        child: Container(
          width: 1.sw,
          decoration: BoxDecoration(
            color: AppColors.cFFFFFF,
            boxShadow: [
              BoxShadow(
                color: AppColors.c000000.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 0),
                spreadRadius: 0,
              ),
            ],
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              /// Section : User Image, User Name, and Action Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  children: [
                    /// Section : User Image
                    CircleAvatar(
                      radius: 47.r,
                      backgroundImage: getUserProfileImage().isNotEmpty
                          ? NetworkImage(getUserProfileImage()) as ImageProvider
                          : AssetImage(Assets.images.userImage.path),
                    ),
                    UIHelper.horizontalSpace(18.w),

                    /// Section : User Name and Action Buttons
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getUserName(),
                            style:
                                TextFontStyle.headline18w700c202020StyleSatoshi,
                          ),
                          UIHelper.verticalSpace(16.h),

                          /// ✅ FIXED BUTTON LOGIC - Updated with loading states
                          if (status == JobRequestStatusEnum.pending) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Cancel Button with loading state
                                if (isCancelling)
                                  Container(
                                    width: 100.w,
                                    height: 38.h,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.h),
                                    child: Center(
                                      child: SizedBox(
                                        width: 20.h,
                                        height: 20.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          color: AppColors.ce73d3d,
                                        ),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.cfce9e9,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  )
                                else
                                  CustomElevatedButton(
                                    onTap: cancelJobRequest,
                                    buttonWidth: 100.w,
                                    buttonHeight: 38.h,
                                    buttonColor: AppColors.cfce9e9,
                                    buttonTitle: 'cancel'.tr,
                                    textStyle: TextFontStyle
                                        .headline14w500ce73d3dStyleSatoshi,
                                  ),

                                UIHelper.horizontalSpace(12.w),

                                // Accept Button with loading state
                                if (isAccepting)
                                  Container(
                                    width: 100.w,
                                    height: 38.h,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.h),
                                    child: Center(
                                      child: SizedBox(
                                        width: 20.h,
                                        height: 20.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          color: AppColors.cFFFFFF,
                                        ),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.c000e08,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  )
                                else
                                  CustomElevatedButton(
                                    onTap: acceptJobRequest,
                                    buttonWidth: 100.w,
                                    buttonHeight: 38.h,
                                    buttonTitle: 'accept'.tr,
                                  ),
                              ],
                            ),
                          ] else if (status ==
                              JobRequestStatusEnum.accepted) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Start Work Button with loading state
                                if (isStartingWork)
                                  Container(
                                    width: 100.w,
                                    height: 38.h,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.h),
                                    child: Center(
                                      child: SizedBox(
                                        width: 20.h,
                                        height: 20.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          color: AppColors.cFFFFFF,
                                        ),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.c000e08,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  )
                                else if (isWorkStarted)
                                  CustomElevatedButton(
                                    onTap: null, // Disabled
                                    buttonWidth: 100.w,
                                    buttonHeight: 38.h,
                                    buttonTitle: 'work_started'.tr,
                                    buttonColor: AppColors.c000e08,
                                  )
                                else
                                  CustomElevatedButton(
                                    onTap: startWork,
                                    buttonWidth: 100.w,
                                    buttonHeight: 38.h,
                                    buttonTitle: 'start_work'.tr,
                                  ),

                                UIHelper.horizontalSpace(12.w),
                                CustomElevatedButton(
                                  onTap: () {
                                    Get.find<MessageScreenController>()
                                        .createMessage(
                                            participantId: userId,
                                            name: getUserName(),
                                            imageUrl:
                                                getUserProfileImage() ?? '');
                                    // Add message functionality here
                                  },
                                  buttonWidth: 100.w,
                                  buttonHeight: 38.h,
                                  buttonColor: Colors.transparent,
                                  buttonTitle: 'message'.tr,
                                  textStyle: TextFontStyle
                                      .headline14w500c000000StyleSatoshi,
                                  isButtonBorderUsed: true,
                                  buttonBorderColor: AppColors.c778beb,
                                  buttonBorderWidth: 1.5.sp,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(16.h),

              /// Section : Divider
              Divider(thickness: 2.h, color: AppColors.cc0caf6),
              UIHelper.verticalSpace(16.h),

              /// Section : Job Address & Date
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Container(
                  width: 1.sw,
                  padding: EdgeInsets.all(14.sp),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.ce6e6e6),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Section : Text -> Job Address & Details
                      Container(
                        width: 1.sw,
                        padding: EdgeInsets.symmetric(
                          vertical: 4.h,
                          horizontal: 8.w,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cf1f3fd,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'job_address_and_date'.tr,
                          style:
                              TextFontStyle.headline16w700c202020StyleSatoshi,
                        ),
                      ),
                      UIHelper.verticalSpace(14.h),

                      /// Section : Divider
                      DottedLineDividerWidget(),
                      UIHelper.verticalSpace(12.h),

                      /// Section : Location
                      DateAndAddressWidgetTile(
                        icon: Icons.location_on,
                        title: getLocation(),
                      ),
                      UIHelper.verticalSpace(6.h),

                      /// Section : Date And Time
                      DateAndAddressWidgetTile(
                        icon: Icons.watch_later,
                        title: getDateTime(),
                      ),
                      UIHelper.verticalSpace(12.h),

                      /// Section : Divider
                      DottedLineDividerWidget(),
                    ],
                  ),
                ),
              ),
              UIHelper.verticalSpace(16.h),

              /// Section : My Price
              Container(
                width: 1.sw,
                color: AppColors.cf1f1f1,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  vertical: 10.h,
                  horizontal: 16.w,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'my_price'.tr,
                      style: TextFontStyle.headline16w700c202020StyleSatoshi,
                    ),
                    Spacer(),

                    /// Section : Initial Payable Price
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${'start_from'.tr} ${AppText.bdTkSign}",
                            style:
                                TextFontStyle.headline12w500c6a6a6aStyleSatoshi,
                          ),
                          TextSpan(
                            text: "${getStartPrice()}",
                            style:
                                TextFontStyle.headline18w700c778bebStyleSatoshi,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(16.h),

              /// Section : Text -> User Information
              Container(
                width: 1.sw,
                color: AppColors.cf1f3fd,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(
                  vertical: 10.h,
                  horizontal: 16.w,
                ),
                child: Text(
                  'user_information'.tr,
                  style: TextFontStyle.headline16w700c202020StyleSatoshi,
                ),
              ),
              UIHelper.verticalSpace(10.h),

              /// Section : Name, Location, Date of Birth, Gender
              Padding(
                padding: EdgeInsets.only(
                  left: 10.w,
                  right: 10.w,
                  bottom: 10.h,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: getUserInfoList().length,
                  separatorBuilder: (context, index) =>
                      UIHelper.verticalSpace(10.h),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    var data = getUserInfoList()[index];
                    return UserInfoTileWidget(
                      fieldName: data.fieldName,
                      data: data.data,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'job_details'.tr,
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: isLoading
            ? _buildLoading()
            : hasError
                ? _buildError()
                : _buildContent(),
      ),
    );
  }
}

// You'll need to add this UserInfoData class if it doesn't exist in your project
class UserInfoData {
  final String fieldName;
  final String data;

  UserInfoData({required this.fieldName, required this.data});
}

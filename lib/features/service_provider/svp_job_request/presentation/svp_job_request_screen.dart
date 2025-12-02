/**
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../../constants/app_enums.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../custom_widgets/recent_job_request_status_widget.dart';

class SvpJobRequestScreen extends StatelessWidget {
  const SvpJobRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Job Request",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: ListView.separated(
            itemCount: 20,
            separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
            itemBuilder: (context, index) {
              return RecentJobRequestStatusWidget(
                onTap: () {
                  log("Tapped on -> Card");
                  Get.toNamed(
                    Routes.svpJobDetailsScreen,
                    arguments: {"status": JobRequestStatusEnum.pending},
                  );
                },
                cancelOnTap: () {
                  log("Button Tapped -> Cancel");
                },
                acceptOnTap: () {
                  log("Button Tapped -> Accept");
                },
                userImage: Assets.images.userImage.path,
                userName: "Chowdhury Md. Imtiazul Islam",
                location: "Rampura Dhaka, Bangladesh",
                dateTime: "Jun 17, 2025  09:31AM",
              );
            },
          ),
        ),
      ),
    );
  }
}
*/






///
///
///
///
/// todo::: fetching fom the api
///
///
///
///





import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';
import '../../../../constants/app_enums.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../custom_widgets/recent_job_request_status_widget.dart';
import '../controller/svp_job_request_controller.dart';

class SvpJobRequestScreen extends StatefulWidget {
  const SvpJobRequestScreen({super.key});

  @override
  State<SvpJobRequestScreen> createState() => _SvpJobRequestScreenState();
}

class _SvpJobRequestScreenState extends State<SvpJobRequestScreen> {
  final SvpJobRequestController controller = Get.put(SvpJobRequestController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Add listener for infinite scroll
    _scrollController.addListener(_scrollListener);

    // Listen to jobRequests changes
    ever(controller.jobRequests, (value) {
      log('📊 UI: JobRequests updated. Count: ${value.length}');
    });

    // Listen to loading state
    ever(controller.isLoading, (value) {
      log('🔄 UI: Loading state changed to: $value');
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      log('📜 Reached bottom of list, loading more...');
      controller.loadMoreData();
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      if (dateTimeString.isEmpty) return 'No date set';

      DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
      String hour = dateTime.hour.toString();
      String minute = dateTime.minute.toString().padLeft(2, '0');
      String period = dateTime.hour < 12 ? 'AM' : 'PM';

      // Convert to 12-hour format
      int hour12 = dateTime.hour % 12;
      hour12 = hour12 == 0 ? 12 : hour12;

      return '${dateTime.day} ${_getMonthName(dateTime.month)}, ${dateTime.year} at $hour12:$minute $period';
    } catch (e) {
      log('❌ Error formatting date: $e');
      return dateTimeString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildJobItem(int index) {
    if (index >= controller.jobRequests.length) {
      return Container(); // Should not happen
    }

    final job = controller.jobRequests[index];
    final jobId = job['_ServiceBookingId']?.toString() ?? 'NO_ID_$index';

    log('🏗️ Building item $index, Job ID: $jobId');

    final userName = controller.getUserName(jobId);
    final location = controller.getUserLocation(jobId);
    final dateTime = _formatDateTime(controller.getBookingDateTime(jobId));
    final hasImage = controller.hasUserImage(jobId);
    final imageUrl = controller.getUserImageUrl(jobId);
    final userId = controller.getUserId(jobId);

    log('👤 Item $index - Name: $userName, Location: $location');

    return RecentJobRequestStatusWidget(
      onTap: () {
        log("👆 Tapped on job card -> $jobId");
        if (userId.isNotEmpty) {
          Get.toNamed(
            Routes.svpJobDetailsScreen,
            arguments: {
              "status": JobRequestStatusEnum.pending,
              "jobId": jobId,
              "userId": userId,
            },
          );
        } else {
          Get.snackbar(
            'Error',
            'User information not available',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      cancelOnTap: () {
        log("❌ Cancel button tapped for job: $jobId");
        _showCancelDialog(jobId, userName);
      },
      acceptOnTap: () {
        log("✅ Accept button tapped for job: $jobId");
        _showAcceptDialog(jobId, userName);
      },
      userImage: hasImage ? imageUrl : Assets.images.userImage.path,
      userName: userName,
      location: location,
      dateTime: dateTime,
    );
  }

  void _showCancelDialog(String jobId, String userName) {
    Get.dialog(
      AlertDialog(
        title: Text('Cancel Job Request'),
        content: Text('Are you sure you want to cancel the job request from $userName?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              log('❌ Cancelled cancellation for job: $jobId');
            },
            child: Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Cancelled',
                'Job request cancelled successfully',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
              log('✅ Job request cancelled for job: $jobId');
            },
            child: Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(String jobId, String userName) {
    Get.dialog(
      AlertDialog(
        title: Text('Accept Job Request'),
        content: Text('Accept job request from $userName?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              log('❌ Cancelled acceptance for job: $jobId');
            },
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Accepted',
                'Job request accepted successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              log('✅ Job request accepted for job: $jobId');
            },
            child: Text('Accept', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    log('🎨 Building SvpJobRequestScreen UI');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Job Requests",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              log('🔄 Manual refresh triggered');
              controller.refreshData();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          log('🔄 Building UI - isLoading: ${controller.isLoading.value}, error: ${controller.errorMessage.value}, count: ${controller.jobRequests.length}');

          // Loading state (initial load)
          if (controller.isLoading.value && controller.jobRequests.isEmpty) {
            return _buildLoadingState();
          }

          // Error state
          if (controller.errorMessage.isNotEmpty && controller.jobRequests.isEmpty) {
            return _buildErrorState();
          }

          // Empty state
          if (controller.jobRequests.isEmpty) {
            return _buildEmptyState();
          }

          // Data loaded successfully
          log('✅ Displaying ${controller.jobRequests.length} job requests');

          return RefreshIndicator(
            onRefresh: () async {
              log('🔄 Pull to refresh triggered');
              await controller.refreshData();
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
              itemCount: controller.jobRequests.length +
                  (controller.hasMoreData.value ? 1 : 0),
              separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
              itemBuilder: (context, index) {
                // Show loading indicator at the bottom when loading more
                if (index >= controller.jobRequests.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return _buildJobItem(index);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.c000e08),
            strokeWidth: 2.0,
          ),
          UIHelper.verticalSpace(20.h),
          Text(
            'Loading job requests...',
            style: TextFontStyle.headline16w700c000000StyleSatoshi,
          ),
          UIHelper.verticalSpace(8.h),
          Text(
            'Please wait a moment',
            style: TextFontStyle.headline14w500c6a6a6aStyleSatoshi,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 72.sp,
              color: Colors.red,
            ),
            UIHelper.verticalSpace(20.h),
            Text(
              'Unable to Load Data',
              style: TextFontStyle.headline18w700c000000StyleSatoshi,
            ),
            UIHelper.verticalSpace(12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                controller.errorMessage.value,
                style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                textAlign: TextAlign.center,
              ),
            ),
            UIHelper.verticalSpace(24.h),
            ElevatedButton(
              onPressed: () {
                log('🔄 Retry button pressed');
                controller.getJobRequests();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextFontStyle.headline14w600cffffffStyleSatoshi,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Assets.images.noDataFound.image(
            //   width: 150.w,
            //   height: 150.h,
            // ),
            UIHelper.verticalSpace(24.h),
            Text(
              'No Job Requests',
              style: TextFontStyle.headline20w700c4d4d4dStyleSatoshi,
            ),
            UIHelper.verticalSpace(12.h),
            Text(
              'You don\'t have any job requests at the moment.',
              style: TextFontStyle.headline14w500c6a6a6aStyleSatoshi,
              textAlign: TextAlign.center,
            ),
            UIHelper.verticalSpace(8.h),
            Text(
              'New requests will appear here automatically.',
              style: TextFontStyle.headline12w500c6a6a6aStyleSatoshi,
              textAlign: TextAlign.center,
            ),
            UIHelper.verticalSpace(32.h),
            ElevatedButton(
              onPressed: () {
                log('🔄 Refresh button pressed in empty state');
                controller.refreshData();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Refresh',
                style: TextFontStyle.headline14w600cffffffStyleSatoshi,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    log('🛑 SvpJobRequestScreen disposed');
    super.dispose();
  }
}





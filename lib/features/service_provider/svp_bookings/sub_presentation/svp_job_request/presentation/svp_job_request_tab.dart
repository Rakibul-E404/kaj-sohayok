/**
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../controller/svp_job_request_tab_controller.dart';

class SvpJobRequestTab extends StatelessWidget {
  const SvpJobRequestTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SvpJobRequestTabController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
          child: Obx(() => _buildContent(controller)),
        ),
      ),
    );
  }

  Widget _buildContent(SvpJobRequestTabController controller) {
    if (controller.isLoading.value) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.c000e08),
              UIHelper.verticalSpace(16.h),
              Text(
                'Loading job requests...',
                style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
              ),
            ],
          ),
        ),
      );
    }

    if (controller.hasError.value) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50.h, color: Colors.red),
              UIHelper.verticalSpace(16.h),
              Text(
                controller.errorMessage.value,
                style: TextFontStyle.headline10w400c6c606cStyleSatoshi.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              UIHelper.verticalSpace(16.h),
              ElevatedButton(
                onPressed: () => controller.fetchJobRequests(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.c000e08,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.jobRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 60.h, color: Colors.grey),
            UIHelper.verticalSpace(16.h),
            Text(
              'No job requests available',
              style: TextFontStyle.headline10w500c000000StyleSatoshi.copyWith(color: Colors.grey),
            ),
            UIHelper.verticalSpace(8.h),
            Text(
              'New job requests will appear here',
              style: TextFontStyle.headline10w400c6c606cStyleSatoshi.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchJobRequests(),
      color: AppColors.c000e08,
      child: ListView.separated(
        itemCount: controller.jobRequests.length,
        separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
        itemBuilder: (context, index) {
          return controller.buildRecentJobRequestWidget(index);
        },
      ),
    );
  }
}*/







///
///
/// todo:: adding the button api
///
///





import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../controller/svp_job_request_tab_controller.dart';

class SvpJobRequestTab extends StatelessWidget {
  const SvpJobRequestTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SvpJobRequestTabController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
          child: Obx(() => _buildContent(controller)),
        ),
      ),
    );
  }

  Widget _buildContent(SvpJobRequestTabController controller) {
    if (controller.isLoading.value) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.c000e08),
              UIHelper.verticalSpace(16.h),
              Text(
                'Loading job requests...',
                style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
              ),
            ],
          ),
        ),
      );
    }

    if (controller.hasError.value) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50.h, color: Colors.red),
              UIHelper.verticalSpace(16.h),
              Text(
                controller.errorMessage.value,
                style: TextFontStyle.headline10w400c6c606cStyleSatoshi.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              UIHelper.verticalSpace(16.h),
              ElevatedButton(
                onPressed: () => controller.fetchJobRequests(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.c000e08,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.jobRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 60.h, color: Colors.grey),
            UIHelper.verticalSpace(16.h),
            Text(
              'No job requests available',
              style: TextFontStyle.headline10w500c000000StyleSatoshi.copyWith(color: Colors.grey),
            ),
            UIHelper.verticalSpace(8.h),
            Text(
              'New job requests will appear here',
              style: TextFontStyle.headline10w400c6c606cStyleSatoshi.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchJobRequests(),
      color: AppColors.c000e08,
      child: ListView.separated(
        itemCount: controller.jobRequests.length,
        separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
        itemBuilder: (context, index) {
          return controller.buildRecentJobRequestWidget(index);
        },
      ),
    );
  }
}



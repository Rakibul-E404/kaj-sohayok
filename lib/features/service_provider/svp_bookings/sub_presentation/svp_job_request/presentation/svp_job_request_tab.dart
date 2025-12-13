import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../controller/svp_job_request_tab_controller.dart';


class SvpJobRequestTab extends StatefulWidget {
  const SvpJobRequestTab({super.key});

  @override
  State<SvpJobRequestTab> createState() => _SvpJobRequestTabState();
}

class _SvpJobRequestTabState extends State<SvpJobRequestTab> {
  final controller = Get.put(SvpJobRequestTabController());
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Listen to scroll events
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <= 0) {
        // At the top, auto-refresh
        controller.fetchJobRequests();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
          child: Obx(() => RefreshIndicator(
            onRefresh: () => controller.fetchJobRequests(),
            color: AppColors.c000e08,
            child: _buildContent(),
          )),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (controller.isLoading.value) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 600, // ensures enough scrollable space
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UIHelper.verticalSpace(16.h),
                  Text(
                    'Loading job requests...',
                    style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (controller.hasError.value) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 600,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 50.h, color: Colors.red),
                  UIHelper.verticalSpace(16.h),
                  Text(
                    controller.errorMessage.value,
                    style: TextFontStyle.headline10w400c6c606cStyleSatoshi
                        .copyWith(color: Colors.red),
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
          ),
        ],
      );
    }

    if (controller.jobRequests.isEmpty) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 600,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline, size: 60.h, color: Colors.grey),
                  UIHelper.verticalSpace(16.h),
                  Text(
                    'No job requests available',
                    style: TextFontStyle.headline10w500c000000StyleSatoshi
                        .copyWith(color: Colors.grey),
                  ),
                  UIHelper.verticalSpace(8.h),
                  Text(
                    'New job requests will appear here',
                    style: TextFontStyle.headline10w400c6c606cStyleSatoshi
                        .copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Data is available
    return ListView.separated(
      controller: _scrollController,
      itemCount: controller.jobRequests.length,
      separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
      itemBuilder: (context, index) {
        return controller.buildRecentJobRequestWidget(index);
      },
    );
  }
}

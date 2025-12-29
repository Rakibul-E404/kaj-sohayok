// notification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../controllers/notification_controller.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../helpers/waiting_widget.dart';
import '../widget/no_notification_widget.dart';
import '../widget/notification_showing_widget.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller (automatically disposed by Get)
    final controller = Get.put(NotificationController(), permanent: false);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'notification'.tr,
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading && controller.notificationList.isEmpty) {
          // Initial loading
          return const Center(child: WaitingWidget());
        }

        if (controller.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: Colors.grey.shade500),
                SizedBox(height: 16.h),
                Text(
                  'failed_to_load_exception'.tr,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: controller.retry,
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        if (controller.notificationList.isEmpty) {
          return const Center(child: NoNotificationWidget());
        }

        // Success: show list with pull-to-refresh
        return RefreshIndicator(
          onRefresh: () => controller.fetchNotification(isRefresh: true),
          child: ListView.separated(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            itemCount: controller.notificationList.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final notification = controller.notificationList[index];
              return NotificationShowingWidget(
                notificationIcon: Assets.icons.bellIcon,
                notificationTitle: notification.title?.en ?? '',
                notificationTime: formatDate(notification.createdAt),
              );
            },
          ),
        );
      }),
    );
  }

  // Helper to format DateTime (add this if not already available)
  String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'just_now'.tr;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) return 'just_now'.tr;
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

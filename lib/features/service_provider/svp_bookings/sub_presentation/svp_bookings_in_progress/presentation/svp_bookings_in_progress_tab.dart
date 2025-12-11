/**
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../controller/svp_bookings_in_prgress_tab_controller.dart';

class SvpBookingsInProgressTab extends StatelessWidget {
  const SvpBookingsInProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SvpBookingsInProgressController());

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

  Widget _buildContent(SvpBookingsInProgressController controller) {
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
                'Loading in-progress bookings...',
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
                onPressed: () => controller.fetchInProgressBookings(),
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
            Icon(Icons.pending_actions, size: 60.h, color: Colors.grey),
            UIHelper.verticalSpace(16.h),
            Text(
              'No bookings in progress',
              style: TextFontStyle.headline10w500c000000StyleSatoshi.copyWith(color: Colors.grey),
            ),
            UIHelper.verticalSpace(8.h),
            Text(
              'Active jobs will appear here',
              style: TextFontStyle.headline10w400c6c606cStyleSatoshi.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchInProgressBookings(),
      color: AppColors.c000e08,
      child: ListView.separated(
        itemCount: controller.jobRequests.length,
        separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
        itemBuilder: (context, index) {
          return controller.buildInProgressBookingWidget(index);
        },
      ),
    );
  }
}*/






///
///
///
///
/// todo::: setting the details navigation
///
///
///
///





// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import '../../../../../../constants/text_font_style.dart';
// import '../../../../../../gen/colors.gen.dart';
// import '../../../../../../helpers/ui_helpers.dart';
// import '../controller/svp_bookings_in_prgress_tab_controller.dart';
//
// class SvpBookingsInProgressTab extends StatelessWidget {
//   const SvpBookingsInProgressTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(SvpBookingsInProgressController());
//
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
//           child: Obx(() => _buildContent(controller)),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildContent(SvpBookingsInProgressController controller) {
//     if (controller.isLoading.value) {
//       return Center(
//         child: Padding(
//           padding: EdgeInsets.all(20.h),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(color: AppColors.c000e08),
//               UIHelper.verticalSpace(16.h),
//               Text(
//                 'Loading in-progress bookings...',
//                 style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     if (controller.hasError.value) {
//       return Center(
//         child: Padding(
//           padding: EdgeInsets.all(20.h),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline, size: 50.h, color: Colors.red),
//               UIHelper.verticalSpace(16.h),
//               Text(
//                 controller.errorMessage.value,
//                 style: TextFontStyle.headline10w400c6c606cStyleSatoshi.copyWith(color: Colors.red),
//                 textAlign: TextAlign.center,
//               ),
//               UIHelper.verticalSpace(16.h),
//               ElevatedButton(
//                 onPressed: () => controller.fetchInProgressBookings(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.c000e08,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     if (controller.jobRequests.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.pending_actions, size: 60.h, color: Colors.grey),
//             UIHelper.verticalSpace(16.h),
//             Text(
//               'No bookings in progress',
//               style: TextFontStyle.headline10w500c000000StyleSatoshi.copyWith(color: Colors.grey),
//             ),
//             UIHelper.verticalSpace(8.h),
//             Text(
//               'Active jobs will appear here',
//               style: TextFontStyle.headline10w400c6c606cStyleSatoshi.copyWith(color: Colors.grey),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: () => controller.fetchInProgressBookings(),
//       color: AppColors.c000e08,
//       child: ListView.separated(
//         itemCount: controller.jobRequests.length,
//         separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
//         itemBuilder: (context, index) {
//           return controller.buildInProgressBookingWidget(index);
//         },
//       ),
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../controller/svp_bookings_in_prgress_tab_controller.dart';

class SvpBookingsInProgressTab extends StatelessWidget {
  const SvpBookingsInProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎯 SvpBookingsInProgressTab - Tab Opened at ${DateTime.now().toLocal()}');

    final controller = Get.put(SvpBookingsInProgressController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: UIHelper.kDefaulutPadding()),
          child: Obx(() {
            // Print when widget rebuilds with data
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!controller.isLoading.value &&
                  !controller.hasError.value &&
                  controller.jobRequests.isNotEmpty) {
                print('📊 Tab Data Loaded - ${controller.jobRequests.length} booking(s) available');
              }
            });

            return _buildContent(controller);
          }),
        ),
      ),
    );
  }

  Widget _buildContent(SvpBookingsInProgressController controller) {
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
                'Loading in-progress bookings...',
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
                onPressed: () => controller.fetchInProgressBookings(),
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
      print('📭 No bookings in progress - Empty state shown');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pending_actions, size: 60.h, color: Colors.grey),
            UIHelper.verticalSpace(16.h),
            Text(
              'No bookings in progress',
              style: TextFontStyle.headline10w500c000000StyleSatoshi.copyWith(color: Colors.grey),
            ),
            UIHelper.verticalSpace(8.h),
            Text(
              'Active jobs will appear here',
              style: TextFontStyle.headline10w400c6c606cStyleSatoshi.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        print('🔄 Manual refresh triggered');
        return controller.fetchInProgressBookings();
      },
      color: AppColors.c000e08,
      child: ListView.separated(
        itemCount: controller.jobRequests.length,
        separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
        itemBuilder: (context, index) {
          return controller.buildInProgressBookingWidget(index);
        },
      ),
    );
  }
}




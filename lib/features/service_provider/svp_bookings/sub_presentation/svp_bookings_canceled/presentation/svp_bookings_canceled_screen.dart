/**
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/custom_widgets/dotted_line_divider_widget.dart';
import 'package:kaz_bd/gen/assets.gen.dart';

import '../../../../../../constants/text_font_style.dart';
import '../../../../../../custom_widgets/date_and_time_widget_tile.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../widgets/svp_bookings_canceled_card.dart';

class SvpBookingsCanceledTab extends StatelessWidget {
  const SvpBookingsCanceledTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          itemCount: 10,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),

          itemBuilder: (context, index) {
            return SvpBookingsCanceledCard(
              cancelButtonOnTap: () {
                log("Button Taped -> Cancel");
              },
              userImage: Assets.images.userImage.path,
              userName: "Chowdhur Md. Imtiazul Islam",
              location: "Rampura Dhaka, Bangladesh",
              dateTime: "Jun 17, 2025  09:31AM",
            );
          },
        ),
      ),
    );
  }
}
*/









///
///
///
/// todo::::: fetching from the api
///
///
///




// lib/.../svp_bookings_canceled_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../controller/svp_bookings_canceled_tab_controller.dart';

class SvpBookingsCanceledTab extends StatelessWidget {
  const SvpBookingsCanceledTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SvpBookingsCanceledController());

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

  Widget _buildContent(SvpBookingsCanceledController controller) {
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
                'Loading canceled bookings...',
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
                onPressed: () => controller.fetchCanceledBookings(),
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

    if (controller.canceledBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, size: 60.h, color: Colors.grey),
            UIHelper.verticalSpace(16.h),
            Text(
              'No canceled bookings',
              style: TextFontStyle.headline10w500c000000StyleSatoshi.copyWith(color: Colors.grey),
            ),
            UIHelper.verticalSpace(8.h),
            Text(
              'Canceled jobs will appear here',
              style: TextFontStyle.headline10w400c6c606cStyleSatoshi.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchCanceledBookings(),
      color: AppColors.c000e08,
      child: ListView.separated(
        itemCount: controller.canceledBookings.length,
        separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),
        itemBuilder: (context, index) {
          return controller.buildCanceledBookingCard(index);
        },
      ),
    );
  }
}
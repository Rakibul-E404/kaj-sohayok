/*
import 'dart:developer';

import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/app_constant_text.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../custom_widgets/payment_summery_card_widget.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../routes/routes.dart';
import '../widgets/address_and_order_date_tile.dart';
import '../widgets/proof_of_work_showing_widget.dart';
import '../widgets/workCompleteDateAndTimeWidget.dart';

class WorkCompletedDetailsScreen extends StatelessWidget {
  const WorkCompletedDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Complete Details",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Work Complete Information ",
                  style: TextFontStyle.headline16w700c000000StyleSatoshi,
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Work Completation Date
                WorkCompleteDateAndTimeWidget(
                  title: "Completion Date",
                  data: "11-08-25",
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Work Duration
                WorkCompleteDateAndTimeWidget(
                  title: "Duration Time",
                  data: "1 Day",
                  isIconVisible: false,
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Working Address
                ///Section : Booking Order Date
                Container(
                  width: 1.sw,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.ce6e6e6),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    children: [
                      ///Section : Working Address
                      AddressAndOrderDateTile(
                        title: "Working Address",
                        icon: Icons.location_on,
                        data: "Rampura Dhaka, Bangladesh",
                      ),
                      UIHelper.verticalSpace(14.h),

                      ///Section : Booking Order Date
                      AddressAndOrderDateTile(
                        title: "Booking Order Date",
                        icon: Icons.watch_later_rounded,
                        data: "Jun 17, 2025  09:31AM",
                      ),
                    ],
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Proof Of Work
                ///Section : Text -> Proof of image
                ///Section : Work Image
                ProofOfWorkShowingWidget(
                  title: "Proof of Image",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: Image.asset(
                      Assets.images.userImage.path,
                      width: 1.sw,
                      height: 200.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Proof Of Work
                ///Section : Text -> Proof of Video
                ///Section : Work Video
                ProofOfWorkShowingWidget(
                  title: "Proof of Video",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: Image.asset(
                      Assets.images.userImage.path,
                      width: 1.sw,
                      height: 200.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Service Provider Image
                ///Section : Service Provider Name
                ///Section : Service Provider
                ///Section : Message
                ///Section : Call
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.serviceProviderProfileDetailsScreen);
                  },
                  child: Container(
                    width: 1.sw,
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                      color: AppColors.cf7f8fd,
                      border: Border.all(color: AppColors.cb4b4b4),
                      borderRadius: BorderRadius.circular(8.r),

                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ca4b1f2.withAlpha(80),
                          blurRadius: 12.r,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        ///Section : Service Provider Image
                        CircleAvatar(
                          radius: 20.r,
                          backgroundImage: AssetImage(
                            Assets.images.userImage.path,
                          ),
                        ),
                        UIHelper.horizontalSpace(6.w),

                        ///Section : Service Provider Name
                        ///Section : Service Provider
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///Section : Service Provider Name
                            Text(
                              "Ripon Mia",
                              style: TextFontStyle
                                  .headline16w500c202020StyleSatoshi,
                            ),
                            UIHelper.verticalSpace(2.h),

                            ///Section : Service Provider
                            Text(
                              "Services Provider",
                              style: TextFontStyle
                                  .headline10w500c4d4d4dStyleSatoshi,
                            ),
                          ],
                        ),
                        Spacer(),

                        ///Section : Message
                        ///Section : Call
                        Row(
                          children: [
                            ///Section : Message
                            InkWell(
                              onTap: () {
                                log("Message Button Taped!");
                              },
                              child: Container(
                                padding: EdgeInsets.all(6.sp),
                                decoration: BoxDecoration(
                                  color: AppColors.c778beb,
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  Assets.icons.messageIcon,
                                ),
                              ),
                            ),
                            UIHelper.horizontalSpace(8.w),

                            ///Section : Call
                            InkWell(
                              onTap: () {
                                log("Call Button Taped!");
                              },
                              child: Container(
                                padding: EdgeInsets.all(6.sp),
                                decoration: BoxDecoration(
                                  color: AppColors.c778beb,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.call,
                                  color: AppColors.cFFFFFF,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Payment Summery
                PaymentSummeryCardWidget(
                  initialPayablePrice: 30.9,
                  otherPartsPrice: 300.5,
                  totalPaymentPrice: 330.14,
                  transactionID: "1234 5678 2345",
                ),
                UIHelper.verticalSpace(55.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/

///
///----------adding video player
///

import 'dart:developer';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/app_constant_text.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:video_player/video_player.dart';

import '../../../../gen/colors.gen.dart';
import '../../../../routes/routes.dart';
import '../../../../custom_widgets/address_and_order_date_tile.dart';
import '../../../../custom_widgets/proof_of_work_showing_widget.dart';
import '../../../../custom_widgets/workCompleteDateAndTimeWidget.dart';

class WorkCompletedDetailsScreen extends StatefulWidget {
  const WorkCompletedDetailsScreen({super.key});

  @override
  State<WorkCompletedDetailsScreen> createState() =>
      _WorkCompletedDetailsScreenState();
}

class _WorkCompletedDetailsScreenState
    extends State<WorkCompletedDetailsScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    // Try multiple video sources - replace with your actual video URL
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      ),
    );

    // Alternative working URLs you can try:
    // Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
    // Uri.parse('https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4')

    // For local asset video, use:
    // _videoController = VideoPlayerController.asset('assets/videos/sample_video.mp4');

    _videoController
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
            log('Video initialized successfully');
          }
        })
        .catchError((error) {
          log('Video initialization error: $error');
          if (mounted) {
            setState(() {
              _isVideoInitialized = false;
            });
          }
        });

    // Add listener for video state changes
    _videoController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized) {
      return Container(
        width: 1.sw,
        height: 200.h,
        decoration: BoxDecoration(
          color: AppColors.c000000.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.c778beb),
              UIHelper.verticalSpace(8.h),
              Text(
                'Loading video...',
                style: TextFontStyle.headline12w400c727272StyleSatoshi,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 1.sw,
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video Player
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),

            // Play/Pause Button Overlay
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_videoController.value.isPlaying) {
                    _videoController.pause();
                  } else {
                    _videoController.play();
                  }
                });
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _videoController.value.isPlaying ? 0.0 : 0.8,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _videoController.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Video Progress Indicator
            Positioned(
              bottom: 8.h,
              left: 8.w,
              right: 8.w,
              child: AnimatedOpacity(
                opacity: _videoController.value.isPlaying ? 0.3 : 0.8,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  height: 4.h,
                  child: VideoProgressIndicator(
                    _videoController,
                    allowScrubbing: true,
                    padding: EdgeInsets.zero,
                    colors: VideoProgressColors(
                      playedColor: AppColors.c778beb,
                      bufferedColor: Colors.white.withOpacity(0.3),
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ),

            // Video Duration Display
            if (!_videoController.value.isPlaying)
              Positioned(
                bottom: 20.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _formatDuration(_videoController.value.duration),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Complete Details",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Work Complete Information ",
                  style: TextFontStyle.headline16w700c000000StyleSatoshi,
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Work Completation Date
                WorkCompleteDateAndTimeWidget(
                  title: "Completion Date",
                  data: "11-08-25",
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Work Duration
                WorkCompleteDateAndTimeWidget(
                  title: "Duration Time",
                  data: "1 Day",
                  isIconVisible: false,
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Working Address
                ///Section : Booking Order Date
                Container(
                  width: 1.sw,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.ce6e6e6),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    children: [
                      ///Section : Working Address
                      AddressAndOrderDateTile(
                        title: "Working Address",
                        icon: Icons.location_on,
                        data: "Rampura Dhaka, Bangladesh",
                      ),
                      UIHelper.verticalSpace(14.h),

                      ///Section : Booking Order Date
                      AddressAndOrderDateTile(
                        title: "Booking Order Date",
                        icon: Icons.watch_later_rounded,
                        data: "Jun 17, 2025  09:31AM",
                      ),
                    ],
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Proof Of Work
                ///Section : Text -> Proof of image
                ///Section : Work Image
                ProofOfWorkShowingWidget(
                  title: "Proof of Image",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: Image.asset(
                      Assets.images.userImage.path,
                      width: 1.sw,
                      height: 200.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Proof Of Work
                ///Section : Text -> Proof of Video
                ///Section : Work Video Player
                ProofOfWorkShowingWidget(
                  title: "Proof of Video",
                  child: _buildVideoPlayer(),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Service Provider Image
                ///Section : Service Provider Name
                ///Section : Service Provider
                ///Section : Message
                ///Section : Call
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.serviceProviderProfileDetailsScreen);
                  },
                  child: Container(
                    width: 1.sw,
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                      color: AppColors.cf7f8fd,
                      border: Border.all(color: AppColors.cb4b4b4),
                      borderRadius: BorderRadius.circular(8.r),

                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ca4b1f2.withAlpha(80),
                          blurRadius: 12.r,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        ///Section : Service Provider Image
                        CircleAvatar(
                          radius: 20.r,
                          backgroundImage: AssetImage(
                            Assets.images.userImage.path,
                          ),
                        ),
                        UIHelper.horizontalSpace(6.w),

                        ///Section : Service Provider Name
                        ///Section : Service Provider
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///Section : Service Provider Name
                            Text(
                              "Ripon Mia",
                              style: TextFontStyle
                                  .headline16w500c202020StyleSatoshi,
                            ),
                            UIHelper.verticalSpace(2.h),

                            ///Section : Service Provider
                            Text(
                              "Services Provider",
                              style: TextFontStyle
                                  .headline10w500c4d4d4dStyleSatoshi,
                            ),
                          ],
                        ),
                        Spacer(),

                        ///Section : Message
                        ///Section : Call
                        Row(
                          children: [
                            ///Section : Message
                            InkWell(
                              onTap: () {
                                log("Message Button Taped!");
                              },
                              child: Container(
                                padding: EdgeInsets.all(6.sp),
                                decoration: BoxDecoration(
                                  color: AppColors.c778beb,
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  Assets.icons.messageIcon,
                                ),
                              ),
                            ),
                            UIHelper.horizontalSpace(8.w),

                            ///Section : Call
                            InkWell(
                              onTap: () {
                                log("Call Button Taped!");
                              },
                              child: Container(
                                padding: EdgeInsets.all(6.sp),
                                decoration: BoxDecoration(
                                  color: AppColors.c778beb,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.call,
                                  color: AppColors.cFFFFFF,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Payment Summery
                Container(
                  width: 1.sw,
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: AppColors.cFFFFFF,
                    border: Border.all(color: AppColors.ce6e6e6),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ca4b1f2.withAlpha(80),
                        blurRadius: 12.r,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///Section : Text -> Payment Summary
                      Text(
                        "Payment Summary",
                        style: TextFontStyle.headline16w700c202020StyleSatoshi,
                      ),
                      UIHelper.verticalSpace(16.h),

                      ///Section : Initial Payment
                      Container(
                        width: 1.sw,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cf1f3fd,
                          border: Border(
                            top: BorderSide(color: AppColors.c778beb),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Initial Cost",
                              style: TextFontStyle
                                  .headline16w700c4d4d4dStyleSatoshi,
                            ),
                            Spacer(),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Start from ${AppText.bdTkSign}",
                                      style: TextFontStyle
                                          .headline12w500c6a6a6aStyleSatoshi,
                                    ),
                                    TextSpan(
                                      text: "${30.90}",
                                      style: TextFontStyle
                                          .headline18w700c778bebStyleSatoshi,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpace(25.h),

                      ///Section : Other Parts
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Other Parts",
                            style:
                                TextFontStyle.headline16w500c202020StyleSatoshi,
                          ),

                          Text(
                            "${AppText.bdTkSign}${300.50}",
                            style:
                                TextFontStyle.headline16w500c202020StyleSatoshi,
                          ),
                        ],
                      ),
                      UIHelper.verticalSpace(25.h),

                      ///Section : Divider
                      DottedLine(
                        direction: Axis.horizontal,
                        lineLength: double.infinity,
                        lineThickness: 1.sp,
                        dashLength: 4.w,
                        dashGapLength: 4.w,
                        dashColor: AppColors.cb4b4b4,
                      ),
                      UIHelper.verticalSpace(12.h),

                      ///Section : Total Payment
                      Container(
                        width: 1.sw,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cf1f3fd,
                          border: Border.all(color: AppColors.ce6e6e6),
                          borderRadius: BorderRadius.circular(8.r),

                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ca4b1f2.withAlpha(80),
                              blurRadius: 12.r,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ///Section : Text-> Total Payment
                            Text(
                              "Total Payment",
                              style: TextFontStyle
                                  .headline16w700c202020StyleSatoshi,
                            ),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpace(10.h),

                      ///Section : Transection ID
                      Container(
                        width: 1.sw,
                        padding: EdgeInsets.all(10.sp),
                        decoration: BoxDecoration(
                          color: AppColors.cFFFFFF,
                          border: Border.all(color: AppColors.ce6e6e6),
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.c000000.withAlpha(40),
                              blurRadius: 12.r,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.sp),
                              decoration: BoxDecoration(
                                color: AppColors.c778beb,
                                borderRadius: BorderRadius.circular(8.sp),
                              ),
                              child: SvgPicture.asset(Assets.icons.walletIcon),
                            ),
                            UIHelper.horizontalSpace(10.w),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Transaction ID",
                                  style: TextFontStyle
                                      .headline16w700c1d242dStyleSatoshi,
                                ),
                                UIHelper.verticalSpace(4.h),
                                Text(
                                  "1234 5678 2345 ",
                                  style: TextFontStyle
                                      .headline12w400c727272StyleSatoshi,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                UIHelper.verticalSpace(55.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/helpers/waiting_widget.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../constants/text_font_style.dart';
import '../../../../../../controllers/svp_profile_screen_documents_tab_controller.dart';
import '../../../../../../custom_widgets/profile_tile_widget.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../normal_user/provider_profile_details/model/profile_tile_model.dart';

class SvpDocumentationTab extends StatefulWidget {
  const SvpDocumentationTab({super.key});

  @override
  State<SvpDocumentationTab> createState() => _SvpDocumentationTabState();
}

class _SvpDocumentationTabState extends State<SvpDocumentationTab> {
  final Map<String, VideoPlayerController> _videoControllers = {};
  final Set<String> _initializedVideos = {};

  @override
  void dispose() {
    // Dispose all video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeVideoController(String videoUrl) {
    if (_videoControllers.containsKey(videoUrl)) return;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl.trim()),
    );

    _videoControllers[videoUrl] = controller;

    controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _initializedVideos.add(videoUrl);
        });
        log('Video initialized: $videoUrl');
      }
    }).catchError((error) {
      log('Failed to load video: $videoUrl | Error: $error');
    });

    controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildVideoPlayer(String videoUrl) {
    final controller = _videoControllers[videoUrl];
    final isInitialized = _initializedVideos.contains(videoUrl);

    if (controller == null || !isInitialized) {
      return Container(
        width: 280.w,
        height: 200.h,
        decoration: BoxDecoration(
          color: AppColors.c000000.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.c778beb),
              UIHelper.verticalSpace(8.h),
              Text(
                'loading_video'.tr,
                style: TextFontStyle.headline12w400c727272StyleSatoshi,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 280.w,
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: controller.value.isPlaying ? 0.0 : 0.8,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        controller.value.isPlaying
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
            Positioned(
              bottom: 8.h,
              left: 8.w,
              right: 8.w,
              child: AnimatedOpacity(
                opacity: controller.value.isPlaying ? 0.3 : 0.8,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  height: 4.h,
                  child: VideoProgressIndicator(
                    controller,
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
            if (!controller.value.isPlaying)
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
                    _formatDuration(controller.value.duration),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            // Video indicator badge
            Positioned(
              top: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam, color: Colors.white, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'video'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(String imageUrl) {
    return Container(
      width: 280.w,
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.ce6e6e6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(child: WaitingWidget()),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 60.sp, color: Colors.grey[400]),
                SizedBox(height: 8.h),
                Text(
                  'failed_to_load_image'.tr,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGallerySection(
    SvpProfileScreenDocumentsTabController controller,
  ) {
    final attachments = controller.providerDocumentDetailsModel.value
            ?.serviceProvider.documentAttachments ??
        [];

    if (attachments.isEmpty) {
      return SizedBox.shrink();
    }

    // Separate images and videos
    final images = attachments
        .where(
          (a) =>
              a.attachmentType?.toLowerCase() == 'image' &&
              a.attachment?.isNotEmpty == true,
        )
        .toList();

    final videos = attachments
        .where(
          (a) =>
              a.attachmentType?.toLowerCase() == 'video' &&
              a.attachment?.isNotEmpty == true,
        )
        .toList();

    // Initialize video controllers
    for (var video in videos) {
      if (video.attachment != null) {
        _initializeVideoController(video.attachment!);
      }
    }

    final allMedia = [...images, ...videos];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UIHelper.verticalSpace(24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'work_gallery'.tr,
            style: TextFontStyle.headline16w700c000000StyleSatoshi,
          ),
        ),
        UIHelper.verticalSpace(12.h),
        SizedBox(
          height: 200.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: allMedia.length,
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final attachment = allMedia[index];
              final isVideo =
                  attachment.attachmentType?.toLowerCase() == 'video';

              if (isVideo && attachment.attachment != null) {
                return _buildVideoPlayer(attachment.attachment!);
              } else if (attachment.attachment != null) {
                return _buildImageItem(attachment.attachment!);
              }
              return SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final SvpProfileScreenDocumentsTabController
        svpProfileScreenDocumentsTabController = Get.put(
      SvpProfileScreenDocumentsTabController(),
    );

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///Section : Profile Image
            ///Section : Name
            ///Section : Ratings
            ///Section : Message
            ///Section : Call
            Card(
              child: Container(
                width: 1.sw,
                decoration: BoxDecoration(
                  color: AppColors.cFFFFFF,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ca4b1f2.withAlpha(80),
                      blurRadius: 12.r,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Obx(() {
                  if (svpProfileScreenDocumentsTabController.loader.value ==
                      true) {
                    return WaitingWidget();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 1.sw,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cf1f3fd,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'provider_documents'.tr,
                              style: TextFontStyle
                                  .headline16w700c000000StyleSatoshi,
                            ),
                            InkWell(
                              onTap: () {
                                log("Navigated to SVP Edit Profile Screen");
                                Get.toNamed(Routes.svpEditDocumentScreen);
                              },
                              child: SvgPicture.asset(Assets.icons.penEditIcon),
                            ),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpace(10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Obx(() {
                          List<ProfileTileModel> userProfileList = [
                            ProfileTileModel(
                              title: "Work Type",
                              data:
                                  "${svpProfileScreenDocumentsTabController.providerDocumentDetailsModel.value?.serviceProvider.serviceCategoryId.name.en} ",
                            ),
                            ProfileTileModel(
                              title: "Services Name",
                              data:
                                  "${svpProfileScreenDocumentsTabController.providerDocumentDetailsModel.value?.serviceProvider.serviceName.en ?? ''} ",
                            ),
                            ProfileTileModel(
                              title: "Year Of Experience",
                              data:
                                  "${svpProfileScreenDocumentsTabController.providerDocumentDetailsModel.value?.serviceProvider.yearsOfExperience ?? 0} ",
                            ),
                            ProfileTileModel(
                              title: "Start from Work Price",
                              data:
                                  "${svpProfileScreenDocumentsTabController.providerDocumentDetailsModel.value?.serviceProvider.startPrice ?? 0} ",
                            ),
                            ProfileTileModel(
                              title: "Intro Bio",
                              data:
                                  "${svpProfileScreenDocumentsTabController.providerDocumentDetailsModel.value?.serviceProvider.introOrBio.en} ",
                            ),
                            ProfileTileModel(
                              title: "Service Description",
                              data:
                                  "${svpProfileScreenDocumentsTabController.providerDocumentDetailsModel.value?.serviceProvider.description.en} ",
                            ),
                          ];
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: userProfileList.length,
                            separatorBuilder: (context, index) =>
                                UIHelper.verticalSpace(10.h),
                            itemBuilder: (context, index) {
                              var data = userProfileList[index];
                              return ProfileTileWidget(
                                onTap: null,
                                title: data.title,
                                data: data.data,
                              );
                            },
                          );
                        }),
                      ),
                      UIHelper.verticalSpace(10.h),
                    ],
                  );
                }),
              ),
            ),

            // Work Gallery Section
            Obx(() {
              if (svpProfileScreenDocumentsTabController.loader.value) {
                return SizedBox.shrink();
              }
              return _buildGallerySection(
                svpProfileScreenDocumentsTabController,
              );
            }),

            SizedBox(height: 24.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                "NID/driving license/passport(font side) image",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Obx(
                () => ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: svpProfileScreenDocumentsTabController
                        .imageFrontSide.value,
                    errorWidget: (context, url, error) => Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey),
                        ),
                        width: Get.width * 0.8,
                        height: 150.h,
                        child: Icon(
                          Icons.photo,
                          size: 60.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                "NID/driving license/passport(back side) image",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Obx(
                () => ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: svpProfileScreenDocumentsTabController
                        .imageBackSide.value,
                    errorWidget: (context, url, error) => Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey),
                        ),
                        width: Get.width * 0.8,
                        height: 150.h,
                        child: Icon(
                          Icons.photo,
                          size: 60.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                "Selfie Image",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 12.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Obx(
                () => ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: svpProfileScreenDocumentsTabController
                        .imageSelfie.value,
                    errorWidget: (context, url, error) => Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey),
                        ),
                        width: Get.width * 0.8,
                        height: 150.h,
                        child: Icon(
                          Icons.photo,
                          size: 60.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 200.h),
          ],
        ),
      ),
    );
  }
}

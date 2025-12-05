import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/helpers/waiting_widget.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../constants/text_font_style.dart';
import '../../../../../../controllers/svp_profile_screen_documents_tab_controller.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';

class SvpDocumentEditPage extends StatelessWidget {
  const SvpDocumentEditPage({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildVideoPlayer(
    String videoUrl,
    VideoPlayerController controller,
    bool isInitialized,
  ) {
    if (!isInitialized) {
      return Container(
        width: 150.w,
        height: 150.h,
        decoration: BoxDecoration(
          color: AppColors.c000000.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.c778beb),
        ),
      );
    }

    return Container(
      width: 150.w,
      height: 150.h,
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
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!controller.value.isPlaying)
              Positioned(
                bottom: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _formatDuration(controller.value.duration),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SvpProfileScreenDocumentsTabController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,

        title: Text(
          "Edit Documents",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.loader.value) {
            return Center(child: WaitingWidget());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Name
                _buildTextField(
                  label: "Service Name",
                  controller: controller.servicesNameController,
                ),
                UIHelper.verticalSpace(16.h),

                // Years of Experience
                _buildTextField(
                  label: "Years of Experience",
                  controller: controller.yearsOfExperienceController,
                  keyboardType: TextInputType.number,
                ),
                UIHelper.verticalSpace(16.h),

                // Start Price
                _buildTextField(
                  label: "Start Price",
                  controller: controller.initialPayableController,
                  keyboardType: TextInputType.number,
                ),
                UIHelper.verticalSpace(16.h),

                // Intro/Bio
                _buildTextField(
                  label: "Intro/Bio",
                  controller: controller.introController,
                  maxLines: 3,
                ),
                UIHelper.verticalSpace(16.h),

                // Description
                _buildTextField(
                  label: "Description",
                  controller: controller.descriptionController,
                  maxLines: 5,
                ),
                UIHelper.verticalSpace(24.h),

                // Gallery Section
                Text(
                  "Gallery (Images & Videos)",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                UIHelper.verticalSpace(8.h),
                Text(
                  "Maximum ${controller.maxMedia} items allowed",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                UIHelper.verticalSpace(12.h),

                // Existing Attachments + New Media
                Obx(() {
                  final attachments =
                      controller
                          .providerDocumentDetailsModel
                          .value
                          ?.serviceProvider
                          .documentAttachments ??
                      [];

                  final visibleAttachments = attachments.where((att) {
                    return !controller.isAttachmentMarkedForDeletion(
                      att.id ?? '',
                    );
                  }).toList();

                  if (visibleAttachments.isEmpty &&
                      controller.selectedMedia.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          "No gallery items",
                          style:
                              TextFontStyle.headline12w400c727272StyleSatoshi,
                        ),
                      ),
                    );
                  }

                  return Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: [
                      // Existing attachments from server
                      ...visibleAttachments.map((attachment) {
                        final isVideo =
                            attachment.attachmentType?.toLowerCase() == 'video';
                        final url = attachment.attachment ?? '';
                        final attachmentId = attachment.id ?? '';

                        if (url.isEmpty) return SizedBox.shrink();

                        return Stack(
                          children: [
                            Container(
                              width: 150.w,
                              height: 150.h,
                              child: isVideo
                                  ? Obx(() {
                                      final videoController =
                                          controller.videoControllers[url];
                                      final isInitialized = controller
                                          .initializedVideos
                                          .contains(url);

                                      if (videoController == null) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text('Video unavailable'),
                                          ),
                                        );
                                      }

                                      return _buildVideoPlayer(
                                        url,
                                        videoController,
                                        isInitialized,
                                      );
                                    })
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: CachedNetworkImage(
                                        imageUrl: url,
                                        width: 150.w,
                                        height: 150.h,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                              color: Colors.grey.shade200,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: AppColors.c778beb,
                                                    ),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              color: Colors.grey.shade200,
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 40.sp,
                                                color: Colors.grey,
                                              ),
                                            ),
                                      ),
                                    ),
                            ),
                            // Delete button
                            Positioned(
                              top: 4.h,
                              right: 4.w,
                              child: GestureDetector(
                                onTap: () {
                                  Get.dialog(
                                    AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          15.0,
                                        ),
                                      ),
                                      title: Text(
                                        'Delete Attachment',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors
                                              .red, // Custom color for title
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to delete this item?',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      actions: [
                                        // Cancel Button with improved styling
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20.0,
                                              vertical: 10.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.blueAccent,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Delete Button with a custom style
                                        TextButton(
                                          onPressed: () {
                                            controller
                                                .markAttachmentForDeletion(
                                                  attachmentId,
                                                );
                                            Get.back();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20.0,
                                              vertical: 10.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4.sp),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),

                      // New selected media (images/videos)
                      ...controller.selectedMedia.asMap().entries.map((entry) {
                        final index = entry.key;
                        final media = entry.value;
                        final isVideo = controller.isVideo(media.path);

                        return Stack(
                          children: [
                            Container(
                              width: 150.w,
                              height: 150.h,
                              child: isVideo
                                  ? Obx(() {
                                      final videoController = controller
                                          .videoControllers[media.path];
                                      final isInitialized = controller
                                          .initializedVideos
                                          .contains(media.path);

                                      if (videoController == null ||
                                          !isInitialized) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  color: AppColors.c778beb,
                                                ),
                                                UIHelper.verticalSpace(8.h),
                                                Text(
                                                  'Loading...',
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      return _buildVideoPlayer(
                                        media.path,
                                        videoController,
                                        true,
                                      );
                                    })
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Image.file(
                                        File(media.path),
                                        width: 150.w,
                                        height: 150.h,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            // Delete button
                            Positioned(
                              top: 4.h,
                              right: 4.w,
                              child: GestureDetector(
                                onTap: () =>
                                    controller.removeGalleryMedia(index),
                                child: Container(
                                  padding: EdgeInsets.all(4.sp),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                ),
                              ),
                            ),
                            // New badge
                            Positioned(
                              bottom: 4.h,
                              left: 4.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Video indicator badge
                            if (isVideo)
                              Positioned(
                                top: 4.h,
                                left: 4.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.videocam,
                                        color: Colors.white,
                                        size: 10.sp,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'VIDEO',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ],
                  );
                }),

                UIHelper.verticalSpace(16.h),

                // Add Media Button
                Obx(() {
                  final totalExisting =
                      (controller
                              .providerDocumentDetailsModel
                              .value
                              ?.serviceProvider
                              .documentAttachments
                              ?.length ??
                          0) -
                      controller.attachmentsToDelete.length;
                  final totalNew = controller.selectedMedia.length;
                  final canAddMore =
                      (totalExisting + totalNew) < controller.maxMedia;

                  return ElevatedButton.icon(
                    onPressed: canAddMore
                        ? controller.showMediaPickerDialog
                        : null,
                    icon: Icon(Icons.add_photo_alternate),
                    label: Text('Add Images/Videos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.c778beb,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  );
                }),

                UIHelper.verticalSpace(32.h),

                // Save Button
                Obx(() {
                  return ElevatedButton(
                    onPressed: controller.loader.value
                        ? null
                        : () => controller.updateProviderDocuments(
                            serviceProviderDetailsId:
                                controller
                                    .providerDocumentDetailsModel
                                    .value
                                    ?.serviceProvider
                                    .id ??
                                '',
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.c778beb,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 52.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: controller.loader.value
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                }),

                UIHelper.verticalSpace(32.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        UIHelper.verticalSpace(8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.c778beb, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }
}

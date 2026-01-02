/**


import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/payment_summery_widget.dart';
import 'package:kaz_bd/controllers/svp_submit_work_form_screen_controller.dart';
import 'package:kaz_bd/custom_widgets/work_address_and_date_widget.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/custom_widgets/more_info_widget_tile.dart';

class SvpSubmitWorkFormScreen extends StatefulWidget {
  const SvpSubmitWorkFormScreen({super.key});

  @override
  State<SvpSubmitWorkFormScreen> createState() =>
      _SvpSubmitWorkFormScreenState();
}

class _SvpSubmitWorkFormScreenState extends State<SvpSubmitWorkFormScreen> {
  final SvpSubmitWorkFormScreenController controller =
      Get.put(SvpSubmitWorkFormScreenController());
  final RxBool isMediaCompleted = false.obs;

  // Store video controllers for different videos
  VideoPlayerController? _currentVideoController;
  ChewieController? _currentChewieController;
  bool _isVideoInitializing = false;

  @override
  void initState() {
    super.initState();
    log("🔄 Screen initialized");
    log("📦 Arguments received: ${Get.arguments}");
    log("📦 Arguments type: ${Get.arguments.runtimeType}");

    SchedulerBinding.instance.addPostFrameCallback((_) {
      log("🎯 Controller bookingId: ${controller.bookingId.value}");
      log("🎯 Controller storedBookingId: ${controller.storedBookingId}");

      if (controller.bookingId.value.isEmpty) {
        log("⚠️ No booking ID found, calling loadWorkDetails...");
        controller.loadWorkDetails();
      }
    });
  }

  @override
  void dispose() {
    // Dispose all video controllers
    _disposeVideoControllers();
    super.dispose();
  }

  void _disposeVideoControllers() {
    log("🗑️ Disposing video controllers");
    _currentChewieController?.pause();
    _currentChewieController?.dispose();
    _currentChewieController = null;

    _currentVideoController?.pause();
    _currentVideoController?.dispose();
    _currentVideoController = null;

    _isVideoInitializing = false;
  }

  // Function to show media in fullscreen dialog
  void _showMediaInDialog(String mediaUrl, String? title, String mediaType) {
    if (mediaType == 'video') {
      _showVideoDialog(mediaUrl, title);
    } else {
      _showImageDialog(mediaUrl, title);
    }
  }

  void _showImageDialog(String imageUrl, String? title) {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.all(20.w),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (title != null && title.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 0.9.sw,
                        maxHeight: 0.7.sh,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => SizedBox(
                            width: 200.w,
                            height: 200.h,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 200.w,
                            height: 200.h,
                            color: Colors.grey.shade800,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 48.h,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'failed_to_load_image'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Get.back(),
                behavior: HitTestBehavior.translucent,
              ),
            ),
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.7),
    );
  }

  void _showVideoDialog(String videoUrl, String? title) async {
    if (_isVideoInitializing) {
      log("⏳ Video already initializing, skipping...");
      return;
    }

    _isVideoInitializing = true;

    try {
      // Show loading dialog first
      Get.dialog(
        Dialog(
          backgroundColor: Colors.black,
          child: Container(
            padding: EdgeInsets.all(40.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20.h),
                Text(
                  'loading_video'.tr,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.8),
      );

      // Dispose previous controllers
      _disposeVideoControllers();

      // Initialize video player
      log("🎬 Initializing video player for URL: $videoUrl");
      _currentVideoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
      );

      // Set up error handling
      _currentVideoController!.addListener(() {
        if (_currentVideoController!.value.hasError) {
          log("❌ Video player error: ${_currentVideoController!.value.errorDescription}");
        }
      });

      // Initialize with timeout
      final initialization = _currentVideoController!.initialize();
      final timeout = Future.delayed(Duration(seconds: 30), () {
        throw TimeoutException("Video initialization timed out");
      });

      await Future.any([initialization, timeout]);

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      _currentChewieController = ChewieController(
          videoPlayerController: _currentVideoController!,
          autoPlay: true,
          looping: false,
          showControls: true,
          allowFullScreen: true,
          allowMuting: true,
          allowPlaybackSpeedChanging: true,
          aspectRatio: _currentVideoController!.value.aspectRatio,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.c000e08,
            handleColor: AppColors.c000e08,
            backgroundColor: Colors.grey.shade300,
            bufferedColor: Colors.grey.shade400,
          ),
          placeholder: Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.white, size: 48.h),
                    SizedBox(height: 16.h),
                    Text(
                      'failed_to_load_video'.tr,
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      errorMessage ?? 'unknown_error'.tr,
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _isVideoInitializing = false;
                        _showVideoDialog(videoUrl, title);
                      },
                      child: Text('retry'.tr),
                    ),
                  ],
                ),
              ),
            );
          });

      // Show the video dialog
      Get.dialog(
        Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title ?? 'video_preview'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 24.h),
                      onPressed: () {
                        _disposeVideoControllers();
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),

              // Video Player
              Container(
                width: double.infinity,
                height: 300.h,
                child: Chewie(controller: _currentChewieController!),
              ),

              // Video Info
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Icon(Icons.videocam, color: Colors.white70, size: 20.h),
                    SizedBox(width: 8.w),
                    Text(
                      'video_file'.tr,
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                    Spacer(),
                    Text(
                      'tap_to_play_pause'.tr,
                      style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.8),
      ).then((_) {
        // Clean up when dialog is closed
        _disposeVideoControllers();
      });
    } catch (e, stackTrace) {
      // Close loading dialog if it's open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      log("❌ Error loading video: $e");
      log("📋 Stack trace: $stackTrace");

      _disposeVideoControllers();

      Get.snackbar(
        'error'.tr,
        "${'failed_to_load_video'.tr}: ${e.toString().split(':').first}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      _isVideoInitializing = false;
    }
  }

  // Function to show local video file
  void _showLocalVideoDialog(File videoFile, String? title) async {
    if (_isVideoInitializing) {
      log("⏳ Video already initializing, skipping...");
      return;
    }

    _isVideoInitializing = true;

    try {
      // Show loading dialog
      Get.dialog(
        Dialog(
          backgroundColor: Colors.black,
          child: Container(
            padding: EdgeInsets.all(40.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20.h),
                Text(
                  'loading_video'.tr,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.8),
      );

      // Dispose previous controllers
      _disposeVideoControllers();

      log("🎬 Initializing local video player for file: ${videoFile.path}");
      _currentVideoController = VideoPlayerController.file(videoFile);
      await _currentVideoController!.initialize();

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      _currentChewieController = ChewieController(
        videoPlayerController: _currentVideoController!,
        autoPlay: true,
        looping: false,
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        aspectRatio: _currentVideoController!.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.c000e08,
          handleColor: AppColors.c000e08,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: Colors.grey.shade400,
        ),
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );

      Get.dialog(
        Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title ?? 'video_preview'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 24.h),
                      onPressed: () {
                        _disposeVideoControllers();
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 300.h,
                child: Chewie(controller: _currentChewieController!),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Icon(Icons.videocam, color: Colors.white70, size: 20.h),
                    SizedBox(width: 8.w),
                    Text(
                      'local_video'.tr,
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                    Spacer(),
                    Text(
                      '${(videoFile.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
                      style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.8),
      ).then((_) {
        // Clean up when dialog is closed
        _disposeVideoControllers();
      });
    } catch (e, stackTrace) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      log("❌ Error loading local video: $e");
      log("📋 Stack trace: $stackTrace");

      _disposeVideoControllers();

      Get.snackbar(
        'error'.tr,
        "${'failed_to_load_video'.tr}: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      _isVideoInitializing = false;
    }
  }

  // Function to show local image file
  void _showLocalImageDialog(File imageFile, String? title) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title ?? 'Image Preview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 24.h),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: 500.h),
              child: Image.file(imageFile, fit: BoxFit.contain),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Icon(Icons.image, color: Colors.white70, size: 20.h),
                  SizedBox(width: 8.w),
                  Text(
                    'Local Image',
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                  Spacer(),
                  Text(
                    '${(imageFile.lengthSync() / 1024).toStringAsFixed(2)} KB',
                    style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8),
    );
  }

  // Function to get file type icon
  Widget _getFileTypeIcon(String path) {
    final fileName = path.toLowerCase();
    if (fileName.endsWith('.mp4') ||
        fileName.endsWith('.mov') ||
        fileName.endsWith('.avi') ||
        fileName.endsWith('.mkv') ||
        fileName.endsWith('.wmv')) {
      return Icon(Icons.videocam, color: Colors.red, size: 24.h);
    } else if (fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif')) {
      return Icon(Icons.image, color: Colors.blue, size: 24.h);
    } else {
      return Icon(Icons.insert_drive_file, color: Colors.grey, size: 24.h);
    }
  }

  // Function to check if file is video
  bool _isVideoFile(String path) {
    final fileName = path.toLowerCase();
    return fileName.endsWith('.mp4') ||
        fileName.endsWith('.mov') ||
        fileName.endsWith('.avi') ||
        fileName.endsWith('.mkv') ||
        fileName.endsWith('.wmv');
  }

  // Function to check if file is image
  bool _isImageFile(String path) {
    final fileName = path.toLowerCase();
    return fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif');
  }

  Future<void> _uploadMediaFiles() async {
    String bookingIdToUse = controller.bookingId.value.isNotEmpty
        ? controller.bookingId.value
        : controller.storedBookingId;

    if (bookingIdToUse.isEmpty) {
      Get.snackbar(
        "Error",
        "Booking ID not found. Please refresh the page.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (controller.mediaFiles.isEmpty) {
      Get.snackbar(
        "Info",
        "No new files to upload",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final List<File> fileObjects = [];

      for (final mediaFile in controller.mediaFiles) {
        final file = File(mediaFile.path);
        if (file.existsSync()) {
          fileObjects.add(file);
        }
      }

      if (fileObjects.isEmpty) {
        Get.snackbar(
          "Error",
          "No valid files to upload",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      log("📤 Uploading ${fileObjects.length} media files for Booking ID: $bookingIdToUse");

      final response = await controller.uploadMultipleMediaFiles(
        bookingId: bookingIdToUse,
        files: fileObjects,
      );

      if (response.isSuccess) {
        isMediaCompleted.value = true;
        controller.clearMediaFilesAfterUpload();

        Get.snackbar(
          "Success",
          "${fileObjects.length} file(s) uploaded successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        await _handleRefresh();
      } else {
        final errorMsg = response.errorMessage ?? "Failed to upload files";
        Get.snackbar(
          "Upload Failed",
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      log("Error uploading media: $e", error: e, stackTrace: stackTrace);
      Get.snackbar(
        "Error",
        "Failed to upload files: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleRefresh() async {
    log("🔄 Pull-to-refresh started...");

    try {
      String bookingIdToUse = controller.bookingId.value;

      if (bookingIdToUse.isEmpty) {
        bookingIdToUse = controller.storedBookingId;
        log("🔄 Using stored booking ID: $bookingIdToUse");
      }

      if (bookingIdToUse.isEmpty) {
        final args = Get.arguments;
        if (args != null) {
          if (args is Map) {
            final bookingIdFromArgs = args['bookingId']?.toString();
            if (bookingIdFromArgs != null && bookingIdFromArgs.isNotEmpty) {
              bookingIdToUse = bookingIdFromArgs;
              controller.bookingId.value = bookingIdToUse;
              log("🔄 Retrieved booking ID from arguments: $bookingIdToUse");
            }
          } else if (args is String) {
            bookingIdToUse = args;
            controller.bookingId.value = bookingIdToUse;
            log("🔄 Retrieved booking ID as string: $bookingIdToUse");
          }
        }
      }

      if (bookingIdToUse.isEmpty) {
        log("⚠️ No booking ID available for refresh");
        Get.snackbar("Info", "No booking information found",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 2));
        return;
      }

      log("📡 Refreshing with Booking ID: $bookingIdToUse");
      await controller.loadWorkDetails();
      log("✅ Refresh completed successfully");
    } catch (e, stackTrace) {
      log("❌ Refresh error: $e", error: e, stackTrace: stackTrace);

      String errorMessage = "Failed to refresh data";
      if (e is SocketException) {
        errorMessage = "No internet connection";
      } else if (e is TimeoutException) {
        errorMessage = "Request timed out";
      } else if (e is HttpException) {
        errorMessage = "Server error";
      }

      Get.snackbar("Error", errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3));

      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isLoadingWorkDetails.value
                  ? 'loading'.tr
                  : 'submit_work_form'.tr,
              style: TextFontStyle.headline18w700c000000StyleSatoshi,
            )),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.h),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingWorkDetails.value) {
          return Center(
              child: CircularProgressIndicator(color: AppColors.c000e08));
        }

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.c000e08,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 20.h),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: UIHelper.kDefaulutPadding()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Section: Working Address & Booking Order Date
                  WorkAddressAndDateWidget(
                    address: controller.address.value.isNotEmpty
                        ? controller.address.value
                        : 'address_not_available'.tr,
                    dateTime: controller.bookingDateTime.value.isNotEmpty
                        ? controller.bookingDateTime.value
                        : 'date_not_valid'.tr,
                  ),
                  UIHelper.verticalSpace(24.h),

                  /// Section: Proof Of Work Complete Information
                  Text(
                    'proof_of_work_completed_information'.tr,
                    style: TextFontStyle.headline16w700c202020StyleSatoshi,
                  ),
                  UIHelper.verticalSpace(16.h),

                  /// Section: Completion Date
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        controller.onCompletionDateSelected(picked);
                      }
                    },
                    child: MoreInfoWidgetTile(
                      title: 'completation_date'.tr,
                      hintText: 'select_date'.tr,
                      isEnabled: false,
                      controller: controller.completionDateController,
                    ),
                  ),

                  UIHelper.verticalSpace(16.h),

                  /// Section: Duration Time (Auto-calculated)
                  MoreInfoWidgetTile(
                    title: 'duration_time'.tr,
                    hintText:
                        'auto_calculated_after_selecting_completion_date'.tr,
                    isEnabled: false,
                    controller: controller.durationTimeController,
                  ),

                  UIHelper.verticalSpace(24.h),

                  /// Section: Existing API Attachments
                  Obx(() {
                    if (controller.apiAttachments.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'existing_proof_files'.tr,
                                style: TextFontStyle
                                    .headline16w700c202020StyleSatoshi,
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: AppColors.c000e08,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  '${controller.apiAttachments.length}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          UIHelper.verticalSpace(12.h),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: controller.apiAttachments
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final attachment = entry.value;
                                    final mediaUrl =
                                        controller.getImageUrl(attachment.url);
                                    final isVideo =
                                        attachment.type == 'video' ||
                                            attachment.url
                                                .toLowerCase()
                                                .contains('.mp4') ||
                                            attachment.url
                                                .toLowerCase()
                                                .contains('.mov') ||
                                            attachment.url
                                                .toLowerCase()
                                                .contains('.avi') ||
                                            attachment.url
                                                .toLowerCase()
                                                .contains('.mkv');

                                    // Video thumbnail
                                    if (isVideo) {
                                      return GestureDetector(
                                        onTap: () {
                                          log("🎬 Playing API video: $mediaUrl");
                                          _showVideoDialog(mediaUrl,
                                              "${'proof_file'.tr} ${index + 1}");
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 80.w,
                                              height: 80.h,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                                color: Colors.black,
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 40.w,
                                                      height: 40.h,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.7),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.play_arrow,
                                                        color: Colors.white,
                                                        size: 24.h,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Text(
                                                      'VIDEO',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 4,
                                              left: 4,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 4.w,
                                                    vertical: 2.h),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.6),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.r),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.videocam,
                                                        color: Colors.white,
                                                        size: 10),
                                                    SizedBox(width: 2.w),
                                                    Text(
                                                      '${index + 1}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    // Image thumbnail
                                    return GestureDetector(
                                      onTap: () {
                                        _showImageDialog(mediaUrl,
                                            "${'proof_file'.tr} ${index + 1}");
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 80.w,
                                            height: 80.h,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              child: CachedNetworkImage(
                                                imageUrl: mediaUrl,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Center(
                                                  child: Icon(Icons.error,
                                                      color: Colors.red,
                                                      size: 24),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 4,
                                            left: 4,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4.w,
                                                  vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.image,
                                                      color: Colors.white,
                                                      size: 10),
                                                  SizedBox(width: 2.w),
                                                  Text(
                                                    '${index + 1}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                UIHelper.verticalSpace(8.h),
                                Text(
                                  'tap_on_any_file_to_see_preview'.tr,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          UIHelper.verticalSpace(16.h),
                        ],
                      );
                    }
                    return SizedBox();
                  }),

                  /// Section: Upload new media files
                  Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'add_new_proof_files'.tr,
                          style:
                              TextFontStyle.headline16w700c202020StyleSatoshi,
                        ),
                        UIHelper.verticalSpace(12.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.ce6e6e6),
                          ),
                          child: Column(
                            children: [
                              // Media files list
                              if (controller.mediaFiles.isNotEmpty)
                                Column(
                                  children: [
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: controller.mediaFiles.length,
                                      separatorBuilder: (context, index) =>
                                          Divider(height: 16.h),
                                      itemBuilder: (context, index) {
                                        final mediaFile =
                                            controller.mediaFiles[index];
                                        final isVideo =
                                            _isVideoFile(mediaFile.path);
                                        final isImage =
                                            _isImageFile(mediaFile.path);
                                        final fileName =
                                            mediaFile.path.split('/').last;

                                        Widget previewWidget;

                                        if (isImage) {
                                          previewWidget = GestureDetector(
                                            onTap: () {
                                              final file = File(mediaFile.path);
                                              _showLocalImageDialog(
                                                  file, fileName);
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6.r),
                                              child: Container(
                                                width: 60.w,
                                                height: 60.h,
                                                color: Colors.grey.shade200,
                                                child: Image.file(
                                                  File(mediaFile.path),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      color:
                                                          Colors.grey.shade300,
                                                      child: Icon(Icons.image,
                                                          color: Colors.grey,
                                                          size: 24.h),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        } else if (isVideo) {
                                          previewWidget = GestureDetector(
                                            onTap: () {
                                              final file = File(mediaFile.path);
                                              log("🎬 Playing local video: ${file.path}");
                                              _showLocalVideoDialog(
                                                  file, fileName);
                                            },
                                            child: Container(
                                              width: 60.w,
                                              height: 60.h,
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius:
                                                    BorderRadius.circular(6.r),
                                              ),
                                              child: Center(
                                                child: Container(
                                                  width: 30.w,
                                                  height: 30.h,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 18.h,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          previewWidget = GestureDetector(
                                            onTap: () {
                                              Get.snackbar(
                                                'Info',
                                                'This file type cannot be previewed',
                                                backgroundColor: Colors.blue,
                                                colorText: Colors.white,
                                              );
                                            },
                                            child: _getFileTypeIcon(
                                                mediaFile.path),
                                          );
                                        }

                                        return Container(
                                          padding: EdgeInsets.all(12.w),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                            border: Border.all(
                                                color: Colors.grey.shade200),
                                          ),
                                          child: Row(
                                            children: [
                                              previewWidget,
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      fileName,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Text(
                                                      isVideo
                                                          ? 'Video file'
                                                          : isImage
                                                              ? 'Image file'
                                                              : 'Document',
                                                      style: TextStyle(
                                                        fontSize: 11.sp,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: Colors.red,
                                                    size: 20.h),
                                                onPressed: () async {
                                                  await controller
                                                      .removeMediaFile(index);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    UIHelper.verticalSpace(16.h),
                                  ],
                                ),

                              // Add New Files button
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.ce6e6e6,
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    log("Browse Button Tapped");
                                    controller.showMediaSourceDialog();
                                  },
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20.h, horizontal: 16.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: AppColors.c000e08,
                                          size: 20.h,
                                        ),
                                        UIHelper.horizontalSpace(10.w),
                                        Text(
                                          'add_new_files'.tr,
                                          style: TextFontStyle
                                              .headline12w700c000e08StyleSatoshi,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // File type hint
                              UIHelper.verticalSpace(12.h),
                              Text(
                                "Supported: Images (.jpg, .png, .gif) and Videos (.mp4, .mov, .avi)",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

                  UIHelper.verticalSpace(16.h),

                  /// Section: Media Done Button
                  Obx(() {
                    final hasNewMedia = controller.mediaFiles.isNotEmpty;
                    final showMediaDoneButton =
                        hasNewMedia && !isMediaCompleted.value;

                    if (!showMediaDoneButton) {
                      return SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (controller.isUploadingMedia.value)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border:
                                      Border.all(color: Colors.blue.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16.h,
                                      height: 16.h,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'uploading'.tr,
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              CustomElevatedButton(
                                onTap: _uploadMediaFiles,
                                buttonWidth: 120.w,
                                buttonHeight: 36.h,
                                buttonTitle: 'Upload'.tr,
                              ),
                          ],
                        ),
                        UIHelper.verticalSpace(24.h),
                      ],
                    );
                  }),

                  /// Section: Payment Summary
                  Obx(() {
                    return PaymentSummeryWidget(
                      initialCost: controller.initialCost.value,
                      additionalCostList: controller.additionalCosts.toList(),
                      totalPayment: controller.calculateTotalPayment(),
                      isAddAdditionalCostButtonVisible: true,
                      enableDelete: true,
                      onTap: () async{
                        _showAddAdditionalCostDialog();
                      },

                      onDelete: () async {
                        // Refresh after delete
                        await _handleRefresh();
                        await _handleRefresh();
                      },
                    );
                  }),
                  UIHelper.verticalSpace(16.h),

                  /// Section: Payment Request Button
                  Obx(() {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: CustomElevatedButton(
                        onTap: controller.isPaymentRequestLoading.value
                            ? null
                            : () {
                                _requestPayment();
                              },
                        buttonTitle: controller.isPaymentRequestLoading.value
                            ? 'requesting'.tr
                            : 'request_payment'.tr,
                      ),
                    );
                  }),
                  UIHelper.verticalSpace(32.h),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // Additional Cost Dialog
  Future<void> _showAddAdditionalCostDialog() async {
    final TextEditingController additionalCostTitle = TextEditingController();
    final TextEditingController additionalCost = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cFFFFFF,
        title: Text(
          'add_additional_cost'.tr,
          style: TextFontStyle.headline16w500c000000StyleSatoshi,
        ),
        content: Form(
          key: formKey,
          child: Container(
            width: 1.sw,
            decoration: BoxDecoration(color: AppColors.cFFFFFF),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  maxLength: 25,
                  controller: additionalCostTitle,
                  decoration: InputDecoration(
                    hintText: 'enter_cost_title'.tr,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.ce6e6e6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'please_enter_cost_title'.tr;
                    }
                    return null;
                  },
                ),
                UIHelper.verticalSpace(10.h),
                TextFormField(
                  controller: additionalCost,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'enter_cost_amount'.tr,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.ce6e6e6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'please_enter_cost_amount'.tr;
                    }
                    final price = double.tryParse(value.trim());
                    if (price == null || price <= 0) {
                      return 'please_enter_valid_amount'.tr;
                    }
                    return null;
                  },
                ),
                UIHelper.verticalSpace(10.h),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  'cancel'.tr,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              CustomElevatedButton(
                onTap: () async {
                  if (formKey.currentState != null &&
                      formKey.currentState!.validate()) {
                    final name = additionalCostTitle.text.trim();
                    final price = double.parse(additionalCost.text.trim());

                    final success =
                        await controller.addAdditionalCost(name, price);

                    if (success) {
                      Get.back();
                    }
                  }
                },
                buttonWidth: 107.w,
                buttonHeight: 38.h,
                buttonTitle: 'save'.tr,
              ),
            ],
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _requestPayment() {
    if (controller.completionDateController.text.isEmpty) {
      Get.snackbar('warning'.tr, 'please_select_completation_date'.tr);
      return;
    }

    if (controller.durationTimeController.text.isEmpty) {
      Get.snackbar('warning'.tr, 'please_enter_duration_time'.tr);
      return;
    }

    final duration = double.tryParse(controller.durationTimeController.text);
    if (duration == null) {
      Get.snackbar('warning'.tr, 'please_enter_a_valid_number_for_duration'.tr);
      return;
    }

    final totalMedia = controller.totalMediaCount;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: AppColors.c000e08),
            SizedBox(width: 8.w),
            Text('request_payment'.tr,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('you_are_about_request_payment_with_these_details'.tr,
                  style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 16.h),
              _buildDetailRow("${'completation_date'.tr}:",
                  controller.completionDateController.text),
              _buildDetailRow('duration'.tr,
                  "${controller.durationTimeController.text} ${'days'.tr}"),
              _buildDetailRow('total_files'.tr, "$totalMedia"),
              if (controller.apiAttachments.isNotEmpty)
                _buildDetailRow("  - ${'existing_files'.tr}",
                    "${controller.apiAttachments.length}"),
              if (controller.mediaFiles.isNotEmpty)
                _buildDetailRow(
                    "  - ${'new_files'.tr}", "${controller.mediaFiles.length}"),
              SizedBox(height: 12.h),
              Divider(),
              SizedBox(height: 12.h),
              _buildDetailRow("${'initial_cost'.tr}:",
                  "\${controller.initialCost.value.toStringAsFixed(2)}"),
              if (controller.additionalCosts.isNotEmpty)
                _buildDetailRow("${'additional_cost'.tr}:",
                    "\${(controller.calculateTotalPayment() - controller.initialCost.value).toStringAsFixed(2)}"),
              SizedBox(height: 8.h),
              _buildDetailRow(
                "${'total_payment'.tr}:",
                "\${controller.calculateTotalPayment().toStringAsFixed(2)}",
                isBold: true,
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'the_client_will_be_notified_about_this_payment_request'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue.shade900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr,
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.requestPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.c778beb,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text('send_request'.tr,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ));
  }
}



 */




///
///
///
///
/// todo:: fixing the payment summery bug
///
///
///
///
///




import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/custom_widgets/payment_summery_widget.dart';
import 'package:kaz_bd/controllers/svp_submit_work_form_screen_controller.dart';
import 'package:kaz_bd/custom_widgets/work_address_and_date_widget.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/custom_widgets/more_info_widget_tile.dart';

class SvpSubmitWorkFormScreen extends StatefulWidget {
  const SvpSubmitWorkFormScreen({super.key});

  @override
  State<SvpSubmitWorkFormScreen> createState() =>
      _SvpSubmitWorkFormScreenState();
}

class _SvpSubmitWorkFormScreenState extends State<SvpSubmitWorkFormScreen> {
  final SvpSubmitWorkFormScreenController controller =
  Get.put(SvpSubmitWorkFormScreenController());
  final RxBool isMediaCompleted = false.obs;

  // Store video controllers for different videos
  VideoPlayerController? _currentVideoController;
  ChewieController? _currentChewieController;
  bool _isVideoInitializing = false;

  @override
  void initState() {
    super.initState();
    log("🔄 Screen initialized");
    log("📦 Arguments received: ${Get.arguments}");
    log("📦 Arguments type: ${Get.arguments.runtimeType}");

    SchedulerBinding.instance.addPostFrameCallback((_) {
      log("🎯 Controller bookingId: ${controller.bookingId.value}");
      log("🎯 Controller storedBookingId: ${controller.storedBookingId}");

      if (controller.bookingId.value.isEmpty) {
        log("⚠️ No booking ID found, calling loadWorkDetails...");
        controller.loadWorkDetails();
      }
    });
  }

  @override
  void dispose() {
    // Dispose all video controllers
    _disposeVideoControllers();
    super.dispose();
  }

  void _disposeVideoControllers() {
    log("🗑️ Disposing video controllers");
    _currentChewieController?.pause();
    _currentChewieController?.dispose();
    _currentChewieController = null;

    _currentVideoController?.pause();
    _currentVideoController?.dispose();
    _currentVideoController = null;

    _isVideoInitializing = false;
  }

  // Function to show media in fullscreen dialog
  void _showMediaInDialog(String mediaUrl, String? title, String mediaType) {
    if (mediaType == 'video') {
      _showVideoDialog(mediaUrl, title);
    } else {
      _showImageDialog(mediaUrl, title);
    }
  }

  void _showImageDialog(String imageUrl, String? title) {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.all(20.w),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (title != null && title.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 0.9.sw,
                        maxHeight: 0.7.sh,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => SizedBox(
                            width: 200.w,
                            height: 200.h,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 200.w,
                            height: 200.h,
                            color: Colors.grey.shade800,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 48.h,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'failed_to_load_image'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Get.back(),
                behavior: HitTestBehavior.translucent,
              ),
            ),
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.7),
    );
  }

  void _showVideoDialog(String videoUrl, String? title) async {
    if (_isVideoInitializing) {
      log("⏳ Video already initializing, skipping...");
      return;
    }

    _isVideoInitializing = true;

    try {
      // Show loading dialog first
      Get.dialog(
        Dialog(
          backgroundColor: Colors.black,
          child: Container(
            padding: EdgeInsets.all(40.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20.h),
                Text(
                  'loading_video'.tr,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.8),
      );

      // Dispose previous controllers
      _disposeVideoControllers();

      // Initialize video player
      log("🎬 Initializing video player for URL: $videoUrl");
      _currentVideoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
      );

      // Set up error handling
      _currentVideoController!.addListener(() {
        if (_currentVideoController!.value.hasError) {
          log("❌ Video player error: ${_currentVideoController!.value.errorDescription}");
        }
      });

      // Initialize with timeout
      final initialization = _currentVideoController!.initialize();
      final timeout = Future.delayed(Duration(seconds: 30), () {
        throw TimeoutException("Video initialization timed out");
      });

      await Future.any([initialization, timeout]);

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      _currentChewieController = ChewieController(
          videoPlayerController: _currentVideoController!,
          autoPlay: true,
          looping: false,
          showControls: true,
          allowFullScreen: true,
          allowMuting: true,
          allowPlaybackSpeedChanging: true,
          aspectRatio: _currentVideoController!.value.aspectRatio,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.c000e08,
            handleColor: AppColors.c000e08,
            backgroundColor: Colors.grey.shade300,
            bufferedColor: Colors.grey.shade400,
          ),
          placeholder: Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.white, size: 48.h),
                    SizedBox(height: 16.h),
                    Text(
                      'failed_to_load_video'.tr,
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      errorMessage ?? 'unknown_error'.tr,
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _isVideoInitializing = false;
                        _showVideoDialog(videoUrl, title);
                      },
                      child: Text('retry'.tr),
                    ),
                  ],
                ),
              ),
            );
          });

      // Show the video dialog
      Get.dialog(
        Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title ?? 'video_preview'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 24.h),
                      onPressed: () {
                        _disposeVideoControllers();
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),

              // Video Player
              Container(
                width: double.infinity,
                height: 300.h,
                child: Chewie(controller: _currentChewieController!),
              ),

              // Video Info
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Icon(Icons.videocam, color: Colors.white70, size: 20.h),
                    SizedBox(width: 8.w),
                    Text(
                      'video_file'.tr,
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                    Spacer(),
                    Text(
                      'tap_to_play_pause'.tr,
                      style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.8),
      ).then((_) {
        // Clean up when dialog is closed
        _disposeVideoControllers();
      });
    } catch (e, stackTrace) {
      // Close loading dialog if it's open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      log("❌ Error loading video: $e");
      log("📋 Stack trace: $stackTrace");

      _disposeVideoControllers();

      Get.snackbar(
        'error'.tr,
        "${'failed_to_load_video'.tr}: ${e.toString().split(':').first}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      _isVideoInitializing = false;
    }
  }

  // Function to show local video file
  void _showLocalVideoDialog(File videoFile, String? title) async {
    if (_isVideoInitializing) {
      log("⏳ Video already initializing, skipping...");
      return;
    }

    _isVideoInitializing = true;

    try {
      // Show loading dialog
      Get.dialog(
        Dialog(
          backgroundColor: Colors.black,
          child: Container(
            padding: EdgeInsets.all(40.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20.h),
                Text(
                  'loading_video'.tr,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.8),
      );

      // Dispose previous controllers
      _disposeVideoControllers();

      log("🎬 Initializing local video player for file: ${videoFile.path}");
      _currentVideoController = VideoPlayerController.file(videoFile);
      await _currentVideoController!.initialize();

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      _currentChewieController = ChewieController(
        videoPlayerController: _currentVideoController!,
        autoPlay: true,
        looping: false,
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        aspectRatio: _currentVideoController!.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.c000e08,
          handleColor: AppColors.c000e08,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: Colors.grey.shade400,
        ),
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );

      Get.dialog(
        Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title ?? 'video_preview'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 24.h),
                      onPressed: () {
                        _disposeVideoControllers();
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 300.h,
                child: Chewie(controller: _currentChewieController!),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Icon(Icons.videocam, color: Colors.white70, size: 20.h),
                    SizedBox(width: 8.w),
                    Text(
                      'local_video'.tr,
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                    Spacer(),
                    Text(
                      '${(videoFile.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
                      style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.8),
      ).then((_) {
        // Clean up when dialog is closed
        _disposeVideoControllers();
      });
    } catch (e, stackTrace) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      log("❌ Error loading local video: $e");
      log("📋 Stack trace: $stackTrace");

      _disposeVideoControllers();

      Get.snackbar(
        'error'.tr,
        "${'failed_to_load_video'.tr}: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      _isVideoInitializing = false;
    }
  }

  // Function to show local image file
  void _showLocalImageDialog(File imageFile, String? title) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title ?? 'Image Preview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 24.h),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: 500.h),
              child: Image.file(imageFile, fit: BoxFit.contain),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Icon(Icons.image, color: Colors.white70, size: 20.h),
                  SizedBox(width: 8.w),
                  Text(
                    'Local Image',
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                  Spacer(),
                  Text(
                    '${(imageFile.lengthSync() / 1024).toStringAsFixed(2)} KB',
                    style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8),
    );
  }

  // Function to get file type icon
  Widget _getFileTypeIcon(String path) {
    final fileName = path.toLowerCase();
    if (fileName.endsWith('.mp4') ||
        fileName.endsWith('.mov') ||
        fileName.endsWith('.avi') ||
        fileName.endsWith('.mkv') ||
        fileName.endsWith('.wmv')) {
      return Icon(Icons.videocam, color: Colors.red, size: 24.h);
    } else if (fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif')) {
      return Icon(Icons.image, color: Colors.blue, size: 24.h);
    } else {
      return Icon(Icons.insert_drive_file, color: Colors.grey, size: 24.h);
    }
  }

  // Function to check if file is video
  bool _isVideoFile(String path) {
    final fileName = path.toLowerCase();
    return fileName.endsWith('.mp4') ||
        fileName.endsWith('.mov') ||
        fileName.endsWith('.avi') ||
        fileName.endsWith('.mkv') ||
        fileName.endsWith('.wmv');
  }

  // Function to check if file is image
  bool _isImageFile(String path) {
    final fileName = path.toLowerCase();
    return fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif');
  }

  Future<void> _uploadMediaFiles() async {
    String bookingIdToUse = controller.bookingId.value.isNotEmpty
        ? controller.bookingId.value
        : controller.storedBookingId;

    if (bookingIdToUse.isEmpty) {
      Get.snackbar(
        "Error",
        "Booking ID not found. Please refresh the page.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (controller.mediaFiles.isEmpty) {
      Get.snackbar(
        "Info",
        "No new files to upload",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final List<File> fileObjects = [];

      for (final mediaFile in controller.mediaFiles) {
        final file = File(mediaFile.path);
        if (file.existsSync()) {
          fileObjects.add(file);
        }
      }

      if (fileObjects.isEmpty) {
        Get.snackbar(
          "Error",
          "No valid files to upload",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      log("📤 Uploading ${fileObjects.length} media files for Booking ID: $bookingIdToUse");

      final response = await controller.uploadMultipleMediaFiles(
        bookingId: bookingIdToUse,
        files: fileObjects,
      );

      if (response.isSuccess) {
        isMediaCompleted.value = true;
        controller.clearMediaFilesAfterUpload();

        Get.snackbar(
          "Success",
          "${fileObjects.length} file(s) uploaded successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        await _handleRefresh();
      } else {
        final errorMsg = response.errorMessage ?? "Failed to upload files";
        Get.snackbar(
          "Upload Failed",
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      log("Error uploading media: $e", error: e, stackTrace: stackTrace);
      Get.snackbar(
        "Error",
        "Failed to upload files: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleRefresh() async {
    log("🔄 Pull-to-refresh started...");

    try {
      String bookingIdToUse = controller.bookingId.value;

      if (bookingIdToUse.isEmpty) {
        bookingIdToUse = controller.storedBookingId;
        log("🔄 Using stored booking ID: $bookingIdToUse");
      }

      if (bookingIdToUse.isEmpty) {
        final args = Get.arguments;
        if (args != null) {
          if (args is Map) {
            final bookingIdFromArgs = args['bookingId']?.toString();
            if (bookingIdFromArgs != null && bookingIdFromArgs.isNotEmpty) {
              bookingIdToUse = bookingIdFromArgs;
              controller.bookingId.value = bookingIdToUse;
              log("🔄 Retrieved booking ID from arguments: $bookingIdToUse");
            }
          } else if (args is String) {
            bookingIdToUse = args;
            controller.bookingId.value = bookingIdToUse;
            log("🔄 Retrieved booking ID as string: $bookingIdToUse");
          }
        }
      }

      if (bookingIdToUse.isEmpty) {
        log("⚠️ No booking ID available for refresh");
        Get.snackbar("Info", "No booking information found",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 2));
        return;
      }

      log("📡 Refreshing with Booking ID: $bookingIdToUse");
      await controller.loadWorkDetails();
      log("✅ Refresh completed successfully");
    } catch (e, stackTrace) {
      log("❌ Refresh error: $e", error: e, stackTrace: stackTrace);

      String errorMessage = "Failed to refresh data";
      if (e is SocketException) {
        errorMessage = "No internet connection";
      } else if (e is TimeoutException) {
        errorMessage = "Request timed out";
      } else if (e is HttpException) {
        errorMessage = "Server error";
      }

      Get.snackbar("Error", errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3));

      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isLoadingWorkDetails.value
              ? 'loading'.tr
              : 'submit_work_form'.tr,
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        )),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.h),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingWorkDetails.value) {
          return Center(
              child: CircularProgressIndicator(color: AppColors.c000e08));
        }

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.c000e08,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 20.h),
            child: Padding(
              padding:
              EdgeInsets.symmetric(horizontal: UIHelper.kDefaulutPadding()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Section: Working Address & Booking Order Date
                  WorkAddressAndDateWidget(
                    address: controller.address.value.isNotEmpty
                        ? controller.address.value
                        : 'address_not_available'.tr,
                    dateTime: controller.bookingDateTime.value.isNotEmpty
                        ? controller.bookingDateTime.value
                        : 'date_not_valid'.tr,
                  ),
                  UIHelper.verticalSpace(24.h),

                  /// Section: Proof Of Work Complete Information
                  Text(
                    'proof_of_work_completed_information'.tr,
                    style: TextFontStyle.headline16w700c202020StyleSatoshi,
                  ),
                  UIHelper.verticalSpace(16.h),

                  /// Section: Completion Date
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        controller.onCompletionDateSelected(picked);
                      }
                    },
                    child: MoreInfoWidgetTile(
                      title: 'completation_date'.tr,
                      hintText: 'select_date'.tr,
                      isEnabled: false,
                      controller: controller.completionDateController,
                    ),
                  ),

                  UIHelper.verticalSpace(16.h),

                  /// Section: Duration Time (Auto-calculated)
                  MoreInfoWidgetTile(
                    title: 'duration_time'.tr,
                    hintText:
                    'auto_calculated_after_selecting_completion_date'.tr,
                    isEnabled: false,
                    controller: controller.durationTimeController,
                  ),

                  UIHelper.verticalSpace(24.h),

                  /// Section: Existing API Attachments
                  Obx(() {
                    if (controller.apiAttachments.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'existing_proof_files'.tr,
                                style: TextFontStyle
                                    .headline16w700c202020StyleSatoshi,
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: AppColors.c000e08,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  '${controller.apiAttachments.length}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          UIHelper.verticalSpace(12.h),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: controller.apiAttachments
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final attachment = entry.value;
                                    final mediaUrl =
                                    controller.getImageUrl(attachment.url);
                                    final isVideo =
                                        attachment.type == 'video' ||
                                            attachment.url
                                                .toLowerCase()
                                                .contains('.mp4') ||
                                            attachment.url
                                                .toLowerCase()
                                                .contains('.mov') ||
                                            attachment.url
                                                .toLowerCase()
                                                .contains('.avi') ||
                                            attachment.url
                                                .toLowerCase()
                                                .contains('.mkv');

                                    // Video thumbnail
                                    if (isVideo) {
                                      return GestureDetector(
                                        onTap: () {
                                          log("🎬 Playing API video: $mediaUrl");
                                          _showVideoDialog(mediaUrl,
                                              "${'proof_file'.tr} ${index + 1}");
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 80.w,
                                              height: 80.h,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(8.r),
                                                border: Border.all(
                                                    color:
                                                    Colors.grey.shade300),
                                                color: Colors.black,
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 40.w,
                                                      height: 40.h,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.7),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.play_arrow,
                                                        color: Colors.white,
                                                        size: 24.h,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Text(
                                                      'VIDEO',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10.sp,
                                                        fontWeight:
                                                        FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 4,
                                              left: 4,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 4.w,
                                                    vertical: 2.h),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.6),
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      4.r),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.videocam,
                                                        color: Colors.white,
                                                        size: 10),
                                                    SizedBox(width: 2.w),
                                                    Text(
                                                      '${index + 1}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10.sp,
                                                        fontWeight:
                                                        FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    // Image thumbnail
                                    return GestureDetector(
                                      onTap: () {
                                        _showImageDialog(mediaUrl,
                                            "${'proof_file'.tr} ${index + 1}");
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 80.w,
                                            height: 80.h,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(8.r),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(8.r),
                                              child: CachedNetworkImage(
                                                imageUrl: mediaUrl,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Center(
                                                      child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                    Center(
                                                      child: Icon(Icons.error,
                                                          color: Colors.red,
                                                          size: 24),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 4,
                                            left: 4,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4.w,
                                                  vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                                borderRadius:
                                                BorderRadius.circular(4.r),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.image,
                                                      color: Colors.white,
                                                      size: 10),
                                                  SizedBox(width: 2.w),
                                                  Text(
                                                    '${index + 1}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                UIHelper.verticalSpace(8.h),
                                Text(
                                  'tap_on_any_file_to_see_preview'.tr,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          UIHelper.verticalSpace(16.h),
                        ],
                      );
                    }
                    return SizedBox();
                  }),

                  /// Section: Upload new media files
                  Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'add_new_proof_files'.tr,
                          style:
                          TextFontStyle.headline16w700c202020StyleSatoshi,
                        ),
                        UIHelper.verticalSpace(12.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.ce6e6e6),
                          ),
                          child: Column(
                            children: [
                              // Media files list
                              if (controller.mediaFiles.isNotEmpty)
                                Column(
                                  children: [
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: controller.mediaFiles.length,
                                      separatorBuilder: (context, index) =>
                                          Divider(height: 16.h),
                                      itemBuilder: (context, index) {
                                        final mediaFile =
                                        controller.mediaFiles[index];
                                        final isVideo =
                                        _isVideoFile(mediaFile.path);
                                        final isImage =
                                        _isImageFile(mediaFile.path);
                                        final fileName =
                                            mediaFile.path.split('/').last;

                                        Widget previewWidget;

                                        if (isImage) {
                                          previewWidget = GestureDetector(
                                            onTap: () {
                                              final file = File(mediaFile.path);
                                              _showLocalImageDialog(
                                                  file, fileName);
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(6.r),
                                              child: Container(
                                                width: 60.w,
                                                height: 60.h,
                                                color: Colors.grey.shade200,
                                                child: Image.file(
                                                  File(mediaFile.path),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      color:
                                                      Colors.grey.shade300,
                                                      child: Icon(Icons.image,
                                                          color: Colors.grey,
                                                          size: 24.h),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        } else if (isVideo) {
                                          previewWidget = GestureDetector(
                                            onTap: () {
                                              final file = File(mediaFile.path);
                                              log("🎬 Playing local video: ${file.path}");
                                              _showLocalVideoDialog(
                                                  file, fileName);
                                            },
                                            child: Container(
                                              width: 60.w,
                                              height: 60.h,
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius:
                                                BorderRadius.circular(6.r),
                                              ),
                                              child: Center(
                                                child: Container(
                                                  width: 30.w,
                                                  height: 30.h,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 18.h,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          previewWidget = GestureDetector(
                                            onTap: () {
                                              Get.snackbar(
                                                'Info',
                                                'This file type cannot be previewed',
                                                backgroundColor: Colors.blue,
                                                colorText: Colors.white,
                                              );
                                            },
                                            child: _getFileTypeIcon(
                                                mediaFile.path),
                                          );
                                        }

                                        return Container(
                                          padding: EdgeInsets.all(12.w),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius:
                                            BorderRadius.circular(8.r),
                                            border: Border.all(
                                                color: Colors.grey.shade200),
                                          ),
                                          child: Row(
                                            children: [
                                              previewWidget,
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      fileName,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Text(
                                                      isVideo
                                                          ? 'Video file'
                                                          : isImage
                                                          ? 'Image file'
                                                          : 'Document',
                                                      style: TextStyle(
                                                        fontSize: 11.sp,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: Colors.red,
                                                    size: 20.h),
                                                onPressed: () async {
                                                  await controller
                                                      .removeMediaFile(index);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    UIHelper.verticalSpace(16.h),
                                  ],
                                ),

                              // Add New Files button
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.ce6e6e6,
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    log("Browse Button Tapped");
                                    controller.showMediaSourceDialog();
                                  },
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20.h, horizontal: 16.w),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: AppColors.c000e08,
                                          size: 20.h,
                                        ),
                                        UIHelper.horizontalSpace(10.w),
                                        Text(
                                          'add_new_files'.tr,
                                          style: TextFontStyle
                                              .headline12w700c000e08StyleSatoshi,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // File type hint
                              UIHelper.verticalSpace(12.h),
                              Text(
                                "Supported: Images (.jpg, .png, .gif) and Videos (.mp4, .mov, .avi)",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

                  UIHelper.verticalSpace(16.h),

                  /// Section: Media Done Button
                  Obx(() {
                    final hasNewMedia = controller.mediaFiles.isNotEmpty;
                    final showMediaDoneButton =
                        hasNewMedia && !isMediaCompleted.value;

                    if (!showMediaDoneButton) {
                      return SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (controller.isUploadingMedia.value)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border:
                                  Border.all(color: Colors.blue.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16.h,
                                      height: 16.h,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'uploading'.tr,
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              CustomElevatedButton(
                                onTap: _uploadMediaFiles,
                                buttonWidth: 120.w,
                                buttonHeight: 36.h,
                                buttonTitle: 'Upload'.tr,
                              ),
                          ],
                        ),
                        UIHelper.verticalSpace(24.h),
                      ],
                    );
                  }),

                  /// Section: Payment Summary - FIXED VERSION
                  Obx(() {
                    return PaymentSummeryWidget(
                      initialCost: controller.initialCost.value,
                      additionalCostList: controller.additionalCosts.toList(),
                      totalPayment: controller.calculateTotalPayment(),
                      isAddAdditionalCostButtonVisible: true,
                      enableDelete: true,
                      onTap: () async {
                        _showAddAdditionalCostDialog();
                      },
                      onDelete: () async {
                        // Refresh the entire data
                        await controller.loadWorkDetails();
                      },
                      onAdditionalCostDeleted: (additionalCostId) async {
                        // Handle deletion properly
                        await controller.handleAdditionalCostDeleted(additionalCostId);
                      },
                    );
                  }),
                  UIHelper.verticalSpace(16.h),

                  /// Section: Payment Request Button
                  Obx(() {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: CustomElevatedButton(
                        onTap: controller.isPaymentRequestLoading.value
                            ? null
                            : () {
                          _requestPayment();
                        },
                        buttonTitle: controller.isPaymentRequestLoading.value
                            ? 'requesting'.tr
                            : 'request_payment'.tr,
                      ),
                    );
                  }),
                  UIHelper.verticalSpace(32.h),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
  Future<void> _showAddAdditionalCostDialog() async {
    final TextEditingController additionalCostTitle = TextEditingController();
    final TextEditingController additionalCost = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool _isSaving = false;

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.cFFFFFF,
            title: Text(
              'add_additional_cost'.tr,
              style: TextFontStyle.headline16w500c000000StyleSatoshi,
            ),
            content: Form(
              key: formKey,
              child: Container(
                width: 1.sw,
                decoration: BoxDecoration(color: AppColors.cFFFFFF),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      maxLength: 25,
                      controller: additionalCostTitle,
                      decoration: InputDecoration(
                        hintText: 'enter_cost_title'.tr,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.ce6e6e6),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'please_enter_cost_title'.tr;
                        }
                        return null;
                      },
                    ),
                    UIHelper.verticalSpace(10.h),
                    TextFormField(
                      controller: additionalCost,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'enter_cost_amount'.tr,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.ce6e6e6),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'please_enter_cost_amount'.tr;
                        }
                        final price = double.tryParse(value.trim());
                        if (price == null || price <= 0) {
                          return 'please_enter_valid_amount'.tr;
                        }
                        return null;
                      },
                    ),
                    UIHelper.verticalSpace(10.h),
                  ],
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                      Get.back();
                    },
                    child: Text(
                      'cancel'.tr,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  CustomElevatedButton(
                    onTap: _isSaving
                        ? null
                        : () async {
                      if (formKey.currentState != null &&
                          formKey.currentState!.validate()) {
                        setState(() {
                          _isSaving = true;
                        });

                        final name = additionalCostTitle.text.trim();
                        final price = double.parse(additionalCost.text.trim());

                        final success =
                        await controller.addAdditionalCost(name, price);

                        if (success) {
                          // Use Navigator to close dialog more reliably
                          Navigator.of(context, rootNavigator: true).pop();
                        } else {
                          setState(() {
                            _isSaving = false;
                          });
                        }
                      }
                    },
                    buttonWidth: 107.w,
                    buttonHeight: 38.h,
                    buttonTitle: _isSaving ? 'saving'.tr : 'save'.tr,
                  ),
                ],
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );
  }


  void _requestPayment() {
    if (controller.completionDateController.text.isEmpty) {
      Get.snackbar(
        'warning'.tr,
        'please_select_completation_date'.tr,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (controller.durationTimeController.text.isEmpty) {
      Get.snackbar('warning'.tr, 'please_enter_duration_time'.tr);
      return;
    }

    final duration = double.tryParse(controller.durationTimeController.text);
    if (duration == null) {
      Get.snackbar('warning'.tr, 'please_enter_a_valid_number_for_duration'.tr);
      return;
    }

    final totalMedia = controller.totalMediaCount;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: AppColors.c000e08),
            SizedBox(width: 8.w),
            Text('request_payment'.tr,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('you_are_about_request_payment_with_these_details'.tr,
                  style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 16.h),
              _buildDetailRow(
                "${'completation_date'.tr}:",
                controller.completionDateController.text,
              ),
              _buildDetailRow(
                'duration'.tr,
                "${controller.durationTimeController.text} ${'days'.tr}",
              ),
              _buildDetailRow(
                'total_files'.tr,
                "$totalMedia",
              ),
              if (controller.apiAttachments.isNotEmpty)
                _buildDetailRow(
                  "  - ${'existing_files'.tr}",
                  "${controller.apiAttachments.length}",
                ),
              if (controller.mediaFiles.isNotEmpty)
                _buildDetailRow(
                  "  - ${'new_files'.tr}",
                  "${controller.mediaFiles.length}",
                ),
              SizedBox(height: 12.h),
              Divider(),
              SizedBox(height: 12.h),
              _buildDetailRow(
                "${'initial_cost'.tr}:",
                "\$${controller.initialCost.value.toStringAsFixed(2)}",
              ),
              if (controller.additionalCosts.isNotEmpty)
                _buildDetailRow(
                  "${'additional_cost'.tr}:",
                  "\$${(controller.calculateTotalPayment() - controller.initialCost.value).toStringAsFixed(2)}",
                ),
              SizedBox(height: 8.h),
              _buildDetailRow(
                "${'total_payment'.tr}:",
                "\$${controller.calculateTotalPayment().toStringAsFixed(2)}",
                isBold: true,
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'the_client_will_be_notified_about_this_payment_request'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue.shade900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr,
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.requestPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.c778beb,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text('send_request'.tr,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: isBold ? AppColors.c000e08 : Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }


}




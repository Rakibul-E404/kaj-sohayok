/**
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/text_font_style.dart';
import 'custom_card.dart';
import 'custom_elevated_button.dart';
import '../gen/assets.gen.dart';
import '../gen/colors.gen.dart';
import '../helpers/ui_helpers.dart';

class ProofOfImageUploadWidget extends StatelessWidget {
  final String title;
  final String? imagePath;
  final void Function()? onTap;
  final void Function()? removeImageOnTap;
  const ProofOfImageUploadWidget({
    super.key,
    required this.title,
    this.onTap,
    this.imagePath,
    this.removeImageOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///Section : Text -> upload NID/driving license/passport(font side)*
          Text(title, style: TextFontStyle.headline14w700c000000StyleSatoshi),
          UIHelper.verticalSpace(16.h),

          ///Section : File Browse
          DottedBorder(
            options: RectDottedBorderOptions(
              color: AppColors.c778beb,
              dashPattern: [4, 2],
              strokeCap: StrokeCap.round,
              strokeWidth: 1.w,
            ),
            child: imagePath == null || imagePath!.isEmpty
                ? Container(
                    width: 1.sw,
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    decoration: BoxDecoration(color: AppColors.cebeded),
                    child: Column(
                      children: [
                        ///Section : Upload Image
                        Image.asset(
                          Assets.images.uploadIcon.path,
                          height: 32.h,
                          width: 32.w,
                          fit: BoxFit.contain,
                        ),
                        UIHelper.verticalSpace(8.h),

                        Text(
                          "Drop file or browse",
                          style:
                              TextFontStyle.headline16w500c202020StyleSatoshi,
                        ),
                        Text(
                          "Format: .jpeg, .png, .mp4 & Max file size: 25 MB",
                          style:
                              TextFontStyle.headline10w400c6c606cStyleSatoshi,
                        ),
                        UIHelper.verticalSpace(17.h),

                        ///Section : Button -> Browse Files
                        CustomElevatedButton(
                          onTap: onTap,
                          buttonWidth: 150.w,
                          buttonHeight: 28.h,
                          buttonTitle: "Browse Files",

                          isButtonBorderUsed: true,
                          borderRadius: 6.r,
                          buttonBorderWidth: 1.5.sp,
                          buttonBorderColor: AppColors.c606060,
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      ///Selected Image
                      Image.file(
                        File(imagePath!),
                        height: 208.h,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),

                      Positioned(
                        bottom: 0.h,
                        right: 0.w,
                        child: CustomElevatedButton(
                          onTap: removeImageOnTap,
                          buttonWidth: 100.w,
                          buttonHeight: 30.h,
                          buttonColor: AppColors.ce73d3d,
                          borderRadius: 4.r,
                          buttonTitle: "Remove",
                          textStyle: TextFontStyle
                              .headline12w500c000000StyleSatoshi
                              .copyWith(color: AppColors.cFFFFFF),
                        ),
                      ),
                    ],
                  ),
          ),
          UIHelper.verticalSpace(16.h),
        ],
      ),
    );
  }
}



*/




///
///
///
/// todo:: mixing it
///
///
///
///




import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import '../constants/text_font_style.dart';
import 'custom_card.dart';
import 'custom_elevated_button.dart';
import '../gen/assets.gen.dart';
import '../gen/colors.gen.dart';
import '../helpers/ui_helpers.dart';

class MediaFile {
  final String path;
  final bool isVideo;
  final String? thumbnail;
  VideoPlayerController? videoController;
  bool isVideoInitialized = false;

  MediaFile({
    required this.path,
    required this.isVideo,
    this.thumbnail,
    this.videoController,
    this.isVideoInitialized = false,
  });
}

class ProofOfMediaUploadWidget extends StatefulWidget {
  final String title;
  final List<MediaFile> mediaFiles;
  final void Function()? onTap;
  final void Function(int index)? removeMediaOnTap;

  const ProofOfMediaUploadWidget({
    super.key,
    required this.title,
    required this.mediaFiles,
    this.onTap,
    this.removeMediaOnTap,
  });

  @override
  State<ProofOfMediaUploadWidget> createState() => _ProofOfMediaUploadWidgetState();
}

class _ProofOfMediaUploadWidgetState extends State<ProofOfMediaUploadWidget> {
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, bool> _videoInitializedStates = {};
  final Map<int, bool> _videoPlayingStates = {};

  @override
  void initState() {
    super.initState();
    _initializeVideoControllers();
  }

  @override
  void didUpdateWidget(ProofOfMediaUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mediaFiles != oldWidget.mediaFiles) {
      _disposeVideoControllers();
      _initializeVideoControllers();
    }
  }

  void _initializeVideoControllers() async {
    for (int i = 0; i < widget.mediaFiles.length; i++) {
      final mediaFile = widget.mediaFiles[i];
      if (mediaFile.isVideo && !_videoControllers.containsKey(i)) {
        await _initializeVideoController(i, mediaFile.path);
      }
    }
  }

  Future<void> _initializeVideoController(int index, String videoPath) async {
    try {
      final controller = VideoPlayerController.file(File(videoPath));
      _videoControllers[index] = controller;

      await controller.initialize();

      if (mounted) {
        setState(() {
          _videoInitializedStates[index] = true;
          _videoPlayingStates[index] = false;
        });
      }

      controller.addListener(() {
        if (mounted) {
          setState(() {
            _videoPlayingStates[index] = controller.value.isPlaying;
          });
        }
      });

      print('Video controller initialized for index $index');
    } catch (e) {
      print('Error initializing video $index: $e');
      if (mounted) {
        setState(() {
          _videoInitializedStates[index] = false;
          _videoPlayingStates[index] = false;
        });
      }
    }
  }

  void _disposeVideoControllers() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    _videoInitializedStates.clear();
    _videoPlayingStates.clear();
  }

  Widget _buildImagePreview(String imagePath, int index) {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.file(
              File(imagePath),
              width: 100.w,
              height: 100.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 24.r,
                    ),
                  ),
                );
              },
            ),
          ),

          // Remove button
          Positioned(
            top: 4.w,
            right: 4.w,
            child: GestureDetector(
              onTap: () => widget.removeMediaOnTap?.call(index),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.close,
                  size: 14.h,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Image icon indicator
          Positioned(
            bottom: 4.w,
            left: 4.w,
            child: Icon(
              Icons.image,
              size: 14.h,
              color: Colors.white,
            ),
          ),

          // Index number
          Positioned(
            top: 4.w,
            left: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(String videoPath, int index) {
    final isInitialized = _videoInitializedStates[index] ?? false;
    final isPlaying = _videoPlayingStates[index] ?? false;
    final controller = _videoControllers[index];

    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.black,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player or loading
          if (isInitialized && controller != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: VideoPlayer(controller),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 8.h),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),

          // Play/Pause overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (isInitialized && controller != null) {
                  setState(() {
                    if (controller.value.isPlaying) {
                      controller.pause();
                      _videoPlayingStates[index] = false;
                    } else {
                      controller.play();
                      _videoPlayingStates[index] = true;
                    }
                  });
                }
              },
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 30.h,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),

          // Remove button
          Positioned(
            top: 4.w,
            right: 4.w,
            child: GestureDetector(
              onTap: () => widget.removeMediaOnTap?.call(index),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.close,
                  size: 14.h,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Video icon indicator
          Positioned(
            bottom: 4.w,
            left: 4.w,
            child: Icon(
              Icons.videocam,
              size: 14.h,
              color: Colors.white,
            ),
          ),

          // Index number
          Positioned(
            top: 4.w,
            left: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Duration indicator (if video is initialized)
          if (isInitialized && controller != null)
            Positioned(
              bottom: 4.w,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${controller.value.duration.inMinutes}:${(controller.value.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.sp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: List.generate(widget.mediaFiles.length, (index) {
        final mediaFile = widget.mediaFiles[index];
        return mediaFile.isVideo
            ? _buildVideoPreview(mediaFile.path, index)
            : _buildImagePreview(mediaFile.path, index);
      }),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        ///Section : Upload Icon
        Image.asset(
          Assets.images.uploadIcon.path,
          height: 40.h,
          width: 40.w,
          fit: BoxFit.contain,
        ),
        UIHelper.verticalSpace(12.h),

        ///Section : Upload Text
        Text(
          "Drop files or browse",
          style: TextFontStyle.headline16w500c202020StyleSatoshi,
        ),
        UIHelper.verticalSpace(4.h),
        Text(
          "Formats: .jpeg, .png, .mp4, .mov",
          style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
        ),
        Text(
          "Max file size: 100 MB each",
          style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
        ),
        UIHelper.verticalSpace(20.h),

        ///Section : Button -> Browse Files
        CustomElevatedButton(
          onTap: widget.onTap,
          buttonWidth: 150.w,
          buttonHeight: 32.h,
          buttonTitle: "Browse Files",
          isButtonBorderUsed: true,
          borderRadius: 6.r,
          buttonBorderWidth: 1.5.sp,
          buttonBorderColor: AppColors.c606060,
        ),
      ],
    );
  }

  Widget _buildMediaState() {
    return Column(
      children: [
        _buildMediaGrid(),
        UIHelper.verticalSpace(16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomElevatedButton(
              onTap: widget.onTap,
              buttonWidth: 180.w,
              buttonHeight: 32.h,
              buttonTitle: "Add More Files",
              isButtonBorderUsed: true,
              borderRadius: 6.r,
              buttonBorderWidth: 1.5.sp,
              buttonBorderColor: AppColors.c606060,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _disposeVideoControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMedia = widget.mediaFiles.isNotEmpty;
    final mediaCount = widget.mediaFiles.length;
    final imageCount = widget.mediaFiles.where((file) => !file.isVideo).length;
    final videoCount = widget.mediaFiles.where((file) => file.isVideo).length;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///Section : Title with count
          Row(
            children: [
              Text(
                widget.title,
                style: TextFontStyle.headline14w700c000000StyleSatoshi,
              ),
              SizedBox(width: 8.w),
              if (hasMedia)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.c000e08,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$mediaCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          UIHelper.verticalSpace(16.h),

          ///Section : File Browse or Media Previews
          DottedBorder(
            options: RectDottedBorderOptions(
              color: AppColors.c778beb,
              dashPattern: [4, 2],
              strokeCap: StrokeCap.round,
              strokeWidth: 1.w,
            ),
            child: Container(
              width: 1.sw,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(color: AppColors.cebeded),
              child: hasMedia ? _buildMediaState() : _buildEmptyState(),
            ),
          ),
          UIHelper.verticalSpace(16.h),

          ///Section : File count summary
          if (hasMedia)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$mediaCount file${mediaCount > 1 ? 's' : ''} selected",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 4.h),
                if (imageCount > 0 || videoCount > 0)
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    children: [
                      if (imageCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image,
                                size: 12.h,
                                color: Colors.green.shade800,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "$imageCount image${imageCount > 1 ? 's' : ''}",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (videoCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.videocam,
                                size: 12.h,
                                color: Colors.purple.shade800,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "$videoCount video${videoCount > 1 ? 's' : ''}",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.purple.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }
}




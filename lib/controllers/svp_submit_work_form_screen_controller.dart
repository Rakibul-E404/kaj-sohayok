/**
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../gen/colors.gen.dart';

class SvpSubmitWorkFormScreenController extends GetxController {
  TextEditingController completionDateController = TextEditingController();
  TextEditingController durationTimeController = TextEditingController();

  /// Section : Profile Image Picker
  final ImagePicker _picker = ImagePicker();

  /// Instead of File, store path for efficiency
  RxString selectedImage = ''.obs;

  /// Pick image from given source (camera/gallery)
  Future<void> pickImage({required ImageSource imagePickerSourceType}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: imagePickerSourceType,
        maxWidth: 1024, // resize for performance
        maxHeight: 1024,
        imageQuality: 85, // compress
      );

      if (image != null) {
        selectedImage.value = image.path;
      } else {
        Get.snackbar("Cancelled", "No image selected");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
    }
  }

  /// Show Camera / Gallery selection
  void showImageSourceDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.cFFFFFF,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ///Section : Camera
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Get.back();
                  pickImage(imagePickerSourceType: ImageSource.camera);
                },
              ),

              ///Section : Gallery
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  Get.back();
                  pickImage(imagePickerSourceType: ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///Remove Selected Image
  void removeImage() {
    selectedImage.value = '';
  }
}
*/










///
///
///
///=======todo: checking for video upload
///
///
///





import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer';
import 'dart:io';

import '../helpers/ui_helpers.dart';

class SvpSubmitWorkFormScreenController extends GetxController {
  TextEditingController completionDateController = TextEditingController();
  TextEditingController durationTimeController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  RxString selectedImage = ''.obs;
  RxString selectedVideo = ''.obs;

  // Video player controller management
  VideoPlayerController? _videoController;
  Rx<VideoPlayerController?> videoController = Rx<VideoPlayerController?>(null);
  RxBool isVideoInitialized = false.obs;
  RxBool isVideoPlaying = false.obs;

  /// Pick image from given source (camera/gallery)
  Future<void> pickImage({required ImageSource imagePickerSourceType}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: imagePickerSourceType,
        maxWidth: 1024, // resize for performance
        maxHeight: 1024,
        imageQuality: 85, // compress
      );

      if (image != null) {
        selectedImage.value = image.path;
        log("Image selected: ${image.path}");
      } else {
        Get.snackbar("Cancelled", "No image selected");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
      log("Error picking image: $e");
    }
  }

  /// Pick video from given source (camera/gallery)
  Future<void> pickVideo({required ImageSource videoPickerSourceType}) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: videoPickerSourceType,
        maxDuration: const Duration(minutes: 10), // optional: limit video duration
      );

      if (video != null) {
        selectedVideo.value = video.path;
        await _initializeVideoPlayer(video.path);
        log("Video selected: ${video.path}");
      } else {
        Get.snackbar("Cancelled", "No video selected");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick video: $e");
      log("Error picking video: $e");
    }
  }

  /// Initialize video player controller
  Future<void> _initializeVideoPlayer(String videoPath) async {
    try {
      // Dispose previous controller if exists
      await _disposeVideoController();

      // Create new video controller
      _videoController = VideoPlayerController.file(File(videoPath));
      videoController.value = _videoController;

      // Initialize video player
      await _videoController!.initialize();

      // Set up listener for play/pause state
      _videoController!.addListener(_videoPlayerListener);

      isVideoInitialized.value = true;
      isVideoPlaying.value = _videoController!.value.isPlaying;

      log("Video player initialized successfully");
    } catch (e) {
      log("Error initializing video player: $e");
      Get.snackbar("Error", "Failed to initialize video player: $e");
      isVideoInitialized.value = false;
    }
  }

  /// Video player listener
  void _videoPlayerListener() {
    if (_videoController != null) {
      isVideoPlaying.value = _videoController!.value.isPlaying;
    }
  }

  /// Play or pause video
  void toggleVideoPlayPause() {
    if (_videoController != null && isVideoInitialized.value) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        isVideoPlaying.value = false;
      } else {
        _videoController!.play();
        isVideoPlaying.value = true;
      }
    }
  }

  /// Dispose video controller
  Future<void> _disposeVideoController() async {
    if (_videoController != null) {
      _videoController!.removeListener(_videoPlayerListener);
      await _videoController!.dispose();
      _videoController = null;
      videoController.value = null;
      isVideoInitialized.value = false;
      isVideoPlaying.value = false;
    }
  }

  /// Show Camera / Gallery selection for images
  void showImageSourceDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Image Source",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text("Camera (Image)"),
                onTap: () {
                  Get.back();
                  pickImage(imagePickerSourceType: ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.green),
                title: const Text("Gallery (Image)"),
                onTap: () {
                  Get.back();
                  pickImage(imagePickerSourceType: ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show Camera / Gallery selection for videos
  void showVideoSourceDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Video Source",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.red),
                title: const Text("Camera (Video)"),
                onTap: () {
                  Get.back();
                  pickVideo(videoPickerSourceType: ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library, color: Colors.purple),
                title: const Text("Gallery (Video)"),
                onTap: () {
                  Get.back();
                  pickVideo(videoPickerSourceType: ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Remove Selected Image
  void removeImage() {
    selectedImage.value = '';
    log("Image removed");
  }

  /// Remove Selected Video
  Future<void> removeVideo() async {
    selectedVideo.value = '';
    await _disposeVideoController();
    log("Video removed and controller disposed");
  }

  /// Get video controller for external use
  VideoPlayerController? getVideoController() {
    return _videoController;
  }

  /// Check if video is ready to play
  bool isVideoReady() {
    return _videoController != null &&
        isVideoInitialized.value &&
        selectedVideo.value.isNotEmpty;
  }

  @override
  void onClose() {
    // Dispose controllers when the screen is closed
    completionDateController.dispose();
    durationTimeController.dispose();
    _disposeVideoController();
    super.onClose();
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget(this.videoPath, {super.key});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath));
    _initializeVideoPlayerFuture = _controller.initialize();

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            height: 180.h,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 180.h,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
                // Play/Pause button overlay
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 24.r,
                    ),
                  ),
                ),
                // Video progress indicator
                Positioned(
                  bottom: 8.h,
                  left: 8.w,
                  right: 8.w,
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Colors.blue,
                      bufferedColor: Colors.grey.shade400,
                      backgroundColor: Colors.black26,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 40.r,
                  ),
                  UIHelper.verticalSpace(8.h),
                  Text(
                    "Error loading video",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.blue,
                    strokeWidth: 2.5,
                  ),
                  UIHelper.verticalSpace(12.h),
                  Text(
                    "Loading video...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
/**
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
}*/







///
///
///
/// todo:: merging the iamge and the video
///
///
///




import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
// import 'dart:log';
import 'dart:io';
import '../custom_widgets/proof_of_image_uploading_widget.dart';
import '../helpers/ui_helpers.dart';



class SvpSubmitWorkFormScreenController extends GetxController {
  // Text controllers
  TextEditingController completionDateController = TextEditingController();
  TextEditingController durationTimeController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  // Combined media files (both images and videos)
  RxList<MediaFile> mediaFiles = <MediaFile>[].obs;

  /// Pick images and videos from gallery (mixed selection)
  Future<void> pickMediaFromGallery() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (files.isNotEmpty) {
        for (var file in files) {
          // Check if file is video by extension
          final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mov') ||
              file.path.toLowerCase().endsWith('.avi') ||
              file.path.toLowerCase().endsWith('.mkv');

          final mediaFile = MediaFile(
            path: file.path,
            isVideo: isVideo,
          );

          mediaFiles.add(mediaFile);

          if (isVideo) {
            await _initializeVideoController(mediaFiles.length - 1);
          }

          log("${isVideo ? 'Video' : 'Image'} added: ${file.path}");
        }

        Get.snackbar(
          "Success",
          "${files.length} file(s) added",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Cancelled",
          "No files selected",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick files: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      log("Error picking files: $e");
    }
  }

  /// Pick photo from camera
  Future<void> pickPhotoFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final mediaFile = MediaFile(
          path: image.path,
          isVideo: false,
        );

        mediaFiles.add(mediaFile);
        log("Photo added from camera: ${image.path}");

        Get.snackbar(
          "Success",
          "Photo captured successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Cancelled",
          "No photo captured",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to capture photo: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      log("Error capturing photo: $e");
    }
  }

  /// Pick video from camera
  Future<void> pickVideoFromCamera() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10),
      );

      if (video != null) {
        final mediaFile = MediaFile(
          path: video.path,
          isVideo: true,
        );

        mediaFiles.add(mediaFile);
        await _initializeVideoController(mediaFiles.length - 1);

        log("Video recorded from camera: ${video.path}");

        Get.snackbar(
          "Success",
          "Video recorded successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Cancelled",
          "No video recorded",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to record video: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      log("Error recording video: $e");
    }
  }

  /// Initialize video player controller
  Future<void> _initializeVideoController(int index) async {
    try {
      if (index >= mediaFiles.length) return;

      final mediaFile = mediaFiles[index];
      if (!mediaFile.isVideo) return;

      final controller = VideoPlayerController.file(File(mediaFile.path));
      mediaFiles[index].videoController = controller;

      await controller.initialize();
      mediaFiles[index].isVideoInitialized = true;

      controller.addListener(() {
        update(); // Trigger UI update when video state changes
      });

      log("Video controller initialized for index $index");
    } catch (e) {
      log("Error initializing video controller for index $index: $e");
      mediaFiles[index].isVideoInitialized = false;
    }
  }

  /// Play or pause specific video
  void toggleVideoPlayPause(int index) {
    if (index < mediaFiles.length &&
        mediaFiles[index].isVideo &&
        mediaFiles[index].videoController != null &&
        mediaFiles[index].isVideoInitialized) {

      final controller = mediaFiles[index].videoController!;
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
      update();
    }
  }

  /// Show media source selection dialog
  void showMediaSourceDialog() {
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
                "Add Proof Files",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text("Take Photo"),
                subtitle: const Text("Capture using camera"),
                onTap: () {
                  Get.back();
                  pickPhotoFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.red),
                title: const Text("Record Video"),
                subtitle: const Text("Record using camera"),
                onTap: () {
                  Get.back();
                  pickVideoFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text("Choose from Gallery"),
                subtitle: const Text("Select images and videos"),
                onTap: () {
                  Get.back();
                  pickMediaFromGallery();
                },
              ),
              SizedBox(height: 8),
              Text(
                "Gallery allows multiple selection of images and videos",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: Get.back,
                child: const Text("Cancel"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Remove specific media file
  Future<void> removeMediaFile(int index) async {
    if (index >= 0 && index < mediaFiles.length) {
      final mediaFile = mediaFiles[index];

      // Dispose video controller if it's a video
      if (mediaFile.isVideo && mediaFile.videoController != null) {
        mediaFile.videoController!.dispose();
      }

      mediaFiles.removeAt(index);
      log("Media file removed at index $index");
    }
  }

  /// Clear all media files
  Future<void> clearAllMediaFiles() async {
    for (var mediaFile in mediaFiles) {
      if (mediaFile.isVideo && mediaFile.videoController != null) {
        mediaFile.videoController!.dispose();
      }
    }
    mediaFiles.clear();
    log("All media files cleared");
  }

  /// Get image count
  int get imageCount => mediaFiles.where((file) => !file.isVideo).length;

  /// Get video count
  int get videoCount => mediaFiles.where((file) => file.isVideo).length;

  /// Get total media count
  int get totalMediaCount => mediaFiles.length;

  /// Get all media for submission
  Map<String, dynamic> getMediaForSubmission() {
    final images = mediaFiles.where((file) => !file.isVideo).map((file) => file.path).toList();
    final videos = mediaFiles.where((file) => file.isVideo).map((file) => file.path).toList();

    return {
      'images': images,
      'videos': videos,
      'imageCount': images.length,
      'videoCount': videos.length,
    };
  }

  @override
  void onClose() {
    completionDateController.dispose();
    durationTimeController.dispose();

    // Dispose all video controllers
    for (var mediaFile in mediaFiles) {
      if (mediaFile.isVideo && mediaFile.videoController != null) {
        mediaFile.videoController!.dispose();
      }
    }
    mediaFiles.clear();

    super.onClose();
  }
}




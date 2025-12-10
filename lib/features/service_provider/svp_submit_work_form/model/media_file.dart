// Add this to your controller file or create separate model file
import 'package:video_player/video_player.dart';

class MediaFile {
  final String path;
  final bool isVideo;
  VideoPlayerController? videoController;
  bool isVideoInitialized = false;

  MediaFile({
    required this.path,
    required this.isVideo,
    this.videoController,
    this.isVideoInitialized = false,
  });
}
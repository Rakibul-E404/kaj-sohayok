import 'package:video_player/video_player.dart';

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
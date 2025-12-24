import 'package:video_player/video_player.dart';

class MediaFile {
  final String path;
  final bool isVideo;
  VideoPlayerController? videoController;

  MediaFile({
    required this.path,
    required this.isVideo,
    this.videoController,
  });

  // Dispose video controller when no longer needed
  void dispose() {
    if (isVideo && videoController != null) {
      videoController!.dispose();
    }
  }
}




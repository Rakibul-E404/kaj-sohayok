import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/utilities/logger_util.dart';
import '../../../../service/agora/agora_service.dart';
import '../controller/call_controller.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallController _controller = Get.find<CallController>();
  final AgoraService _agoraService = AgoraService();

  // User details from arguments
  late String userName;
  late String userImage;

  @override
  void initState() {
    super.initState();
    _handleRouteArguments();
    ever(_controller.callState, (CallState state) {
      if (state == CallState.ended ||
          state == CallState.rejected ||
          state == CallState.failed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.back();
        });
      }
    });
  }

  void _handleRouteArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      userName = args['userName'] ?? 'Unknown User';
      userImage = args['userImage'] ?? '';
    } else {
      userName = 'Unknown User';
      userImage = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button during call
        if (_controller.callState.value == CallState.connected ||
            _controller.callState.value == CallState.connecting) {
          _showEndCallDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          final state = _controller.callState.value;
          final isVideo = _controller.callType.value == CallType.video;

          return SafeArea(
            child: Stack(
              children: [
                // Video views (only for video calls)
                if (isVideo) _buildVideoViews(),

                // Audio call UI (for audio calls)
                if (!isVideo) _buildAudioCallUI(),

                // Top bar with status
                _buildTopBar(),

                // Call controls
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: _buildCallControls(),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVideoViews() {
    return Obx(() {
      final remoteJoined = _controller.isRemoteUserJoined.value;
      final remoteUserId = _controller.remoteUid.value;

      return Stack(
        children: [
          // Remote video (full screen)
          if (remoteJoined && remoteUserId > 0)
            SizedBox.expand(
              child: AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _agoraService.engine!,
                  canvas: VideoCanvas(uid: remoteUserId),
                  connection: RtcConnection(
                    channelId: _controller.channelName.value,
                  ),
                ),
              ),
            )
          else
            Container(
              color: Colors.grey[900],
              child: Center(
                child: Text(
                  'waiting_for_other_user'.tr,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

          // Local video (small preview in corner)
          if (!_controller.isCameraOff.value)
            Positioned(
              top: 60,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _agoraService.engine!,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildAudioCallUI() {
    final String imageUrl;
    LoggerUtils.debug(userImage);

    if (userImage.isNotEmpty &&
        userImage.contains(
          'amazonaws',
        )) {
      imageUrl = userImage;
    } else {
      // imageUrl = "${AppUrl.imageBaseUrl}${userImage}";
      imageUrl = userImage;
    }
    LoggerUtils.debug(imageUrl);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // User avatar with image
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipOval(
              child: userImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 32),

          // User name
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Call status text
          Obx(() {
            final state = _controller.callState.value;
            String statusText;
            Color statusColor;

            switch (state) {
              case CallState.ringing:
                statusText = 'ringing'.tr;
                statusColor = Colors.blue;
                break;
              case CallState.connecting:
                statusText = 'connecting'.tr;
                statusColor = Colors.orange;
                break;
              case CallState.connected:
                statusText = _controller.callDuration.value;
                statusColor = Colors.green;
                break;
              case CallState.ended:
                statusText = 'call_ended'.tr;
                statusColor = Colors.grey;
                break;
              case CallState.rejected:
                statusText = 'call_rejected'.tr;
                statusColor = Colors.red;
                break;
              case CallState.failed:
                statusText = 'call_failed'.tr;
                statusColor = Colors.red;
                break;
              default:
                statusText = 'calling...'.tr;
                statusColor = Colors.white;
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state == CallState.connected)
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }),

          // Mic status indicator
          const SizedBox(height: 20),
          Obx(() {
            if (_controller.isMicMuted.value) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic_off, color: Colors.red, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'michrophone_is_muted'.tr,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            // Call type icon
            Obx(() {
              final isVideo = _controller.callType.value == CallType.video;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isVideo ? Icons.videocam : Icons.call,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isVideo ? 'video_call'.tr : 'voice_call'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCallControls() {
    return Obx(() {
      final state = _controller.callState.value;
      final isVideo = _controller.callType.value == CallType.video;
      final isRinging = state == CallState.ringing;
      final isConnected =
          state == CallState.connected || state == CallState.connecting;

      // Incoming call - show accept/reject buttons
      if (isRinging && Get.arguments?['isIncoming'] == true) {
        return _buildIncomingCallControls();
      }

      // Active call controls
      if (isConnected) {
        return _buildActiveCallControls(isVideo);
      }

      // Outgoing call - show only end button
      return Center(
        child: _buildEndCallButton(),
      );
    });
  }

  Widget _buildIncomingCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Reject button
        _buildControlButton(
          icon: Icons.call_end,
          label: 'reject'.tr,
          color: Colors.red,
          size: 70,
          iconSize: 35,
          onTap: () => _controller.rejectCall(),
        ),

        // Accept button
        _buildControlButton(
          icon: Icons.call,
          label: 'accept'.tr,
          color: Colors.green,
          size: 70,
          iconSize: 35,
          onTap: () => _controller.acceptCall(),
        ),
      ],
    );
  }

  Widget _buildActiveCallControls(bool isVideo) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mute button
            Obx(() => _buildControlButton(
                  icon:
                      _controller.isMicMuted.value ? Icons.mic_off : Icons.mic,
                  label: _controller.isMicMuted.value ? 'unmute'.tr : 'mute'.tr,
                  color:
                      _controller.isMicMuted.value ? Colors.red : Colors.white,
                  onTap: () => _controller.toggleMicrophone(),
                )),

            // End call button
            _buildEndCallButton(),

            // Speaker button (for audio calls)
            if (!isVideo)
              Obx(() => _buildControlButton(
                    icon: _controller.isSpeakerOn.value
                        ? Icons.volume_up
                        : Icons.volume_off,
                    label: 'speaker'.tr,
                    color: _controller.isSpeakerOn.value
                        ? Colors.blue
                        : Colors.white,
                    onTap: () => _controller
                        .toggleSpeaker(!_controller.isSpeakerOn.value),
                  )),

            // Camera button (for video calls)
            if (isVideo)
              Obx(() => _buildControlButton(
                    icon: _controller.isCameraOff.value
                        ? Icons.videocam_off
                        : Icons.videocam,
                    label: 'camera'.tr,
                    color: _controller.isCameraOff.value
                        ? Colors.red
                        : Colors.white,
                    onTap: () => _controller.toggleCamera(),
                  )),
          ],
        ),

        // Switch camera button for video calls
        if (isVideo) ...[
          const SizedBox(height: 16),
          _buildControlButton(
            icon: Icons.flip_camera_ios,
            label: 'Flip',
            color: Colors.white,
            onTap: () => _controller.switchCamera(),
          ),
        ],
      ],
    );
  }

  Widget _buildEndCallButton() {
    return _buildControlButton(
      icon: Icons.call_end,
      label: 'end'.tr,
      color: Colors.red,
      size: 70,
      iconSize: 35,
      onTap: () => _controller.endCall(),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    double size = 60,
    double iconSize = 30,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              icon,
              color: color,
              size: iconSize,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showEndCallDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('end_call'.tr),
        content: Text('are_you_sure_you_want_to_end_this_call'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _controller.endCall();
            },
            child: Text(
              'end_calll'.tr,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

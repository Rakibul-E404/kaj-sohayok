import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utilities/logger_util.dart';

class AgoraService {
  static final AgoraService _instance = AgoraService._internal();

  factory AgoraService() => _instance;

  AgoraService._internal();

  RtcEngine? _engine;
  bool _isInitialized = false;
  String? _currentChannelName;
  int? _currentUid;

  // Getters
  RtcEngine? get engine => _engine;

  bool get isInitialized => _isInitialized;

  String? get currentChannelName => _currentChannelName;

  int? get currentUid => _currentUid;

  /// Initialize Agora Engine
  Future<bool> initialize() async {
    if (_isInitialized) {
      LoggerUtils.debug('✅ Agora already initialized');
      return true;
    }

    try {
      // final appId = dotenv.env['AGORA_APP_ID'];
      final appId = "b3251e5723734a1199e715218a99d32a";
       // final appId = "17554af77ad14181b0a08ab436001289"; // <-- This is the correct App ID

      if (appId == null || appId.isEmpty) {
        LoggerUtils.debug('❌ AGORA_APP_ID not found in .env file');
        return false;
      }

      // Create Agora Engine
      _engine = createAgoraRtcEngine();

      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Enable audio and video
      await _engine!.enableVideo();
      await _engine!.enableAudio();

      // Set default audio profile
      await _engine!.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioGameStreaming,
      );

      _isInitialized = true;
      LoggerUtils.debug('✅ Agora initialized successfully');
      return true;
    } catch (e) {
      LoggerUtils.debug('❌ Failed to initialize Agora: $e');
      return false;
    }
  }

  /// Request necessary permissions
  Future<bool> requestPermissions() async {
    try {
      final permissions = <Permission>[
        Permission.camera,
        Permission.microphone,
      ];

      // Add Bluetooth permission for Android 12+
      if (defaultTargetPlatform == TargetPlatform.android) {
        permissions.add(Permission.bluetoothConnect);
      }

      final statuses = await permissions.request();

      final allGranted = statuses.values.every(
        (status) => status.isGranted || status.isLimited,
      );

      if (!allGranted) {
        LoggerUtils.debug('⚠️ Some permissions not granted: $statuses');
      }

      return allGranted;
    } catch (e) {
      LoggerUtils.debug('❌ Error requesting permissions: $e');
      return false;
    }
  }

  /// Register event handlers for Agora callbacks
  void registerEventHandlers({
    required Function(RtcConnection connection, int remoteUid, int elapsed)
        onUserJoined,
    required Function(RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason)
        onUserOffline,
    required Function(RtcConnection connection, RtcStats stats) onLeaveChannel,
    required Function(
            RtcConnection connection, int remoteUid, RemoteVideoStats stats)
        onRemoteVideoStats,
    Function(RtcConnection connection, ErrorCodeType err, String msg)? onError,
    Function(RtcConnection connection, int elapsed)? onJoinChannelSuccess,
  }) {
    if (_engine == null) {
      LoggerUtils.debug('⚠️ Engine not initialized');
      return;
    }

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          LoggerUtils.debug('✅ Joined channel: ${connection.channelId}');
          onJoinChannelSuccess?.call(connection, elapsed);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          LoggerUtils.debug('👤 Remote user joined: $remoteUid');
          onUserJoined(connection, remoteUid, elapsed);
        },
        onUserOffline: (connection, remoteUid, reason) {
          LoggerUtils.debug(
              '👋 Remote user offline: $remoteUid, reason: $reason');
          onUserOffline(connection, remoteUid, reason);
        },
        onLeaveChannel: (connection, stats) {
          LoggerUtils.debug('📤 Left channel: ${connection.channelId}');
          onLeaveChannel(connection, stats);
        },
        onError: (err, msg) {
          LoggerUtils.debug('🚨 Agora Error: $err - $msg');
          onError?.call(
              RtcConnection(channelId: _currentChannelName), err, msg);
        },
        onRemoteVideoStats: (connection, stats) {
          onRemoteVideoStats(connection, stats.uid ?? 0, stats);
        },
      ),
    );
  }

  /// Join a channel (voice or video call)
  Future<bool> joinChannel({
    required String channelName,
    required String token,
    required int uid,
    bool isVideoCall = true,
  }) async {
    if (!_isInitialized || _engine == null) {
      LoggerUtils.debug('⚠️ Agora not initialized');
      return false;
    }

    try {
      // Enable/disable video based on call type
      if (isVideoCall) {
        await _engine!.enableVideo();
        await _engine!.startPreview();
      } else {
        await _engine!.disableVideo();
      }

      // Join channel
      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
      );

      _currentChannelName = channelName;
      _currentUid = uid;

      LoggerUtils.debug('✅ Joining channel: $channelName with UID: $uid');
      return true;
    } catch (e) {
      LoggerUtils.debug('❌ Failed to join channel: $e');
      return false;
    }
  }

  /// Leave the current channel
  Future<void> leaveChannel() async {
    if (_engine == null) return;

    try {
      await _engine!.leaveChannel();
      _currentChannelName = null;
      _currentUid = null;
      LoggerUtils.debug('✅ Left channel');
    } catch (e) {
      LoggerUtils.debug('❌ Error leaving channel: $e');
    }
  }

  /// Toggle microphone
  Future<void> toggleMicrophone(bool muted) async {
    if (_engine == null) return;

    try {
      await _engine!.muteLocalAudioStream(muted);
      LoggerUtils.debug('🎤 Microphone ${muted ? "muted" : "unmuted"}');
    } catch (e) {
      LoggerUtils.debug('❌ Error toggling microphone: $e');
    }
  }

  /// Toggle camera
  Future<void> toggleCamera(bool disabled) async {
    if (_engine == null) return;

    try {
      await _engine!.muteLocalVideoStream(disabled);
      LoggerUtils.debug('📹 Camera ${disabled ? "disabled" : "enabled"}');
    } catch (e) {
      LoggerUtils.debug('❌ Error toggling camera: $e');
    }
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_engine == null) return;

    try {
      await _engine!.switchCamera();
      LoggerUtils.debug('🔄 Camera switched');
    } catch (e) {
      LoggerUtils.debug('❌ Error switching camera: $e');
    }
  }

  /// Enable/disable speaker
  Future<void> toggleSpeaker(bool enabled) async {
    if (_engine == null) return;

    try {
      await _engine!.setEnableSpeakerphone(enabled);
      LoggerUtils.debug('🔊 Speaker ${enabled ? "enabled" : "disabled"}');
    } catch (e) {
      LoggerUtils.debug('❌ Error toggling speaker: $e');
    }
  }

  /// Dispose Agora engine
  Future<void> dispose() async {
    if (_engine != null) {
      try {
        await leaveChannel();
        await _engine!.release();
        _engine = null;
        _isInitialized = false;
        _currentChannelName = null;
        _currentUid = null;
        LoggerUtils.debug('✅ Agora disposed');
      } catch (e) {
        LoggerUtils.debug('❌ Error disposing Agora: $e');
      }
    }
  }

  /// Reset service (for logout)
  void reset() {
    dispose();
  }
}

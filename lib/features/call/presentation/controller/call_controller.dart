import 'dart:async';
import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../models/provider_profile_model.dart';
import '../../../../service/agora/agora_service.dart';
import '../../../../service/network_caller.dart';
import '../../../../service/network_response.dart';
import '../../../../service/secured_storage.dart';
import '../../../../service/socket_service.dart';
import '../../../../utilities/app_constants.dart';
import '../../../../utilities/app_url.dart';
import '../../../../utilities/logger_util.dart';
import '../../../normal_user/chat_list/model/chat_list_response_model.dart';

enum CallState {
  idle,
  initiating,
  ringing,
  connecting,
  connected,
  ended,
  rejected,
  failed,
}

enum CallType {
  audio,
  video,
}

class CallController extends GetxController {
  final AgoraService _agoraService = AgoraService();
  final SocketServices _socketService = SocketServices();
  final NetworkCaller _networkCaller = NetworkCaller();

  // Observable states
  final Rx<CallState> callState = CallState.idle.obs;
  final Rx<CallType> callType = CallType.audio.obs;
  final RxBool isMicMuted = false.obs;
  final RxBool isCameraOff = false.obs;
  final RxBool isSpeakerOn = true.obs;
  final RxBool isRemoteUserJoined = false.obs;
  final RxInt remoteUid = 0.obs;
  final RxString conversationId = ''.obs;
  final RxString channelName = ''.obs;
  final RxString token = ''.obs;
  final RxInt localUid = 0.obs;
  final RxString callDuration = '00:00'.obs;

  Timer? _callTimer;
  int _callSeconds = 0;

  @override
  void onInit() {
    super.onInit();
    _initializeAgora();
    _setupSocketListeners();
  }

  /// Initialize Agora
  Future<void> _initializeAgora() async {
    final initialized = await _agoraService.initialize();
    if (initialized) {
      _registerAgoraEventHandlers();
    } else {
      LoggerUtils.debug('❌ Failed to initialize Agora');
    }
  }

  /// Register Agora event handlers
  void _registerAgoraEventHandlers() {
    _agoraService.registerEventHandlers(
      onUserJoined: (connection, remoteUserId, elapsed) {
        LoggerUtils.debug('👤 Remote user joined: $remoteUserId');
        remoteUid.value = remoteUserId;
        isRemoteUserJoined.value = true;

        if (callState.value == CallState.connecting ||
            callState.value == CallState.ringing) {
          callState.value = CallState.connected;
          _startCallTimer();
          _showSnackbar('call_connected'.tr);
        }
      },
      onUserOffline: (connection, remoteUserId, reason) {
        LoggerUtils.debug('👋 Remote user offline: $remoteUserId');
        if (remoteUserId == remoteUid.value) {
          isRemoteUserJoined.value = false;
          remoteUid.value = 0;
          // Remote user left, end the call
          _endCall(showMessage: true, message: 'call_ended_by_other_user'.tr);
        }
      },
      onLeaveChannel: (connection, stats) {
        LoggerUtils.debug('📤 Left channel');
      },
      onJoinChannelSuccess: (connection, elapsed) {
        LoggerUtils.debug(
            '✅ Successfully joined channel: ${connection.channelId}');

        // If we're in ringing state (outgoing call), move to connecting
        if (callState.value == CallState.ringing) {
          callState.value = CallState.connecting;
          _showSnackbar('calling...'.tr);
        }
      },
      onRemoteVideoStats: (connection, uid, stats) {
        // Handle remote video stats if needed
      },
      onError: (connection, err, msg) {
        LoggerUtils.debug('🚨 Call Error: $err - $msg');
        if (callState.value != CallState.idle &&
            callState.value != CallState.ended) {
          callState.value = CallState.failed;

          // Provide user-friendly error message
          String errorMessage = 'call_failed'.tr;
          if (err == ErrorCodeType.errInvalidToken) {
            errorMessage = 'invalid_call_token_please_try_again'.tr;
          } else if (err == ErrorCodeType.errTokenExpired) {
            errorMessage = 'call_token_expired_please_try_again'.tr;
          } else if (err == ErrorCodeType.errNetDown) {
            errorMessage = 'network_connection_failed'.tr;
          }

          _showErrorDialog(errorMessage);
          _endCall(showMessage: false);
        }
      },
    );
  }

  /// Setup socket listeners for call events
  void _setupSocketListeners() {
    // Listen for incoming calls
    _socketService.listen('incoming-call', (data) {
      LoggerUtils.debug('📞 Incoming call: $data');
      _handleIncomingCall(data);
    });

    // Listen for call accepted
    _socketService.listen('call-connected', (data) {
      LoggerUtils.debug('✅ Call accepted: $data');
      if (callState.value == CallState.ringing ||
          callState.value == CallState.connecting) {
        _showSnackbar('call_accepted_connecting'.tr);
        _handleCallAccepted(data);
      }
    });

    // Listen for call rejected
    _socketService.listen('call-rejected', (data) {
      LoggerUtils.debug('❌ Call rejected: $data');
      if (callState.value != CallState.idle) {
        callState.value = CallState.rejected;
        _endCall(showMessage: true, message: 'Call was rejected');
      }
    });

    // Listen for call ended
    _socketService.listen('call-end', (data) {
      LoggerUtils.debug('📴 Call ended: $data');
      if (callState.value != CallState.idle) {
        callState.value = CallState.ended;
        _endCall(showMessage: true, message: 'Call ended by other user');
      }
    });
  }

  /// Initiate a call
  Future<void> initiateCall({
    required String convId,
    required CallType type,
  }) async {
    if (callState.value != CallState.idle) {
      LoggerUtils.debug('⚠️ Call already in progress');
      return;
    }

    // Request permissions
    final hasPermissions = await _agoraService.requestPermissions();
    if (!hasPermissions) {
      _showErrorDialog('camera_and_michro_phone_permission_are_required'.tr);
      return;
    }

    callState.value = CallState.initiating;
    conversationId.value = convId;
    callType.value = type;

    // Get Agora token from backend with role "publisher"
    final tokenResponse = await _getAgoraToken(
      convId,
      role: 'publisher',
    );

    if (tokenResponse == null) {
      callState.value = CallState.failed;
      _showErrorDialog('failed_to_get_call_token_please_try_again'.tr);
      _resetCallState();
      return;
    }

    token.value = tokenResponse['token'] ?? '';
    channelName.value = tokenResponse['channelName'] ?? convId;
    localUid.value = tokenResponse['uid'] ?? 0;

    LoggerUtils.debug('🎯 Initiating call:');
    LoggerUtils.debug('   - UID: ${localUid.value}');
    LoggerUtils.debug('   - Channel: ${channelName.value}');
    LoggerUtils.debug('   - Token: ${token.value.substring(0, 20)}...');

    // Emit call-started event via socket
    await _socketService.emit('call-started', {
      'conversationId': convId,
    });

    callState.value = CallState.ringing;

    // Join Agora channel
    final joined = await _agoraService.joinChannel(
      channelName: channelName.value,
      token: token.value,
      uid: localUid.value,
      isVideoCall: type == CallType.video,
    );

    if (!joined) {
      callState.value = CallState.failed;
      _showErrorDialog('failed_to_join_call'.tr);
      _resetCallState();
      return;
    }

    // Set speaker appropriately for audio calls
    if (type == CallType.audio) {
      // Use earpiece for audio calls
      await toggleSpeaker(false);
    } else {
      // Use speaker for video calls
      await toggleSpeaker(true);
    }
  }

  /// Initiate audio call from PersonalInbox - Moved from UI
  Future<void> initiateAudioCallFromInbox({
    required String? conversationId,
    required UserIdModel? receiverProfile,
  }) async {
    if (conversationId == null || conversationId.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'cannot_initiate_call_invalid_conversation'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Initiate the call
      await initiateCall(
        convId: conversationId,
        type: CallType.audio,
      );

      // Close any open dialogs
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Navigate to call screen
      Get.toNamed('/call-screen', arguments: {
        'isIncoming': false,
        'conversationId': conversationId,
        'callType': CallType.audio,
        'userName': receiverProfile?.name ?? 'unknown'.tr,
        'userImage': receiverProfile?.profileImage?.imageUrl ?? '',
      });
    } catch (e) {
      // Close any open dialogs
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      LoggerUtils.debug('❌ Failed to initiate call: $e');
      Get.snackbar(
        'call_failed'.tr,
        'failed_to_start_the_call_please_try_again'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// ==================> Initiate Call From Outside of the personal Inbox ====>
  Future<void> initiateAudioCallOutsideInbox(
      {required String? receiverId,
      required String? name,
      required ProfileImageModel image}) async {
    try {
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';
      final Map<String, dynamic> loginForm = <String, dynamic>{
        "participants": [receiverId],
        "message": ""
      };
      final NetworkResponse postResponse = await NetworkCaller().postRequest(
        AppUrl.createConversation,
        body: loginForm,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (postResponse.isSuccess) {
        LoggerUtils.debug(postResponse.jsonResponse);
        final String? conversationId =
            postResponse.jsonResponse?['data']['attributes']['_conversationId'];
        LoggerUtils.error(image.imageUrl);
        initiateAudioCallFromInbox(
            conversationId: conversationId,
            receiverProfile: UserIdModel(name: name, profileImage: image));
      } else {
        LoggerUtils.debug(postResponse.jsonResponse);
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  /// Handle incoming call
  void _handleIncomingCall(dynamic data) {
    if (callState.value != CallState.idle) {
      // Reject if already in a call
      rejectCall();
      return;
    }

    final convId =
        data['conversationId'] ?? data['data']?['conversationId'] ?? '';
    final callTypeStr =
        data['callType'] ?? data['data']?['callType'] ?? 'audio';

    if (convId.isEmpty) {
      LoggerUtils.debug('⚠️ Invalid conversationId in incoming call');
      return;
    }

    conversationId.value = convId;
    callType.value = callTypeStr == 'video' ? CallType.video : CallType.audio;
    callState.value = CallState.ringing;

    // Note: Navigation is handled in MessageScreenController
  }

  /// Accept incoming call
  Future<void> acceptCall() async {
    if (callState.value != CallState.ringing) {
      LoggerUtils.debug('⚠️ No incoming call to accept');
      return;
    }

    // Request permissions
    final hasPermissions = await _agoraService.requestPermissions();
    if (!hasPermissions) {
      _showErrorDialog('camera_and_michro_phone_permission_are_required'.tr);
      rejectCall();
      return;
    }

    callState.value = CallState.connecting;
    _showSnackbar('accepting_call'.tr);

    // Get Agora token with role "publisher"
    final tokenResponse = await _getAgoraToken(
      conversationId.value,
      role: 'publisher',
    );

    if (tokenResponse == null) {
      callState.value = CallState.failed;
      _showErrorDialog('failed_to_get_call_token_please_try_again'.tr);
      _resetCallState();
      return;
    }

    token.value = tokenResponse['token'] ?? '';
    channelName.value = tokenResponse['channelName'] ?? conversationId.value;
    localUid.value = tokenResponse['uid'] ?? 0;

    LoggerUtils.debug('🎯 Accepting call:');
    LoggerUtils.debug('   - UID: ${localUid.value}');
    LoggerUtils.debug('   - Channel: ${channelName.value}');

    // Emit call-accepted event
    await _socketService.emit('call-accepted', {
      'conversationId': conversationId.value,
    });

    // Join Agora channel
    final joined = await _agoraService.joinChannel(
      channelName: channelName.value,
      token: token.value,
      uid: localUid.value,
      isVideoCall: callType.value == CallType.video,
    );

    if (!joined) {
      callState.value = CallState.failed;
      _showErrorDialog('failed_to_join_call'.tr);
      _resetCallState();
      return;
    }

    // Set speaker appropriately
    if (callType.value == CallType.audio) {
      await toggleSpeaker(false); // Earpiece
    } else {
      await toggleSpeaker(true); // Speaker
    }
  }

  /// Handle call accepted (for caller)
  Future<void> _handleCallAccepted(dynamic data) async {
    if (callState.value == CallState.ringing ||
        callState.value == CallState.connecting) {
      // Wait a bit for both users to join
      await Future.delayed(const Duration(milliseconds: 500));

      // If remote user hasn't joined yet, stay in connecting state
      if (!isRemoteUserJoined.value) {
        callState.value = CallState.connecting;
      }
    }
  }

  /// Reject call
  Future<void> rejectCall() async {
    if (conversationId.value.isEmpty) {
      _resetCallState();
      if (Get.currentRoute == '/call-screen') {
        Get.back();
      }
      return;
    }

    await _socketService.emit('call-rejected', {
      'conversationId': conversationId.value,
    });

    callState.value = CallState.rejected;
    _showSnackbar('call_rejected'.tr);
    _endCall(showMessage: false);
  }

  /// End call
  Future<void> endCall() async {
    if (conversationId.value.isEmpty) {
      _resetCallState();
      if (Get.currentRoute == '/call-screen') {
        Get.back();
      }
      return;
    }

    await _socketService.emit('call-end', {
      'conversationId': conversationId.value,
    });

    callState.value = CallState.ended;
    _endCall(showMessage: false);
  }

  /// Internal end call logic
  Future<void> _endCall({bool showMessage = false, String message = ''}) async {
    _stopCallTimer();

    try {
      await _agoraService.leaveChannel();
    } catch (e) {
      LoggerUtils.debug('❌ Error leaving channel: $e');
    }

    // Show message if needed
    if (showMessage && message.isNotEmpty) {
      _showSnackbar(message);
    }

    // Delay to allow state changes to propagate
    await Future.delayed(const Duration(milliseconds: 500));

    _resetCallState();

    // Navigate back to previous screen
    if (Get.currentRoute == '/call-screen') {
      Get.back();
    }
  }

  /// Toggle microphone
  Future<void> toggleMicrophone() async {
    isMicMuted.value = !isMicMuted.value;
    await _agoraService.toggleMicrophone(isMicMuted.value);
    _showSnackbar(
        isMicMuted.value ? 'michrophone_muted'.tr : 'michrophone_unmuted'.tr);
  }

  /// Toggle camera
  Future<void> toggleCamera() async {
    isCameraOff.value = !isCameraOff.value;
    await _agoraService.toggleCamera(isCameraOff.value);
    _showSnackbar(isCameraOff.value ? 'camera_off'.tr : 'camera_on'.tr);
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    await _agoraService.switchCamera();
    _showSnackbar('camera_switched'.tr);
  }

  /// Toggle speaker
  Future<void> toggleSpeaker(bool enable) async {
    isSpeakerOn.value = enable;
    try {
      await _agoraService.toggleSpeaker(enable);
      _showSnackbar(enable ? 'speaker_on'.tr : 'earpiece_mode'.tr);
    } catch (e) {
      LoggerUtils.debug('⚠️ Speaker toggle error (non-critical): $e');
      // This error is non-critical and can be ignored
      // It happens on some devices but doesn't affect call quality
    }
  }

  /// Get Agora token from backend
  Future<Map<String, dynamic>?> _getAgoraToken(
    String convId, {
    required String role,
  }) async {
    try {
      final String accessToken =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      // Include role in the request body
      final response = await _networkCaller.postRequest(
        AppUrl.getAgoraToken,
        body: {
          'channelName': convId,
          'role': role, // publisher or subscriber
        },
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      LoggerUtils.debug('📡 Token Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];
        final attributes = data['attributes'];

        return {
          'token': attributes['token'] ?? '',
          'channelName': attributes['channelName'] ?? convId,
          'uid': 0, // Use 0 to allow any UID
        };
      }

      LoggerUtils.debug('❌ Invalid response format or unsuccessful');
      return null;
    } catch (e) {
      LoggerUtils.debug('❌ Error getting Agora token: $e');
      return null;
    }
  }

  /// Generate a random UID for Agora
  int _generateRandomUid() {
    // Generate a random UID between 1 and 2^31-1 (positive integers only)
    final random = Random();
    final uid = random.nextInt(2147483647) + 1;
    return uid;
  }

  /// Start call timer
  void _startCallTimer() {
    _callSeconds = 0;
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callSeconds++;
      final minutes = (_callSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (_callSeconds % 60).toString().padLeft(2, '0');
      callDuration.value = '$minutes:$seconds';
    });
  }

  /// Stop call timer
  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
    _callSeconds = 0;
    callDuration.value = '00:00';
  }

  /// Reset call state
  void _resetCallState() {
    callState.value = CallState.idle;
    conversationId.value = '';
    channelName.value = '';
    token.value = '';
    localUid.value = 0;
    remoteUid.value = 0;
    isRemoteUserJoined.value = false;
    isMicMuted.value = false;
    isCameraOff.value = false;
    isSpeakerOn.value = true;
    callDuration.value = '00:00';
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    if (Get.isDialogOpen ?? false) {
      Get.back(); // Close any existing dialog
    }

    Get.dialog(
      AlertDialog(
        title: Text('call_error'.tr),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              if (Get.currentRoute == '/call-screen') {
                Get.back(); // Go back to previous screen
              }
            },
            child: Text('ok'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show snackbar
  void _showSnackbar(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    // Get.snackbar(
    //   'Call',
    //   message,
    //   snackPosition: SnackPosition.BOTTOM,
    //   duration: const Duration(seconds: 2),
    //   backgroundColor: Colors.black87,
    //   colorText: Colors.white,
    //   margin: const EdgeInsets.all(16),
    // );
  }

  @override
  void onClose() {
    _stopCallTimer();
    // Don't dispose Agora service here as it might be used again
    super.onClose();
  }
}

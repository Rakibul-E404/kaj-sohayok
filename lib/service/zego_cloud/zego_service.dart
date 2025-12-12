//
// import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
// import '../../utilities/logger_util.dart';
//
// // ============================================================
// // 1. lib/config/zego_config.dart
// // ============================================================
// class ZegoConfig {
//   // Your credentials from the screenshot
//   static const int appID = 1986145205 ;
//   static const String appSign = '83d33c96c96842947be948451454d3205b811c41ed1c4e5d3395f73f260bee28'; // Replace with full AppSign
//
//   // Alternative: Use ServerSecret for token generation (more secure)
//   static const String serverSecret = 'dbe1461c54b2a7966967a4b9361077cd'; // From your screenshot
//
//   // Call configuration
//   static const int callTimeoutSeconds = 60; // Timeout for unanswered calls
//   static const bool enableCallWaiting = true;
//   static const bool enableMiniOverlay = true; // Picture-in-picture mode
// }
//
// // ============================================================
// // 2. lib/models/call_user_model.dart
// // ============================================================
// class CallUserModel {
//   final String userId;
//   final String userName;
//   final String? userAvatar;
//
//   CallUserModel({
//     required this.userId,
//     required this.userName,
//     this.userAvatar,
//   });
//
//   Map<String, dynamic> toJson() => {
//     'userId': userId,
//     'userName': userName,
//     'userAvatar': userAvatar,
//   };
//
//   factory CallUserModel.fromJson(Map<String, dynamic> json) => CallUserModel(
//     userId: json['userId'] as String,
//     userName: json['userName'] as String,
//     userAvatar: json['userAvatar'] as String?,
//   );
// }
//
// enum CallType { audio, video }
//
// enum CallState {
//   idle,
//   calling,
//   ringing,
//   connected,
//   ended,
//   rejected,
//   busy,
//   timeout,
//   error,
// }
//
// // ============================================================
// // 3. lib/services/zego_call_service.dart
// // ============================================================
//
// class ZegoCallService {
//   static final ZegoCallService _instance = ZegoCallService._internal();
//   factory ZegoCallService() => _instance;
//   ZegoCallService._internal();
//
//   bool _isInitialized = false;
//   String? _currentUserId;
//
//   bool get isInitialized => _isInitialized;
//
//   /// ✅ CORRECT INITIALIZATION (v4+)
//   Future<bool> initialize({
//     required String userId,
//     required String userName,
//     String? userAvatar,
//   }) async {
//     if (_isInitialized && _currentUserId == userId) return true;
//
//     try {
//       if (_isInitialized) await uninitialize();
//
//       // ✅ Step 1: Initialize core SDK
//       await ZegoUIKit().init(
//         appID: ZegoConfig.appID,
//         appSign: ZegoConfig.appSign,
//       );
//
//       // ✅ Step 2: Initialize invitation service with user info
//       await ZegoUIKitPrebuiltCallInvitationService().init(
//         userID: userId,
//         userName: userName,
//         plugins: [
//           ZegoUIKitSignalingPlugin(),
//           ZegoUIKitPrebuiltCallInvitationPlugin(),
//         ],
//         notificationConfig: ZegoCallInvitationNotificationConfig(
//           androidNotificationConfig: ZegoCallAndroidNotificationConfig(
//             channelID: 'zego_call_channel',
//             channelName: 'Call Notifications',
//           ),
//           iOSNotificationConfig: ZegoCallIOSNotificationConfig(),
//         ),
//         ringtoneConfig: ZegoCallRingtoneConfig(
//           incomingCallPath: 'assets/sounds/incoming_call.mp3',
//           outgoingCallPath: 'assets/sounds/outgoing_call.mp3',
//         ),
//       );
//
//       _isInitialized = true;
//       _currentUserId = userId;
//       LoggerUtils.debug('✅ ZEGO initialized for $userId');
//       return true;
//     } catch (e, st) {
//       LoggerUtils.debug('❌ ZEGO init failed: $e\n$st');
//       return false;
//     }
//   }
//
//   /// ✅ Start audio call — returns call ID
//   Future<String?> startAudioCall({
//     required String calleeId,
//     required String calleeName,
//     String? customData,
//   }) async {
//     if (!_isInitialized) {
//       LoggerUtils.warning('ZEGO not initialized');
//       return null;
//     }
//
//     final callID = 'call_${DateTime.now().millisecondsSinceEpoch}';
//     final result = await ZegoUIKitPrebuiltCallInvitationService().inviteUsers(
//       resourceID: callID,
//       callees: [
//         ZegoUIKitUser(id: calleeId, name: calleeName),
//       ],
//       callType: ZegoCallType.oneOnOneVoiceCall,
//       timeout: ZegoConfig.callTimeoutSeconds,
//     );
//
//     if (result.error != null) {
//       LoggerUtils.debug('❌ Call invite failed: ${result.error}');
//       return null;
//     }
//
//     LoggerUtils.debug('✅ Audio call started: $callID');
//     return callID;
//   }
//
//   /// ✅ Start video call
//   Future<String?> startVideoCall({
//     required String calleeId,
//     required String calleeName,
//     String? customData,
//   }) async {
//     if (!_isInitialized) return null;
//
//     final callID = 'call_${DateTime.now().millisecondsSinceEpoch}';
//     final result = await ZegoUIKitPrebuiltCallInvitationService().inviteUsers(
//       resourceID: callID,
//       callees: [ZegoUIKitUser(id: calleeId, name: calleeName)],
//       callType: ZegoCallType.oneOnOneVideoCall,
//       timeout: ZegoConfig.callTimeoutSeconds,
//     );
//
//     if (result.error != null) {
//       LoggerUtils.debug('❌ Video call failed: ${result.error}');
//       return null;
//     }
//
//     LoggerUtils.debug('✅ Video call started: $callID');
//     return callID;
//   }
//
//   /// ✅ Proper uninit
//   Future<void> uninitialize() async {
//     if (!_isInitialized) return;
//     await ZegoUIKit().uninit();
//     _isInitialized = false;
//     _currentUserId = null;
//     LoggerUtils.debug('🔌 ZEGO uninitialized');
//   }
// }
//
// // ============================================================
// // 4. lib/controllers/call_controller.dart
// // ============================================================
//
//
// class CallController extends GetxController {
//   final _zegoService = ZegoCallService();
//
//   // Observable state
//   final Rx<CallState> callState = CallState.idle.obs;
//   final RxBool isInCall = false.obs;
//   final RxString currentCallId = ''.obs;
//   final Rxn<CallUserModel> currentCallUser = Rxn<CallUserModel>();
//   final Rx<CallType> currentCallType = CallType.audio.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     LoggerUtils.debug('📱 CallController initialized');
//   }
//
//   /// Initialize ZegoCloud for current user
//   Future<bool> initializeCallService({
//     required String userId,
//     required String userName,
//     String? userAvatar,
//   }) async {
//     try {
//       LoggerUtils.debug('🔧 Initializing call service...');
//
//       final success = await _zegoService.initialize(
//         userId: userId,
//         userName: userName,
//         userAvatar: userAvatar,
//       );
//
//       if (success) {
//         LoggerUtils.debug('✅ Call service initialized');
//         return true;
//       } else {
//         LoggerUtils.warning('⚠️ Failed to initialize call service');
//         return false;
//       }
//     } catch (e) {
//       LoggerUtils.debug('❌ Error initializing call service: $e');
//       return false;
//     }
//   }
//
//   /// Make an audio call
//   Future<void> makeAudioCall({
//     required String receiverId,
//     required String receiverName,
//     String? receiverAvatar,
//   }) async {
//     try {
//       LoggerUtils.debug('📞 Making audio call to: $receiverName');
//
//       callState.value = CallState.calling;
//       isInCall.value = true;
//       currentCallType.value = CallType.audio;
//
//       currentCallUser.value = CallUserModel(
//         userId: receiverId,
//         userName: receiverName,
//         userAvatar: receiverAvatar,
//       );
//
//       final success = await _zegoService.startAudioCall(
//         inviteeUserIds: [receiverId],
//         inviteeUserNames: [receiverName],
//       );
//
//       if (!success) {
//         callState.value = CallState.error;
//         isInCall.value = false;
//
//         Get.snackbar(
//           'Call Failed',
//           'Failed to start audio call',
//           snackPosition: SnackPosition.TOP,
//         );
//       }
//     } catch (e) {
//       LoggerUtils.debug('❌ Error making audio call: $e');
//       callState.value = CallState.error;
//       isInCall.value = false;
//
//       Get.snackbar(
//         'Error',
//         'An error occurred while starting the call',
//         snackPosition: SnackPosition.TOP,
//       );
//     }
//   }
//
//   /// Make a video call
//   Future<void> makeVideoCall({
//     required String receiverId,
//     required String receiverName,
//     String? receiverAvatar,
//   }) async {
//     try {
//       LoggerUtils.debug('📹 Making video call to: $receiverName');
//
//       callState.value = CallState.calling;
//       isInCall.value = true;
//       currentCallType.value = CallType.video;
//
//       currentCallUser.value = CallUserModel(
//         userId: receiverId,
//         userName: receiverName,
//         userAvatar: receiverAvatar,
//       );
//
//       final success = await _zegoService.startVideoCall(
//         inviteeUserIds: [receiverId],
//         inviteeUserNames: [receiverName],
//       );
//
//       if (!success) {
//         callState.value = CallState.error;
//         isInCall.value = false;
//
//         Get.snackbar(
//           'Call Failed',
//           'Failed to start video call',
//           snackPosition: SnackPosition.TOP,
//         );
//       }
//     } catch (e) {
//       LoggerUtils.debug('❌ Error making video call: $e');
//       callState.value = CallState.error;
//       isInCall.value = false;
//
//       Get.snackbar(
//         'Error',
//         'An error occurred while starting the call',
//         snackPosition: SnackPosition.TOP,
//       );
//     }
//   }
//
//   /// End current call
//   void endCall() {
//     LoggerUtils.debug('📴 Ending call');
//     callState.value = CallState.ended;
//     isInCall.value = false;
//     currentCallId.value = '';
//     currentCallUser.value = null;
//   }
//
//   /// Uninitialize call service (on logout)
//   Future<void> dispose() async {
//     await _zegoService.uninitialize();
//     callState.value = CallState.idle;
//     isInCall.value = false;
//     currentCallId.value = '';
//     currentCallUser.value = null;
//   }
//
//   @override
//   void onClose() {
//     LoggerUtils.debug('🔌 CallController closing');
//     super.onClose();
//   }
// }
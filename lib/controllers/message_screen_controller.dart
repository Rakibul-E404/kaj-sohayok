import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/service/get_storage.dart';
import 'package:kaz_bd/utilities/app_constants.dart';
import '../features/call/presentation/controller/call_controller.dart';
import '../features/normal_user/chat_inbox/model/chat_individual_message_model.dart';
import '../features/normal_user/chat_inbox/presentation/chat_inbox_screen.dart';
import '../features/normal_user/chat_list/model/chat_list_response_model.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../service/socket_service.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';

class MessageScreenController extends GetxController {
  TextEditingController messageScreenSearchController = TextEditingController();
  var searchText = ''.obs;
  final RxBool loader = false.obs;
  final RxList<ChatListResponseModel> chatLists = <ChatListResponseModel>[].obs;

  // Flag to prevent initialization after logout
  bool _isInitialized = false;

  // Add this computed property to get filtered chat list
  List<ChatListResponseModel> get filteredChatLists {
    if (searchText.value.isEmpty) {
      return chatLists;
    }

    return chatLists.where((chat) {
      final userName = chat.userId?.name?.toLowerCase() ?? '';
      final lastMessage =
          chat.conversations.firstOrNull?.lastMessage?.toLowerCase() ?? '';
      final searchQuery = searchText.value.toLowerCase();

      return userName.contains(searchQuery) ||
          lastMessage.contains(searchQuery);
    }).toList();
  }

  Future<void> messagingInitialize() async {
    // Check if user is actually logged in
    final token = await SecureStorageService().read(AppConstants.accessToken);
    if (token == null || token.isEmpty) {
      LoggerUtils.warning('🚫 No token - skipping messagingInitialize');
      return;
    }

    final String userId = GetStorageModel().read(AppConstants.userId);
    if (userId.isEmpty) {
      LoggerUtils.warning('🚫 No userId - skipping messagingInitialize');
      return;
    }

    LoggerUtils.debug('🔧 Initializing messaging for user: $userId');

    // Clear old data first
    chatLists.clear();
    individualChatLists.clear();

    // Listen for conversation list updates
    SocketServices().listen("conversation-list-updated::$userId",
        (dynamic data) async {
      LoggerUtils.warning(data);
      await handleFetchChatList();
    });

    // Listen for user online status
    SocketServices().listen("related-user-online-status::$userId",
        (dynamic data) {
      LoggerUtils.warning(data);
    });

    // Listen for notifications
    SocketServices().listen("notification::$userId", (dynamic data) {
      LoggerUtils.warning(data);
    });

    // ============ INCOMING CALL LISTENER ============
    _setupCallListeners(userId);

    await handleFetchChatList();
    _isInitialized = true;
  }

  /// Setup call-related socket listeners
  void _setupCallListeners(String userId) {
    // Listen for incoming calls
    SocketServices().listen("incoming-call", (dynamic data) {
      LoggerUtils.debug('📞 Incoming call event received: $data');
      _handleIncomingCall(data);
    });

    // Listen for call connected
    SocketServices().listen("call-connected", (dynamic data) {
      LoggerUtils.debug('✅ Call connected: $data');
    });

    // Listen for call rejected
    SocketServices().listen("call-rejected", (dynamic data) {
      LoggerUtils.debug('❌ Call rejected: $data');
      _handleRemoteCallEnd();
    });

    // Listen for call ended
    SocketServices().listen("call-end", (dynamic data) async {
      LoggerUtils.debug('📴 Call ended: $data');
      await Get.find<CallController>().endCall();
    });
  }

  Future<void> _handleRemoteCallEnd() async {
    try {
      if (Get.isRegistered<CallController>()) {
        final callController = Get.find<CallController>();
        // Only end if call is active or ringing
        if (callController.callState.value != CallState.idle) {
          await callController.endCall();
        }
      }
    } catch (e) {
      LoggerUtils.debug('⚠️ Error handling remote call end: $e');
    }
  }

  /// Handle incoming call
  void _handleIncomingCall(dynamic data) {
    try {
      // Extract call data
      final conversationId =
          data['conversationId'] ?? data['data']?['conversationId'] ?? '';

      if (conversationId.isEmpty) {
        LoggerUtils.debug('⚠️ Invalid conversationId in incoming call');
        return;
      }

      // Find the conversation to get caller details
      final conversation = chatLists.firstWhereOrNull(
        (chat) =>
            chat.conversations.firstOrNull?.conversationId == conversationId,
      );

      final callerName = conversation?.userId?.name ?? 'Unknown Caller';
      final callerImage = conversation?.userId?.profileImage?.imageUrl ?? '';

      // Get or create CallController
      final CallController callController;
      if (Get.isRegistered<CallController>()) {
        callController = Get.find<CallController>();
      } else {
        callController = Get.put(CallController(), permanent: true);
      }

      // Set call data in controller
      callController.conversationId.value = conversationId;
      callController.callType.value = CallType.audio;
      callController.callState.value = CallState.ringing;

      // Show incoming call screen
      Get.toNamed('/call-screen', arguments: {
        'isIncoming': true,
        'conversationId': conversationId,
        'callType': CallType.audio,
        'userName': callerName,
        'userImage': callerImage,
      });

      // Optional: Show notification if app is in background
      // _showIncomingCallNotification(
      //   conversationId: conversationId,
      //   callerName: callerName,
      // );
    } catch (e) {
      LoggerUtils.debug('❌ Error handling incoming call: $e');
    }
  }

  /// Show incoming call notification
  void _showIncomingCallNotification({
    required String conversationId,
    required String callerName,
  }) {
    Get.snackbar(
      '📞 Incoming Call',
      '$callerName is calling you...',
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 5),
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: Icon(Icons.call, color: Colors.white),
      borderRadius: 12,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      snackStyle: SnackStyle.FLOATING,
      isDismissible: true,
      mainButton: TextButton(
        onPressed: () {
          Get.back(); // Close snackbar
          // Navigate to call screen if not already there
          if (Get.currentRoute != '/call-screen') {
            Get.toNamed('/call-screen');
          }
        },
        child: Text(
          'ANSWER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> onInit() async {
    LoggerUtils.debug('📱 MessageScreenController onInit called');

    // Only initialize if not already initialized and user is logged in
    if (!_isInitialized) {
      final token = await SecureStorageService().read(AppConstants.accessToken);
      if (token != null && token.isNotEmpty) {
        await messagingInitialize();
      } else {
        LoggerUtils.warning('⚠️ onInit skipped - no token');
      }
    }
    super.onInit();
  }

  // Clear all data on logout
  void clearAllData() {
    LoggerUtils.debug('🧹 Clearing MessageScreenController data...');

    chatLists.clear();
    individualChatLists.clear();
    messageScreenSearchController.clear();
    searchText.value = '';
    loader.value = false;
    _isInitialized = false;

    LoggerUtils.debug('✅ MessageScreenController cleared');
  }

  @override
  void onClose() {
    clearAllData();
    messageScreenSearchController.dispose();
    super.onClose();
  }

  ///  ================== Create a conversation =========================
  createMessage({
    required String participantId,
    required String name,
    required String imageUrl,
  }) async {
    loader.value = true;

    final Map<String, dynamic> loginForm = <String, dynamic>{
      "participants": [participantId],
      "message": ""
    };
    final String token =
        await SecureStorageService().read(AppConstants.accessToken) ?? '';
    final NetworkResponse postResponse = await NetworkCaller().postRequest(
      AppUrl.createConversation,
      body: loginForm,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (postResponse.isSuccess) {
      await Get.find<MessageScreenController>().handleViewSingleProfileChat(
          conversationId: postResponse.jsonResponse?['data']['attributes']
              ['_conversationId']);
      Get.to(() => PersonalInbox(), arguments: {
        'receiverModel': UserIdModel(
            userId: participantId,
            name: name,
            profileImage: ProfileImageModel(imageUrl: imageUrl),
            role: ''),
        'conversationId': postResponse.jsonResponse?['data']['attributes']
            ['_conversationId']
      });
    } else {
      LoggerUtils.debug(postResponse.jsonResponse);
      LoggerUtils.debug(participantId);
    }
  }

  // ================== Handle the Chat List Fetching ===============>
  handleFetchChatList() async {
    try {
      loader.value = true;
      final chatListResponse = await SocketServices().emitAsync(
        "get-all-conversations-with-pagination",
        {"page": 1, "limit": 50000, "search": ""},
      );

      if (chatListResponse != null) {
        chatLists.clear();
        final resultList = chatListResponse['data']['results'];

        for (final result in resultList) {
          final ChatListResponseModel model = ChatListResponseModel.fromJson(
            result as Map<String, dynamic>,
          );
          chatLists.add(model);
        }
      }
    } catch (e) {
      LoggerUtils.debug("Exception : ${e.toString()}");
    } finally {
      loader.value = false;
    }
  }

  // ================== Handle the individual messaging ==========>
  final RxList<IndividualChatMessage> individualChatLists =
      <IndividualChatMessage>[].obs;

  handleViewSingleProfileChat({required String conversationId}) async {
    final chatListResponse = await SocketServices().emitAsync(
      "get-all-message-by-conversationId",
      {"conversationId": conversationId, "page": 1, "limit": 50000000},
    );

    if (chatListResponse != null) {
      individualChatLists.clear();
      final resultList = chatListResponse['data']['results'];

      for (final result in resultList) {
        final IndividualChatMessage model = IndividualChatMessage.fromJson(
          result as Map<String, dynamic>,
        );
        individualChatLists.add(model);
      }

      SocketServices().listen("new-message-received::$conversationId",
          (dynamic data) {
        handleViewSingleProfileChat(conversationId: conversationId);
      });
    }
  }
}

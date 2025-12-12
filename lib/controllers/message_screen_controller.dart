import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/service/get_storage.dart';
import 'package:kaz_bd/utilities/app_constants.dart';
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

    SocketServices().listen("conversation-list-updated::$userId",
            (dynamic data) async {
          LoggerUtils.warning(data);
      // Get.snackbar(
      //   'New Message',
      //   data?['lastMessage']?['text']?.toString() ?? 'No message',
      //   snackPosition: SnackPosition.TOP,
      //   duration: Duration(seconds: 3),
      //   backgroundColor: AppColors.c778beb,
      //   colorText: Colors.white,
      //   icon: Icon(
      //     Icons.message,
      //     color: Colors.white,
      //   ),
      //   borderRadius: 12,
      //   margin: EdgeInsets.all(16),
      //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      //   snackStyle: SnackStyle.FLOATING,
      //   animationDuration: Duration(milliseconds: 500),
      //   isDismissible: true,
      //   forwardAnimationCurve: Curves.easeOutBack,
      // );

      await handleFetchChatList();
        });

    SocketServices().listen("related-user-online-status::$userId",
            (dynamic data) {
          LoggerUtils.warning(data);
        });

    SocketServices().listen("notification::$userId", (dynamic data) {
      LoggerUtils.warning(data);
    });

    await handleFetchChatList();
    _isInitialized = true;
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
  createMessage(
      {required String participantId,
        required String name,
        required String imageUrl}) async {
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
    }
  }

  // ================== Handle the individual messaging ==========>
  final RxList<IndividualChatMessage> individualChatLists =
      <IndividualChatMessage>[].obs;

  handleViewSingleProfileChat({required String conversationId}) async {
    final chatListResponse = await SocketServices().emitAsync(
      "get-all-message-by-conversationId",
      {
        "conversationId": conversationId,
        "page": 1,
        "limit": 50000000
      },
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
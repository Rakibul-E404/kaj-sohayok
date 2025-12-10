import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constants/appList.dart';
import '../features/normal_user/chat_inbox/model/chat_message_model.dart';
import '../service/socket_service.dart';
import '../utilities/logger_util.dart';
import 'message_screen_controller.dart';

class ChatInboxScreenController extends GetxController {
  TextEditingController sendMessageController = TextEditingController();

  Future<void> sendMessage({required String conversationId}) async {
    if (sendMessageController.text.isNotEmpty) {
      final chatListResponse =
          await SocketServices().emitAsync("send-new-message", {
        // for send-new-message
        "conversationId": conversationId,
        "text": sendMessageController.text.trim()
      });
      if (chatListResponse != null)
        {
          Get.find<MessageScreenController>().handleFetchChatList(); 
          Get.find<MessageScreenController>().handleViewSingleProfileChat(conversationId: conversationId);
          sendMessageController.clear();

        }
      // final newMessage = ChatMessageModel(
      //   message: sendMessageController.text,
      //   isSentByMe: true,
      //   time: DateFormat('h:mm a').format(DateTime.now()),
      // );

      // AppList.chatInboxMessageList.add(newMessage);

      // sendMessageController.clear();
    }
  }

  @override
  void onClose() {
    sendMessageController.dispose();
    super.onClose();
  }

  ///Section : End Drawer Logic
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void openEndDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  void closeEndDrawer() {
    scaffoldKey.currentState?.closeEndDrawer();
  }
}

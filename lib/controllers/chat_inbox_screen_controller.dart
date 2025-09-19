import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constants/appList.dart';
import '../features/normal_user/chat_inbox/model/chat_message_model.dart';

class ChatInboxScreenController extends GetxController {
  TextEditingController sendMessageController = TextEditingController();

  void sendMessage() {
    if (sendMessageController.text.isNotEmpty) {
      final newMessage = ChatMessageModel(
        message: sendMessageController.text,
        isSentByMe: true,
        time: DateFormat('h:mm a').format(DateTime.now()),
      );

      AppList.chatInboxMessageList.add(newMessage);

      sendMessageController.clear();
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

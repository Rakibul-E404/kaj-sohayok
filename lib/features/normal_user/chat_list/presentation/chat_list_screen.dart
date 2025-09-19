import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/features/normal_user/chat_list/widgets/message_tile.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/appList.dart';
import '../../../../controllers/message_screen_controller.dart';
import '../../../../gen/colors.gen.dart';
import '../widgets/search_bar_widget.dart';

// MessageScreen Class (Main Screen)
class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  MessageScreenController controller = Get.put(MessageScreenController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Chat',
          style: TextFontStyle.headline18w700c4d4d4dStyleSatoshi,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: Column(
            children: [
              ///Section : Search Bar
              SearchBarWidget(
                textController: controller.messageScreenSearchController,
                searchText: controller.searchText,
                onChanged: (value) => controller.searchText.value = value,
                onClear: () {
                  controller.messageScreenSearchController.clear();
                  controller.searchText.value = '';
                },
              ),
              UIHelper.verticalSpace(24.h),

              ///Section : Message List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: AppList.messages.length,
                separatorBuilder: (context, index) =>
                    UIHelper.verticalSpace(24.h),
                itemBuilder: (context, index) {
                  final message = AppList.messages[index];
                  return MessageTile(
                    userName: message.name,
                    lastMessage: message.lastMessage,
                    time: message.time,
                    isUnread: message.isUnread,
                    totalUnrededMessage: message.totalUnrededMessage,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

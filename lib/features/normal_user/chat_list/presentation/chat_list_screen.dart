import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/features/normal_user/chat_list/widgets/message_tile.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/models/user_profile_model.dart';

import '../../../../constants/appList.dart';
import '../../../../controllers/message_screen_controller.dart';
import '../../../../gen/colors.gen.dart';
import '../../chat_inbox/presentation/chat_inbox_screen.dart';
import '../model/chat_list_response_model.dart';
import '../widgets/search_bar_widget.dart';

// MessageScreen Class (Main Screen)
class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  MessageScreenController controller = Get.find<MessageScreenController>();

  @override
  void initState() {
    controller.messagingInitialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controller.handleFetchChatList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Chat',
          style: TextFontStyle.headline18w700c4d4d4dStyleSatoshi,
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
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
              Obx(
                () {
                  // Use the filtered list instead of the full list
                  final filteredChats = controller.filteredChatLists;

                  // Show "No results" message if search is active but no results
                  if (controller.searchText.value.isNotEmpty &&
                      filteredChats.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: Text(
                        'No chats found',
                        style: TextFontStyle.headline18w700c4d4d4dStyleSatoshi
                            .copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    // reverse: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredChats.length,
                    separatorBuilder: (context, index) =>
                        UIHelper.verticalSpace(24.h),
                    itemBuilder: (context, index) {
                      final ChatListResponseModel message =
                          filteredChats[index];
                      return InkWell(
                        onTap: () async {
                          await controller.handleViewSingleProfileChat(
                              conversationId: message.conversations.firstOrNull
                                      ?.conversationId ??
                                  '');
                          Get.to(() => PersonalInbox(),
                              arguments: {
                                'receiverModel': message.userId,
                                'conversationId': message.conversations
                                        .firstOrNull?.conversationId ??
                                    ''
                              },
                              transition: Transition.rightToLeft);
                        },
                        child: MessageTile(
                          imageUrl:
                              message.userId?.profileImage?.imageUrl ?? '',
                          userName: message.userId?.name ?? '',
                          lastMessage:
                              message.conversations.firstOrNull?.lastMessage ??
                                  '',
                          time: (formatIsoDate(
                              message.conversations.firstOrNull?.updatedAt ??
                                  '')),
                          isUnread: false,
                          totalUnrededMessage: 0,
                        ),
                      );
                    },
                  );
                },
              ),
              UIHelper.verticalSpace(120),
            ],
          ),
        ),
      ),
    );
  }
}

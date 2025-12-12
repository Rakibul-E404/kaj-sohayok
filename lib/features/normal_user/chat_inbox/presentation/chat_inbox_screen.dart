import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/features/normal_user/chat_list/widgets/message_tile.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/service/get_storage.dart';
import 'package:kaz_bd/utilities/app_constants.dart';
import 'package:kaz_bd/utilities/logger_util.dart';
import '../../../../constants/appList.dart';
import '../../../../controllers/chat_inbox_screen_controller.dart';
import '../../../../controllers/message_screen_controller.dart';
import '../../../../gen/colors.gen.dart';
import '../../chat_list/model/chat_list_response_model.dart';
import '../model/chat_individual_message_model.dart';
import '../widgets/chat_bubble_widget.dart';
import '../widgets/end_drawer_widget.dart';
import '../widgets/send_message_widget.dart';

// PersonalInbox Screen
class PersonalInbox extends StatefulWidget {
  const PersonalInbox({
    super.key,
  }); // Constructor to accept name

  @override
  State<PersonalInbox> createState() => _PersonalInboxState();
}

class _PersonalInboxState extends State<PersonalInbox> {
  ChatInboxScreenController controller = Get.put(ChatInboxScreenController());
  MessageScreenController messageScreenController =
      Get.find<MessageScreenController>();

  final UserIdModel? receiverProfile = Get.arguments["receiverModel"];
  final String? conversationId = Get.arguments["conversationId"];

  @override
  Widget build(BuildContext context) {
     /// ================= Receive the Conversation ID ==================>
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: AppColors.cFFFFFF,
      endDrawer: EndDrawerWidget(),
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(Icons.arrow_back_ios),
        ),
        // leadingWidth: 100.w,
        title: Row(
          spacing: 16,
          children: [
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  height: 45,
                  imageUrl: receiverProfile?.profileImage?.imageUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.person, size: 26),
                  ),
                ),
              ),
            )),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ///Section : User Name
                  Text(
                    receiverProfile?.name ?? '',
                    style: TextStyle(
                      color: AppColors.c111111,
                      fontSize: 16, // Slightly smaller font
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  UIHelper.verticalSpace(2.h),

                  ///Section : User Active Status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(backgroundColor: Colors.green, radius: 4),
                      SizedBox(width: 6), // Reduced spacing
                      Flexible(
                        child: Text(
                          "Active Now",
                          style: TextStyle(
                            color: AppColors.c111111,
                            fontSize: 12, // Smaller font
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.cFFFFFF,
        actions: [
          ///Section : Audio call button
          InkWell(
            onTap: () {
              Get.snackbar(
                "Adio Call..",
                "Audio Call button has been taped!",
                snackPosition: SnackPosition.TOP,
              );
            },
            child: Icon(Icons.call, color: AppColors.c999999),
          ),

          UIHelper.horizontalSpace(10.w),

          // More options button
          InkWell(
            onTap: () {
              controller.openEndDrawer();
            },
            child: Icon(Icons.more_vert, color: AppColors.cb4b4b4),
          ),
        ],
      ),

      ///Section : Message Showing
      body: Column(
        children: [
          ///Section : Message Showing
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true,
                itemCount: messageScreenController.individualChatLists.length,
                itemBuilder: (context, index) {
                  final message =
                      messageScreenController.individualChatLists[index];
                  final currentUserId =
                      GetStorageModel().read(AppConstants.userId) ?? '';

                  final isSentByMe =
                      (message.sender?.userId ?? '') == currentUserId;

                  return ChatBubble(
                    message: message.text ?? '',
                    isSentByMe: isSentByMe,
                    time: message.updatedAt != null
                        ? formatIsoDate(message.updatedAt!)
                        : '',
                  );
                },
              ),
            ),
          ),

          ///Section : Send Message Option.....
          SendMessageWidget(
            onTap: () {
              controller.sendMessage(conversationId: conversationId ?? '');
            },
            controller: controller.sendMessageController,
          ),
        ],
      ),
    );
  }
}

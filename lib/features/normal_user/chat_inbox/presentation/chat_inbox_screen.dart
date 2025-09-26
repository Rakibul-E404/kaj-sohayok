import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import '../../../../constants/appList.dart';
import '../../../../controllers/chat_inbox_screen_controller.dart';
import '../../../../gen/colors.gen.dart';
import '../widgets/chat_bubble_widget.dart';
import '../widgets/end_drawer_widget.dart';
import '../widgets/send_message_widget.dart';

// PersonalInbox Screen
class PersonalInbox extends StatefulWidget {
  final String name; // Receive the name as a parameter

  const PersonalInbox({
    super.key,
    required this.name,
  }); // Constructor to accept name

  @override
  State<PersonalInbox> createState() => _PersonalInboxState();
}

class _PersonalInboxState extends State<PersonalInbox> {
  ChatInboxScreenController controller = Get.put(ChatInboxScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: AppColors.cFFFFFF,
      endDrawer: EndDrawerWidget(),
      appBar: AppBar(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: UIHelper.kDefaulutPadding()),

            ///Section : Go Back Icon
            InkWell(
              onTap: () {
                Get.back();
              },
              child: Icon(Icons.arrow_back_ios),
            ),
            UIHelper.horizontalSpace(4.w),

            ///Section : User Image
            CircleAvatar(
              radius: 20.r,
              backgroundImage: NetworkImage(
                'https://static.vecteezy.com/system/resources/previews/004/320/558/non_2x/group-icon-isolated-sign-symbol-illustration-five-people-gathered-icons-black-and-white-design-free-vector.jpg',
              ),
            ),
          ],
        ),
        leadingWidth: 100.w,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ///Section : User Name
            Text(
              widget.name,
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

          SizedBox(width: 10,),

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
            child: ListView.builder(
              itemCount: AppList.chatInboxMessageList.length,
              itemBuilder: (context, index) {
                final message = AppList.chatInboxMessageList[index];
                return ChatBubble(
                  message: message.message,
                  isSentByMe: message.isSentByMe,
                  time: message.time,
                );
              },
            ),
          ),

          ///Section : Send Message Option.....
          SendMessageWidget(
            onTap: () {
              controller.sendMessage();
            },
            controller: controller.sendMessageController,
          ),
        ],
      ),
    );
  }
}

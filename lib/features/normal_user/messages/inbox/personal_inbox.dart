import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import DateFormat from intl package
import '../../../../gen/colors.gen.dart';

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
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(message: "Hyyy!!!", isSentByMe: true, time: "3:00 pm"),
    ChatMessage(
      message: "When are we meeting? It's been so long!",
      isSentByMe: false,
      time: "3:01 pm",
    ),
    ChatMessage(message: "Hyyyy.... georg.", isSentByMe: true, time: "3:02 pm"),
    ChatMessage(
      message: "Next week for sure.",
      isSentByMe: false,
      time: "3:02 pm",
    ),
  ];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final newMessage = ChatMessage(
        message: _controller.text,
        isSentByMe: true,
        time: DateFormat('h:mm a').format(DateTime.now()),
      );
      setState(() {
        _messages.add(newMessage);
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cFFFFFF,
      endDrawer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.55, // Responsive width
            height: Get.height * 0.28,
            child: Drawer(
              backgroundColor: AppColors.cFFFFFF,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0,30,0,0),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.notifications,color: AppColors.c111111,),
                        title: Text('Mute Notifications',style: TextStyle(
                            color: AppColors.c111111
                        ),),
                        onTap: () {
                          // Handle mute notifications
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.block,color: AppColors.c111111),
                        title: Text('Block User',style: TextStyle(
                            color: AppColors.c111111
                        ),),
                        onTap: () {
                          // Handle block user
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete,color: AppColors.c111111),
                        title: Text('Delete Chat',style: TextStyle(
                            color: AppColors.c111111
                        ),),
                        onTap: () {
                          // Handle delete chat
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.black,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 0), // Smaller constraint
            ),
            SizedBox(width: 4), // Reduced spacing
            CircleAvatar(
              radius: 20, // Smaller avatar
              backgroundImage: NetworkImage(
                'https://static.vecteezy.com/system/resources/previews/004/320/558/non_2x/group-icon-isolated-sign-symbol-illustration-five-people-gathered-icons-black-and-white-design-free-vector.jpg',
              ),
            ),
          ],
        ),
        leadingWidth: 100, // Match the SizedBox width
        title: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.name,
                style: TextStyle(
                  color: AppColors.c111111,
                  fontSize: 16, // Slightly smaller font
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: 2),
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
        backgroundColor: AppColors.cFFFFFF,
        actions: [
          // Audio call button
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Audio Call button pressed",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
            icon: Icon(Icons.call, color: AppColors.c999999),
            padding: EdgeInsets.symmetric(horizontal: 8), // Compact padding
          ),

          // Video call button
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Video Call button pressed",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
            icon: Icon(
              CupertinoIcons.video_camera_solid,
              color: AppColors.c92a2ef,
            ),
            padding: EdgeInsets.symmetric(horizontal: 8), // Compact padding
          ),

          // More options button
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: Icon(Icons.more_vert, color: AppColors.cb4b4b4),
              padding: EdgeInsets.symmetric(horizontal: 8), // Compact padding
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message.message,
                  isSentByMe: message.isSentByMe,
                  time: message.time,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.ca4b1f2,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Send a message...",
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: null, // Allow multiline input
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.c8b8b8b,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),

          ),
        ],
      ),
    );
  }
}

///
///----------- ChatMessage Class
///
class ChatMessage {
  final String message;
  final bool isSentByMe;
  final String time;

  ChatMessage({
    required this.message,
    required this.isSentByMe,
    required this.time,
  });
}

// ChatBubble Widget
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;
  final String time;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: isSentByMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75, // Max 75% width
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                decoration: BoxDecoration(
                  borderRadius: isSentByMe
                      ?
                  BorderRadiusGeometry.directional(
                      topStart: Radius.circular(12),
                      topEnd: Radius.circular(12),
                      bottomStart: Radius.circular(12)
                  )
                      :
                  BorderRadiusGeometry.directional(
                      topStart: Radius.circular(12),
                      topEnd: Radius.circular(12),
                      bottomEnd: Radius.circular(12)
                  ),
                  color: isSentByMe
                      ? AppColors.c778beb
                      : AppColors.c8b8b8b.withValues(alpha: 0.9),
                ),
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white),
                  softWrap: true,
                ),
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              time,
              style: TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
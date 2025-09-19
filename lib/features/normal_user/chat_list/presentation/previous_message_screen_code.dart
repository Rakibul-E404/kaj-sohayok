// import 'package:flutter/material.dart';
// import '../../../gen/colors.gen.dart';
// import 'inbox/personal_inbox.dart'; // For formatting date and time


// // MessageScreen Class (Main Screen)
// class MessageScreen extends StatefulWidget {
//   const MessageScreen({super.key});

//   @override
//   _MessageScreenState createState() => _MessageScreenState();
// }

// class _MessageScreenState extends State<MessageScreen> {
//   final List<Message> messages = [
//     Message(
//       name: 'Rocky Parker',
//       lastMessage: 'Your okay fine.',
//       time: '08:36 am',
//       isUnread: true,
//     ),
//     Message(
//       name: 'Jobless Community Jobless Community',
//       lastMessage: 'Your okay fine.',
//       time: '08:36 am',
//       isUnread: false,
//     ),
//     Message(
//       name: 'IT Job',
//       lastMessage: 'Your okay fine.',
//       time: '08:36 am',
//       isUnread: false,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.cFFFFFF,
//         automaticallyImplyLeading: false,
//         centerTitle: true,
//         title: Text(
//           'Chat',
//           style: TextStyle(
//             color: Colors.black,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search Connections',
//                 hintStyle: TextStyle(color: Colors.grey),
//                 prefixIcon: Icon(Icons.search, color: Colors.grey),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: AppColors.ca4b1f2),
//                   borderRadius: BorderRadius.circular(15.0),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.black),
//                   borderRadius: BorderRadius.circular(15.0),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(vertical: 12.0),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final message = messages[index];
//                 return MessageTile(
//                   name: message.name,
//                   lastMessage: message.lastMessage,
//                   time: message.time,
//                   isUnread: message.isUnread,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Message Class
// class Message {
//   final String name;
//   final String lastMessage;
//   final String time;
//   final bool isUnread;

//   Message({
//     required this.name,
//     required this.lastMessage,
//     required this.time,
//     required this.isUnread,
//   });
// }

// // MessageTile (Each Message Item)
// class MessageTile extends StatelessWidget {
//   final String name;
//   final String lastMessage;
//   final String time;
//   final bool isUnread;

//   const MessageTile({
//     super.key,
//     required this.name,
//     required this.lastMessage,
//     required this.time,
//     required this.isUnread,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: Colors.blueAccent,
//         child: Text(
//           name[0],
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       title: Row(
//         children: [
//           Expanded(
//             child: Text(
//               name,
//               style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
//               ),
//             ),
//           ),
//           Text(
//             time,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//       subtitle: Text(
//         lastMessage,
//         style: TextStyle(
//           fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
//           color: isUnread ? AppColors.c778beb : AppColors.ca4b1f2,
//         ),
//         overflow: TextOverflow.ellipsis,
//       ),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => PersonalInbox(name: name),
//           ),
//         );
//       },
//     );
//   }
// }



class MessageModel {
  final String name;
  final String lastMessage;
  final String time;
  final bool isUnread;
  final int totalUnrededMessage;

  MessageModel({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.isUnread,
    required this.totalUnrededMessage,
  });
}

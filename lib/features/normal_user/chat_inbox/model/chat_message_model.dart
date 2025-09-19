class ChatMessageModel {
  final String message;
  final bool isSentByMe;
  final String time;

  ChatMessageModel({
    required this.message,
    required this.isSentByMe,
    required this.time,
  });
}

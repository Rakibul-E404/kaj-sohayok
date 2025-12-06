class ChatListResponseModel {
  final UserIdModel? userId;
  final List<ConversationModel> conversations;

  ChatListResponseModel({
    this.userId,
    required this.conversations,
  });

  factory ChatListResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ChatListResponseModel(conversations: []);
    }

    return ChatListResponseModel(
      userId: UserIdModel.fromJson(json['userId'] as Map<String, dynamic>?),
      conversations: (json['conversations'] as List<dynamic>?)
          ?.map((e) => ConversationModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class UserIdModel {
  final String? userId;
  final String? name;
  final ProfileImageModel? profileImage;
  final String? role;

  UserIdModel({
    this.userId,
    this.name,
    this.profileImage,
    this.role,
  });

  factory UserIdModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserIdModel();

    return UserIdModel(
      userId: json['_userId'] as String?,
      name: json['name'] as String?,
      profileImage:
      ProfileImageModel.fromJson(json['profileImage'] as Map<String, dynamic>?),
      role: json['role'] as String?,
    );
  }
}

class ProfileImageModel {
  final String? imageUrl;
  final String? id;

  ProfileImageModel({this.imageUrl, this.id});

  factory ProfileImageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProfileImageModel();

    return ProfileImageModel(
      imageUrl: json['imageUrl'] as String?,
      id: json['_id'] as String?,
    );
  }
}

class ConversationModel {
  final String? conversationId;
  final String? lastMessage;
  final String? updatedAt;

  ConversationModel({
    this.conversationId,
    this.lastMessage,
    this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConversationModel();

    return ConversationModel(
      conversationId: json['_conversationId'] as String?,
      lastMessage: json['lastMessage'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

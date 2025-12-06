class IndividualChatMessage {
  final String? text;
  final List<dynamic>? attachments; // Adjust type if you have a more specific Attachment model
  final Sender? sender;
  final String? conversationId;
  final bool? isDeleted;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final String? messageId;

  IndividualChatMessage({
    this.text,
    this.attachments,
    this.sender,
    this.conversationId,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.messageId,
  });

  factory IndividualChatMessage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return IndividualChatMessage();

    return IndividualChatMessage(
      text: json['text'] as String?,
      attachments: json['attachments'] as List<dynamic>?,
      sender: Sender.fromJson(json['senderId'] as Map<String, dynamic>?),
      conversationId: json['conversationId'] as String?,
      isDeleted: json['isDeleted'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as int?,
      messageId: json['_messageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'attachments': attachments,
      'senderId': sender?.toJson(),
      'conversationId': conversationId,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      '_messageId': messageId,
    };
  }
}

class Sender {
  final String? name;
  final ProfileImage? profileImage;
  final String? userId;

  Sender({this.name, this.profileImage, this.userId});

  factory Sender.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Sender();

    return Sender(
      name: json['name'] as String?,
      profileImage: ProfileImage.fromJson(json['profileImage'] as Map<String, dynamic>?),
      userId: json['_userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profileImage': profileImage?.toJson(),
      '_userId': userId,
    };
  }
}

class ProfileImage {
  final String? imageUrl;
  final String? id;

  ProfileImage({this.imageUrl, this.id});

  factory ProfileImage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProfileImage();

    return ProfileImage(
      imageUrl: json['imageUrl'] as String?,
      id: json['_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      '_id': id,
    };
  }
}

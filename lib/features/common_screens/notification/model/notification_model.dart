class NotificationModel {
  final TitleText? title;
  final String? id;
  final String? senderId;
  final String? receiverId;
  final String? receiverRole;
  final String? type;
  final String? idOfType;
  final String? linkFor;
  final String? linkId;
  final bool viewStatus;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  NotificationModel({
    this.title,
    this.id,
    this.senderId,
    this.receiverId,
    this.receiverRole,
    this.type,
    this.idOfType,
    this.linkFor,
    this.linkId,
    this.viewStatus = false,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  /// Null-safe fromJson
  factory NotificationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NotificationModel();

    return NotificationModel(
      title: json['title'] != null
          ? TitleText.fromJson(json['title'])
          : null,
      id: json['_id'] as String?,
      senderId: json['senderId'] as String?,
      receiverId: json['receiverId'] as String?,
      receiverRole: json['receiverRole'] as String?,
      type: json['type'] as String?,
      idOfType: json['idOfType'] as String?,
      linkFor: json['linkFor'] as String?,
      linkId: json['linkId'] as String?,
      viewStatus: json['viewStatus'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      v: json['__v'] as int?,
    );
  }

  /// Convert model back to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title?.toJson(),
      '_id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'receiverRole': receiverRole,
      'type': type,
      'idOfType': idOfType,
      'linkFor': linkFor,
      'linkId': linkId,
      'viewStatus': viewStatus,
      'isDeleted': isDeleted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}

/// Nested title object
class TitleText {
  final String? en;
  final String? bn;

  TitleText({this.en, this.bn});

  factory TitleText.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TitleText();
    return TitleText(
      en: json['en'] as String?,
      bn: json['bn'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'bn': bn,
    };
  }
}

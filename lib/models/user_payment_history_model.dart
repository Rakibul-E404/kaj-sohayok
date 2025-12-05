class UserPaymentHistoryModel {
  final Address? address;
  final ProviderId? providerId;
  final ProviderDetailsId? providerDetailsId;
  final String? bookingDateTime;
  final double? startPrice;
  final bool? hasReview;
  final String? serviceBookingId;

  UserPaymentHistoryModel({
    this.address,
    this.providerId,
    this.providerDetailsId,
    this.bookingDateTime,
    this.startPrice,
    this.hasReview,
    this.serviceBookingId,
  });

  // Factory method to create instance from JSON
  factory UserPaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return UserPaymentHistoryModel(
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
      providerId: json['providerId'] != null
          ? ProviderId.fromJson(json['providerId'])
          : null,
      providerDetailsId: json['providerDetailsId'] != null
          ? ProviderDetailsId.fromJson(json['providerDetailsId'])
          : null,
      bookingDateTime: json['bookingDateTime'] as String?,
      startPrice: json['startPrice'] is int
          ? (json['startPrice'] as int).toDouble()  // Handle int -> double conversion
          : json['startPrice'] as double?,
      hasReview: json['hasReview'] as bool?,
      serviceBookingId: json['_ServiceBookingId'] as String?,
    );
  }

  // Factory method to create instance from Map
  factory UserPaymentHistoryModel.fromMap(Map<String, dynamic> map) {
    return UserPaymentHistoryModel(
      address: map['address'] != null
          ? Address.fromMap(map['address'])
          : null,
      providerId: map['providerId'] != null
          ? ProviderId.fromMap(map['providerId'])
          : null,
      providerDetailsId: map['providerDetailsId'] != null
          ? ProviderDetailsId.fromMap(map['providerDetailsId'])
          : null,
      bookingDateTime: map['bookingDateTime'] as String?,
      startPrice: map['startPrice'] is int
          ? (map['startPrice'] as int).toDouble()  // Handle int -> double conversion
          : map['startPrice'] as double?,
      hasReview: map['hasReview'] as bool?,
      serviceBookingId: map['_ServiceBookingId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address?.toJson(),
      'providerId': providerId?.toJson(),
      'providerDetailsId': providerDetailsId?.toJson(),
      'bookingDateTime': bookingDateTime,
      'startPrice': startPrice,
      'hasReview': hasReview,
      '_ServiceBookingId': serviceBookingId,
    };
  }
}

class Address {
  final String? en;
  final String? bn;

  Address({this.en, this.bn});

  // Factory method to create instance from JSON
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      en: json['en'] as String?,
      bn: json['bn'] as String?,
    );
  }

  // Factory method to create instance from Map
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      en: map['en'] as String?,
      bn: map['bn'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'bn': bn,
    };
  }
}

class ProviderId {
  final String? name;
  final String? role;
  final ProfileImage? profileImage;
  final String? userId;

  ProviderId({this.name, this.role, this.profileImage, this.userId});

  // Factory method to create instance from JSON
  factory ProviderId.fromJson(Map<String, dynamic> json) {
    return ProviderId(
      name: json['name'] as String?,
      role: json['role'] as String?,
      profileImage: json['profileImage'] != null
          ? ProfileImage.fromJson(json['profileImage'])
          : null,
      userId: json['_userId'] as String?,
    );
  }

  // Factory method to create instance from Map
  factory ProviderId.fromMap(Map<String, dynamic> map) {
    return ProviderId(
      name: map['name'] as String?,
      role: map['role'] as String?,
      profileImage: map['profileImage'] != null
          ? ProfileImage.fromMap(map['profileImage'])
          : null,
      userId: map['_userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'profileImage': profileImage?.toJson(),
      '_userId': userId,
    };
  }
}

class ProfileImage {
  final String? imageUrl;
  final String? id;

  ProfileImage({this.imageUrl, this.id});

  // Factory method to create instance from JSON
  factory ProfileImage.fromJson(Map<String, dynamic> json) {
    return ProfileImage(
      imageUrl: json['imageUrl'] as String?,
      id: json['_id'] as String?,
    );
  }

  // Factory method to create instance from Map
  factory ProfileImage.fromMap(Map<String, dynamic> map) {
    return ProfileImage(
      imageUrl: map['imageUrl'] as String?,
      id: map['_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      '_id': id,
    };
  }
}

class ProviderDetailsId {
  final ServiceName? serviceName;
  final String? serviceProviderId;

  ProviderDetailsId({this.serviceName, this.serviceProviderId});

  // Factory method to create instance from JSON
  factory ProviderDetailsId.fromJson(Map<String, dynamic> json) {
    return ProviderDetailsId(
      serviceName: json['serviceName'] != null
          ? ServiceName.fromJson(json['serviceName'])
          : null,
      serviceProviderId: json['_ServiceProviderId'] as String?,
    );
  }

  // Factory method to create instance from Map
  factory ProviderDetailsId.fromMap(Map<String, dynamic> map) {
    return ProviderDetailsId(
      serviceName: map['serviceName'] != null
          ? ServiceName.fromMap(map['serviceName'])
          : null,
      serviceProviderId: map['_ServiceProviderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceName': serviceName?.toJson(),
      '_ServiceProviderId': serviceProviderId,
    };
  }
}

class ServiceName {
  final String? en;
  final String? bn;

  ServiceName({this.en, this.bn});

  // Factory method to create instance from JSON
  factory ServiceName.fromJson(Map<String, dynamic> json) {
    return ServiceName(
      en: json['en'] as String?,
      bn: json['bn'] as String?,
    );
  }

  // Factory method to create instance from Map
  factory ServiceName.fromMap(Map<String, dynamic> map) {
    return ServiceName(
      en: map['en'] as String?,
      bn: map['bn'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'bn': bn,
    };
  }
}

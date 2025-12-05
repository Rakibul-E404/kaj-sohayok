class UserPaymentHistoryDetailsModel {
  final ServiceBooking? serviceBooking;
  final List<AdditionalCost>? additionalCosts;
  final dynamic review;

  UserPaymentHistoryDetailsModel({
    this.serviceBooking,
    this.additionalCosts,
    this.review,
  });

  // fromJson method
  factory UserPaymentHistoryDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserPaymentHistoryDetailsModel(
      serviceBooking: json['serviceBooking'] != null
          ? ServiceBooking.fromJson(json['serviceBooking'])
          : null,
      additionalCosts: (json['additionalCosts'] as List?)
          ?.map((e) => AdditionalCost.fromJson(e))
          .toList(),
      review: json['review'],
    );
  }

  // fromMap method
  factory UserPaymentHistoryDetailsModel.fromMap(Map<String, dynamic> map) {
    return UserPaymentHistoryDetailsModel(
      serviceBooking: map['serviceBooking'] != null
          ? ServiceBooking.fromMap(map['serviceBooking'])
          : null,
      additionalCosts: (map['additionalCosts'] as List?)
          ?.map((e) => AdditionalCost.fromMap(e))
          .toList(),
      review: map['review'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceBooking': serviceBooking?.toJson(),
      'additionalCosts': additionalCosts?.map((e) => e.toJson()).toList(),
      'review': review,
    };
  }
}

class ServiceBooking {
  final Address? address;
  final String? userId;
  final ProviderId? providerId;
  final String? providerDetailsId;
  final String? bookingDateTime;
  final String? bookingMonth;
  final String? status;
  final String? lat;
  final String? long;
  final List<Attachment>? attachments;
  final double? startPrice;
  final double? adminPercentageOfStartPrice;
  final String? paymentTransactionId;
  final String? paymentMethod;
  final String? paymentStatus;
  final bool? hasReview;
  final String? completionDate;
  final String? duration;
  final double? totalCost;
  final String? serviceBookingId;

  ServiceBooking({
    this.address,
    this.userId,
    this.providerId,
    this.providerDetailsId,
    this.bookingDateTime,
    this.bookingMonth,
    this.status,
    this.lat,
    this.long,
    this.attachments,
    this.startPrice,
    this.adminPercentageOfStartPrice,
    this.paymentTransactionId,
    this.paymentMethod,
    this.paymentStatus,
    this.hasReview,
    this.completionDate,
    this.duration,
    this.totalCost,
    this.serviceBookingId,
  });

  // fromJson method
  factory ServiceBooking.fromJson(Map<String, dynamic> json) {
    return ServiceBooking(
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      userId: json['userId'],
      providerId: json['providerId'] != null
          ? ProviderId.fromJson(json['providerId'])
          : null,
      providerDetailsId: json['providerDetailsId'],
      bookingDateTime: json['bookingDateTime'],
      bookingMonth: json['bookingMonth'],
      status: json['status'],
      lat: json['lat'],
      long: json['long'],
      attachments: (json['attachments'] as List?)
          ?.map((e) => Attachment.fromJson(e))
          .toList(),
      startPrice: json['startPrice']?.toDouble(),
      adminPercentageOfStartPrice: json['adminPercentageOfStartPrice']?.toDouble(),
      paymentTransactionId: json['paymentTransactionId'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      hasReview: json['hasReview'],
      completionDate: json['completionDate'],
      duration: json['duration'],
      totalCost: json['totalCost']?.toDouble(),
      serviceBookingId: json['_ServiceBookingId'],
    );
  }

  // fromMap method
  factory ServiceBooking.fromMap(Map<String, dynamic> map) {
    return ServiceBooking(
      address: map['address'] != null ? Address.fromMap(map['address']) : null,
      userId: map['userId'],
      providerId: map['providerId'] != null
          ? ProviderId.fromMap(map['providerId'])
          : null,
      providerDetailsId: map['providerDetailsId'],
      bookingDateTime: map['bookingDateTime'],
      bookingMonth: map['bookingMonth'],
      status: map['status'],
      lat: map['lat'],
      long: map['long'],
      attachments: (map['attachments'] as List?)
          ?.map((e) => Attachment.fromMap(e))
          .toList(),
      startPrice: map['startPrice']?.toDouble(),
      adminPercentageOfStartPrice: map['adminPercentageOfStartPrice']?.toDouble(),
      paymentTransactionId: map['paymentTransactionId'],
      paymentMethod: map['paymentMethod'],
      paymentStatus: map['paymentStatus'],
      hasReview: map['hasReview'],
      completionDate: map['completionDate'],
      duration: map['duration'],
      totalCost: map['totalCost']?.toDouble(),
      serviceBookingId: map['_ServiceBookingId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address?.toJson(),
      'userId': userId,
      'providerId': providerId?.toJson(),
      'providerDetailsId': providerDetailsId,
      'bookingDateTime': bookingDateTime,
      'bookingMonth': bookingMonth,
      'status': status,
      'lat': lat,
      'long': long,
      'attachments': attachments?.map((e) => e.toJson()).toList(),
      'startPrice': startPrice,
      'adminPercentageOfStartPrice': adminPercentageOfStartPrice,
      'paymentTransactionId': paymentTransactionId,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'hasReview': hasReview,
      'completionDate': completionDate,
      'duration': duration,
      'totalCost': totalCost,
      '_ServiceBookingId': serviceBookingId,
    };
  }
}

class Address {
  final String? en;
  final String? bn;

  Address({this.en, this.bn});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      en: json['en'],
      bn: json['bn'],
    );
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      en: map['en'],
      bn: map['bn'],
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
  final ProfileImage? profileImage;
  final String? userId;

  ProviderId({this.name, this.profileImage, this.userId});

  factory ProviderId.fromJson(Map<String, dynamic> json) {
    return ProviderId(
      name: json['name'],
      profileImage: json['profileImage'] != null
          ? ProfileImage.fromJson(json['profileImage'])
          : null,
      userId: json['_userId'],
    );
  }

  factory ProviderId.fromMap(Map<String, dynamic> map) {
    return ProviderId(
      name: map['name'],
      profileImage: map['profileImage'] != null
          ? ProfileImage.fromMap(map['profileImage'])
          : null,
      userId: map['_userId'],
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

  factory ProfileImage.fromJson(Map<String, dynamic> json) {
    return ProfileImage(
      imageUrl: json['imageUrl'],
      id: json['_id'],
    );
  }

  factory ProfileImage.fromMap(Map<String, dynamic> map) {
    return ProfileImage(
      imageUrl: map['imageUrl'],
      id: map['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      '_id': id,
    };
  }
}

class Attachment {
  final String? attachment;
  final String? attachmentId;
  final String? attachmentType;  // Added the attachmentType field

  Attachment({
    this.attachment,
    this.attachmentId,
    this.attachmentType, // Include the attachmentType in the constructor
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      attachment: json['attachment'],
      attachmentId: json['_attachmentId'],
      attachmentType: json['attachmentType'],  // Parse attachmentType from JSON
    );
  }

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      attachment: map['attachment'],
      attachmentId: map['_attachmentId'],
      attachmentType: map['attachmentType'],  // Parse attachmentType from Map
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attachment': attachment,
      '_attachmentId': attachmentId,
      'attachmentType': attachmentType,  // Add attachmentType to the JSON
    };
  }
}

class AdditionalCost {
  final String? serviceBookingId;
  final String? costName;
  final double? price;
  final List<String>? proofImage;
  final String? additionalCostId;

  AdditionalCost({
    this.serviceBookingId,
    this.costName,
    this.price,
    this.proofImage,
    this.additionalCostId,
  });

  factory AdditionalCost.fromJson(Map<String, dynamic> json) {
    return AdditionalCost(
      serviceBookingId: json['serviceBookingId'],
      costName: json['costName'],
      price: json['price']?.toDouble(),
      proofImage: (json['proofImage'] as List?)?.map((e) => e as String).toList(),
      additionalCostId: json['_AdditionalCostId'],
    );
  }

  factory AdditionalCost.fromMap(Map<String, dynamic> map) {
    return AdditionalCost(
      serviceBookingId: map['serviceBookingId'],
      costName: map['costName'],
      price: map['price']?.toDouble(),
      proofImage: (map['proofImage'] as List?)?.map((e) => e as String).toList(),
      additionalCostId: map['_AdditionalCostId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceBookingId': serviceBookingId,
      'costName': costName,
      'price': price,
      'proofImage': proofImage,
      '_AdditionalCostId': additionalCostId,
    };
  }
}

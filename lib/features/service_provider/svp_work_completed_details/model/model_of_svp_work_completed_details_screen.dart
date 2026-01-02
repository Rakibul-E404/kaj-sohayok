class ModelOfSvpWorkCompletedDetails {
  final int code;
  final String message;
  final Data data;

  ModelOfSvpWorkCompletedDetails({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ModelOfSvpWorkCompletedDetails.fromJson(Map<String, dynamic> json) {
    return ModelOfSvpWorkCompletedDetails(
      code: json['code'],
      message: json['message'],
      data: Data.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'data': data.toJson(),
      };
}

class Data {
  final Attributes attributes;

  Data({required this.attributes});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      attributes: Attributes.fromJson(json['attributes']),
    );
  }

  Map<String, dynamic> toJson() => {
        'attributes': attributes.toJson(),
      };
}

class Attributes {
  final ServiceBooking serviceBooking;
  final List<AdditionalCost> additionalCosts;
  final dynamic review;

  Attributes({
    required this.serviceBooking,
    required this.additionalCosts,
    this.review,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) {
    return Attributes(
      serviceBooking: ServiceBooking.fromJson(json['serviceBooking']),
      additionalCosts: json['additionalCosts'] != null
          ? List<AdditionalCost>.from(
              json['additionalCosts'].map((x) => AdditionalCost.fromJson(x)))
          : [],
      review: json['review'],
    );
  }

  Map<String, dynamic> toJson() => {
        'serviceBooking': serviceBooking.toJson(),
        'additionalCosts': additionalCosts.map((x) => x.toJson()).toList(),
        'review': review,
      };
}

class ServiceBooking {
  final Address address;
  final String userId;
  final ProviderId providerId;
  final String providerDetailsId;
  final DateTime bookingDateTime;
  final String bookingMonth;
  final String status;
  final String lat;
  final String long;
  final List<Attachment> attachments;
  final int startPrice;
  final int adminPercentageOfStartPrice;
  final String? paymentTransactionId;
  final String? paymentMethod;
  final String paymentStatus;
  final bool hasReview;
  final DateTime? completionDate;
  final String? duration;
  final int? totalCost;
  final String serviceBookingId;

  ServiceBooking({
    required this.address,
    required this.userId,
    required this.providerId,
    required this.providerDetailsId,
    required this.bookingDateTime,
    required this.bookingMonth,
    required this.status,
    required this.lat,
    required this.long,
    required this.attachments,
    required this.startPrice,
    required this.adminPercentageOfStartPrice,
    this.paymentTransactionId,
    this.paymentMethod,
    required this.paymentStatus,
    required this.hasReview,
    this.completionDate,
    this.duration,
    this.totalCost,
    required this.serviceBookingId,
  });

  factory ServiceBooking.fromJson(Map<String, dynamic> json) {
    return ServiceBooking(
      address: Address.fromJson(json['address']),
      userId: json['userId'],
      providerId: ProviderId.fromJson(json['providerId']),
      providerDetailsId: json['providerDetailsId'],
      bookingDateTime: DateTime.parse(json['bookingDateTime']),
      bookingMonth: json['bookingMonth'],
      status: json['status'],
      lat: json['lat'],
      long: json['long'],
      attachments: json['attachments'] != null
          ? List<Attachment>.from(
              json['attachments'].map((x) => Attachment.fromJson(x)))
          : [],
      startPrice: json['startPrice'],
      adminPercentageOfStartPrice: json['adminPercentageOfStartPrice'],
      paymentTransactionId: json['paymentTransactionId'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      hasReview: json['hasReview'],
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
      duration: json['duration'],
      totalCost: json['totalCost'],
      serviceBookingId: json['_ServiceBookingId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address.toJson(),
        'userId': userId,
        'providerId': providerId.toJson(),
        'providerDetailsId': providerDetailsId,
        'bookingDateTime': bookingDateTime.toIso8601String(),
        'bookingMonth': bookingMonth,
        'status': status,
        'lat': lat,
        'long': long,
        'attachments': attachments.map((x) => x.toJson()).toList(),
        'startPrice': startPrice,
        'adminPercentageOfStartPrice': adminPercentageOfStartPrice,
        'paymentTransactionId': paymentTransactionId,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'hasReview': hasReview,
        'completionDate':
            completionDate != null ? completionDate!.toIso8601String() : null,
        'duration': duration,
        'totalCost': totalCost,
        '_ServiceBookingId': serviceBookingId,
      };
}

class Address {
  final String en;
  final String bn;

  Address({required this.en, required this.bn});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      en: json['en'],
      bn: json['bn'],
    );
  }

  Map<String, dynamic> toJson() => {
        'en': en,
        'bn': bn,
      };
}

class ProviderId {
  final String name;
  final ProfileImage profileImage;
  final String userId;

  ProviderId({
    required this.name,
    required this.profileImage,
    required this.userId,
  });

  factory ProviderId.fromJson(Map<String, dynamic> json) {
    return ProviderId(
      name: json['name'],
      profileImage: ProfileImage.fromJson(json['profileImage']),
      userId: json['_userId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'profileImage': profileImage.toJson(),
        '_userId': userId,
      };
}

class ProfileImage {
  final String imageUrl;
  final String id;

  ProfileImage({required this.imageUrl, required this.id});

  factory ProfileImage.fromJson(Map<String, dynamic> json) {
    return ProfileImage(
      imageUrl: json['imageUrl'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        '_id': id,
      };
}

class Attachment {
  final String attachment;
  final String attachmentType;
  final String attachmentId;

  Attachment({
    required this.attachment,
    required this.attachmentType,
    required this.attachmentId,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      attachment: json['attachment'],
      attachmentType: json['attachmentType'],
      attachmentId: json['_attachmentId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'attachment': attachment,
        'attachmentType': attachmentType,
        '_attachmentId': attachmentId,
      };
}

class AdditionalCost {
  final String serviceBookingId;
  final String costName;
  final int price;
  final List<dynamic> proofImage;
  final String additionalCostId;

  AdditionalCost({
    required this.serviceBookingId,
    required this.costName,
    required this.price,
    required this.proofImage,
    required this.additionalCostId,
  });

  factory AdditionalCost.fromJson(Map<String, dynamic> json) {
    return AdditionalCost(
      serviceBookingId: json['serviceBookingId'],
      costName: json['costName'],
      price: json['price'],
      proofImage: json['proofImage'] ?? [],
      additionalCostId: json['_AdditionalCostId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'serviceBookingId': serviceBookingId,
        'costName': costName,
        'price': price,
        'proofImage': proofImage,
        '_AdditionalCostId': additionalCostId,
      };
}

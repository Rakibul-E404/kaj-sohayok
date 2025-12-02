import 'dart:convert';

class ServiceBookingsModel {
  int? code;
  String? message;
  Data? data;
  bool? success;

  ServiceBookingsModel({this.code, this.message, this.data, this.success});

  factory ServiceBookingsModel.fromRawJson(String str) =>
      ServiceBookingsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ServiceBookingsModel.fromJson(Map<String, dynamic> json) =>
      ServiceBookingsModel(
        code: json["code"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
    "success": success,
  };
}

class Data {
  Attributes? attributes;

  Data({this.attributes});

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    attributes: json["attributes"] == null
        ? null
        : Attributes.fromJson(json["attributes"]),
  );

  Map<String, dynamic> toJson() => {"attributes": attributes?.toJson()};
}

class Attributes {
  String? userId;
  String? providerId;
  String? providerDetailsId;
  DateTime? bookingDateTime;
  String? bookingMonth;
  String? status;
  Address? address;
  String? lat;
  String? long;
  List<dynamic>? attachments;
  int? startPrice;
  int? adminPercentageOfStartPrice;
  dynamic paymentTransactionId;
  dynamic paymentMethod;
  String? paymentStatus;
  bool? hasReview;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? serviceBookingId;

  Attributes({
    this.userId,
    this.providerId,
    this.providerDetailsId,
    this.bookingDateTime,
    this.bookingMonth,
    this.status,
    this.address,
    this.lat,
    this.long,
    this.attachments,
    this.startPrice,
    this.adminPercentageOfStartPrice,
    this.paymentTransactionId,
    this.paymentMethod,
    this.paymentStatus,
    this.hasReview,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.serviceBookingId,
  });

  factory Attributes.fromRawJson(String str) =>
      Attributes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
    userId: json["userId"],
    providerId: json["providerId"],
    providerDetailsId: json["providerDetailsId"],
    bookingDateTime: json["bookingDateTime"] == null
        ? null
        : DateTime.parse(json["bookingDateTime"]),
    bookingMonth: json["bookingMonth"],
    status: json["status"],
    address: json["address"] == null ? null : Address.fromJson(json["address"]),
    lat: (json["lat"] != null) ? json["lat"].toString() : null,
    long: (json["long"] != null) ? json["long"].toString() : null,
    attachments: json["attachments"] == null
        ? []
        : List<dynamic>.from(json["attachments"]!.map((x) => x)),
    startPrice: json["startPrice"],
    adminPercentageOfStartPrice: json["adminPercentageOfStartPrice"],
    paymentTransactionId: json["paymentTransactionId"],
    paymentMethod: json["paymentMethod"],
    paymentStatus: json["paymentStatus"],
    hasReview: json["hasReview"],
    isDeleted: json["isDeleted"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    serviceBookingId: json["_ServiceBookingId"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "providerId": providerId,
    "providerDetailsId": providerDetailsId,
    "bookingDateTime": bookingDateTime?.toIso8601String(),
    "bookingMonth": bookingMonth,
    "status": status,
    "address": address?.toJson(),
    "lat": lat,
    "long": long,
    "attachments": attachments == null
        ? []
        : List<dynamic>.from(attachments!.map((x) => x)),
    "startPrice": startPrice,
    "adminPercentageOfStartPrice": adminPercentageOfStartPrice,
    "paymentTransactionId": paymentTransactionId,
    "paymentMethod": paymentMethod,
    "paymentStatus": paymentStatus,
    "hasReview": hasReview,
    "isDeleted": isDeleted,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "_ServiceBookingId": serviceBookingId,
  };
}

class Address {
  String? en;
  String? bn;

  Address({this.en, this.bn});

  factory Address.fromRawJson(String str) => Address.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Address.fromJson(Map<String, dynamic> json) =>
      Address(en: json["en"], bn: json["bn"]);

  Map<String, dynamic> toJson() => {"en": en, "bn": bn};
}

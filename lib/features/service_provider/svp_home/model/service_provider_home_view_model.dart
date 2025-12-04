import 'dart:convert';

class ServiceProviderHomeViewModel {
  int? code;
  String? message;
  Data? data;
  bool? success;

  ServiceProviderHomeViewModel({
    this.code,
    this.message,
    this.data,
    this.success,
  });

  factory ServiceProviderHomeViewModel.fromRawJson(String str) =>
      ServiceProviderHomeViewModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ServiceProviderHomeViewModel.fromJson(Map<String, dynamic> json) =>
      ServiceProviderHomeViewModel(
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
  int? totalIncome;
  String? type;
  List<ChartDatum>? chartData;
  Stats? stats;
  List<RecentJobRequest>? recentJobRequests;

  Attributes({
    this.totalIncome,
    this.type,
    this.chartData,
    this.stats,
    this.recentJobRequests,
  });

  factory Attributes.fromRawJson(String str) =>
      Attributes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
    totalIncome: json["totalIncome"],
    type: json["type"],
    chartData: json["chartData"] == null
        ? []
        : List<ChartDatum>.from(
            json["chartData"]!.map((x) => ChartDatum.fromJson(x)),
          ),
    stats: json["stats"] == null ? null : Stats.fromJson(json["stats"]),
    recentJobRequests: json["recentJobRequests"] == null
        ? []
        : List<RecentJobRequest>.from(
            json["recentJobRequests"]!.map((x) => RecentJobRequest.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "totalIncome": totalIncome,
    "type": type,
    "chartData": chartData == null
        ? []
        : List<dynamic>.from(chartData!.map((x) => x.toJson())),
    "stats": stats?.toJson(),
    "recentJobRequests": recentJobRequests == null
        ? []
        : List<dynamic>.from(recentJobRequests!.map((x) => x.toJson())),
  };
}

class ChartDatum {
  String? label;
  int? income;

  ChartDatum({this.label, this.income});

  factory ChartDatum.fromRawJson(String str) =>
      ChartDatum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChartDatum.fromJson(Map<String, dynamic> json) =>
      ChartDatum(label: json["label"], income: json["income"]);

  Map<String, dynamic> toJson() => {"label": label, "income": income};
}

class RecentJobRequest {
  String? id;
  UserId? userId;
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
  double? adminPercentageOfStartPrice;
  dynamic paymentTransactionId;
  dynamic paymentMethod;
  String? paymentStatus;
  bool? hasReview;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  RecentJobRequest({
    this.id,
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
  });

  factory RecentJobRequest.fromRawJson(String str) =>
      RecentJobRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecentJobRequest.fromJson(Map<String, dynamic> json) =>
      RecentJobRequest(
        id: json["_id"],
        userId: json["userId"] == null ? null : UserId.fromJson(json["userId"]),
        providerId: json["providerId"],
        providerDetailsId: json["providerDetailsId"],
        bookingDateTime: json["bookingDateTime"] == null
            ? null
            : DateTime.parse(json["bookingDateTime"]),
        bookingMonth: json["bookingMonth"],
        status: json["status"],
        address: json["address"] == null
            ? null
            : Address.fromJson(json["address"]),
        lat: json["lat"],
        long: json["long"],
        attachments: json["attachments"] == null
            ? []
            : List<dynamic>.from(json["attachments"]!.map((x) => x)),
        startPrice: json["startPrice"],
        adminPercentageOfStartPrice: json["adminPercentageOfStartPrice"]
            ?.toDouble(),
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
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId?.toJson(),
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

class UserId {
  String? id;
  String? name;
  ProfileImage? profileImage;

  UserId({this.id, this.name, this.profileImage});

  factory UserId.fromRawJson(String str) => UserId.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserId.fromJson(Map<String, dynamic> json) => UserId(
    id: json["_id"],
    name: json["name"],
    profileImage: json["profileImage"] == null
        ? null
        : ProfileImage.fromJson(json["profileImage"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "profileImage": profileImage?.toJson(),
  };
}

class ProfileImage {
  String? imageUrl;
  String? id;

  ProfileImage({this.imageUrl, this.id});

  factory ProfileImage.fromRawJson(String str) =>
      ProfileImage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProfileImage.fromJson(Map<String, dynamic> json) =>
      ProfileImage(imageUrl: json["imageUrl"], id: json["_id"]);

  Map<String, dynamic> toJson() => {"imageUrl": imageUrl, "_id": id};
}

class Stats {
  int? totalRequests;
  int? accepted;
  int? inProgress;
  int? completed;

  Stats({this.totalRequests, this.accepted, this.inProgress, this.completed});

  factory Stats.fromRawJson(String str) => Stats.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    totalRequests: json["totalRequests"],
    accepted: json["accepted"],
    inProgress: json["inProgress"],
    completed: json["completed"],
  );

  Map<String, dynamic> toJson() => {
    "totalRequests": totalRequests,
    "accepted": accepted,
    "inProgress": inProgress,
    "completed": completed,
  };
}

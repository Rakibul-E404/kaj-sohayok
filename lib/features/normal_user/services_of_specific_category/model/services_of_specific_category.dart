import 'dart:convert';

class ServicesOfSpecificCategory {
  int? code;
  String? message;
  Data? data;
  bool? success;

  ServicesOfSpecificCategory({
    this.code,
    this.message,
    this.data,
    this.success,
  });

  factory ServicesOfSpecificCategory.fromRawJson(String str) =>
      ServicesOfSpecificCategory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ServicesOfSpecificCategory.fromJson(Map<String, dynamic> json) =>
      ServicesOfSpecificCategory(
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

  Data({
    this.attributes,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        attributes: json["attributes"] == null
            ? null
            : Attributes.fromJson(json["attributes"]),
      );

  Map<String, dynamic> toJson() => {
        "attributes": attributes?.toJson(),
      };
}

class Attributes {
  List<Result>? results;
  int? totalResults;
  int? limit;
  String? page;
  int? totalPages;

  Attributes({
    this.results,
    this.totalResults,
    this.limit,
    this.page,
    this.totalPages,
  });

  factory Attributes.fromRawJson(String str) =>
      Attributes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
        results: json["results"] == null
            ? []
            : List<Result>.from(
                json["results"]!.map((x) => Result.fromJson(x))),
        totalResults: json["totalResults"],
        limit: json["limit"],
        page: json["page"],
        totalPages: json["totalPages"],
      );

  Map<String, dynamic> toJson() => {
        "results": results == null
            ? []
            : List<dynamic>.from(results!.map((x) => x.toJson())),
        "totalResults": totalResults,
        "limit": limit,
        "page": page,
        "totalPages": totalPages,
      };
}

class Result {
  String? id;
  String? providerId;
  String? locationId;
  Description? serviceName;
  String? serviceCategoryId;
  int? startPrice;
  // int? rating;
  double? rating;
  Description? introOrBio;
  Description? description;
  int? yearsOfExperience;
  String? providerApprovalStatus;
  DateTime? createdAt;
  String? providerName;
  ProfileImage? profileImage;
  List<dynamic>? attachmentsForGallery;

  Result({
    this.id,
    this.providerId,
    this.locationId,
    this.serviceName,
    this.serviceCategoryId,
    this.startPrice,
    this.rating,
    this.introOrBio,
    this.description,
    this.yearsOfExperience,
    this.providerApprovalStatus,
    this.createdAt,
    this.providerName,
    this.profileImage,
    this.attachmentsForGallery,
  });

  factory Result.fromRawJson(String str) => Result.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["_id"],
        providerId: json["providerId"],
        locationId: json["locationId"],
        serviceName: json["serviceName"] == null
            ? null
            : Description.fromJson(json["serviceName"]),
        serviceCategoryId: json["serviceCategoryId"],
        startPrice: json["startPrice"],
        // rating: json["rating"],
        rating: (json["rating"] ?? 0 as num).toDouble(),
        introOrBio: json["introOrBio"] == null
            ? null
            : Description.fromJson(json["introOrBio"]),
        description: json["description"] == null
            ? null
            : Description.fromJson(json["description"]),
        yearsOfExperience: json["yearsOfExperience"],
        providerApprovalStatus: json["providerApprovalStatus"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        providerName: json["providerName"],
        profileImage: json["profileImage"] == null
            ? null
            : ProfileImage.fromJson(json["profileImage"]),
        attachmentsForGallery: json["attachmentsForGallery"] == null
            ? []
            : List<dynamic>.from(json["attachmentsForGallery"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "providerId": providerId,
        "locationId": locationId,
        "serviceName": serviceName?.toJson(),
        "serviceCategoryId": serviceCategoryId,
        "startPrice": startPrice,
        "rating": rating,
        "introOrBio": introOrBio?.toJson(),
        "description": description?.toJson(),
        "yearsOfExperience": yearsOfExperience,
        "providerApprovalStatus": providerApprovalStatus,
        "createdAt": createdAt?.toIso8601String(),
        "providerName": providerName,
        "profileImage": profileImage?.toJson(),
        "attachmentsForGallery": attachmentsForGallery == null
            ? []
            : List<dynamic>.from(attachmentsForGallery!.map((x) => x)),
      };
}

class Description {
  String? en;
  String? bn;

  Description({
    this.en,
    this.bn,
  });

  factory Description.fromRawJson(String str) =>
      Description.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Description.fromJson(Map<String, dynamic> json) => Description(
        en: json["en"],
        bn: json["bn"],
      );

  Map<String, dynamic> toJson() => {
        "en": en,
        "bn": bn,
      };
}

class ProfileImage {
  String? imageUrl;
  String? id;

  ProfileImage({
    this.imageUrl,
    this.id,
  });

  factory ProfileImage.fromRawJson(String str) =>
      ProfileImage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProfileImage.fromJson(Map<String, dynamic> json) => ProfileImage(
        imageUrl: json["imageUrl"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "imageUrl": imageUrl,
        "_id": id,
      };
}

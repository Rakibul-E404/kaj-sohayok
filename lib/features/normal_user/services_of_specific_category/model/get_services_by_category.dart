import 'dart:convert';

class GetServicesByCategoriesModel {
  int? code;
  String? message;
  Data? data;
  bool? success;

  GetServicesByCategoriesModel({
    this.code,
    this.message,
    this.data,
    this.success,
  });

  factory GetServicesByCategoriesModel.fromRawJson(String str) =>
      GetServicesByCategoriesModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetServicesByCategoriesModel.fromJson(Map<String, dynamic> json) =>
      GetServicesByCategoriesModel(
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
  List<Result>? results;
  String? page;
  int? limit;
  int? totalPages;
  int? totalResults;

  Attributes({
    this.results,
    this.page,
    this.limit,
    this.totalPages,
    this.totalResults,
  });

  factory Attributes.fromRawJson(String str) =>
      Attributes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
    results: json["results"] == null
        ? []
        : List<Result>.from(json["results"]!.map((x) => Result.fromJson(x))),
    page: json["page"],
    limit: json["limit"],
    totalPages: json["totalPages"],
    totalResults: json["totalResults"],
  );

  Map<String, dynamic> toJson() => {
    "results": results == null
        ? []
        : List<dynamic>.from(results!.map((x) => x.toJson())),
    "page": page,
    "limit": limit,
    "totalPages": totalPages,
    "totalResults": totalResults,
  };
}

class Result {
  Description? serviceName;
  Description? introOrBio;
  Description? description;
  ProviderId? providerId;
  String? serviceCategoryId;
  String? providerApprovalStatus;
  int? startPrice;
  int? rating;
  List<AttachmentsForGallery>? attachmentsForGallery;
  List<dynamic>? attachmentsForCoverPhoto;
  int? yearsOfExperience;
  int? v;
  String? serviceProviderId;

  Result({
    this.serviceName,
    this.introOrBio,
    this.description,
    this.providerId,
    this.serviceCategoryId,
    this.providerApprovalStatus,
    this.startPrice,
    this.rating,
    this.attachmentsForGallery,
    this.attachmentsForCoverPhoto,
    this.yearsOfExperience,
    this.v,
    this.serviceProviderId,
  });

  factory Result.fromRawJson(String str) => Result.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    serviceName: json["serviceName"] == null
        ? null
        : Description.fromJson(json["serviceName"]),
    introOrBio: json["introOrBio"] == null
        ? null
        : Description.fromJson(json["introOrBio"]),
    description: json["description"] == null
        ? null
        : Description.fromJson(json["description"]),
    providerId: json["providerId"] == null
        ? null
        : ProviderId.fromJson(json["providerId"]),
    serviceCategoryId: json["serviceCategoryId"],
    providerApprovalStatus: json["providerApprovalStatus"],
    startPrice: json["startPrice"],
    rating: json["rating"],
    attachmentsForGallery: json["attachmentsForGallery"] == null
        ? []
        : List<AttachmentsForGallery>.from(
            json["attachmentsForGallery"]!.map(
              (x) => AttachmentsForGallery.fromJson(x),
            ),
          ),
    attachmentsForCoverPhoto: json["attachmentsForCoverPhoto"] == null
        ? []
        : List<dynamic>.from(json["attachmentsForCoverPhoto"]!.map((x) => x)),
    yearsOfExperience: json["yearsOfExperience"],
    v: json["__v"],
    serviceProviderId: json["_ServiceProviderId"],
  );

  Map<String, dynamic> toJson() => {
    "serviceName": serviceName?.toJson(),
    "introOrBio": introOrBio?.toJson(),
    "description": description?.toJson(),
    "providerId": providerId?.toJson(),
    "serviceCategoryId": serviceCategoryId,
    "providerApprovalStatus": providerApprovalStatus,
    "startPrice": startPrice,
    "rating": rating,
    "attachmentsForGallery": attachmentsForGallery == null
        ? []
        : List<dynamic>.from(attachmentsForGallery!.map((x) => x.toJson())),
    "attachmentsForCoverPhoto": attachmentsForCoverPhoto == null
        ? []
        : List<dynamic>.from(attachmentsForCoverPhoto!.map((x) => x)),
    "yearsOfExperience": yearsOfExperience,
    "__v": v,
    "_ServiceProviderId": serviceProviderId,
  };
}

class AttachmentsForGallery {
  String? attachment;
  String? attachmentId;

  AttachmentsForGallery({this.attachment, this.attachmentId});

  factory AttachmentsForGallery.fromRawJson(String str) =>
      AttachmentsForGallery.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttachmentsForGallery.fromJson(Map<String, dynamic> json) =>
      AttachmentsForGallery(
        attachment: json["attachment"],
        attachmentId: json["_attachmentId"],
      );

  Map<String, dynamic> toJson() => {
    "attachment": attachment,
    "_attachmentId": attachmentId,
  };
}

class Description {
  String? en;
  String? bn;

  Description({this.en, this.bn});

  factory Description.fromRawJson(String str) =>
      Description.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Description.fromJson(Map<String, dynamic> json) =>
      Description(en: json["en"], bn: json["bn"]);

  Map<String, dynamic> toJson() => {"en": en, "bn": bn};
}

class ProviderId {
  String? name;
  ProfileImage? profileImage;
  String? userId;

  ProviderId({this.name, this.profileImage, this.userId});

  factory ProviderId.fromRawJson(String str) =>
      ProviderId.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProviderId.fromJson(Map<String, dynamic> json) => ProviderId(
    name: json["name"],
    profileImage: json["profileImage"] == null
        ? null
        : ProfileImage.fromJson(json["profileImage"]),
    userId: json["_userId"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "profileImage": profileImage?.toJson(),
    "_userId": userId,
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

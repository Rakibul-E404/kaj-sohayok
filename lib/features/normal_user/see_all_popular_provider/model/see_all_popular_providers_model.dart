import 'dart:convert';

class SeeAllPopularProvidersModel {
  int? code;
  String? message;
  Data? data;
  bool? success;

  SeeAllPopularProvidersModel({
    this.code,
    this.message,
    this.data,
    this.success,
  });

  factory SeeAllPopularProvidersModel.fromRawJson(String str) =>
      SeeAllPopularProvidersModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SeeAllPopularProvidersModel.fromJson(Map<String, dynamic> json) =>
      SeeAllPopularProvidersModel(
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
  List<Provider>? providers;

  Attributes({this.providers});

  factory Attributes.fromRawJson(String str) =>
      Attributes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
    providers: json["providers"] == null
        ? []
        : List<Provider>.from(
            json["providers"]!.map((x) => Provider.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "providers": providers == null
        ? []
        : List<dynamic>.from(providers!.map((x) => x.toJson())),
  };
}

class Provider {
  Description? serviceName;
  Description? introOrBio;
  Description? description;
  String? providerId;
  String? serviceCategoryId;
  String? providerApprovalStatus;
  int? startPrice;
  int? rating;
  List<AttachmentsForGallery>? attachmentsForGallery;
  List<dynamic>? attachmentsForCoverPhoto;
  int? yearsOfExperience;
  String? serviceProviderId;

  Provider({
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
    this.serviceProviderId,
  });

  factory Provider.fromRawJson(String str) =>
      Provider.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Provider.fromJson(Map<String, dynamic> json) => Provider(
    serviceName: json["serviceName"] == null
        ? null
        : Description.fromJson(json["serviceName"]),
    introOrBio: json["introOrBio"] == null
        ? null
        : Description.fromJson(json["introOrBio"]),
    description: json["description"] == null
        ? null
        : Description.fromJson(json["description"]),
    providerId: json["providerId"],
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
    serviceProviderId: json["_ServiceProviderId"],
  );

  Map<String, dynamic> toJson() => {
    "serviceName": serviceName?.toJson(),
    "introOrBio": introOrBio?.toJson(),
    "description": description?.toJson(),
    "providerId": providerId,
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
    "_ServiceProviderId": serviceProviderId,
  };
}

class AttachmentsForGallery {
  String? attachment;
  String? attachmentType;
  String? attachmentId;

  AttachmentsForGallery({
    this.attachment,
    this.attachmentType,
    this.attachmentId,
  });

  factory AttachmentsForGallery.fromRawJson(String str) =>
      AttachmentsForGallery.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttachmentsForGallery.fromJson(Map<String, dynamic> json) =>
      AttachmentsForGallery(
        attachment: json["attachment"],
        attachmentType: json["attachmentType"],
        attachmentId: json["_attachmentId"],
      );

  Map<String, dynamic> toJson() => {
    "attachment": attachment,
    "attachmentType": attachmentType,
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

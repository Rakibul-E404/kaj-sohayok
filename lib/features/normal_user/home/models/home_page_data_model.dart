import 'dart:convert';

class HomePageDataModel {
  int? code;
  String? message;
  Data? data;
  bool? success;

  HomePageDataModel({this.code, this.message, this.data, this.success});

  factory HomePageDataModel.fromRawJson(String str) =>
      HomePageDataModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HomePageDataModel.fromJson(Map<String, dynamic> json) =>
      HomePageDataModel(
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
  List<Category>? categories;
  List<Provider>? providers;
  List<Banner>? banners;

  Attributes({this.categories, this.providers, this.banners});

  factory Attributes.fromRawJson(String str) =>
      Attributes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
    categories: json["categories"] == null
        ? []
        : List<Category>.from(
            json["categories"]!.map((x) => Category.fromJson(x)),
          ),
    providers: json["providers"] == null
        ? []
        : List<Provider>.from(
            json["providers"]!.map((x) => Provider.fromJson(x)),
          ),
    banners: json["banners"] == null
        ? []
        : List<Banner>.from(json["banners"]!.map((x) => Banner.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "categories": categories == null
        ? []
        : List<dynamic>.from(categories!.map((x) => x.toJson())),
    "providers": providers == null
        ? []
        : List<dynamic>.from(providers!.map((x) => x.toJson())),
    "banners": banners == null
        ? []
        : List<dynamic>.from(banners!.map((x) => x.toJson())),
  };
}

class Banner {
  List<BannerAttachment>? attachments;
  String? bannerId;

  Banner({this.attachments, this.bannerId});

  factory Banner.fromRawJson(String str) => Banner.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
    attachments: json["attachments"] == null
        ? []
        : List<BannerAttachment>.from(
            json["attachments"]!.map((x) => BannerAttachment.fromJson(x)),
          ),
    bannerId: json["_BannerId"],
  );

  Map<String, dynamic> toJson() => {
    "attachments": attachments == null
        ? []
        : List<dynamic>.from(attachments!.map((x) => x.toJson())),
    "_BannerId": bannerId,
  };
}

class BannerAttachment {
  String? attachment;
  String? attachmentId;

  BannerAttachment({this.attachment, this.attachmentId});

  factory BannerAttachment.fromRawJson(String str) =>
      BannerAttachment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BannerAttachment.fromJson(Map<String, dynamic> json) =>
      BannerAttachment(
        attachment: json["attachment"],
        attachmentId: json["_attachmentId"],
      );

  Map<String, dynamic> toJson() => {
    "attachment": attachment,
    "_attachmentId": attachmentId,
  };
}

class Category {
  Name? name;
  List<AttachmentsForGalleryElement>? attachments;
  String? serviceCategoryId;

  Category({this.name, this.attachments, this.serviceCategoryId});

  factory Category.fromRawJson(String str) =>
      Category.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    name: json["name"] == null ? null : Name.fromJson(json["name"]),
    attachments: json["attachments"] == null
        ? []
        : List<AttachmentsForGalleryElement>.from(
            json["attachments"]!.map(
              (x) => AttachmentsForGalleryElement.fromJson(x),
            ),
          ),
    serviceCategoryId: json["_ServiceCategoryId"],
  );

  Map<String, dynamic> toJson() => {
    "name": name?.toJson(),
    "attachments": attachments == null
        ? []
        : List<dynamic>.from(attachments!.map((x) => x.toJson())),
    "_ServiceCategoryId": serviceCategoryId,
  };
}

class AttachmentsForGalleryElement {
  String? attachment;
  String? attachmentType;
  String? attachmentId;

  AttachmentsForGalleryElement({
    this.attachment,
    this.attachmentType,
    this.attachmentId,
  });

  factory AttachmentsForGalleryElement.fromRawJson(String str) =>
      AttachmentsForGalleryElement.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttachmentsForGalleryElement.fromJson(Map<String, dynamic> json) =>
      AttachmentsForGalleryElement(
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

class Name {
  String? en;
  String? bn;

  Name({this.en, this.bn});

  factory Name.fromRawJson(String str) => Name.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Name.fromJson(Map<String, dynamic> json) =>
      Name(en: json["en"], bn: json["bn"]);

  Map<String, dynamic> toJson() => {"en": en, "bn": bn};
}

class Provider {
  Name? serviceName;
  Name? introOrBio;
  Name? description;
  String? providerId;
  String? serviceCategoryId;
  String? providerApprovalStatus;
  int? startPrice;
  int? rating;
  List<AttachmentsForGalleryElement>? attachmentsForGallery;
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
        : Name.fromJson(json["serviceName"]),
    introOrBio: json["introOrBio"] == null
        ? null
        : Name.fromJson(json["introOrBio"]),
    description: json["description"] == null
        ? null
        : Name.fromJson(json["description"]),
    providerId: json["providerId"],
    serviceCategoryId: json["serviceCategoryId"],
    providerApprovalStatus: json["providerApprovalStatus"],
    startPrice: json["startPrice"],
    rating: json["rating"],
    attachmentsForGallery: json["attachmentsForGallery"] == null
        ? []
        : List<AttachmentsForGalleryElement>.from(
            json["attachmentsForGallery"]!.map(
              (x) => AttachmentsForGalleryElement.fromJson(x),
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

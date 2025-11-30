import 'dart:convert';

class GetServiceProviderProfileDetailsModel {
  int? code;
  String? message;
  Data? data;
  bool? success;

  GetServiceProviderProfileDetailsModel({
    this.code,
    this.message,
    this.data,
    this.success,
  });

  factory GetServiceProviderProfileDetailsModel.fromRawJson(String str) =>
      GetServiceProviderProfileDetailsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetServiceProviderProfileDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) => GetServiceProviderProfileDetailsModel(
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
  String? id;
  String? providerId;
  Description? serviceName;
  ServiceCategoryId? serviceCategoryId;
  String? providerApprovalStatus;
  int? startPrice;
  int? rating;
  Description? introOrBio;
  Description? description;
  List<String>? attachmentsForGallery;
  List<dynamic>? attachmentsForCoverPhoto;
  int? yearsOfExperience;
  DateTime? dob;
  String? gender;
  Description? location;
  String? name;
  ProfileImage? profileImage;
  String? phoneNumber;

  Attributes({
    this.id,
    this.providerId,
    this.serviceName,
    this.serviceCategoryId,
    this.providerApprovalStatus,
    this.startPrice,
    this.rating,
    this.introOrBio,
    this.description,
    this.attachmentsForGallery,
    this.attachmentsForCoverPhoto,
    this.yearsOfExperience,
    this.dob,
    this.gender,
    this.location,
    this.name,
    this.profileImage,
    this.phoneNumber,
  });

  factory Attributes.fromRawJson(String str) =>
      Attributes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
    id: json["_id"],
    providerId: json["providerId"],
    serviceName: json["serviceName"] == null
        ? null
        : Description.fromJson(json["serviceName"]),
    serviceCategoryId: json["serviceCategoryId"] == null
        ? null
        : ServiceCategoryId.fromJson(json["serviceCategoryId"]),
    providerApprovalStatus: json["providerApprovalStatus"],
    startPrice: json["startPrice"],
    rating: json["rating"],
    introOrBio: json["introOrBio"] == null
        ? null
        : Description.fromJson(json["introOrBio"]),
    description: json["description"] == null
        ? null
        : Description.fromJson(json["description"]),
    attachmentsForGallery: json["attachmentsForGallery"] == null
        ? []
        : List<String>.from(json["attachmentsForGallery"]!.map((x) => x)),
    attachmentsForCoverPhoto: json["attachmentsForCoverPhoto"] == null
        ? []
        : List<dynamic>.from(json["attachmentsForCoverPhoto"]!.map((x) => x)),
    yearsOfExperience: json["yearsOfExperience"],
    dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
    gender: json["gender"],
    location: json["location"] == null
        ? null
        : Description.fromJson(json["location"]),
    name: json["name"],
    profileImage: json["profileImage"] == null
        ? null
        : ProfileImage.fromJson(json["profileImage"]),
    phoneNumber: json["phoneNumber"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "providerId": providerId,
    "serviceName": serviceName?.toJson(),
    "serviceCategoryId": serviceCategoryId?.toJson(),
    "providerApprovalStatus": providerApprovalStatus,
    "startPrice": startPrice,
    "rating": rating,
    "introOrBio": introOrBio?.toJson(),
    "description": description?.toJson(),
    "attachmentsForGallery": attachmentsForGallery == null
        ? []
        : List<dynamic>.from(attachmentsForGallery!.map((x) => x)),
    "attachmentsForCoverPhoto": attachmentsForCoverPhoto == null
        ? []
        : List<dynamic>.from(attachmentsForCoverPhoto!.map((x) => x)),
    "yearsOfExperience": yearsOfExperience,
    "dob": dob?.toIso8601String(),
    "gender": gender,
    "location": location?.toJson(),
    "name": name,
    "profileImage": profileImage?.toJson(),
    "phoneNumber": phoneNumber,
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

class ServiceCategoryId {
  String? id;
  Description? name;

  ServiceCategoryId({this.id, this.name});

  factory ServiceCategoryId.fromRawJson(String str) =>
      ServiceCategoryId.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ServiceCategoryId.fromJson(Map<String, dynamic> json) =>
      ServiceCategoryId(
        id: json["_id"],
        name: json["name"] == null ? null : Description.fromJson(json["name"]),
      );

  Map<String, dynamic> toJson() => {"_id": id, "name": name?.toJson()};
}

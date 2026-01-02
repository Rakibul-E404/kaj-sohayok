// import 'dart:convert';

// class GetSpecificServiceDetailsModel {
//   int? code;
//   String? message;
//   Data? data;

//   GetSpecificServiceDetailsModel({this.code, this.message, this.data});

//   factory GetSpecificServiceDetailsModel.fromRawJson(String str) =>
//       GetSpecificServiceDetailsModel.fromJson(json.decode(str));

//   String toRawJson() => json.encode(toJson());

//   factory GetSpecificServiceDetailsModel.fromJson(Map<String, dynamic> json) =>
//       GetSpecificServiceDetailsModel(
//         code: json["code"],
//         message: json["message"],
//         data: json["data"] == null ? null : Data.fromJson(json["data"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "code": code,
//         "message": message,
//         "data": data?.toJson(),
//       };
// }

// class Data {
//   Attributes? attributes;

//   Data({this.attributes});

//   factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

//   String toRawJson() => json.encode(toJson());

//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//         attributes: json["attributes"] == null
//             ? null
//             : Attributes.fromJson(json["attributes"]),
//       );

//   Map<String, dynamic> toJson() => {"attributes": attributes?.toJson()};
// }

// class Attributes {
//   Result? result;
//   List<Review>? reviews;
//   List<FullResult>? fullResult;

//   Attributes({this.result, this.reviews, this.fullResult});

//   factory Attributes.fromRawJson(String str) =>
//       Attributes.fromJson(json.decode(str));

//   String toRawJson() => json.encode(toJson());

//   factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
//         result: json["result"] == null ? null : Result.fromJson(json["result"]),
//         reviews: json["reviews"] == null
//             ? []
//             : List<Review>.from(
//                 json["reviews"]!.map((x) => Review.fromJson(x))),
//         fullResult: json["fullResult"] == null
//             ? []
//             : List<FullResult>.from(
//                 json["fullResult"]!.map((x) => FullResult.fromJson(x)),
//               ),
//       );

//   Map<String, dynamic> toJson() => {
//         "result": result?.toJson(),
//         "reviews": reviews == null
//             ? []
//             : List<dynamic>.from(reviews!.map((x) => x.toJson())),
//         "fullResult": fullResult == null
//             ? []
//             : List<dynamic>.from(fullResult!.map((x) => x.toJson())),
//       };
// }

// class FullResult {
//   int? rating;
//   int? count;

//   FullResult({this.rating, this.count});

//   factory FullResult.fromRawJson(String str) =>
//       FullResult.fromJson(json.decode(str));

//   String toRawJson() => json.encode(toJson());

//   factory FullResult.fromJson(Map<String, dynamic> json) =>
//       FullResult(rating: json["rating"], count: json["count"]);

//   Map<String, dynamic> toJson() => {"rating": rating, "count": count};
// }

// class Result {
//   Description? serviceName;
//   Description? introOrBio;
//   Description? description;
//   ProviderId? providerId;
//   String? serviceCategoryId;
//   String? providerApprovalStatus;
//   int? startPrice;
//   double? rating;
//   List<AttachmentsForGallery>? attachmentsForGallery;
//   List<dynamic>? attachmentsForCoverPhoto;
//   int? yearsOfExperience;
//   String? serviceProviderId;

//   Result({
//     this.serviceName,
//     this.introOrBio,
//     this.description,
//     this.providerId,
//     this.serviceCategoryId,
//     this.providerApprovalStatus,
//     this.startPrice,
//     this.rating,
//     this.attachmentsForGallery,
//     this.attachmentsForCoverPhoto,
//     this.yearsOfExperience,
//     this.serviceProviderId,
//   });

//   factory Result.fromRawJson(String str) => Result.fromJson(json.decode(str));

//   String toRawJson() => json.encode(toJson());

//   factory Result.fromJson(Map<String, dynamic> json) => Result(
//         serviceName: json["serviceName"] == null
//             ? null
//             : Description.fromJson(json["serviceName"]),
//         introOrBio: json["introOrBio"] == null
//             ? null
//             : Description.fromJson(json["introOrBio"]),
//         description: json["description"] == null
//             ? null
//             : Description.fromJson(json["description"]),
//         providerId: json["providerId"] == null
//             ? null
//             : ProviderId.fromJson(json["providerId"]),
//         serviceCategoryId: json["serviceCategoryId"],
//         providerApprovalStatus: json["providerApprovalStatus"],
//         startPrice: json["startPrice"],
//         // rating: json["rating"],
//         rating: (json["rating"] ?? 0 as num).toDouble(),
//         attachmentsForGallery: json["attachmentsForGallery"] == null
//             ? []
//             : List<AttachmentsForGallery>.from(
//                 json["attachmentsForGallery"]!.map(
//                   (x) => AttachmentsForGallery.fromJson(x),
//                 ),
//               ),
//         attachmentsForCoverPhoto: json["attachmentsForCoverPhoto"] == null
//             ? []
//             : List<dynamic>.from(
//                 json["attachmentsForCoverPhoto"]!.map((x) => x)),
//         yearsOfExperience: json["yearsOfExperience"],
//         serviceProviderId: json["_ServiceProviderId"],
//       );

//   Map<String, dynamic> toJson() => {
//         "serviceName": serviceName?.toJson(),
//         "introOrBio": introOrBio?.toJson(),
//         "description": description?.toJson(),
//         "providerId": providerId?.toJson(),
//         "serviceCategoryId": serviceCategoryId,
//         "providerApprovalStatus": providerApprovalStatus,
//         "startPrice": startPrice,
//         "rating": rating,
//         "attachmentsForGallery": attachmentsForGallery == null
//             ? []
//             : List<dynamic>.from(attachmentsForGallery!.map((x) => x.toJson())),
//         "attachmentsForCoverPhoto": attachmentsForCoverPhoto == null
//             ? []
//             : List<dynamic>.from(attachmentsForCoverPhoto!.map((x) => x)),
//         "yearsOfExperience": yearsOfExperience,
//         "_ServiceProviderId": serviceProviderId,
//       };
// }

// class AttachmentsForGallery {
//   String? attachment;
//   String? attachmentId;

//   AttachmentsForGallery({this.attachment, this.attachmentId});

//   factory AttachmentsForGallery.fromRawJson(String str) =>
//       AttachmentsForGallery.fromJson(json.decode(str));

//   String toRawJson() => json.encode(toJson());

//   factory AttachmentsForGallery.fromJson(Map<String, dynamic> json) =>
//       AttachmentsForGallery(
//         attachment: json["attachment"],
//         attachmentId: json["_attachmentId"],
//       );

//   Map<String, dynamic> toJson() => {
//         "attachment": attachment,
//         "_attachmentId": attachmentId,
//       };
// }

// class Description {
//   String? en;
//   String? bn;

//   Description({this.en, this.bn});

//   factory Description.fromRawJson(String str) =>
//       Description.fromJson(json.decode(str));

//   String toRawJson() => json.encode(toJson());

//   factory Description.fromJson(Map<String, dynamic> json) =>
//       Description(en: json["en"], bn: json["bn"]);

//   Map<String, dynamic> toJson() => {"en": en, "bn": bn};
// }

// class ProviderId {
//   String? name;
//   ProfileImage? profileImage;
//   String? userId;

//   ProviderId({this.name, this.profileImage, this.userId});

//   factory ProviderId.fromRawJson(String str) =>
//       ProviderId.fromJson(json.decode(str));

//   String toRawJson() => json.encode(toJson());

//   factory ProviderId.fromJson(Map<String, dynamic> json) => ProviderId(
//         name: json["name"],
//         profileImage: json["profileImage"] == null
//             ? null
//             : ProfileImage.fromJson(json["profileImage"]),
//         userId: json["_userId"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "profileImage": profileImage?.toJson(),
//         "_userId": userId,
//       };
// }

// class ProfileImage {
//   String? imageUrl;
//   String? id;

//   ProfileImage({this.imageUrl, this.id});

//   factory ProfileImage.fromRawJson(String str) =>
//       ProfileImage.fromJson(json.decode(str));

//   String toRawJson() => json.encode(toJson());

//   factory ProfileImage.fromJson(Map<String, dynamic> json) =>
//       ProfileImage(imageUrl: json["imageUrl"], id: json["_id"]);

//   Map<String, dynamic> toJson() => {"imageUrl": imageUrl, "_id": id};
// }

// class Review {
//   Description? review;
//   String? originalLanguage;
//   int? rating;
//   String? userId;
//   String? serviceProviderDetailsId;
//   String? serviceBookingId;
//   bool? isDeleted;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   int? v;
//   String? reviewId;

//   Review({
//     this.review,
//     this.originalLanguage,
//     this.rating,
//     this.userId,
//     this.serviceProviderDetailsId,
//     this.serviceBookingId,
//     this.isDeleted,
//     this.createdAt,
//     this.updatedAt,
//     this.v,
//     this.reviewId,
//   });

//   factory Review.fromRawJson(String str) => Review.fromJson(json.decode(str));

//   String toRawJson() => json.encode(toJson());

//   factory Review.fromJson(Map<String, dynamic> json) => Review(
//         review: json["review"] == null
//             ? null
//             : Description.fromJson(json["review"]),
//         originalLanguage: json["originalLanguage"],
//         rating: json["rating"],
//         userId: json["userId"],
//         serviceProviderDetailsId: json["serviceProviderDetailsId"],
//         serviceBookingId: json["serviceBookingId"],
//         isDeleted: json["isDeleted"],
//         createdAt: json["createdAt"] == null
//             ? null
//             : DateTime.parse(json["createdAt"]),
//         updatedAt: json["updatedAt"] == null
//             ? null
//             : DateTime.parse(json["updatedAt"]),
//         v: json["__v"],
//         reviewId: json["_ReviewId"],
//       );

//   Map<String, dynamic> toJson() => {
//         "review": review?.toJson(),
//         "originalLanguage": originalLanguage,
//         "rating": rating,
//         "userId": userId,
//         "serviceProviderDetailsId": serviceProviderDetailsId,
//         "serviceBookingId": serviceBookingId,
//         "isDeleted": isDeleted,
//         "createdAt": createdAt?.toIso8601String(),
//         "updatedAt": updatedAt?.toIso8601String(),
//         "__v": v,
//         "_ReviewId": reviewId,
//       };
// }

//------------>>>> New Model

class GetSpecificServiceDetailsModel {
  final int? code;
  final String? message;
  final Data? data;

  GetSpecificServiceDetailsModel({
    this.code,
    this.message,
    this.data,
  });

  factory GetSpecificServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    return GetSpecificServiceDetailsModel(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }
}

/* ───────────────────── DATA ───────────────────── */

class Data {
  final Attributes? attributes;

  Data({this.attributes});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      attributes: json['attributes'] != null
          ? Attributes.fromJson(json['attributes'])
          : null,
    );
  }
}

/* ─────────────────── ATTRIBUTES ────────────────── */

class Attributes {
  final Result? result;
  final List<Review>? reviews;
  final List<FullResult>? fullResult;

  Attributes({
    this.result,
    this.reviews,
    this.fullResult,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) {
    return Attributes(
      result: json['result'] != null ? Result.fromJson(json['result']) : null,
      reviews: json['reviews'] != null
          ? List<Review>.from(json['reviews'].map((x) => Review.fromJson(x)))
          : [],
      fullResult: json['fullResult'] != null
          ? List<FullResult>.from(
              json['fullResult'].map((x) => FullResult.fromJson(x)))
          : [],
    );
  }
}

/* ───────────────────── RESULT ──────────────────── */

class Result {
  final Description? serviceName;
  final Description? introOrBio;
  final Description? description;
  final ProviderId? providerId;
  final String? locationId;
  final String? serviceCategoryId;
  final int? startPrice;
  final double? rating;
  final List<AttachmentsForGallery>? attachmentsForGallery;
  final List<dynamic>? attachmentsForCoverPhoto;
  final String? nidNumber;
  final int? yearsOfExperience;
  final String? providerApprovalStatus;
  final String? serviceProviderId;

  Result({
    this.serviceName,
    this.introOrBio,
    this.description,
    this.providerId,
    this.locationId,
    this.serviceCategoryId,
    this.startPrice,
    this.rating,
    this.attachmentsForGallery,
    this.attachmentsForCoverPhoto,
    this.nidNumber,
    this.yearsOfExperience,
    this.providerApprovalStatus,
    this.serviceProviderId,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      serviceName: json['serviceName'] != null
          ? Description.fromJson(json['serviceName'])
          : null,
      introOrBio: json['introOrBio'] != null
          ? Description.fromJson(json['introOrBio'])
          : null,
      description: json['description'] != null
          ? Description.fromJson(json['description'])
          : null,
      providerId: json['providerId'] != null
          ? ProviderId.fromJson(json['providerId'])
          : null,
      locationId: json['locationId'],
      serviceCategoryId: json['serviceCategoryId'],
      startPrice: json['startPrice'],
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      attachmentsForGallery: json['attachmentsForGallery'] != null
          ? List<AttachmentsForGallery>.from(json['attachmentsForGallery']
              .map((x) => AttachmentsForGallery.fromJson(x)))
          : [],
      attachmentsForCoverPhoto: json['attachmentsForCoverPhoto'],
      nidNumber: json['nidNumber'],
      yearsOfExperience: json['yearsOfExperience'],
      providerApprovalStatus: json['providerApprovalStatus'],
      serviceProviderId: json['_ServiceProviderId'],
    );
  }
}

/* ─────────────────── DESCRIPTION ────────────────── */

class Description {
  final String? en;
  final String? bn;

  Description({this.en, this.bn});

  factory Description.fromJson(Map<String, dynamic> json) {
    return Description(
      en: json['en'],
      bn: json['bn'],
    );
  }
}

/* ─────────────────── PROVIDER ───────────────────── */

class ProviderId {
  final String? name;
  final ProfileImage? profileImage;
  final String? userId;

  ProviderId({
    this.name,
    this.profileImage,
    this.userId,
  });

  factory ProviderId.fromJson(Map<String, dynamic> json) {
    return ProviderId(
      name: json['name'],
      profileImage: json['profileImage'] != null
          ? ProfileImage.fromJson(json['profileImage'])
          : null,
      userId: json['_userId'],
    );
  }
}

/* ───────────────── PROFILE IMAGE ───────────────── */

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
}

/* ───────────── ATTACHMENTS (GALLERY) ───────────── */

class AttachmentsForGallery {
  final String? attachment;
  final String? attachmentId;

  AttachmentsForGallery({
    this.attachment,
    this.attachmentId,
  });

  factory AttachmentsForGallery.fromJson(Map<String, dynamic> json) {
    return AttachmentsForGallery(
      attachment: json['attachment'],
      attachmentId: json['_attachmentId'],
    );
  }
}

/* ───────────────────── REVIEW ───────────────────── */

class Review {
  final Description? review;
  final String? originalLanguage;
  final double? rating;
  final String? userId;
  final String? serviceProviderDetailsId;
  final String? serviceBookingId;
  final bool? isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? reviewId;

  Review({
    this.review,
    this.originalLanguage,
    this.rating,
    this.userId,
    this.serviceProviderDetailsId,
    this.serviceBookingId,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.reviewId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      review:
          json['review'] != null ? Description.fromJson(json['review']) : null,
      originalLanguage: json['originalLanguage'],
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      userId: json['userId']?['_userId'],
      serviceProviderDetailsId: json['serviceProviderDetailsId'],
      serviceBookingId: json['serviceBookingId'],
      isDeleted: json['isDeleted'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      v: json['__v'],
      reviewId: json['_ReviewId'],
    );
  }
}

/* ─────────────────── FULL RESULT ────────────────── */

class FullResult {
  final int? rating;
  final int? count;

  FullResult({this.rating, this.count});

  factory FullResult.fromJson(Map<String, dynamic> json) {
    return FullResult(
      rating: json['rating'],
      count: json['count'],
    );
  }
}

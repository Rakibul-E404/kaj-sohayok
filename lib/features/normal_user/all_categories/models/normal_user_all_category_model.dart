import 'dart:convert';

class NormalUserAllCategoryModel {
    int? code;
    String? message;
    Data? data;
    bool? success;

    NormalUserAllCategoryModel({
        this.code,
        this.message,
        this.data,
        this.success,
    });

    factory NormalUserAllCategoryModel.fromRawJson(String str) => NormalUserAllCategoryModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory NormalUserAllCategoryModel.fromJson(Map<String, dynamic> json) => NormalUserAllCategoryModel(
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
        attributes: json["attributes"] == null ? null : Attributes.fromJson(json["attributes"]),
    );

    Map<String, dynamic> toJson() => {
        "attributes": attributes?.toJson(),
    };
}

class Attributes {
    List<Result>? results;
    String? page;
    String? limit;
    int? totalPages;
    int? totalResults;

    Attributes({
        this.results,
        this.page,
        this.limit,
        this.totalPages,
        this.totalResults,
    });

    factory Attributes.fromRawJson(String str) => Attributes.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
        results: json["results"] == null ? [] : List<Result>.from(json["results"]!.map((x) => Result.fromJson(x))),
        page: json["page"],
        limit: json["limit"],
        totalPages: json["totalPages"],
        totalResults: json["totalResults"],
    );

    Map<String, dynamic> toJson() => {
        "results": results == null ? [] : List<dynamic>.from(results!.map((x) => x.toJson())),
        "page": page,
        "limit": limit,
        "totalPages": totalPages,
        "totalResults": totalResults,
    };
}

class Result {
    Name? name;
    List<Attachment>? attachments;
    String? createdBy;
    String? createdByUserId;
    bool? isVisible;
    int? v;
    String? serviceCategoryId;

    Result({
        this.name,
        this.attachments,
        this.createdBy,
        this.createdByUserId,
        this.isVisible,
        this.v,
        this.serviceCategoryId,
    });

    factory Result.fromRawJson(String str) => Result.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        name: json["name"] == null ? null : Name.fromJson(json["name"]),
        attachments: json["attachments"] == null ? [] : List<Attachment>.from(json["attachments"]!.map((x) => Attachment.fromJson(x))),
        createdBy: json["createdBy"],
        createdByUserId: json["createdByUserId"],
        isVisible: json["isVisible"],
        v: json["__v"],
        serviceCategoryId: json["_ServiceCategoryId"],
    );

    Map<String, dynamic> toJson() => {
        "name": name?.toJson(),
        "attachments": attachments == null ? [] : List<dynamic>.from(attachments!.map((x) => x.toJson())),
        "createdBy": createdBy,
        "createdByUserId": createdByUserId,
        "isVisible": isVisible,
        "__v": v,
        "_ServiceCategoryId": serviceCategoryId,
    };
}

class Attachment {
    String? attachment;
    String? attachmentId;

    Attachment({
        this.attachment,
        this.attachmentId,
    });

    factory Attachment.fromRawJson(String str) => Attachment.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        attachment: json["attachment"],
        attachmentId: json["_attachmentId"],
    );

    Map<String, dynamic> toJson() => {
        "attachment": attachment,
        "_attachmentId": attachmentId,
    };
}

class Name {
    String? en;
    String? bn;

    Name({
        this.en,
        this.bn,
    });

    factory Name.fromRawJson(String str) => Name.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Name.fromJson(Map<String, dynamic> json) => Name(
        en: json["en"],
        bn: json["bn"],
    );

    Map<String, dynamic> toJson() => {
        "en": en,
        "bn": bn,
    };
}

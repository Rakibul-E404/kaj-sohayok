import 'dart:convert';

class ServiceDataPreviewModel {
  int? code;
  String? message;
  Data? data;

  ServiceDataPreviewModel({this.code, this.message, this.data});

  factory ServiceDataPreviewModel.fromRawJson(String str) =>
      ServiceDataPreviewModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ServiceDataPreviewModel.fromJson(Map<String, dynamic> json) =>
      ServiceDataPreviewModel(
        code: json["code"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
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
  List<Result>? result;

  Attributes({this.result});

  factory Attributes.fromRawJson(String str) =>
      Attributes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
    result: json["result"] == null
        ? []
        : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "result": result == null
        ? []
        : List<dynamic>.from(result!.map((x) => x.toJson())),
  };
}

class Result {
  ServiceName? serviceName;
  double? startPrice;
  List<Attachment>? attachmentsForGallery;
  String? serviceProviderId;

  Result({
    this.serviceName,
    this.startPrice,
    this.attachmentsForGallery,
    this.serviceProviderId,
  });

  factory Result.fromRawJson(String str) => Result.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    serviceName: json["serviceName"] == null
        ? null
        : ServiceName.fromJson(json["serviceName"]),
    startPrice: json["startPrice"] is int ? json["startPrice"].toDouble() : json["startPrice"]?.toDouble(),
    attachmentsForGallery: json["attachmentsForGallery"] == null
        ? []
        : List<Attachment>.from(
            json["attachmentsForGallery"]!.map(
              (x) => Attachment.fromJson(x),
            ),
          ),
    serviceProviderId: json["_ServiceProviderId"],
  );

  Map<String, dynamic> toJson() => {
    "serviceName": serviceName?.toJson(),
    "startPrice": startPrice,
    "attachmentsForGallery": attachmentsForGallery == null
        ? []
        : List<dynamic>.from(attachmentsForGallery!.map((x) => x.toJson())),
    "_ServiceProviderId": serviceProviderId,
  };
}

class Attachment {
  String? attachment;
  String? attachmentId;

  Attachment({this.attachment, this.attachmentId});

  factory Attachment.fromRawJson(String str) =>
      Attachment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      Attachment(
        attachment: json["attachment"],
        attachmentId: json["_attachmentId"],
      );

  Map<String, dynamic> toJson() => {
    "attachment": attachment,
    "_attachmentId": attachmentId,
  };
}

class ServiceName {
  String? en;
  String? bn;

  ServiceName({this.en, this.bn});

  factory ServiceName.fromRawJson(String str) =>
      ServiceName.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ServiceName.fromJson(Map<String, dynamic> json) =>
      ServiceName(en: json["en"], bn: json["bn"]);

  Map<String, dynamic> toJson() => {"en": en, "bn": bn};
}

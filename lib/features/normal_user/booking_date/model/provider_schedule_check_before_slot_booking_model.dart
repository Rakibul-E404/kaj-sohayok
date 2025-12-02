import 'dart:convert';

class ProviderSchedulCheckBeforeSlotBookingModel {
  int? code;
  String? message;
  Data? data;
  bool? success;

  ProviderSchedulCheckBeforeSlotBookingModel({
    this.code,
    this.message,
    this.data,
    this.success,
  });

  factory ProviderSchedulCheckBeforeSlotBookingModel.fromRawJson(String str) =>
      ProviderSchedulCheckBeforeSlotBookingModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProviderSchedulCheckBeforeSlotBookingModel.fromJson(
    Map<String, dynamic> json,
  ) => ProviderSchedulCheckBeforeSlotBookingModel(
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
  DateTime? bookingDateTime;
  String? providerId;

  Attributes({this.bookingDateTime, this.providerId});

  factory Attributes.fromRawJson(String str) =>
      Attributes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
    bookingDateTime: json["bookingDateTime"] == null
        ? null
        : DateTime.parse(json["bookingDateTime"]),
    providerId: json["providerId"],
  );

  Map<String, dynamic> toJson() => {
    "bookingDateTime": bookingDateTime?.toIso8601String(),
    "providerId": providerId,
  };
}

import 'package:intl/intl.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final ProfileImage profileImage;
  final DateTime? dob;
  final String gender;
  final Location location;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profileImage,
    required this.dob,
    required this.gender,
    required this.location,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      profileImage: json["profileImage"] != null
          ? ProfileImage.fromJson(json["profileImage"])
          : ProfileImage.empty(),
      dob: json["dob"] != null ? DateTime.tryParse(json["dob"]) : null,
      gender: json["gender"] ?? "",
      location: json["location"] != null
          ? Location.fromJson(json["location"])
          : Location.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "dob": dob?.toIso8601String(),
      "profileImage": profileImage.toJson(),

      "gender": gender,
      "location": location.toJson(),
    };
  }
}

class ProfileImage {
  final String imageUrl;
  final String id;

  ProfileImage({required this.imageUrl, required this.id});

  factory ProfileImage.fromJson(Map<String, dynamic> json) {
    return ProfileImage(
      imageUrl: json["imageUrl"] ?? "",
      id: json["_id"] ?? "",
    );
  }

  factory ProfileImage.empty() {
    return ProfileImage(imageUrl: "", id: "");
  }

  Map<String, dynamic> toJson() {
    return {"imageUrl": imageUrl, "_id": id};
  }
}

class Location {
  final String bn;
  final String en;

  Location({required this.bn, required this.en});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(bn: json["bn"] ?? "", en: json["en"] ?? "");
  }

  factory Location.empty() {
    return Location(bn: "", en: "");
  }

  Map<String, dynamic> toJson() {
    return {"bn": bn, "en": en};
  }
}
String formatDateTime(DateTime? dateTime, {String format = 'dd MMM yyyy'}) {
  if (dateTime == null) return '';
  try {
    return DateFormat(format).format(dateTime);
  } catch (e) {
    return '';
  }
}

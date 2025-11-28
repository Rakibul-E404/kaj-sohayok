class ProviderProfileModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;

  final ProfileImage profileImage;
  final DateTime? dob;
  final String gender;
  final Location location;
  final ServiceName serviceName;
  final double rating;

  ProviderProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.dob,
    required this.gender,
    required this.phoneNumber,

    required this.location,
    required this.serviceName,
    required this.rating,
  });

  factory ProviderProfileModel.fromJson(Map<String, dynamic> json) {
    return ProviderProfileModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      email: json["email"] ?? "",
      profileImage: json["profileImage"] != null
          ? ProfileImage.fromJson(json["profileImage"])
          : ProfileImage.empty(),
      dob: json["dob"] != null ? DateTime.tryParse(json["dob"]) : null,
      gender: json["gender"] ?? "",
      location: json["location"] != null
          ? Location.fromJson(json["location"])
          : Location.empty(),
      serviceName: json["serviceName"] != null
          ? ServiceName.fromJson(json["serviceName"])
          : ServiceName.empty(),
      rating: (json["rating"] is num) ? json["rating"].toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "email": email,
      "profileImage": profileImage.toJson(),
      "dob": dob?.toIso8601String(),
      "phoneNumber": phoneNumber,
      "gender": gender,
      "location": location.toJson(),
      "serviceName": serviceName.toJson(),
      "rating": rating,
    };
  }
}

/// PROFILE IMAGE MODEL
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

/// LOCATION MODEL
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

/// SERVICE NAME MODEL
class ServiceName {
  final String en;
  final String bn;

  ServiceName({required this.en, required this.bn});

  factory ServiceName.fromJson(Map<String, dynamic> json) {
    return ServiceName(en: json["en"] ?? "", bn: json["bn"] ?? "");
  }

  factory ServiceName.empty() {
    return ServiceName(en: "", bn: "");
  }

  Map<String, dynamic> toJson() {
    return {"en": en, "bn": bn};
  }
}

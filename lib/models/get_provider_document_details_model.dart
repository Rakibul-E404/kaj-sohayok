class ProviderDocumentDetailsModel {
  final ServiceProvider serviceProvider;
  final UserProfile userProfile;

  ProviderDocumentDetailsModel({
    required this.serviceProvider,
    required this.userProfile,
  });

  factory ProviderDocumentDetailsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('JSON cannot be null');
    }

    return ProviderDocumentDetailsModel(
      serviceProvider: ServiceProvider.fromJson(
        json['serviceProvider'] as Map<String, dynamic>?,
      ),
      userProfile: UserProfile.fromJson(
        json['userProfile'] as Map<String, dynamic>?,
      ),
    );
  }
}

class ServiceProvider {
  final String? id;
  final LocalizedString serviceName;
  final ServiceCategory serviceCategoryId;
  final int? startPrice;
  final LocalizedString introOrBio;
  final LocalizedString description;
  final int? yearsOfExperience;

  ServiceProvider({
    this.id,
    required this.serviceName,
    required this.serviceCategoryId,
    this.startPrice,
    required this.introOrBio,
    required this.description,
    this.yearsOfExperience,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic>? json) {
    if (json == null)
      return ServiceProvider(
        serviceName: LocalizedString(),
        serviceCategoryId: ServiceCategory(name: LocalizedString()),
        introOrBio: LocalizedString(),
        description: LocalizedString(),
      );

    return ServiceProvider(
      id: json['_id'] as String?,
      serviceName: LocalizedString.fromJson(json['serviceName']),
      serviceCategoryId: ServiceCategory.fromJson(json['serviceCategoryId']),
      startPrice: json['startPrice'] as int?,
      introOrBio: LocalizedString.fromJson(json['introOrBio']),
      description: LocalizedString.fromJson(json['description']),
      yearsOfExperience: json['yearsOfExperience'] as int?,
    );
  }
}

class ServiceCategory {
  final String? id;
  final LocalizedString name;

  ServiceCategory({this.id, required this.name});

  factory ServiceCategory.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ServiceCategory(name: LocalizedString());

    return ServiceCategory(
      id: json['_id'] as String?,
      name: LocalizedString.fromJson(json['name']),
    );
  }
}

class LocalizedString {
  final String? en;
  final String? bn;

  LocalizedString({this.en, this.bn});

  factory LocalizedString.fromJson(dynamic json) {
    if (json == null) return LocalizedString();

    final map = json is Map<String, dynamic> ? json : {};
    return LocalizedString(en: map['en'] as String?, bn: map['bn'] as String?);
  }
}

class UserProfile {
  final String? id;
  final List<CertificateImage> frontSideCertificateImage;
  final List<CertificateImage> backSideCertificateImage;
  final List<dynamic> faceImageFromFrontCam;

  UserProfile({
    this.id,
    required this.frontSideCertificateImage,
    required this.backSideCertificateImage,
    required this.faceImageFromFrontCam,
  });

  factory UserProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return UserProfile(
        frontSideCertificateImage: [],
        backSideCertificateImage: [],
        faceImageFromFrontCam: [],
      );
    }

    final frontList =
        (json['frontSideCertificateImage'] as List<dynamic>?)
            ?.map((e) => CertificateImage.fromJson(e as Map<String, dynamic>?))
            .whereType<CertificateImage>()
            .toList() ??
        [];
    final backList =
        (json['backSideCertificateImage'] as List<dynamic>?)
            ?.map((e) => CertificateImage.fromJson(e as Map<String, dynamic>?))
            .whereType<CertificateImage>()
            .toList() ??
        [];
    final faceList = json['faceImageFromFrontCam'] as List<dynamic>? ?? [];

    return UserProfile(
      id: json['_id'] as String?,
      frontSideCertificateImage: frontList,
      backSideCertificateImage: backList,
      faceImageFromFrontCam: faceList,
    );
  }
}

class CertificateImage {
  final String? id;
  final String? attachmentUrl;

  CertificateImage({this.id, this.attachmentUrl});

  factory CertificateImage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CertificateImage();

    // Trim whitespace from URL if present (your example has trailing spaces!)
    String? url = json['attachment'] as String?;
    if (url != null) {
      url = url.trim();
    }

    return CertificateImage(id: json['_id'] as String?, attachmentUrl: url);
  }
}

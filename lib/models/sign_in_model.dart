class SignInProfileModel {
  final String? id;
  final String? profileId;
  final String? name;
  final String? email;
  final String? role;
  final ProfileImage? profileImage;
  final bool? isEmailVerified;
  final bool? isResetPassword;
  final int? failedLoginAttempts;
  final String? walletId;
  final bool? isDeleted;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final bool? isServiceProviderDetailsFound;
  final String? providerApprovalStatusFromUsersRoleData;

  SignInProfileModel({
    this.id,
    this.profileId,
    this.name,
    this.email,
    this.role,
    this.profileImage,
    this.isEmailVerified,
    this.isResetPassword,
    this.failedLoginAttempts,
    this.walletId,
    this.isDeleted,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isServiceProviderDetailsFound,
    this.providerApprovalStatusFromUsersRoleData,
   });

  factory SignInProfileModel.fromJson(Map<String, dynamic> json) {
    return SignInProfileModel(
      id: json['userWithoutPassword']['id'] as String?,
      profileId: json['userWithoutPassword']['profileId'] as String?,
      name: json['userWithoutPassword']['name'] as String?,
      email: json['userWithoutPassword']['email'] as String?,
      role: json['userWithoutPassword']['role'] as String?,
      profileImage: json['userWithoutPassword']['profileImage'] != null
          ? ProfileImage.fromJson(json['userWithoutPassword']['profileImage'])
          : null,
      isEmailVerified: json['userWithoutPassword']['isEmailVerified'] as bool?,
      isResetPassword: json['userWithoutPassword']['isResetPassword'] as bool?,
      failedLoginAttempts: json['userWithoutPassword']['failedLoginAttempts'] as int?,
      walletId: json['userWithoutPassword']['walletId'] as String?,
      isDeleted: json['userWithoutPassword']['isDeleted'] as bool?,
      deletedAt: json['userWithoutPassword']['deletedAt'] as String?,
      createdAt: json['userWithoutPassword']['createdAt'] as String?,
      updatedAt: json['userWithoutPassword']['updatedAt'] as String?,
      v: json['userWithoutPassword']['__v'] as int?,
      isServiceProviderDetailsFound:
      json['isServiceProviderDetailsFound'] as bool?,
      providerApprovalStatusFromUsersRoleData:
      json['providerApprovalStatusFromUsersRoleData'] as String?,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileId': profileId,
      'name': name,
      'email': email,
      'role': role,
      'profileImage': profileImage?.toJson(),
      'isEmailVerified': isEmailVerified,
      'isResetPassword': isResetPassword,
      'failedLoginAttempts': failedLoginAttempts,
      'walletId': walletId,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'isServiceProviderDetailsFound': isServiceProviderDetailsFound,
      'providerApprovalStatusFromUsersRoleData':
      providerApprovalStatusFromUsersRoleData,
     };
  }
}

class ProfileImage {
  final String? imageUrl;
  final String? id;

  ProfileImage({this.imageUrl, this.id});

  factory ProfileImage.fromJson(Map<String, dynamic> json) {
    return ProfileImage(
      imageUrl: json['imageUrl'] as String?,
      id: json['_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'imageUrl': imageUrl, '_id': id};
  }
}



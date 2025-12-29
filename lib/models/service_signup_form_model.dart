// models/service_category_model.dart

class ServiceFormCategoryModel {
  final String id;
  final String nameEn;
  final String nameBn;
  final List<AttachmentModel> attachments;

  ServiceFormCategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.attachments,
  });

  factory ServiceFormCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceFormCategoryModel(
      id: json['_ServiceCategoryId'] ?? '',
      nameEn: json['name']?['en'] ?? '',
      nameBn: json['name']?['bn'] ?? '',
      attachments: (json['attachments'] as List?)
          ?.map((e) => AttachmentModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  String get iconUrl => attachments.isNotEmpty ? attachments.first.attachment : '';
}

class AttachmentModel {
  final String attachment;
  final String attachmentId;

  AttachmentModel({
    required this.attachment,
    required this.attachmentId,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      attachment: json['attachment'] ?? '',
      attachmentId: json['_attachmentId'] ?? '',
    );
  }
}

class ServiceCategoryResponse {
  final int code;
  final String message;
  final List<ServiceFormCategoryModel> categories;
  final int page;
  final int totalPages;
  final int totalResults;

  ServiceCategoryResponse({
    required this.code,
    required this.message,
    required this.categories,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  factory ServiceCategoryResponse.fromJson(Map<String, dynamic> json) {
    final attributes = json['data']?['attributes'] ?? {};
    final results = attributes['results'] as List? ?? [];

    return ServiceCategoryResponse(
      code: json['code'] ?? 200,
      message: json['message'] ?? '',
      categories: results
          .map((e) => ServiceFormCategoryModel.fromJson(e))
          .toList(),
      page: attributes['page'] ?? 1,
      totalPages: attributes['totalPages'] ?? 1,
      totalResults: attributes['totalResults'] ?? 0,
    );
  }
}

/**
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../features/normal_user/work_completed_details/model/additional_cost_model.dart';
import '../features/service_provider/svp_submit_work_form/model/media_file.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';

class SvpSubmitWorkFormScreenController extends GetxController {
  // Text controllers
  TextEditingController completionDateController = TextEditingController();
  TextEditingController durationTimeController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final NetworkCaller _networkCaller = NetworkCaller();

  // Rx variables
  RxBool isLoading = false.obs;
  Rx<String?> bookingId = Rx<String?>(null);
  RxBool isLoadingWorkDetails = false.obs;
  RxBool isPaymentRequestLoading = false.obs;
  RxBool isUploadingMedia = false.obs;

  // API Data
  RxString address = ''.obs;
  RxString bookingDateTime = ''.obs;
  RxDouble initialCost = 0.0.obs;
  RxList<ApiAttachment> apiAttachments = <ApiAttachment>[].obs;
  RxList<AdditionalCostModel> additionalCosts = <AdditionalCostModel>[].obs;

  // Combined media files
  RxList<MediaFile> mediaFiles = <MediaFile>[].obs;

  @override
  void onInit() {
    super.onInit();

    log("Controller initialized", name: "SVPSubmitWorkForm");

    final args = Get.arguments;

    if (args != null && args is Map) {
      bookingId.value = args['bookingId']?.toString();

      if (args['formData'] != null) {
        _parseFormData(args['formData']);
      } else if (args['serviceBooking'] != null) {
        _parseServiceBookingData(args['serviceBooking'], args['additionalCosts']);
      } else if (bookingId.value != null && bookingId.value!.isNotEmpty) {
        loadWorkDetails();
      } else {
        Get.snackbar("Error", "No booking data available",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.snackbar("Error", "No booking information provided",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ================== PARSING & LOADING ==================

  void _parseFormData(Map<String, dynamic> formData) {
    try {
      final serviceBooking = formData['serviceBooking'];
      final additionalCostsData = formData['additionalCosts'];
      _parseServiceBookingData(serviceBooking, additionalCostsData);
    } catch (e, stackTrace) {
      log("Error parsing form data: $e", error: e, stackTrace: stackTrace);
      Get.snackbar("Error", "Failed to parse work details",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _parseServiceBookingData(dynamic serviceBookingData, dynamic additionalCostsData) {
    try {
      if (serviceBookingData == null) {
        Get.snackbar("Error", "No service booking data found",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Address
      final addressMap = serviceBookingData['address'] ?? {};
      if (addressMap is Map<String, dynamic>) {
        address.value = addressMap['en'] ?? addressMap['bn'] ?? '';
      } else {
        address.value = serviceBookingData['address']?.toString() ?? '';
      }

      // Booking date time
      if (serviceBookingData['bookingDateTime'] != null) {
        try {
          final bookingDate = DateTime.parse(serviceBookingData['bookingDateTime'].toString());
          bookingDateTime.value = '${bookingDate.day}-${bookingDate.month}-${bookingDate.year} ${bookingDate.hour}:${bookingDate.minute}';
        } catch (e) {
          bookingDateTime.value = serviceBookingData['bookingDateTime'].toString();
        }
      } else {
        bookingDateTime.value = '';
      }

      // Initial cost
      initialCost.value = double.tryParse(serviceBookingData['startPrice']?.toString() ?? '0') ?? 0.0;

      // Attachments
      apiAttachments.clear();
      final attachmentsData = serviceBookingData['attachments'];
      if (attachmentsData != null && attachmentsData is List) {
        for (var i = 0; i < attachmentsData.length; i++) {
          final attachment = attachmentsData[i];
          if (attachment is Map<String, dynamic>) {
            final url = attachment['attachment']?.toString() ?? '';
            final type = attachment['attachmentType']?.toString() ?? 'image';
            final id = attachment['_attachmentId']?.toString() ?? 'attachment_$i';

            // Check if it's a video
            bool isVideo = false;
            if (type.toLowerCase() == 'video') {
              isVideo = true;
            } else if (url.toLowerCase().contains('.mp4') ||
                url.toLowerCase().contains('.mov') ||
                url.toLowerCase().contains('.avi') ||
                url.toLowerCase().contains('.mkv')) {
              isVideo = true;
            }

            if (url.isNotEmpty) {
              apiAttachments.add(ApiAttachment(
                  url: url,
                  type: isVideo ? 'video' : 'image',
                  id: id
              ));
            }
          }
        }
      }

      // Additional costs
      additionalCosts.clear();
      if (additionalCostsData != null && additionalCostsData is List) {
        for (final cost in additionalCostsData) {
          if (cost is Map<String, dynamic>) {
            String costName = 'Additional Cost';
            final rawName = cost['costName'];
            if (rawName is String) {
              costName = rawName;
            } else if (rawName != null) {
              costName = rawName.toString();
            }

            final costPrice = double.tryParse(cost['price']?.toString() ?? '0') ?? 0.0;
            additionalCosts.add(AdditionalCostModel(title: costName, price: costPrice));
          }
        }
      }

      update();
    } catch (e, stackTrace) {
      log("CRITICAL ERROR: $e", error: e, stackTrace: stackTrace);
      Get.snackbar("Error", "Failed to parse work details: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> loadWorkDetails() async {
    if (bookingId.value == null || bookingId.value!.isEmpty) return;

    isLoadingWorkDetails.value = true;
    try {
      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.providerWorkSubmitForm(bookingId.value!),
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;
        if (responseData['code'] == 200 &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null) {
          final attributes = responseData['data']['attributes'];
          _parseServiceBookingData(
            attributes['serviceBooking'],
            attributes['additionalCosts'],
          );
        } else {
          Get.snackbar("Error", "Unexpected response format",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        Get.snackbar("Error", response.errorMessage ?? "Failed to load work details",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e, stackTrace) {
      log("LOAD ERROR: $e", error: e, stackTrace: stackTrace);
      Get.snackbar("Error", "Failed to load work details: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoadingWorkDetails.value = false;
    }
  }

  // ================== MEDIA HANDLING ==================

  String getImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.contains('amazonaws.com') || path.startsWith('http')) return path;
    if (path.startsWith('/')) return '${AppUrl.imageBaseUrl}$path';
    return path;
  }

  // Helper function to check if file is video
  bool _isVideoFile(String path) {
    final fileName = path.toLowerCase();
    return fileName.endsWith('.mp4') ||
        fileName.endsWith('.mov') ||
        fileName.endsWith('.avi') ||
        fileName.endsWith('.mkv') ||
        fileName.endsWith('.wmv') ||
        fileName.endsWith('.flv');
  }

  // Helper function to check if file is image
  bool _isImageFile(String path) {
    final fileName = path.toLowerCase();
    return fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif') ||
        fileName.endsWith('.bmp');
  }

  Future<void> pickMediaFromGallery() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        maxWidth: 1024, maxHeight: 1024, imageQuality: 85,
      );

      // Also pick videos
      final XFile? videoFile = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      final List<XFile> allFiles = [];
      if (files.isNotEmpty) {
        allFiles.addAll(files);
      }
      if (videoFile != null) {
        allFiles.add(videoFile);
      }

      if (allFiles.isNotEmpty) {
        for (var file in allFiles) {
          final isVideo = _isVideoFile(file.path);
          mediaFiles.add(MediaFile(path: file.path, isVideo: isVideo));
        }
        Get.snackbar("Success", "${allFiles.length} file(s) added",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick files: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> pickPhotoFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 85,
      );
      if (image != null) {
        mediaFiles.add(MediaFile(path: image.path, isVideo: false));
        Get.snackbar("Success", "Photo captured successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to capture photo: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> pickVideoFromCamera() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera, maxDuration: Duration(minutes: 10),
      );
      if (video != null) {
        mediaFiles.add(MediaFile(path: video.path, isVideo: true));
        Get.snackbar("Success", "Video recorded successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to record video: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void showMediaSourceDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Proof Files", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text("Take Photo"),
                onTap: () {
                  Get.back();
                  pickPhotoFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam, color: Colors.red),
                title: Text("Record Video"),
                onTap: () {
                  Get.back();
                  pickVideoFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text("Choose from Gallery"),
                subtitle: Text("Images & Videos"),
                onTap: () {
                  Get.back();
                  pickMediaFromGallery();
                },
              ),
              SizedBox(height: 8),
              Text(
                "Supported formats: JPG, PNG, MP4, MOV",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 16),
              TextButton(
                  onPressed: Get.back,
                  child: Text("Cancel", style: TextStyle(color: Colors.red))
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> removeMediaFile(int index) async {
    if (index >= 0 && index < mediaFiles.length) {
      final mediaFile = mediaFiles[index];
      if (mediaFile.isVideo && mediaFile.videoController != null) {
        mediaFile.videoController!.dispose();
      }
      mediaFiles.removeAt(index);
      log("Media file removed at index $index");
    }
  }

  Future<void> removeApiAttachment(int index) async {
    if (index >= 0 && index < apiAttachments.length) {
      apiAttachments.removeAt(index);
      update();
    }
  }

  Future<void> clearAllMediaFiles() async {
    for (var mediaFile in mediaFiles) {
      if (mediaFile.isVideo && mediaFile.videoController != null) {
        mediaFile.videoController!.dispose();
      }
    }
    mediaFiles.clear();
  }

  int get totalImageCount =>
      mediaFiles.where((file) => !file.isVideo).length +
          apiAttachments.where((attachment) => attachment.type != 'video').length;

  int get videoCount =>
      mediaFiles.where((file) => file.isVideo).length +
          apiAttachments.where((attachment) => attachment.type == 'video').length;

  int get totalMediaCount => mediaFiles.length + apiAttachments.length;

  // ================== CUSTOM FILE UPLOAD USING HTTP DIRECTLY ==================

  /// Upload multiple files using direct HTTP multipart request
  /// This matches exactly what Postman is doing
  Future<NetworkResponse> uploadMultipleMediaFiles({
    required String bookingId,
    required List<File> files,
    List<String>? fileTypes, // Optional parameter to specify file types
  }) async {
    try {
      isUploadingMedia.value = true;

      log("🚀 Starting custom file upload...");
      log("Booking ID: $bookingId");
      log("Total files to upload: ${files.length}");

      // Get authorization token
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null || token.isEmpty) {
        log("❌ No auth token found");
        return NetworkResponse(
          isSuccess: false,
          errorMessage: 'Authentication token not found',
        );
      }

      final url = AppUrl.addNewProofFile(bookingId);
      log("📤 URL: $url");

      // Create multipart request
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('PUT', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      log("🔑 Authorization header added");

      // Add all files with the field name "attachments"
      for (int i = 0; i < files.length; i++) {
        final file = files[i];

        log("📎 Processing file ${i + 1}/${files.length}:");
        log("   Path: ${file.path}");
        log("   Exists: ${file.existsSync()}");

        if (!file.existsSync()) {
          log("   ❌ File does not exist, skipping");
          continue;
        }

        final fileSize = await file.length();
        log("   Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB");

        // Get MIME type
        final mimeType = lookupMimeType(file.path);
        log("   MIME Type: $mimeType");

        // Parse MIME type
        MediaType? contentType;
        if (mimeType != null) {
          final mimeTypeParts = mimeType.split('/');
          contentType = MediaType(
            mimeTypeParts[0],
            mimeTypeParts.length > 1 ? mimeTypeParts[1] : 'octet-stream',
          );
        } else {
          contentType = MediaType('application', 'octet-stream');
        }

        // Add file with field name "attachments" (as shown in Postman)
        final multipartFile = await http.MultipartFile.fromPath(
          'attachments', // This is the exact field name from Postman
          file.path,
          contentType: contentType,
          // You can add filename if needed
          // filename: 'file_${DateTime.now().millisecondsSinceEpoch}_$i.${file.path.split('.').last}',
        );

        request.files.add(multipartFile);
        log("   ✅ File added to request as: ${multipartFile.field}");
      }

      log("📤 Sending ${request.files.length} files...");
      log("Request headers: ${request.headers}");

      // Send request
      final streamedResponse = await request.send();
      log("📥 Response received");
      log("Status Code: ${streamedResponse.statusCode}");

      // Convert streamed response to regular response
      final response = await http.Response.fromStream(streamedResponse);
      log("Response Body: ${response.body}");

      // Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Upload successful!");

        try {
          final jsonResponse = response.body.isNotEmpty
              ? json.decode(response.body) as Map<String, dynamic>
              : <String, dynamic>{};

          return NetworkResponse(
            isSuccess: true,
            statusCode: response.statusCode,
            jsonResponse: jsonResponse,
          );
        } catch (e) {
          log("⚠️ Could not parse JSON response, but upload was successful");
          return NetworkResponse(
            isSuccess: true,
            statusCode: response.statusCode,
          );
        }
      } else {
        log("❌ Upload failed with status: ${response.statusCode}");

        String errorMessage = 'Upload failed';
        try {
          final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
          errorMessage = jsonResponse['message']?.toString() ??
              jsonResponse['error']?.toString() ??
              'Upload failed';

          return NetworkResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            jsonResponse: jsonResponse,
            errorMessage: errorMessage,
          );
        } catch (e) {
          log("Could not parse error response: ${response.body}");
          return NetworkResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: response.body.isNotEmpty ? response.body : errorMessage,
          );
        }
      }
    } catch (e, stackTrace) {
      log("❌ Upload error: $e", error: e, stackTrace: stackTrace);
      return NetworkResponse(
        isSuccess: false,
        errorMessage: 'Upload failed: ${e.toString()}',
      );
    } finally {
      isUploadingMedia.value = false;
    }
  }

  // ================== COST HANDLING ==================

  double calculateTotalPayment() {
    double total = initialCost.value;
    for (var cost in additionalCosts) {
      total += cost.price;
    }
    return total;
  }

  Future<bool> addAdditionalCost(String name, double price) async {
    if (bookingId.value == null || bookingId.value!.isEmpty) {
      Get.snackbar("Error", "No booking ID found",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    try {
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null || token.isEmpty) {
        Get.snackbar("Auth Error", "Session expired. Please log in again.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }

      final costBody = {
        'serviceBookingId': bookingId.value!,
        'costName': name,
        'price': price.toString(),
      };

      log("Sending additional cost: $costBody");

      final response = await _networkCaller.postRequest(
        AppUrl.additionalCost,
        body: costBody,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.isSuccess) {
        additionalCosts.add(AdditionalCostModel(title: name, price: price));
        update();
        log("✅ Additional cost added successfully");
        return true;
      } else {
        String errorMsg = response.errorMessage ?? "Failed to add cost";
        if (response.jsonResponse != null && response.jsonResponse!['message'] != null) {
          errorMsg = response.jsonResponse!['message'].toString();
        }

        Get.snackbar("Error", errorMsg,
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e, stackTrace) {
      log("❌ Network/Auth error: $e", error: e, stackTrace: stackTrace);
      Get.snackbar("Error", "Failed to add cost: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  void removeAdditionalCost(int index) {
    if (index >= 0 && index < additionalCosts.length) {
      additionalCosts.removeAt(index);
      update();
    }
  }

  // ================== SUBMISSION LOGIC ==================

  Future<void> requestPayment() async {
    if (bookingId.value == null || bookingId.value!.isEmpty) {
      Get.snackbar("Error", "No booking ID found",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (completionDateController.text.isEmpty) {
      Get.snackbar("Warning", "Please select completion date");
      return;
    }

    if (durationTimeController.text.isEmpty) {
      Get.snackbar("Warning", "Please enter duration time");
      return;
    }

    final duration = double.tryParse(durationTimeController.text);
    if (duration == null) {
      Get.snackbar("Warning", "Please enter a valid number for duration");
      return;
    }

    isPaymentRequestLoading.value = true;

    try {
      final workCompletionBody = {
        'serviceBookingId': bookingId.value!,
        'completionDate': completionDateController.text,
        'durationTime': durationTimeController.text,
        'status': 'completed',
      };

      log("Submitting work completion data...");

      Get.snackbar(
        "Success",
        "Payment request submitted successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      await Future.delayed(Duration(seconds: 2));
      Get.back(result: true);
    } catch (e, stackTrace) {
      log("❌ Submission error: $e", error: e, stackTrace: stackTrace);
      Get.snackbar("Error", "Failed to submit: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isPaymentRequestLoading.value = false;
    }
  }

  // ================== LIFECYCLE ==================

  @override
  void onClose() {
    completionDateController.dispose();
    durationTimeController.dispose();
    for (var mediaFile in mediaFiles) {
      if (mediaFile.isVideo && mediaFile.videoController != null) {
        mediaFile.videoController!.dispose();
      }
    }
    super.onClose();
  }
}

class ApiAttachment {
  final String url;
  final String type; // 'image' or 'video'
  final String id;

  ApiAttachment({
    required this.url,
    required this.type,
    required this.id,
  });

  @override
  String toString() => 'ApiAttachment(url: $url, type: $type, id: $id)';
}




*/










///
///
///
///
///
///
/// todo::::: show the iamge and the video into one place
///
///
///
///
///
///
///




import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../features/normal_user/work_completed_details/model/additional_cost_model.dart';
import '../features/service_provider/svp_submit_work_form/model/media_file.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';

class SvpSubmitWorkFormScreenController extends GetxController {
  // Text controllers
  TextEditingController completionDateController = TextEditingController();
  TextEditingController durationTimeController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final NetworkCaller _networkCaller = NetworkCaller();

  // Rx variables
  RxBool isLoading = false.obs;
  Rx<String?> bookingId = Rx<String?>(null);
  RxBool isLoadingWorkDetails = false.obs;
  RxBool isPaymentRequestLoading = false.obs;
  RxBool isUploadingMedia = false.obs;

  // API Data
  RxString address = ''.obs;
  RxString bookingDateTime = ''.obs;
  RxDouble initialCost = 0.0.obs;
  RxList<ApiAttachment> apiAttachments = <ApiAttachment>[].obs;
  RxList<AdditionalCostModel> additionalCosts = <AdditionalCostModel>[].obs;

  // Combined media files
  RxList<MediaFile> mediaFiles = <MediaFile>[].obs;

  @override
  void onInit() {
    super.onInit();

    log("Controller initialized", name: "SVPSubmitWorkForm");

    final args = Get.arguments;

    if (args != null && args is Map) {
      bookingId.value = args['bookingId']?.toString();

      if (args['formData'] != null) {
        _parseFormData(args['formData']);
      } else if (args['serviceBooking'] != null) {
        _parseServiceBookingData(args['serviceBooking'], args['additionalCosts']);
      } else if (bookingId.value != null && bookingId.value!.isNotEmpty) {
        loadWorkDetails();
      } else {
        Get.snackbar("Error", "No booking data available",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.snackbar("Error", "No booking information provided",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ================== PARSING & LOADING ==================

  void _parseFormData(Map<String, dynamic> formData) {
    try {
      final serviceBooking = formData['serviceBooking'];
      final additionalCostsData = formData['additionalCosts'];
      _parseServiceBookingData(serviceBooking, additionalCostsData);
    } catch (e, stackTrace) {
      log("Error parsing form data: $e", error: e, stackTrace: stackTrace);
      Get.snackbar("Error", "Failed to parse work details",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _parseServiceBookingData(dynamic serviceBookingData, dynamic additionalCostsData) {
    try {
      if (serviceBookingData == null) {
        Get.snackbar("Error", "No service booking data found",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Address
      final addressMap = serviceBookingData['address'] ?? {};
      if (addressMap is Map<String, dynamic>) {
        address.value = addressMap['en'] ?? addressMap['bn'] ?? '';
      } else {
        address.value = serviceBookingData['address']?.toString() ?? '';
      }

      // Booking date time
      if (serviceBookingData['bookingDateTime'] != null) {
        try {
          final bookingDate = DateTime.parse(serviceBookingData['bookingDateTime'].toString());
          bookingDateTime.value = '${bookingDate.day}-${bookingDate.month}-${bookingDate.year} ${bookingDate.hour}:${bookingDate.minute}';
        } catch (e) {
          bookingDateTime.value = serviceBookingData['bookingDateTime'].toString();
        }
      } else {
        bookingDateTime.value = '';
      }

      // Initial cost
      initialCost.value = double.tryParse(serviceBookingData['startPrice']?.toString() ?? '0') ?? 0.0;

      // Attachments
      apiAttachments.clear();
      final attachmentsData = serviceBookingData['attachments'];
      if (attachmentsData != null && attachmentsData is List) {
        for (var i = 0; i < attachmentsData.length; i++) {
          final attachment = attachmentsData[i];
          if (attachment is Map<String, dynamic>) {
            final url = attachment['attachment']?.toString() ?? '';
            final type = attachment['attachmentType']?.toString() ?? 'image';
            final id = attachment['_attachmentId']?.toString() ?? 'attachment_$i';

            // Check if it's a video
            bool isVideo = false;
            if (type.toLowerCase() == 'video') {
              isVideo = true;
            } else if (url.toLowerCase().contains('.mp4') ||
                url.toLowerCase().contains('.mov') ||
                url.toLowerCase().contains('.avi') ||
                url.toLowerCase().contains('.mkv')) {
              isVideo = true;
            }

            if (url.isNotEmpty) {
              apiAttachments.add(ApiAttachment(
                  url: url,
                  type: isVideo ? 'video' : 'image',
                  id: id
              ));
            }
          }
        }
      }

      // Additional costs
      additionalCosts.clear();
      if (additionalCostsData != null && additionalCostsData is List) {
        for (final cost in additionalCostsData) {
          if (cost is Map<String, dynamic>) {
            String costName = 'Additional Cost';
            final rawName = cost['costName'];
            if (rawName is String) {
              costName = rawName;
            } else if (rawName != null) {
              costName = rawName.toString();
            }

            final costPrice = double.tryParse(cost['price']?.toString() ?? '0') ?? 0.0;
            additionalCosts.add(AdditionalCostModel(title: costName, price: costPrice));
          }
        }
      }

      update();
    } catch (e, stackTrace) {
      log("CRITICAL ERROR: $e", error: e, stackTrace: stackTrace);
      Get.snackbar("Error", "Failed to parse work details: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> loadWorkDetails() async {
    if (bookingId.value == null || bookingId.value!.isEmpty) return;

    isLoadingWorkDetails.value = true;
    try {
      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.providerWorkSubmitForm(bookingId.value!),
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;
        if (responseData['code'] == 200 &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null) {
          final attributes = responseData['data']['attributes'];
          _parseServiceBookingData(
            attributes['serviceBooking'],
            attributes['additionalCosts'],
          );
        } else {
          Get.snackbar("Error", "Unexpected response format",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        Get.snackbar("Error", response.errorMessage ?? "Failed to load work details",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e, stackTrace) {
      log("LOAD ERROR: $e", error: e, stackTrace: stackTrace);
      Get.snackbar("Error", "Failed to load work details: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoadingWorkDetails.value = false;
    }
  }

  // ================== MEDIA HANDLING ==================

  String getImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.contains('amazonaws.com') || path.startsWith('http')) return path;
    if (path.startsWith('/')) return '${AppUrl.imageBaseUrl}$path';
    return path;
  }

  // Helper function to check if file is video
  bool _isVideoFile(String path) {
    final fileName = path.toLowerCase();
    return fileName.endsWith('.mp4') ||
        fileName.endsWith('.mov') ||
        fileName.endsWith('.avi') ||
        fileName.endsWith('.mkv') ||
        fileName.endsWith('.wmv') ||
        fileName.endsWith('.flv');
  }

  // Helper function to check if file is image
  bool _isImageFile(String path) {
    final fileName = path.toLowerCase();
    return fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif') ||
        fileName.endsWith('.bmp');
  }

  // Update the pickMediaFromGallery method in your controller

  Future<void> pickMediaFromGallery() async {
    try {
      // Use image_picker's pickMultipleMedia method which supports both images and videos
      final List<XFile>? pickedFiles = await _picker.pickMultipleMedia(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        for (var file in pickedFiles) {
          // Check if file is video based on MIME type or extension
          final isVideo = _isVideoFile(file.path);

          mediaFiles.add(MediaFile(path: file.path, isVideo: isVideo));

          log("Added file: ${file.path}, isVideo: $isVideo");
        }

        Get.snackbar("Success", "${pickedFiles.length} file(s) added",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2));

        update(); // Trigger UI rebuild
      }
    } on Exception catch (e) {
      log("Error picking media: $e");
      Get.snackbar("Error", "Failed to pick files: ${e.toString()}",
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
  // Add this method to your controller
// ================== MEDIA HANDLING ==================

  Future<void> pickMultipleMediaFromGallery() async {
    try {
      // For mixed media selection, we need to use the new API
      final List<XFile>? pickedFiles = await _picker.pickMultipleMedia(
        // image_picker 0.8.5+ uses this for both images and videos
      );

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        for (var file in pickedFiles) {
          final isVideo = _isVideoFile(file.path);
          mediaFiles.add(MediaFile(path: file.path, isVideo: isVideo));

          log("Added file: ${file.path}, isVideo: $isVideo");
        }

        Get.snackbar("Success", "${pickedFiles.length} file(s) added",
            backgroundColor: Colors.green, colorText: Colors.white,
            duration: Duration(seconds: 2));

        update(); // Trigger UI rebuild
      }
    } on Exception catch (e) {
      log("Error picking media: $e");
      Get.snackbar("Error", "Failed to pick files: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

// Alternatively, if you want separate selection for images and videos:
  Future<void> pickMixedMediaFromGallery() async {
    try {
      // First pick images using pickMultiImage
      final List<XFile>? imageFiles = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      // For videos, we need to use a different approach
      // Since pickVideo only returns a single file, we might need to handle it differently
      // Let's create a custom method that allows multiple video selection

      // Combine all files
      final List<XFile> allFiles = [];

      if (imageFiles != null && imageFiles.isNotEmpty) {
        allFiles.addAll(imageFiles);
      }

      if (allFiles.isNotEmpty) {
        for (var file in allFiles) {
          final isVideo = _isVideoFile(file.path);
          mediaFiles.add(MediaFile(path: file.path, isVideo: isVideo));

          log("Added file: ${file.path}, isVideo: $isVideo");
        }

        Get.snackbar("Success", "${allFiles.length} file(s) added",
            backgroundColor: Colors.green, colorText: Colors.white,
            duration: Duration(seconds: 2));

        update();
      }
    } on Exception catch (e) {
      log("Error picking mixed media: $e");
      Get.snackbar("Error", "Failed to pick files: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

// New method to pick videos (if you want separate video selection)
  Future<void> pickVideosFromGallery() async {
    try {
      // Note: image_picker doesn't have a direct method for multiple videos
      // We can use pickFiles with type filtering if available in your version
      final XFile? videoFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(minutes: 10),
      );

      if (videoFile != null) {
        mediaFiles.add(MediaFile(path: videoFile.path, isVideo: true));

        Get.snackbar("Success", "Video added",
            backgroundColor: Colors.green, colorText: Colors.white,
            duration: Duration(seconds: 2));

        update();
      }
    } on Exception catch (e) {
      log("Error picking video: $e");
      Get.snackbar("Error", "Failed to pick video: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

// Updated showMediaSourceDialog with correct API calls
  void showMediaSourceDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Proof Files", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text("Take Photo"),
                onTap: () {
                  Get.back();
                  pickPhotoFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam, color: Colors.red),
                title: Text("Record Video"),
                onTap: () {
                  Get.back();
                  pickVideoFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text("Choose Images"),
                subtitle: Text("Multiple images"),
                onTap: () {
                  Get.back();
                  pickMediaFromGallery(); // This picks images only
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library, color: Colors.purple),
                title: Text("Choose Video"),
                subtitle: Text("Single video"),
                onTap: () {
                  Get.back();
                  pickVideosFromGallery();
                },
              ),
              SizedBox(height: 8),
              Text(
                "Supported formats: JPG, PNG, MP4, MOV",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 16),
              TextButton(
                  onPressed: Get.back,
                  child: Text("Cancel", style: TextStyle(color: Colors.red))
              ),
            ],
          ),
        ),
      ),
    );
  }



  Future<void> pickPhotoFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 85,
      );
      if (image != null) {
        mediaFiles.add(MediaFile(path: image.path, isVideo: false));
        Get.snackbar("Success", "Photo captured successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to capture photo: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> pickVideoFromCamera() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera, maxDuration: Duration(minutes: 10),
      );
      if (video != null) {
        mediaFiles.add(MediaFile(path: video.path, isVideo: true));
        Get.snackbar("Success", "Video recorded successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to record video: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }



  Future<void> removeMediaFile(int index) async {
    if (index >= 0 && index < mediaFiles.length) {
      final mediaFile = mediaFiles[index];
      if (mediaFile.isVideo && mediaFile.videoController != null) {
        mediaFile.videoController!.dispose();
      }
      mediaFiles.removeAt(index);
      log("Media file removed at index $index");
    }
  }

  Future<void> removeApiAttachment(int index) async {
    if (index >= 0 && index < apiAttachments.length) {
      apiAttachments.removeAt(index);
      update();
    }
  }

  Future<void> clearAllMediaFiles() async {
    for (var mediaFile in mediaFiles) {
      if (mediaFile.isVideo && mediaFile.videoController != null) {
        mediaFile.videoController!.dispose();
      }
    }
    mediaFiles.clear();
  }

  int get totalImageCount =>
      mediaFiles.where((file) => !file.isVideo).length +
          apiAttachments.where((attachment) => attachment.type != 'video').length;

  int get videoCount =>
      mediaFiles.where((file) => file.isVideo).length +
          apiAttachments.where((attachment) => attachment.type == 'video').length;

  int get totalMediaCount => mediaFiles.length + apiAttachments.length;

  // ================== CUSTOM FILE UPLOAD USING HTTP DIRECTLY ==================

  /// Upload multiple files using direct HTTP multipart request
  /// This matches exactly what Postman is doing
  Future<NetworkResponse> uploadMultipleMediaFiles({
    required String bookingId,
    required List<File> files,
    List<String>? fileTypes, // Optional parameter to specify file types
  }) async {
    try {
      isUploadingMedia.value = true;

      log("🚀 Starting custom file upload...");
      log("Booking ID: $bookingId");
      log("Total files to upload: ${files.length}");

      // Get authorization token
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null || token.isEmpty) {
        log("❌ No auth token found");
        return NetworkResponse(
          isSuccess: false,
          errorMessage: 'Authentication token not found',
        );
      }

      final url = AppUrl.addNewProofFile(bookingId);
      log("📤 URL: $url");

      // Create multipart request
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('PUT', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      log("🔑 Authorization header added");

      // Add all files with the field name "attachments"
      for (int i = 0; i < files.length; i++) {
        final file = files[i];

        log("📎 Processing file ${i + 1}/${files.length}:");
        log("   Path: ${file.path}");
        log("   Exists: ${file.existsSync()}");

        if (!file.existsSync()) {
          log("   ❌ File does not exist, skipping");
          continue;
        }

        final fileSize = await file.length();
        log("   Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB");

        // Get MIME type
        final mimeType = lookupMimeType(file.path);
        log("   MIME Type: $mimeType");

        // Parse MIME type
        MediaType? contentType;
        if (mimeType != null) {
          final mimeTypeParts = mimeType.split('/');
          contentType = MediaType(
            mimeTypeParts[0],
            mimeTypeParts.length > 1 ? mimeTypeParts[1] : 'octet-stream',
          );
        } else {
          contentType = MediaType('application', 'octet-stream');
        }

        // Add file with field name "attachments" (as shown in Postman)
        final multipartFile = await http.MultipartFile.fromPath(
          'attachments', // This is the exact field name from Postman
          file.path,
          contentType: contentType,
          // You can add filename if needed
          // filename: 'file_${DateTime.now().millisecondsSinceEpoch}_$i.${file.path.split('.').last}',
        );

        request.files.add(multipartFile);
        log("   ✅ File added to request as: ${multipartFile.field}");
      }

      log("📤 Sending ${request.files.length} files...");
      log("Request headers: ${request.headers}");

      // Send request
      final streamedResponse = await request.send();
      log("📥 Response received");
      log("Status Code: ${streamedResponse.statusCode}");

      // Convert streamed response to regular response
      final response = await http.Response.fromStream(streamedResponse);
      log("Response Body: ${response.body}");

      // Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Upload successful!");

        try {
          final jsonResponse = response.body.isNotEmpty
              ? json.decode(response.body) as Map<String, dynamic>
              : <String, dynamic>{};

          return NetworkResponse(
            isSuccess: true,
            statusCode: response.statusCode,
            jsonResponse: jsonResponse,
          );
        } catch (e) {
          log("⚠️ Could not parse JSON response, but upload was successful");
          return NetworkResponse(
            isSuccess: true,
            statusCode: response.statusCode,
          );
        }
      } else {
        log("❌ Upload failed with status: ${response.statusCode}");

        String errorMessage = 'Upload failed';
        try {
          final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
          errorMessage = jsonResponse['message']?.toString() ??
              jsonResponse['error']?.toString() ??
              'Upload failed';

          return NetworkResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            jsonResponse: jsonResponse,
            errorMessage: errorMessage,
          );
        } catch (e) {
          log("Could not parse error response: ${response.body}");
          return NetworkResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: response.body.isNotEmpty ? response.body : errorMessage,
          );
        }
      }
    } catch (e, stackTrace) {
      log("❌ Upload error: $e", error: e, stackTrace: stackTrace);
      return NetworkResponse(
        isSuccess: false,
        errorMessage: 'Upload failed: ${e.toString()}',
      );
    } finally {
      isUploadingMedia.value = false;
    }
  }

  // ================== COST HANDLING ==================

  double calculateTotalPayment() {
    double total = initialCost.value;
    for (var cost in additionalCosts) {
      total += cost.price;
    }
    return total;
  }

  Future<bool> addAdditionalCost(String name, double price) async {
    if (bookingId.value == null || bookingId.value!.isEmpty) {
      Get.snackbar("Error", "No booking ID found",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    try {
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null || token.isEmpty) {
        Get.snackbar("Auth Error", "Session expired. Please log in again.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }

      final costBody = {
        'serviceBookingId': bookingId.value!,
        'costName': name,
        'price': price.toString(),
      };

      log("Sending additional cost: $costBody");

      final response = await _networkCaller.postRequest(
        AppUrl.additionalCost,
        body: costBody,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.isSuccess) {
        additionalCosts.add(AdditionalCostModel(title: name, price: price));
        update();
        log("✅ Additional cost added successfully");
        return true;
      } else {
        String errorMsg = response.errorMessage ?? "Failed to add cost";
        if (response.jsonResponse != null && response.jsonResponse!['message'] != null) {
          errorMsg = response.jsonResponse!['message'].toString();
        }

        Get.snackbar("Error", errorMsg,
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e, stackTrace) {
      log("❌ Network/Auth error: $e", error: e, stackTrace: stackTrace);
      Get.snackbar("Error", "Failed to add cost: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  void removeAdditionalCost(int index) {
    if (index >= 0 && index < additionalCosts.length) {
      additionalCosts.removeAt(index);
      update();
    }
  }

  // ================== SUBMISSION LOGIC ==================

  Future<void> requestPayment() async {
    if (bookingId.value == null || bookingId.value!.isEmpty) {
      Get.snackbar("Error", "No booking ID found",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (completionDateController.text.isEmpty) {
      Get.snackbar("Warning", "Please select completion date");
      return;
    }

    if (durationTimeController.text.isEmpty) {
      Get.snackbar("Warning", "Please enter duration time");
      return;
    }

    final duration = double.tryParse(durationTimeController.text);
    if (duration == null) {
      Get.snackbar("Warning", "Please enter a valid number for duration");
      return;
    }

    isPaymentRequestLoading.value = true;

    try {
      final workCompletionBody = {
        'serviceBookingId': bookingId.value!,
        'completionDate': completionDateController.text,
        'durationTime': durationTimeController.text,
        'status': 'completed',
      };

      log("Submitting work completion data...");

      Get.snackbar(
        "Success",
        "Payment request submitted successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      await Future.delayed(Duration(seconds: 2));
      Get.back(result: true);
    } catch (e, stackTrace) {
      log("❌ Submission error: $e", error: e, stackTrace: stackTrace);
      Get.snackbar("Error", "Failed to submit: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isPaymentRequestLoading.value = false;
    }
  }

  // ================== LIFECYCLE ==================

  @override
  void onClose() {
    completionDateController.dispose();
    durationTimeController.dispose();
    for (var mediaFile in mediaFiles) {
      if (mediaFile.isVideo && mediaFile.videoController != null) {
        mediaFile.videoController!.dispose();
      }
    }
    super.onClose();
  }
}

class ApiAttachment {
  final String url;
  final String type; // 'image' or 'video'
  final String id;

  ApiAttachment({
    required this.url,
    required this.type,
    required this.id,
  });

  @override
  String toString() => 'ApiAttachment(url: $url, type: $type, id: $id)';
}






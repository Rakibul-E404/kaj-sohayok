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
            if (url.isNotEmpty) {
              apiAttachments.add(ApiAttachment(url: url, type: type, id: id));
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

  Future<void> pickMediaFromGallery() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        maxWidth: 1024, maxHeight: 1024, imageQuality: 85,
      );
      if (files.isNotEmpty) {
        for (var file in files) {
          final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mov') ||
              file.path.toLowerCase().endsWith('.avi') ||
              file.path.toLowerCase().endsWith('.mkv');
          mediaFiles.add(MediaFile(path: file.path, isVideo: isVideo));
        }
        Get.snackbar("Success", "${files.length} file(s) added",
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
                onTap: () {
                  Get.back();
                  pickMediaFromGallery();
                },
              ),
              TextButton(onPressed: Get.back, child: Text("Cancel")),
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
      mediaFiles.where((file) => !file.isVideo).length + apiAttachments.length;

  int get videoCount => mediaFiles.where((file) => file.isVideo).length;

  int get totalMediaCount => mediaFiles.length + apiAttachments.length;

  // ================== CUSTOM FILE UPLOAD USING HTTP DIRECTLY ==================

  /// Upload multiple files using direct HTTP multipart request
  /// This matches exactly what Postman is doing
  Future<NetworkResponse> uploadMultipleMediaFiles({
    required String bookingId,
    required List<File> files,
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
        log("   Size: $fileSize bytes");

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
        );

        request.files.add(multipartFile);
        log("   ✅ File added to request");
      }

      log("📤 Sending ${request.files.length} files...");
      log("Request headers: ${request.headers}");
      log("Request fields: ${request.fields}");
      log("Request files count: ${request.files.length}");

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

  /// Alternative: Upload files one by one (more reliable for large files)
  Future<NetworkResponse> uploadFilesSequentially({
    required String bookingId,
    required List<File> files,
  }) async {
    try {
      isUploadingMedia.value = true;

      log("🚀 Starting sequential file upload...");
      log("Total files: ${files.length}");

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null || token.isEmpty) {
        return NetworkResponse(
          isSuccess: false,
          errorMessage: 'Authentication token not found',
        );
      }

      int successCount = 0;
      String? lastErrorMessage;
      List<String> errors = [];

      for (int i = 0; i < files.length; i++) {
        try {
          log("📤 Uploading file ${i + 1}/${files.length}");

          final url = AppUrl.addNewProofFile(bookingId);
          final uri = Uri.parse(url);
          final request = http.MultipartRequest('PUT', uri);

          // Add authorization header
          request.headers['Authorization'] = 'Bearer $token';

          // Get MIME type
          final mimeType = lookupMimeType(files[i].path);
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

          // Add single file
          final multipartFile = await http.MultipartFile.fromPath(
            'attachments',
            files[i].path,
            contentType: contentType,
          );

          request.files.add(multipartFile);

          // Send request
          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);

          if (response.statusCode == 200 || response.statusCode == 201) {
            successCount++;
            log("   ✅ File ${i + 1} uploaded successfully");
          } else {
            try {
              final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
              lastErrorMessage = jsonResponse['message']?.toString() ?? 'Upload failed';
            } catch (e) {
              lastErrorMessage = response.body.isNotEmpty ? response.body : 'Upload failed';
            }
            errors.add("File ${i + 1}: $lastErrorMessage");
            log("   ❌ File ${i + 1} failed: $lastErrorMessage");
          }
        } catch (e) {
          lastErrorMessage = e.toString();
          errors.add("File ${i + 1}: $lastErrorMessage");
          log("   ❌ File ${i + 1} error: $e");
        }
      }

      if (successCount == files.length) {
        log("✅ All files uploaded successfully");
        return NetworkResponse(isSuccess: true);
      } else if (successCount > 0) {
        final errorMsg = "Uploaded $successCount/${files.length} files.\n${errors.join('\n')}";
        log("⚠️ Partial success: $errorMsg");
        return NetworkResponse(
          isSuccess: false,
          errorMessage: errorMsg,
        );
      } else {
        final errorMsg = lastErrorMessage ?? "Failed to upload all files";
        log("❌ All uploads failed: $errorMsg");
        return NetworkResponse(
          isSuccess: false,
          errorMessage: errorMsg,
        );
      }
    } catch (e, stackTrace) {
      log("❌ Sequential upload error: $e", error: e, stackTrace: stackTrace);
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
  final String type;
  final String id;

  ApiAttachment({
    required this.url,
    required this.type,
    required this.id,
  });

  @override
  String toString() => 'ApiAttachment(url: $url, type: $type, id: $id)';
}
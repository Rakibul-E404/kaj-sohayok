/**
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
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
  RxString bookingId = RxString('');
  RxBool isLoadingWorkDetails = false.obs;
  RxBool isPaymentRequestLoading = false.obs;
  RxBool isUploadingMedia = false.obs;

  // Date variables for calculation
  Rx<DateTime?> bookingDate = Rx<DateTime?>(null);
  Rx<DateTime?> completionDate = Rx<DateTime?>(null);

  // API Data
  RxString address = ''.obs;
  RxString bookingDateTime = ''.obs;
  RxDouble initialCost = 0.0.obs;
  RxList<ApiAttachment> apiAttachments = <ApiAttachment>[].obs;
  RxList<AdditionalCostModel> additionalCosts = <AdditionalCostModel>[].obs;

  // Combined media files
  RxList<MediaFile> mediaFiles = <MediaFile>[].obs;

  // Private variable to store booking ID safely
  String _storedBookingId = '';

  @override
  void onInit() {
    super.onInit();

    log("🎯 Controller initialized", name: "SVPSubmitWorkForm");

    // First extract booking ID from arguments
    _extractBookingIdFromArguments();

    // Then parse form data if available
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['formData'] != null) {
        log("📝 Parsing form data...");
        _parseFormData(args['formData']);
      } else if (args['serviceBooking'] != null) {
        log("📝 Parsing service booking data...");
        _parseServiceBookingData(args['serviceBooking'], args['additionalCosts']);
      } else if (bookingId.value.isNotEmpty) {
        log("📡 Loading work details from API...");
        loadWorkDetails();
      } else {
        log("⚠️ No booking data available");
        Get.snackbar("Info", "No booking data available",
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } else {
      log("⚠️ No arguments provided");
      Get.snackbar("Info", "No booking information provided",
          backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  void _extractBookingIdFromArguments() {
    final args = Get.arguments;

    if (args != null) {
      log("📦 Arguments type: ${args.runtimeType}");
      log("📦 Arguments content: $args");

      if (args is Map) {
        final bookingIdFromArgs = args['bookingId']?.toString();
        if (bookingIdFromArgs != null && bookingIdFromArgs.isNotEmpty) {
          bookingId.value = bookingIdFromArgs;
          _storedBookingId = bookingIdFromArgs;
          log("✅ Booking ID stored from map: ${bookingId.value}");
        } else {
          log("❌ No bookingId found in map arguments");
        }
      } else if (args is String) {
        // Handle case where bookingId is passed directly as a string
        bookingId.value = args;
        _storedBookingId = args;
        log("✅ Booking ID stored directly as string: ${bookingId.value}");
      } else {
        log("❌ Arguments type not recognized: ${args.runtimeType}");
      }
    } else {
      log("❌ No arguments found");
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

      // Booking date time - store as DateTime object
      if (serviceBookingData['bookingDateTime'] != null) {
        try {
          final bookingDateString = serviceBookingData['bookingDateTime'].toString();
          bookingDate.value = DateTime.parse(bookingDateString);

          // Format for display
          final parsedDate = bookingDate.value!;
          bookingDateTime.value = '${parsedDate.day}-${parsedDate.month}-${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute}';

          log("📅 Booking date stored: ${bookingDate.value}");
          log("📅 Booking date display: ${bookingDateTime.value}");
        } catch (e) {
          log("❌ Error parsing booking date: $e");
          bookingDateTime.value = serviceBookingData['bookingDateTime'].toString();
          bookingDate.value = null;
        }
      } else {
        bookingDateTime.value = '';
        bookingDate.value = null;
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

  // ================== DATE HANDLING & DURATION CALCULATION ==================

  // Method to handle completion date selection
// Add this Rx variable
  RxBool isDateSelected = false.obs;

// Update onCompletionDateSelected method
  void onCompletionDateSelected(DateTime selectedDate) {
    // Validate if booking date is available
    if (bookingDate.value == null) {
      Get.snackbar(
        "Info",
        "Booking date not available. Cannot calculate duration.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return;
    }

    // Validate if completion date is valid
    if (!_isCompletionDateValid(selectedDate)) {
      return;
    }

    // Format date for display (MM-dd-yyyy format)
    final formattedDate = DateFormat('MM-dd-yyyy').format(selectedDate);
    completionDateController.text = formattedDate;
    completionDate.value = selectedDate;

    // Set date selected flag to true
    isDateSelected.value = true;

    // Calculate and set duration
    _calculateAndSetDuration(selectedDate);

    // Show calculation info
    _showDurationCalculationInfo(selectedDate);
  }

// Update clearDateAndDuration method
  void clearDateAndDuration() {
    completionDateController.clear();
    durationTimeController.clear();
    completionDate.value = null;
    isDateSelected.value = false; // Reset the flag
    log("🗑️ Date and duration cleared");
  }

  // Validate completion date
  bool _isCompletionDateValid(DateTime selectedDate) {
    if (bookingDate.value == null) return true;

    // Check if completion date is after booking date
    if (selectedDate.isBefore(bookingDate.value!)) {
      final bookingDateFormatted = DateFormat('MMM dd, yyyy').format(bookingDate.value!);
      final selectedDateFormatted = DateFormat('MMM dd, yyyy').format(selectedDate);

      Get.snackbar(
        "Invalid Date",
        "Completion date ($selectedDateFormatted) cannot be before the booking date ($bookingDateFormatted)",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
      return false;
    }

    // Optional: Check if completion date is within reasonable timeframe (2 years max)
    final maxDays = 730; // 2 years
    final daysDifference = selectedDate.difference(bookingDate.value!).inDays;

    if (daysDifference > maxDays) {
      Get.snackbar(
        "Invalid Date",
        "Completion date cannot be more than 2 years after booking date",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return false;
    }

    return true;
  }

  // Calculate and set duration
  void _calculateAndSetDuration(DateTime selectedDate) {
    if (bookingDate.value == null) return;

    // Calculate difference in days
    final differenceInDays = selectedDate.difference(bookingDate.value!).inDays;

    // Ensure minimum duration is 1 day
    final durationDays = differenceInDays > 0 ? differenceInDays : 1;

    // Set the duration in the controller
    durationTimeController.text = durationDays.toString();

    log("📅 Duration calculated: $durationDays days");
    log("📅 From: ${bookingDate.value} to: $selectedDate");
  }

  // Show calculation info to user
  void _showDurationCalculationInfo(DateTime selectedDate) {
    if (bookingDate.value == null) return;

    final durationDays = selectedDate.difference(bookingDate.value!).inDays;
    final startDate = DateFormat('MMM dd, yyyy').format(bookingDate.value!);
    final endDate = DateFormat('MMM dd, yyyy').format(selectedDate);
    final effectiveDuration = durationDays > 0 ? durationDays : 1;

    Get.snackbar(
      "✓ Duration Calculated",
      "Booking: $startDate\nCompletion: $endDate\n\nDuration: $effectiveDuration days",
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
      icon: Icon(Icons.calendar_today, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }

  // Method to manually recalculate duration (if needed)
  void recalculateDuration() {
    if (completionDate.value != null && bookingDate.value != null) {
      _calculateAndSetDuration(completionDate.value!);
      _showDurationCalculationInfo(completionDate.value!);
    } else {
      Get.snackbar(
        "Info",
        "Please select completion date first",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }



  Future<void> loadWorkDetails() async {
    // Use the stored booking ID if the observable is empty
    String idToUse = bookingId.value.isNotEmpty ? bookingId.value : _storedBookingId;

    if (idToUse.isEmpty) {
      log("❌ No booking ID available for loading work details");
      Get.snackbar("Info", "Booking information not found",
          backgroundColor: Colors.orange, colorText: Colors.white, duration: Duration(seconds: 2));
      return;
    }

    log("📡 Loading work details for Booking ID: $idToUse");

    // Log the exact URL being called
    final apiUrl = AppUrl.providerWorkSubmitForm(idToUse);
    log("🌐 API URL: $apiUrl");

    isLoadingWorkDetails.value = true;

    try {
      // 🔥 CRITICAL FIX: Get authentication token
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null || token.isEmpty) {
        log("❌ No auth token found for API call");
        Get.snackbar("Error", "Session expired. Please log in again.",
            backgroundColor: Colors.red, colorText: Colors.white, duration: Duration(seconds: 2));
        isLoadingWorkDetails.value = false;
        return;
      }

      log("🔑 Auth token found, length: ${token.length} characters");

      // 🔥 CRITICAL FIX: Prepare headers with authentication
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      log("📤 Making authenticated API request...");

      // Call network caller with headers
      final NetworkResponse response = await _networkCaller.getRequest(
        apiUrl,
        headers: headers, // Pass headers to network caller
      );

      log("📥 API Response Status: ${response.statusCode}");
      log("📥 API Response Success: ${response.isSuccess}");

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;
        log("✅ Work details response received from API");
        log("📊 Response code: ${responseData['code']}");

        if (responseData['code'] == 200 &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null) {
          final attributes = responseData['data']['attributes'];

          log("📊 Attributes loaded successfully");

          // Check if serviceBooking exists
          if (attributes['serviceBooking'] != null) {
            final serviceBooking = attributes['serviceBooking'];

            _parseServiceBookingData(
              serviceBooking,
              attributes['additionalCosts'],
            );
            log("✅ Work details loaded successfully from API");

            // Show success message
            Get.snackbar(
                "Success",
                "Work details refreshed",
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: Duration(seconds: 1)
            );
          } else {
            log("⚠️ No serviceBooking data in API response");
            Get.snackbar("Info", "No work details found in API response",
                backgroundColor: Colors.orange, colorText: Colors.white, duration: Duration(seconds: 2));
          }
        } else {
          final errorMessage = responseData['message']?.toString() ?? "Unexpected response format";
          log("⚠️ API Error in response data: $errorMessage");
          Get.snackbar("Info", errorMessage,
              backgroundColor: Colors.orange, colorText: Colors.white, duration: Duration(seconds: 2));
        }
      } else {
        log("❌ API Request Failed");
        log("❌ Status Code: ${response.statusCode}");
        log("❌ Error Message: ${response.errorMessage}");

        // Handle specific error codes
        if (response.statusCode == 401) {
          Get.snackbar("Session Expired", "Please log in again",
              backgroundColor: Colors.red, colorText: Colors.white, duration: Duration(seconds: 3));
        } else if (response.statusCode == 404) {
          Get.snackbar("Not Found", "Booking details not found",
              backgroundColor: Colors.orange, colorText: Colors.white, duration: Duration(seconds: 2));
        } else {
          Get.snackbar("Error", "Could not refresh data. Please try again.",
              backgroundColor: Colors.red, colorText: Colors.white, duration: Duration(seconds: 2));
        }
      }
    } catch (e, stackTrace) {
      log("❌ LOAD ERROR: $e", error: e, stackTrace: stackTrace);

      // Handle specific exceptions
      if (e is SocketException) {
        Get.snackbar("No Internet", "Please check your connection",
            backgroundColor: Colors.red, colorText: Colors.white, duration: Duration(seconds: 2));
      } else if (e is TimeoutException) {
        Get.snackbar("Timeout", "Request took too long. Please try again.",
            backgroundColor: Colors.orange, colorText: Colors.white, duration: Duration(seconds: 2));
      } else {
        Get.snackbar("Error", "Network error. Please try again.",
            backgroundColor: Colors.red, colorText: Colors.white, duration: Duration(seconds: 2));
      }
    } finally {
      isLoadingWorkDetails.value = false;
    }
  }

  // Getter for stored booking ID
  String get storedBookingId => _storedBookingId;

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
      // Use pickMultipleMedia to get both images and videos
      final List<XFile> selectedFiles = await _picker.pickMultipleMedia(
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (selectedFiles.isNotEmpty) {
        for (var file in selectedFiles) {
          final isVideo = _isVideoFile(file.path);
          mediaFiles.add(MediaFile(path: file.path, isVideo: isVideo));
        }
        Get.snackbar("Success", "${selectedFiles.length} file(s) added",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      log("Error picking files from gallery: $e");
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

  // Clear media files after successful upload
  void clearMediaFilesAfterUpload() {
    // Clear all media files
    for (var mediaFile in mediaFiles) {
      if (mediaFile.isVideo && mediaFile.videoController != null) {
        mediaFile.videoController!.dispose();
      }
    }
    mediaFiles.clear();

    update();
    log("✅ Media files cleared after successful upload");
  }

  // Refresh after upload to get updated attachments
  Future<void> refreshAfterUpload() async {
    log("🔄 Refreshing after upload...");
    await loadWorkDetails();
    log("✅ Refresh completed after upload");
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

  Future<NetworkResponse> uploadMultipleMediaFiles({
    required String bookingId,
    required List<File> files,
    List<String>? fileTypes,
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

        // Add file with field name "attachments"
        final multipartFile = await http.MultipartFile.fromPath(
          'attachments',
          file.path,
          contentType: contentType,
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
    String idToUse = bookingId.value.isNotEmpty ? bookingId.value : _storedBookingId;

    if (idToUse.isEmpty) {
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
        'serviceBookingId': idToUse,
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

  /// ================== SUBMISSION LOGIC ==================

  Future<void> requestPayment() async {
    String idToUse = bookingId.value.isNotEmpty ? bookingId.value : _storedBookingId;

    // Validate booking ID
    if (idToUse.isEmpty) {
      Get.snackbar("Error", "No booking ID found",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Validate completion date
    if (completionDateController.text.isEmpty) {
      Get.snackbar("Warning", "Please select completion date");
      return;
    }

    // Validate duration (must be non-empty and numeric)
    final durationText = durationTimeController.text.trim();
    if (durationText.isEmpty) {
      Get.snackbar("Warning", "Duration is required. Please select a valid completion date.");
      return;
    }

    final duration = double.tryParse(durationText);
    if (duration == null || duration <= 0) {
      Get.snackbar("Warning", "Please enter a valid duration (must be > 0).");
      return;
    }

    // Ensure completionDate is in ISO 8601 format (UTC)
    // Your current completionDateController.text is in "MM-dd-yyyy"
    // So we need to convert it to "yyyy-MM-ddT00:00:00Z"

    DateTime? selectedDate;
    try {
      // Parse the displayed date (e.g., "12-04-2025")
      selectedDate = DateFormat('MM-dd-yyyy').parseStrict(completionDateController.text);
    } catch (e) {
      Get.snackbar("Error", "Invalid date format");
      return;
    }

    // Convert to ISO UTC midnight (as per your example: "2025-12-04T00:00:00Z")
    final completionDateIso = '${selectedDate.toUtc().toIso8601String().split('T')[0]}T00:00:00Z';

    isPaymentRequestLoading.value = true;

    try {
      final token = await SecureStorageService().read(AppConstants.accessToken);
      if (token == null || token.isEmpty) {
        Get.snackbar("Auth Error", "Session expired. Please log in again.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final body = {
        'completionDate': completionDateIso,
        'duration': duration.toInt().toString(), // API expects string "10", not number
      };

      log("📤 Requesting payment with body: $body");

      final response = await _networkCaller.putRequest(
        AppUrl.providerRequestPayment(idToUse),
        body: body,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess) {
        Get.snackbar(
          "Success",
          "Payment request submitted successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        await Future.delayed(Duration(seconds: 2));
        Get.back(result: true);
      } else {
        String errorMsg = response.errorMessage ?? "Failed to submit payment request";
        if (response.jsonResponse?['message'] != null) {
          errorMsg = response.jsonResponse!['message'].toString();
        }
        Get.snackbar("Error", errorMsg,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e, stackTrace) {
      log("❌ Payment request error: $e", error: e, stackTrace: stackTrace);
      Get.snackbar("Error", "Failed to submit: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isPaymentRequestLoading.value = false;
    }
  }

  /// ================== LIFECYCLE ==================

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







import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import '../features/normal_user/work_completed_details/model/additional_cost_model.dart';
import '../features/service_provider/svp_bookings/presentation/svp_bookings_screen.dart';
import '../features/service_provider/svp_submit_work_form/model/media_file.dart';
import '../routes/routes.dart';
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
  RxString bookingId = RxString('');
  RxBool isLoadingWorkDetails = false.obs;
  RxBool isPaymentRequestLoading = false.obs;
  RxBool isUploadingMedia = false.obs;

  // Date variables for calculation
  Rx<DateTime?> bookingDate = Rx<DateTime?>(null);
  Rx<DateTime?> completionDate = Rx<DateTime?>(null);

  // API Data
  RxString address = ''.obs;
  RxString bookingDateTime = ''.obs;
  RxDouble initialCost = 0.0.obs;
  RxList<ApiAttachment> apiAttachments = <ApiAttachment>[].obs;
  RxList<AdditionalCostModel> additionalCosts = <AdditionalCostModel>[].obs;

  // Combined media files
  RxList<MediaFile> mediaFiles = <MediaFile>[].obs;

  // Private variable to store booking ID safely
  String _storedBookingId = '';

  @override
  void onInit() {
    super.onInit();

    log("🎯 Controller initialized", name: "SVPSubmitWorkForm");

    // First extract booking ID from arguments
    _extractBookingIdFromArguments();

    // Then parse form data if available
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['formData'] != null) {
        log("📝 Parsing form data...");
        _parseFormData(args['formData']);
      } else if (args['serviceBooking'] != null) {
        log("📝 Parsing service booking data...");
        _parseServiceBookingData(args['serviceBooking'], args['additionalCosts']);
      } else if (bookingId.value.isNotEmpty) {
        log("📡 Loading work details from API...");
        loadWorkDetails();
      } else {
        log("⚠️ No booking data available");
        Get.snackbar("Info", "No booking data available",
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } else {
      log("⚠️ No arguments provided");
      Get.snackbar("Info", "No booking information provided",
          backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  void _extractBookingIdFromArguments() {
    final args = Get.arguments;

    if (args != null) {
      log("📦 Arguments type: ${args.runtimeType}");
      log("📦 Arguments content: $args");

      if (args is Map) {
        final bookingIdFromArgs = args['bookingId']?.toString();
        if (bookingIdFromArgs != null && bookingIdFromArgs.isNotEmpty) {
          bookingId.value = bookingIdFromArgs;
          _storedBookingId = bookingIdFromArgs;
          log("✅ Booking ID stored from map: ${bookingId.value}");
        } else {
          log("❌ No bookingId found in map arguments");
        }
      } else if (args is String) {
        // Handle case where bookingId is passed directly as a string
        bookingId.value = args;
        _storedBookingId = args;
        log("✅ Booking ID stored directly as string: ${bookingId.value}");
      } else {
        log("❌ Arguments type not recognized: ${args.runtimeType}");
      }
    } else {
      log("❌ No arguments found");
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

      // Booking date time - store as DateTime object
      if (serviceBookingData['bookingDateTime'] != null) {
        try {
          final bookingDateString = serviceBookingData['bookingDateTime'].toString();
          bookingDate.value = DateTime.parse(bookingDateString);

          // Format for display
          final parsedDate = bookingDate.value!;
          bookingDateTime.value = '${parsedDate.day}-${parsedDate.month}-${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute}';

          log("📅 Booking date stored: ${bookingDate.value}");
          log("📅 Booking date display: ${bookingDateTime.value}");
        } catch (e) {
          log("❌ Error parsing booking date: $e");
          bookingDateTime.value = serviceBookingData['bookingDateTime'].toString();
          bookingDate.value = null;
        }
      } else {
        bookingDateTime.value = '';
        bookingDate.value = null;
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

  // ================== DATE HANDLING & DURATION CALCULATION ==================

  // Method to handle completion date selection
// Add this Rx variable
  RxBool isDateSelected = false.obs;

// Update onCompletionDateSelected method
  void onCompletionDateSelected(DateTime selectedDate) {
    // Validate if booking date is available
    if (bookingDate.value == null) {
      Get.snackbar(
        "Info",
        "Booking date not available. Cannot calculate duration.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return;
    }

    // Validate if completion date is valid
    if (!_isCompletionDateValid(selectedDate)) {
      return;
    }

    // Format date for display (MM-dd-yyyy format)
    final formattedDate = DateFormat('MM-dd-yyyy').format(selectedDate);
    completionDateController.text = formattedDate;
    completionDate.value = selectedDate;

    // Set date selected flag to true
    isDateSelected.value = true;

    // Calculate and set duration
    _calculateAndSetDuration(selectedDate);

    // Show calculation info
    _showDurationCalculationInfo(selectedDate);
  }

// Update clearDateAndDuration method
  void clearDateAndDuration() {
    completionDateController.clear();
    durationTimeController.clear();
    completionDate.value = null;
    isDateSelected.value = false; // Reset the flag
    log("🗑️ Date and duration cleared");
  }

  // Validate completion date
  bool _isCompletionDateValid(DateTime selectedDate) {
    if (bookingDate.value == null) return true;

    // Check if completion date is after booking date
    if (selectedDate.isBefore(bookingDate.value!)) {
      final bookingDateFormatted = DateFormat('MMM dd, yyyy').format(bookingDate.value!);
      final selectedDateFormatted = DateFormat('MMM dd, yyyy').format(selectedDate);

      Get.snackbar(
        "Invalid Date",
        "Completion date ($selectedDateFormatted) cannot be before the booking date ($bookingDateFormatted)",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
      return false;
    }

    // Optional: Check if completion date is within reasonable timeframe (2 years max)
    final maxDays = 730; // 2 years
    final daysDifference = selectedDate.difference(bookingDate.value!).inDays;

    if (daysDifference > maxDays) {
      Get.snackbar(
        "Invalid Date",
        "Completion date cannot be more than 2 years after booking date",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return false;
    }

    return true;
  }

  // Calculate and set duration
  void _calculateAndSetDuration(DateTime selectedDate) {
    if (bookingDate.value == null) return;

    // Calculate difference in days
    final differenceInDays = selectedDate.difference(bookingDate.value!).inDays;

    // Ensure minimum duration is 1 day
    final durationDays = differenceInDays > 0 ? differenceInDays : 1;

    // Set the duration in the controller
    durationTimeController.text = durationDays.toString();

    log("📅 Duration calculated: $durationDays days");
    log("📅 From: ${bookingDate.value} to: $selectedDate");
  }

  // Show calculation info to user
  void _showDurationCalculationInfo(DateTime selectedDate) {
    if (bookingDate.value == null) return;

    final durationDays = selectedDate.difference(bookingDate.value!).inDays;
    final startDate = DateFormat('MMM dd, yyyy').format(bookingDate.value!);
    final endDate = DateFormat('MMM dd, yyyy').format(selectedDate);
    final effectiveDuration = durationDays > 0 ? durationDays : 1;

    Get.snackbar(
      "✓ Duration Calculated",
      "Booking: $startDate\nCompletion: $endDate\n\nDuration: $effectiveDuration days",
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
      icon: Icon(Icons.calendar_today, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }

  // Method to manually recalculate duration (if needed)
  void recalculateDuration() {
    if (completionDate.value != null && bookingDate.value != null) {
      _calculateAndSetDuration(completionDate.value!);
      _showDurationCalculationInfo(completionDate.value!);
    } else {
      Get.snackbar(
        "Info",
        "Please select completion date first",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }



  Future<void> loadWorkDetails() async {
    // Use the stored booking ID if the observable is empty
    String idToUse = bookingId.value.isNotEmpty ? bookingId.value : _storedBookingId;

    if (idToUse.isEmpty) {
      log("❌ No booking ID available for loading work details");
      Get.snackbar("Info", "Booking information not found",
          backgroundColor: Colors.orange, colorText: Colors.white, duration: Duration(seconds: 2));
      return;
    }

    log("📡 Loading work details for Booking ID: $idToUse");

    // Log the exact URL being called
    final apiUrl = AppUrl.providerWorkSubmitForm(idToUse);
    log("🌐 API URL: $apiUrl");

    isLoadingWorkDetails.value = true;

    try {
      // 🔥 CRITICAL FIX: Get authentication token
      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null || token.isEmpty) {
        log("❌ No auth token found for API call");
        Get.snackbar("Error", "Session expired. Please log in again.",
            backgroundColor: Colors.red, colorText: Colors.white, duration: Duration(seconds: 2));
        isLoadingWorkDetails.value = false;
        return;
      }

      log("🔑 Auth token found, length: ${token.length} characters");

      // 🔥 CRITICAL FIX: Prepare headers with authentication
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      log("📤 Making authenticated API request...");

      // Call network caller with headers
      final NetworkResponse response = await _networkCaller.getRequest(
        apiUrl,
        headers: headers, // Pass headers to network caller
      );

      log("📥 API Response Status: ${response.statusCode}");
      log("📥 API Response Success: ${response.isSuccess}");

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;
        log("✅ Work details response received from API");
        log("📊 Response code: ${responseData['code']}");

        if (responseData['code'] == 200 &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null) {
          final attributes = responseData['data']['attributes'];

          log("📊 Attributes loaded successfully");

          // Check if serviceBooking exists
          if (attributes['serviceBooking'] != null) {
            final serviceBooking = attributes['serviceBooking'];

            _parseServiceBookingData(
              serviceBooking,
              attributes['additionalCosts'],
            );
            log("✅ Work details loaded successfully from API");

            // Show success message
            Get.snackbar(
                "Success",
                "Work details refreshed",
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: Duration(seconds: 1)
            );
          } else {
            log("⚠️ No serviceBooking data in API response");
            Get.snackbar("Info", "No work details found in API response",
                backgroundColor: Colors.orange, colorText: Colors.white, duration: Duration(seconds: 2));
          }
        } else {
          final errorMessage = responseData['message']?.toString() ?? "Unexpected response format";
          log("⚠️ API Error in response data: $errorMessage");
          Get.snackbar("Info", errorMessage,
              backgroundColor: Colors.orange, colorText: Colors.white, duration: Duration(seconds: 2));
        }
      } else {
        log("❌ API Request Failed");
        log("❌ Status Code: ${response.statusCode}");
        log("❌ Error Message: ${response.errorMessage}");

        // Handle specific error codes
        if (response.statusCode == 401) {
          Get.snackbar("Session Expired", "Please log in again",
              backgroundColor: Colors.red, colorText: Colors.white, duration: Duration(seconds: 3));
        } else if (response.statusCode == 404) {
          Get.snackbar("Not Found", "Booking details not found",
              backgroundColor: Colors.orange, colorText: Colors.white, duration: Duration(seconds: 2));
        } else {
          Get.snackbar("Error", "Could not refresh data. Please try again.",
              backgroundColor: Colors.red, colorText: Colors.white, duration: Duration(seconds: 2));
        }
      }
    } catch (e, stackTrace) {
      log("❌ LOAD ERROR: $e", error: e, stackTrace: stackTrace);

      // Handle specific exceptions
      if (e is SocketException) {
        Get.snackbar("No Internet", "Please check your connection",
            backgroundColor: Colors.red, colorText: Colors.white, duration: Duration(seconds: 2));
      } else if (e is TimeoutException) {
        Get.snackbar("Timeout", "Request took too long. Please try again.",
            backgroundColor: Colors.orange, colorText: Colors.white, duration: Duration(seconds: 2));
      } else {
        Get.snackbar("Error", "Network error. Please try again.",
            backgroundColor: Colors.red, colorText: Colors.white, duration: Duration(seconds: 2));
      }
    } finally {
      isLoadingWorkDetails.value = false;
    }
  }

  // Getter for stored booking ID
  String get storedBookingId => _storedBookingId;

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
      // Use pickMultipleMedia to get both images and videos
      final List<XFile> selectedFiles = await _picker.pickMultipleMedia(
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (selectedFiles.isNotEmpty) {
        for (var file in selectedFiles) {
          final isVideo = _isVideoFile(file.path);
          mediaFiles.add(MediaFile(path: file.path, isVideo: isVideo));
        }
        Get.snackbar("Success", "${selectedFiles.length} file(s) added",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      log("Error picking files from gallery: $e");
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

  // Clear media files after successful upload
  void clearMediaFilesAfterUpload() {
    // Clear all media files
    for (var mediaFile in mediaFiles) {
      if (mediaFile.isVideo && mediaFile.videoController != null) {
        mediaFile.videoController!.dispose();
      }
    }
    mediaFiles.clear();

    update();
    log("✅ Media files cleared after successful upload");
  }

  // Refresh after upload to get updated attachments
  Future<void> refreshAfterUpload() async {
    log("🔄 Refreshing after upload...");
    await loadWorkDetails();
    log("✅ Refresh completed after upload");
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

  Future<NetworkResponse> uploadMultipleMediaFiles({
    required String bookingId,
    required List<File> files,
    List<String>? fileTypes,
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

        // Add file with field name "attachments"
        final multipartFile = await http.MultipartFile.fromPath(
          'attachments',
          file.path,
          contentType: contentType,
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
    String idToUse = bookingId.value.isNotEmpty ? bookingId.value : _storedBookingId;

    if (idToUse.isEmpty) {
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
        'serviceBookingId': idToUse,
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

  /// ================== SUBMISSION LOGIC ==================

  Future<void> requestPayment() async {
    String idToUse = bookingId.value.isNotEmpty ? bookingId.value : _storedBookingId;

    // Validate booking ID
    if (idToUse.isEmpty) {
      Get.snackbar("Error", "No booking ID found",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Validate completion date
    if (completionDateController.text.isEmpty) {
      Get.snackbar("Warning", "Please select completion date");
      return;
    }

    // Validate duration (must be non-empty and numeric)
    final durationText = durationTimeController.text.trim();
    if (durationText.isEmpty) {
      Get.snackbar("Warning", "Duration is required. Please select a valid completion date.");
      return;
    }

    final duration = double.tryParse(durationText);
    if (duration == null || duration <= 0) {
      Get.snackbar("Warning", "Please enter a valid duration (must be > 0).");
      return;
    }

    // Ensure completionDate is in ISO 8601 format (UTC)
    // Your current completionDateController.text is in "MM-dd-yyyy"
    // So we need to convert it to "yyyy-MM-ddT00:00:00Z"

    DateTime? selectedDate;
    try {
      // Parse the displayed date (e.g., "12-04-2025")
      selectedDate = DateFormat('MM-dd-yyyy').parseStrict(completionDateController.text);
    } catch (e) {
      Get.snackbar("Error", "Invalid date format");
      return;
    }

    // Convert to ISO UTC midnight (as per your example: "2025-12-04T00:00:00Z")
    final completionDateIso = '${selectedDate.toUtc().toIso8601String().split('T')[0]}T00:00:00Z';

    isPaymentRequestLoading.value = true;

    try {
      final token = await SecureStorageService().read(AppConstants.accessToken);
      if (token == null || token.isEmpty) {
        Get.snackbar("Auth Error", "Session expired. Please log in again.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final body = {
        'completionDate': completionDateIso,
        'duration': duration.toInt().toString(), // API expects string "10", not number
      };

      log("📤 Requesting payment with body: $body");

      final response = await _networkCaller.putRequest(
        AppUrl.providerRequestPayment(idToUse),
        body: body,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess) {
        Get.snackbar(
          "Success",
          "Payment request submitted successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

        // Navigate directly to SvpBookingsScreen and pass initial tab index
        Get.offAll(
              () => SvpBookingsScreen(),
          arguments: {'initialTabIndex': 2},
        );
      }
      else {
        String errorMsg = response.errorMessage ?? "Failed to submit payment request";
        if (response.jsonResponse?['message'] != null) {
          errorMsg = response.jsonResponse!['message'].toString();
        }
        Get.snackbar("Error", errorMsg,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e, stackTrace) {
      log("❌ Payment request error: $e", error: e, stackTrace: stackTrace);
      Get.snackbar("Error", "Failed to submit: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isPaymentRequestLoading.value = false;
    }
  }

  /// ================== LIFECYCLE ==================

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
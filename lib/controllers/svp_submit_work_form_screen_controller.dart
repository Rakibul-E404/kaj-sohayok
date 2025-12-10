/**
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../features/service_provider/svp_submit_work_form/model/media_file.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../utilities/app_url.dart';
import '../features/normal_user/work_completed_details/model/additional_cost_model.dart';

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

  // API Data
  RxString address = ''.obs;
  RxString bookingDateTime = ''.obs;
  RxDouble initialCost = 0.0.obs;
  RxList<ApiAttachment> apiAttachments = <ApiAttachment>[].obs;
  RxList<AdditionalCostModel> additionalCosts = <AdditionalCostModel>[].obs;

  // Combined media files (both images and videos)
  RxList<MediaFile> mediaFiles = <MediaFile>[].obs;

  @override
  void onInit() {
    super.onInit();

    log("╔════════════════════════════════════════╗");
    log("║  CONTROLLER INIT STARTED               ║");
    log("╚════════════════════════════════════════╝");

    // Get all arguments
    final args = Get.arguments;

    if (args != null && args is Map) {
      // Get bookingId
      bookingId.value = args['bookingId']?.toString();

      log("📋 Arguments received:");
      log("   - bookingId: ${bookingId.value}");
      log("   - Has formData: ${args['formData'] != null}");
      log("   - Has serviceBooking: ${args['serviceBooking'] != null}");
      log("   - Has additionalCosts: ${args['additionalCosts'] != null}");

      // Check if we have formData passed from the previous screen
      if (args['formData'] != null) {
        log("✓ Using formData from arguments");
        _parseFormData(args['formData']);
      } else if (args['serviceBooking'] != null) {
        log("✓ Using serviceBooking from arguments");
        _parseServiceBookingData(args['serviceBooking'], args['additionalCosts']);
      } else if (bookingId.value != null && bookingId.value!.isNotEmpty) {
        log("✓ Fetching work details from API");
        loadWorkDetails();
      } else {
        log("✗ No valid data source found");
        Get.snackbar(
          "Error",
          "No booking data available",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      log("✗ No arguments provided");
      Get.snackbar(
        "Error",
        "No booking information provided",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Parse form data that was already fetched
  void _parseFormData(Map<String, dynamic> formData) {
    try {
      log("\n╔════════════════════════════════════════╗");
      log("║  PARSING FORM DATA                     ║");
      log("╚════════════════════════════════════════╝");

      log("Full formData: ${jsonEncode(formData)}");

      final serviceBooking = formData['serviceBooking'];
      final additionalCostsData = formData['additionalCosts'];

      log("ServiceBooking exists: ${serviceBooking != null}");
      log("AdditionalCosts exists: ${additionalCostsData != null}");

      _parseServiceBookingData(serviceBooking, additionalCostsData);

    } catch (e, stackTrace) {
      log("✗ Error parsing form data: $e", error: e, stackTrace: stackTrace);
      Get.snackbar(
        "Error",
        "Failed to parse work details",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Parse service booking data
  void _parseServiceBookingData(dynamic serviceBookingData, dynamic additionalCostsData) {
    try {
      log("\n╔════════════════════════════════════════╗");
      log("║  PARSING SERVICE BOOKING DATA          ║");
      log("╚════════════════════════════════════════╝");

      if (serviceBookingData == null) {
        log("✗ Service booking data is null!");
        Get.snackbar(
          "Error",
          "No service booking data found",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      log("Service Booking Data Type: ${serviceBookingData.runtimeType}");
      log("Service Booking Raw: ${jsonEncode(serviceBookingData)}");

      // Get address
      final addressMap = serviceBookingData['address'] ?? {};
      if (addressMap is Map<String, dynamic>) {
        address.value = addressMap['en'] ?? addressMap['bn'] ?? '';
      } else {
        address.value = serviceBookingData['address']?.toString() ?? '';
      }
      log("✓ Address parsed: ${address.value}");

      // Format booking date
      if (serviceBookingData['bookingDateTime'] != null) {
        try {
          final bookingDate = DateTime.parse(serviceBookingData['bookingDateTime'].toString());
          bookingDateTime.value = '${bookingDate.day}-${bookingDate.month}-${bookingDate.year} ${bookingDate.hour}:${bookingDate.minute}';
          log("✓ Booking DateTime parsed: ${bookingDateTime.value}");
        } catch (e) {
          log("✗ Error parsing date: $e");
          bookingDateTime.value = serviceBookingData['bookingDateTime'].toString();
        }
      } else {
        bookingDateTime.value = '';
        log("⚠ No booking date time found");
      }

      // Parse initial cost
      try {
        if (serviceBookingData['startPrice'] != null) {
          initialCost.value = double.parse(serviceBookingData['startPrice'].toString());
          log("✓ Initial Cost parsed: ${initialCost.value}");
        } else {
          initialCost.value = 0.0;
          log("⚠ No start price found");
        }
      } catch (e) {
        log("✗ Error parsing initial cost: $e");
        initialCost.value = 0.0;
      }

      // Parse API attachments
      log("\n--- PARSING ATTACHMENTS ---");
      apiAttachments.clear();

      final attachmentsData = serviceBookingData['attachments'];
      log("Attachments field exists: ${attachmentsData != null}");
      log("Attachments type: ${attachmentsData?.runtimeType}");

      if (attachmentsData != null && attachmentsData is List) {
        log("Attachments is a List with ${attachmentsData.length} items");

        for (var i = 0; i < attachmentsData.length; i++) {
          final attachment = attachmentsData[i];
          log("\nAttachment [$i]:");
          log("  Type: ${attachment?.runtimeType}");
          log("  Raw: ${jsonEncode(attachment)}");

          if (attachment is Map<String, dynamic>) {
            final url = attachment['attachment']?.toString() ?? '';
            final type = attachment['attachmentType']?.toString() ?? 'image';
            final id = attachment['_attachmentId']?.toString() ?? 'attachment_$i';

            log("  ✓ Parsed:");
            log("    - URL: $url");
            log("    - Type: $type");
            log("    - ID: $id");

            if (url.isNotEmpty) {
              final apiAttachment = ApiAttachment(
                url: url,
                type: type,
                id: id,
              );
              apiAttachments.add(apiAttachment);
              log("  ✓ Added to apiAttachments list");
            } else {
              log("  ✗ URL is empty, skipping");
            }
          } else {
            log("  ✗ Not a Map, skipping");
          }
        }
        log("\n✓ Total API Attachments added: ${apiAttachments.length}");
      } else {
        log("✗ Attachments is null or not a List");
      }

      // Parse additional costs
      log("\n--- PARSING ADDITIONAL COSTS ---");
      additionalCosts.clear();

      log("AdditionalCosts field exists: ${additionalCostsData != null}");
      log("AdditionalCosts type: ${additionalCostsData?.runtimeType}");

      if (additionalCostsData != null && additionalCostsData is List) {
        log("AdditionalCosts is a List with ${additionalCostsData.length} items");

        for (var i = 0; i < additionalCostsData.length; i++) {
          final cost = additionalCostsData[i];
          log("\nAdditional Cost [$i]:");
          log("  Type: ${cost?.runtimeType}");
          log("  Raw: ${jsonEncode(cost)}");

          if (cost is Map<String, dynamic>) {
            final costName = cost['costName']?.toString() ?? 'Additional Cost ${i + 1}';
            final costPrice = double.tryParse(cost['price']?.toString() ?? '0') ?? 0.0;

            log("  ✓ Parsed:");
            log("    - Name: $costName");
            log("    - Price: $costPrice");

            final additionalCost = AdditionalCostModel(
              title: costName,
              price: costPrice,
            );
            additionalCosts.add(additionalCost);
            log("  ✓ Added to additionalCosts list");
          } else {
            log("  ✗ Not a Map, skipping");
          }
        }
        log("\n✓ Total Additional Costs added: ${additionalCosts.length}");
      } else {
        log("✗ AdditionalCosts is null or not a List");
      }

      log("\n╔════════════════════════════════════════╗");
      log("║  PARSING COMPLETE - SUMMARY            ║");
      log("╚════════════════════════════════════════╝");
      log("✓ Address: ${address.value}");
      log("✓ DateTime: ${bookingDateTime.value}");
      log("✓ Initial Cost: \$${initialCost.value}");
      log("✓ API Attachments: ${apiAttachments.length}");
      log("✓ Additional Costs: ${additionalCosts.length}");
      log("✓ Total Payment: \$${calculateTotalPayment()}");

      // Force UI update
      update();

      // Double check the values are actually set
      Future.delayed(Duration(milliseconds: 100), () {
        log("\n--- POST-UPDATE CHECK ---");
        log("apiAttachments.length in observable: ${apiAttachments.length}");
        log("additionalCosts.length in observable: ${additionalCosts.length}");

        if (apiAttachments.isNotEmpty) {
          log("First attachment URL: ${apiAttachments[0].url}");
        }

        if (additionalCosts.isNotEmpty) {
          log("First additional cost: ${additionalCosts[0].title} - \$${additionalCosts[0].price}");
        }
      });

    } catch (e, stackTrace) {
      log("✗✗✗ CRITICAL ERROR parsing service booking data: $e");
      log("StackTrace: $stackTrace");
      Get.snackbar(
        "Error",
        "Failed to parse work details: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Load work details from API
  Future<void> loadWorkDetails() async {
    if (bookingId.value == null || bookingId.value!.isEmpty) {
      Get.snackbar(
        "Error",
        "No booking ID found",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoadingWorkDetails.value = true;
    try {
      log("\n╔════════════════════════════════════════╗");
      log("║  LOADING WORK DETAILS FROM API         ║");
      log("╚════════════════════════════════════════╝");
      log("Booking ID: ${bookingId.value}");

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.providerWorkSubmitForm(bookingId.value!),
      );

      log("API Response Status: ${response.statusCode}");
      log("API Response Success: ${response.isSuccess}");

      if (response.jsonResponse != null) {
        log("API Response Body: ${jsonEncode(response.jsonResponse)}");
      }

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        // Check response structure
        if (responseData['code'] == 200 &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null) {

          final attributes = responseData['data']['attributes'];
          log("✓ Attributes found");

          // Use the parsing method
          _parseServiceBookingData(
              attributes['serviceBooking'],
              attributes['additionalCosts']
          );

        } else {
          log("✗ Unexpected response structure");
          Get.snackbar(
            "Error",
            "Unexpected response format",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          response.errorMessage ?? "Failed to load work details",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      log("✗✗✗ CRITICAL ERROR loading work details: $e");
      log("StackTrace: $stackTrace");
      Get.snackbar(
        "Error",
        "Failed to load work details: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingWorkDetails.value = false;
    }
  }

  /// Get image URL - handles both local paths and API URLs
  String getImageUrl(String path) {
    if (path.isEmpty) return '';

    if (path.contains('amazonaws.com') || path.startsWith('http')) {
      return path;
    } else if (path.startsWith('/')) {
      return '${AppUrl.imageBaseUrl}$path';
    } else {
      return path;
    }
  }

  /// Pick images and videos from gallery
  Future<void> pickMediaFromGallery() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (files.isNotEmpty) {
        for (var file in files) {
          final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mov') ||
              file.path.toLowerCase().endsWith('.avi') ||
              file.path.toLowerCase().endsWith('.mkv');

          final mediaFile = MediaFile(
            path: file.path,
            isVideo: isVideo,
          );

          mediaFiles.add(mediaFile);
          log("${isVideo ? 'Video' : 'Image'} added: ${file.path}");
        }

        Get.snackbar(
          "Success",
          "${files.length} file(s) added",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log("Error picking files: $e");
      Get.snackbar(
        "Error",
        "Failed to pick files: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Pick photo from camera
  Future<void> pickPhotoFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        mediaFiles.add(MediaFile(path: image.path, isVideo: false));
        log("Photo added from camera: ${image.path}");
        Get.snackbar("Success", "Photo captured successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      log("Error capturing photo: $e");
      Get.snackbar("Error", "Failed to capture photo: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// Pick video from camera
  Future<void> pickVideoFromCamera() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10),
      );

      if (video != null) {
        mediaFiles.add(MediaFile(path: video.path, isVideo: true));
        log("Video recorded from camera: ${video.path}");
        Get.snackbar("Success", "Video recorded successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      log("Error recording video: $e");
      Get.snackbar("Error", "Failed to record video: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// Show media source selection dialog
  void showMediaSourceDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Proof Files",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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

  /// Remove specific media file
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

  /// Remove API attachment
  Future<void> removeApiAttachment(int index) async {
    if (index >= 0 && index < apiAttachments.length) {
      log("Removing API attachment at index $index");
      apiAttachments.removeAt(index);
      log("API attachments remaining: ${apiAttachments.length}");
      update();
    }
  }

  /// Clear all media files
  Future<void> clearAllMediaFiles() async {
    for (var mediaFile in mediaFiles) {
      if (mediaFile.isVideo && mediaFile.videoController != null) {
        mediaFile.videoController!.dispose();
      }
    }
    mediaFiles.clear();
    log("All media files cleared");
  }

  int get totalImageCount =>
      mediaFiles.where((file) => !file.isVideo).length + apiAttachments.length;

  int get videoCount => mediaFiles.where((file) => file.isVideo).length;

  int get totalMediaCount => mediaFiles.length + apiAttachments.length;

  List<File> getNewFilesForSubmission() {
    return mediaFiles
        .where((file) => !file.isVideo)
        .map((file) => File(file.path))
        .toList();
  }

  /// Submit work form
  Future<void> submitWorkForm() async {
    if (bookingId.value == null || bookingId.value!.isEmpty) {
      Get.snackbar("Error", "No booking ID found",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (completionDateController.text.isEmpty) {
      Get.snackbar("Error", "Please select completion date",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (durationTimeController.text.isEmpty) {
      Get.snackbar("Error", "Please enter duration time",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final Map<String, dynamic> body = {
        'completionDate': completionDateController.text,
        'duration': durationTimeController.text,
        'additionalCosts': additionalCosts
            .map((cost) => {'costName': cost.title, 'price': cost.price})
            .toList(),
      };

      final Map<String, File> files = {};
      int fileIndex = 0;

      for (var mediaFile in mediaFiles) {
        if (!mediaFile.isVideo) {
          files['attachment_$fileIndex'] = File(mediaFile.path);
          fileIndex++;
        }
      }

      NetworkResponse response;
      if (files.isNotEmpty) {
        response = await _networkCaller.multipartRequest2(
          AppUrl.providerWorkSubmitForm(bookingId.value!),
          body: body,
          files: files,
          method: 'PATCH',
        );
      } else {
        response = await _networkCaller.patchRequest(
          AppUrl.providerWorkSubmitForm(bookingId.value!),
          body: body,
        );
      }

      if (response.isSuccess) {
        Get.snackbar("Success", "Work form submitted successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
        completionDateController.clear();
        durationTimeController.clear();
        mediaFiles.clear();
        Future.delayed(Duration(seconds: 2), () => Get.back(result: true));
      } else {
        Get.snackbar("Error",
            response.errorMessage ?? "Failed to submit work form",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      log("Error submitting work form: $e");
      Get.snackbar("Error", "Failed to submit work form: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  double calculateTotalPayment() {
    double total = initialCost.value;
    for (var cost in additionalCosts) {
      total += cost.price;
    }
    return total;
  }

  void addAdditionalCost(String name, double price) {
    log("Adding additional cost: $name = \$$price");
    additionalCosts.add(AdditionalCostModel(title: name, price: price));
    log("Total additional costs: ${additionalCosts.length}");
    update();
  }

  void removeAdditionalCost(int index) {
    if (index >= 0 && index < additionalCosts.length) {
      additionalCosts.removeAt(index);
      update();
    }
  }

  @override
  void onClose() {
    completionDateController.dispose();
    durationTimeController.dispose();
    for (var mediaFile in mediaFiles) {
      if (mediaFile.isVideo && mediaFile.videoController != null) {
        mediaFile.videoController!.dispose();
      }
    }
    mediaFiles.clear();
    super.onClose();
  }
}

/// Data Models
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



*/








///
///
///
///
/// todO:: fixing the error
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
import '../features/normal_user/work_completed_details/model/additional_cost_model.dart';
import '../features/service_provider/svp_submit_work_form/model/media_file.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../utilities/app_url.dart';
// import '../features/normal_at_user/work_completed_details/model/additional_cost_model.dart'; // Fix typo if needed ("normal_at_user" → "normal_user")

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
  RxBool isPaymentRequestLoading = false.obs; // ✅ ADDED

  // API Data
  RxString address = ''.obs;
  RxString bookingDateTime = ''.obs;
  RxDouble initialCost = 0.0.obs;
  RxList<ApiAttachment> apiAttachments = <ApiAttachment>[].obs;
  RxList<AdditionalCostModel> additionalCosts = <AdditionalCostModel>[].obs;

  // Combined media files (both images and videos)
  RxList<MediaFile> mediaFiles = <MediaFile>[].obs;

  @override
  void onInit() {
    super.onInit();

    log("╔════════════════════════════════════════╗");
    log("║  CONTROLLER INIT STARTED               ║");
    log("╚════════════════════════════════════════╝");

    // Get all arguments
    final args = Get.arguments;

    if (args != null && args is Map) {
      bookingId.value = args['bookingId']?.toString();

      log("📋 Arguments received:");
      log("   - bookingId: ${bookingId.value}");
      log("   - Has formData: ${args['formData'] != null}");
      log("   - Has serviceBooking: ${args['serviceBooking'] != null}");
      log("   - Has additionalCosts: ${args['additionalCosts'] != null}");

      if (args['formData'] != null) {
        log("✓ Using formData from arguments");
        _parseFormData(args['formData']);
      } else if (args['serviceBooking'] != null) {
        log("✓ Using serviceBooking from arguments");
        _parseServiceBookingData(args['serviceBooking'], args['additionalCosts']);
      } else if (bookingId.value != null && bookingId.value!.isNotEmpty) {
        log("✓ Fetching work details from API");
        loadWorkDetails();
      } else {
        log("✗ No valid data source found");
        Get.snackbar(
          "Error",
          "No booking data available",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      log("✗ No arguments provided");
      Get.snackbar(
        "Error",
        "No booking information provided",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _parseFormData(Map<String, dynamic> formData) {
    try {
      log("\n╔════════════════════════════════════════╗");
      log("║  PARSING FORM DATA                     ║");
      log("╚════════════════════════════════════════╝");

      log("Full formData: ${jsonEncode(formData)}");

      final serviceBooking = formData['serviceBooking'];
      final additionalCostsData = formData['additionalCosts'];

      log("ServiceBooking exists: ${serviceBooking != null}");
      log("AdditionalCosts exists: ${additionalCostsData != null}");

      _parseServiceBookingData(serviceBooking, additionalCostsData);

    } catch (e, stackTrace) {
      log("✗ Error parsing form data: $e", error: e, stackTrace: stackTrace);
      Get.snackbar(
        "Error",
        "Failed to parse work details",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _parseServiceBookingData(dynamic serviceBookingData, dynamic additionalCostsData) {
    try {
      log("\n╔════════════════════════════════════════╗");
      log("║  PARSING SERVICE BOOKING DATA          ║");
      log("╚════════════════════════════════════════╝");

      if (serviceBookingData == null) {
        log("✗ Service booking data is null!");
        Get.snackbar(
          "Error",
          "No service booking data found",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      log("Service Booking Data Type: ${serviceBookingData.runtimeType}");
      log("Service Booking Raw: ${jsonEncode(serviceBookingData)}");

      final addressMap = serviceBookingData['address'] ?? {};
      if (addressMap is Map<String, dynamic>) {
        address.value = addressMap['en'] ?? addressMap['bn'] ?? '';
      } else {
        address.value = serviceBookingData['address']?.toString() ?? '';
      }
      log("✓ Address parsed: ${address.value}");

      if (serviceBookingData['bookingDateTime'] != null) {
        try {
          final bookingDate = DateTime.parse(serviceBookingData['bookingDateTime'].toString());
          bookingDateTime.value = '${bookingDate.day}-${bookingDate.month}-${bookingDate.year} ${bookingDate.hour}:${bookingDate.minute}';
          log("✓ Booking DateTime parsed: ${bookingDateTime.value}");
        } catch (e) {
          log("✗ Error parsing date: $e");
          bookingDateTime.value = serviceBookingData['bookingDateTime'].toString();
        }
      } else {
        bookingDateTime.value = '';
        log("⚠ No booking date time found");
      }

      try {
        if (serviceBookingData['startPrice'] != null) {
          initialCost.value = double.parse(serviceBookingData['startPrice'].toString());
          log("✓ Initial Cost parsed: ${initialCost.value}");
        } else {
          initialCost.value = 0.0;
          log("⚠ No start price found");
        }
      } catch (e) {
        log("✗ Error parsing initial cost: $e");
        initialCost.value = 0.0;
      }

      log("\n--- PARSING ATTACHMENTS ---");
      apiAttachments.clear();

      final attachmentsData = serviceBookingData['attachments'];
      log("Attachments field exists: ${attachmentsData != null}");
      log("Attachments type: ${attachmentsData?.runtimeType}");

      if (attachmentsData != null && attachmentsData is List) {
        log("Attachments is a List with ${attachmentsData.length} items");

        for (var i = 0; i < attachmentsData.length; i++) {
          final attachment = attachmentsData[i];
          log("\nAttachment [$i]:");
          log("  Type: ${attachment?.runtimeType}");
          log("  Raw: ${jsonEncode(attachment)}");

          if (attachment is Map<String, dynamic>) {
            final url = attachment['attachment']?.toString() ?? '';
            final type = attachment['attachmentType']?.toString() ?? 'image';
            final id = attachment['_attachmentId']?.toString() ?? 'attachment_$i';

            log("  ✓ Parsed:");
            log("    - URL: $url");
            log("    - Type: $type");
            log("    - ID: $id");

            if (url.isNotEmpty) {
              final apiAttachment = ApiAttachment(
                url: url,
                type: type,
                id: id,
              );
              apiAttachments.add(apiAttachment);
              log("  ✓ Added to apiAttachments list");
            } else {
              log("  ✗ URL is empty, skipping");
            }
          } else {
            log("  ✗ Not a Map, skipping");
          }
        }
        log("\n✓ Total API Attachments added: ${apiAttachments.length}");
      } else {
        log("✗ Attachments is null or not a List");
      }

      log("\n--- PARSING ADDITIONAL COSTS ---");
      additionalCosts.clear();

      log("AdditionalCosts field exists: ${additionalCostsData != null}");
      log("AdditionalCosts type: ${additionalCostsData?.runtimeType}");

      if (additionalCostsData != null && additionalCostsData is List) {
        log("AdditionalCosts is a List with ${additionalCostsData.length} items");

        for (var i = 0; i < additionalCostsData.length; i++) {
          final cost = additionalCostsData[i];
          log("\nAdditional Cost [$i]:");
          log("  Type: ${cost?.runtimeType}");
          log("  Raw: ${jsonEncode(cost)}");

          if (cost is Map<String, dynamic>) {
            final costName = cost['costName']?.toString() ?? 'Additional Cost ${i + 1}';
            final costPrice = double.tryParse(cost['price']?.toString() ?? '0') ?? 0.0;

            log("  ✓ Parsed:");
            log("    - Name: $costName");
            log("    - Price: $costPrice");

            final additionalCost = AdditionalCostModel(
              title: costName,
              price: costPrice,
            );
            additionalCosts.add(additionalCost);
            log("  ✓ Added to additionalCosts list");
          } else {
            log("  ✗ Not a Map, skipping");
          }
        }
        log("\n✓ Total Additional Costs added: ${additionalCosts.length}");
      } else {
        log("✗ AdditionalCosts is null or not a List");
      }

      log("\n╔════════════════════════════════════════╗");
      log("║  PARSING COMPLETE - SUMMARY            ║");
      log("╚════════════════════════════════════════╝");
      log("✓ Address: ${address.value}");
      log("✓ DateTime: ${bookingDateTime.value}");
      log("✓ Initial Cost: \$${initialCost.value}");
      log("✓ API Attachments: ${apiAttachments.length}");
      log("✓ Additional Costs: ${additionalCosts.length}");
      log("✓ Total Payment: \$${calculateTotalPayment()}");

      update();

      Future.delayed(Duration(milliseconds: 100), () {
        log("\n--- POST-UPDATE CHECK ---");
        log("apiAttachments.length in observable: ${apiAttachments.length}");
        log("additionalCosts.length in observable: ${additionalCosts.length}");
      });

    } catch (e, stackTrace) {
      log("✗✗✗ CRITICAL ERROR parsing service booking data: $e");
      log("StackTrace: $stackTrace");
      Get.snackbar(
        "Error",
        "Failed to parse work details: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> loadWorkDetails() async {
    if (bookingId.value == null || bookingId.value!.isEmpty) {
      Get.snackbar(
        "Error",
        "No booking ID found",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoadingWorkDetails.value = true;
    try {
      log("\n╔════════════════════════════════════════╗");
      log("║  LOADING WORK DETAILS FROM API         ║");
      log("╚════════════════════════════════════════╝");
      log("Booking ID: ${bookingId.value}");

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.providerWorkSubmitForm(bookingId.value!),
      );

      log("API Response Status: ${response.statusCode}");
      log("API Response Success: ${response.isSuccess}");

      if (response.jsonResponse != null) {
        log("API Response Body: ${jsonEncode(response.jsonResponse)}");
      }

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['code'] == 200 &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null) {

          final attributes = responseData['data']['attributes'];
          log("✓ Attributes found");

          _parseServiceBookingData(
              attributes['serviceBooking'],
              attributes['additionalCosts']
          );

        } else {
          log("✗ Unexpected response structure");
          Get.snackbar(
            "Error",
            "Unexpected response format",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          response.errorMessage ?? "Failed to load work details",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      log("✗✗✗ CRITICAL ERROR loading work details: $e");
      log("StackTrace: $stackTrace");
      Get.snackbar(
        "Error",
        "Failed to load work details: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingWorkDetails.value = false;
    }
  }

  String getImageUrl(String path) {
    if (path.isEmpty) return '';

    if (path.contains('amazonaws.com') || path.startsWith('http')) {
      return path;
    } else if (path.startsWith('/')) {
      return '${AppUrl.imageBaseUrl}$path';
    } else {
      return path;
    }
  }

  Future<void> pickMediaFromGallery() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (files.isNotEmpty) {
        for (var file in files) {
          final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mov') ||
              file.path.toLowerCase().endsWith('.avi') ||
              file.path.toLowerCase().endsWith('.mkv');

          final mediaFile = MediaFile(
            path: file.path,
            isVideo: isVideo,
          );

          mediaFiles.add(mediaFile);
          log("${isVideo ? 'Video' : 'Image'} added: ${file.path}");
        }

        Get.snackbar(
          "Success",
          "${files.length} file(s) added",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log("Error picking files: $e");
      Get.snackbar(
        "Error",
        "Failed to pick files: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickPhotoFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        mediaFiles.add(MediaFile(path: image.path, isVideo: false));
        log("Photo added from camera: ${image.path}");
        Get.snackbar("Success", "Photo captured successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      log("Error capturing photo: $e");
      Get.snackbar("Error", "Failed to capture photo: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> pickVideoFromCamera() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10),
      );

      if (video != null) {
        mediaFiles.add(MediaFile(path: video.path, isVideo: true));
        log("Video recorded from camera: ${video.path}");
        Get.snackbar("Success", "Video recorded successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      log("Error recording video: $e");
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Proof Files",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
      log("Removing API attachment at index $index");
      apiAttachments.removeAt(index);
      log("API attachments remaining: ${apiAttachments.length}");
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
    log("All media files cleared");
  }

  int get totalImageCount =>
      mediaFiles.where((file) => !file.isVideo).length + apiAttachments.length;

  int get videoCount => mediaFiles.where((file) => file.isVideo).length;

  int get totalMediaCount => mediaFiles.length + apiAttachments.length;

  List<File> getNewFilesForSubmission() {
    return mediaFiles
        .where((file) => !file.isVideo)
        .map((file) => File(file.path))
        .toList();
  }

  Future<void> submitWorkForm() async {
    if (bookingId.value == null || bookingId.value!.isEmpty) {
      Get.snackbar("Error", "No booking ID found",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (completionDateController.text.isEmpty) {
      Get.snackbar("Error", "Please select completion date",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (durationTimeController.text.isEmpty) {
      Get.snackbar("Error", "Please enter duration time",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final Map<String, dynamic> body = {
        'completionDate': completionDateController.text,
        'duration': durationTimeController.text,
        'additionalCosts': additionalCosts
            .map((cost) => {'costName': cost.title, 'price': cost.price})
            .toList(),
      };

      final Map<String, File> files = {};
      int fileIndex = 0;

      for (var mediaFile in mediaFiles) {
        if (!mediaFile.isVideo) {
          files['attachment_$fileIndex'] = File(mediaFile.path);
          fileIndex++;
        }
      }

      NetworkResponse response;
      if (files.isNotEmpty) {
        response = await _networkCaller.multipartRequest2(
          AppUrl.providerWorkSubmitForm(bookingId.value!),
          body: body,
          files: files,
          method: 'PATCH',
        );
      } else {
        response = await _networkCaller.patchRequest(
          AppUrl.providerWorkSubmitForm(bookingId.value!),
          body: body,
        );
      }

      if (response.isSuccess) {
        Get.snackbar("Success", "Work form submitted successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
        completionDateController.clear();
        durationTimeController.clear();
        mediaFiles.clear();
        Future.delayed(Duration(seconds: 2), () => Get.back(result: true));
      } else {
        Get.snackbar("Error",
            response.errorMessage ?? "Failed to submit work form",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      log("Error submitting work form: $e");
      Get.snackbar("Error", "Failed to submit work form: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  double calculateTotalPayment() {
    double total = initialCost.value;
    for (var cost in additionalCosts) {
      total += cost.price;
    }
    return total;
  }

  void addAdditionalCost(String name, double price) {
    log("Adding additional cost: $name = \$$price");
    additionalCosts.add(AdditionalCostModel(title: name, price: price));
    log("Total additional costs: ${additionalCosts.length}");
    update();
  }

  void removeAdditionalCost(int index) {
    if (index >= 0 && index < additionalCosts.length) {
      additionalCosts.removeAt(index);
      update();
    }
  }

  // ✅ NEW METHOD: Request Payment
  Future<void> requestPayment() async {
    if (bookingId.value == null || bookingId.value!.isEmpty) {
      Get.snackbar("Error", "No booking ID found",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isPaymentRequestLoading.value = true;
    try {
      // 👇 Replace with real API when ready
      await Future.delayed(Duration(seconds: 1)); // Mock delay

      Get.snackbar("Success", "Payment request sent successfully!",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      log("Error requesting payment: $e");
      Get.snackbar("Error", "Failed to request payment: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isPaymentRequestLoading.value = false;
    }
  }

  @override
  void onClose() {
    completionDateController.dispose();
    durationTimeController.dispose();
    for (var mediaFile in mediaFiles) {
      if (mediaFile.isVideo && mediaFile.videoController != null) {
        mediaFile.videoController!.dispose();
      }
    }
    mediaFiles.clear();
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




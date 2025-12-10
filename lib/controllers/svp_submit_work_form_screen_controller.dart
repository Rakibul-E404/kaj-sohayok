/**
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

  // Completion trackers (for UI "Done" buttons)
  RxBool isMediaCompleted = false.obs;
  RxBool isPaymentCompleted = false.obs;

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

    final args = Get.arguments;

    if (args != null && args is Map) {
      bookingId.value = args['bookingId']?.toString();

      log("📋 Arguments received:");
      log("   - bookingId: ${bookingId.value}");
      log("   - Has formData: ${args['formData'] != null}");
      log("   - Has serviceBooking: ${args['serviceBooking'] != null}");
      log("   - Has additionalCosts: ${args['additionalCosts'] != null}");

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
      log("\n╔════════════════════════════════════════╗");
      log("║  PARSING FORM DATA                     ║");
      log("╚════════════════════════════════════════╝");
      final serviceBooking = formData['serviceBooking'];
      final additionalCostsData = formData['additionalCosts'];
      _parseServiceBookingData(serviceBooking, additionalCostsData);
    } catch (e, stackTrace) {
      log("✗ Error parsing form data: $e", error: e, stackTrace: stackTrace);
      Get.snackbar("Error", "Failed to parse work details",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _parseServiceBookingData(dynamic serviceBookingData, dynamic additionalCostsData) {
    try {
      log("\n╔════════════════════════════════════════╗");
      log("║  PARSING SERVICE BOOKING DATA          ║");
      log("╚════════════════════════════════════════╝");

      if (serviceBookingData == null) {
        Get.snackbar("Error", "No service booking data found",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final addressMap = serviceBookingData['address'] ?? {};
      if (addressMap is Map<String, dynamic>) {
        address.value = addressMap['en'] ?? addressMap['bn'] ?? '';
      } else {
        address.value = serviceBookingData['address']?.toString() ?? '';
      }

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

      initialCost.value = double.tryParse(serviceBookingData['startPrice']?.toString() ?? '0') ?? 0.0;

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

      additionalCosts.clear();
      if (additionalCostsData != null && additionalCostsData is List) {
        for (final cost in additionalCostsData) {
          if (cost is Map<String, dynamic>) {
            final costName = cost['costName']?.toString() ?? 'Additional Cost';
            final costPrice = double.tryParse(cost['price']?.toString() ?? '0') ?? 0.0;
            additionalCosts.add(AdditionalCostModel(title: costName, price: costPrice));
          }
        }
      }

      update();
    } catch (e, stackTrace) {
      log("✗✗✗ CRITICAL ERROR: $e", error: e, stackTrace: stackTrace);
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
      log("✗✗✗ LOAD ERROR: $e", error: e, stackTrace: stackTrace);
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

  // ================== COST HANDLING ==================

  double calculateTotalPayment() {
    double total = initialCost.value;
    for (var cost in additionalCosts) {
      total += cost.price;
    }
    return total;
  }

  void addAdditionalCost(String name, double price) {
    additionalCosts.add(AdditionalCostModel(title: name, price: price));
    update();
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
      Get.snackbar("Warning", "Please select completion date",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (durationTimeController.text.isEmpty) {
      Get.snackbar("Warning", "Please enter duration time",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isPaymentRequestLoading.value = true;

    try {
      // STEP 1: Upload NEW proof files (PUT)
      if (mediaFiles.isNotEmpty) {
        final Map<String, File> files = {};
        int index = 0;
        for (final mediaFile in mediaFiles) {
          if (!mediaFile.isVideo) {
            files['attachment_$index'] = File(mediaFile.path);
            index++;
          }
        }

        if (files.isNotEmpty) {
          final NetworkResponse uploadResponse = await _networkCaller.multipartPutRequest(
            AppUrl.addNewProofFile(bookingId.value!),
            files: files,
          );

          if (!uploadResponse.isSuccess) {
            final errorMsg = uploadResponse.errorMessage ?? "Failed to upload proof files";
            Get.snackbar("Upload Failed", errorMsg,
                backgroundColor: Colors.red, colorText: Colors.white);
            return;
          }
          log("✅ Proof files uploaded");
        }
      }

      // STEP 2: Submit additional costs (POST)
      if (additionalCosts.isNotEmpty) {
        for (final cost in additionalCosts) {
          final costBody = {
            'serviceBookingId': bookingId.value!,
            'costName': cost.title,
            'price': cost.price.toString(),
          };

          final NetworkResponse costResponse = await _networkCaller.postRequest(
            AppUrl.addNewCost(bookingId.value!),
            body: costBody,
          );

          if (!costResponse.isSuccess) {
            final errorMsg = costResponse.errorMessage ?? "Failed to add cost: ${cost.title}";
            Get.snackbar("Cost Failed", errorMsg,
                backgroundColor: Colors.red, colorText: Colors.white);
            return;
          }
          log("✅ Cost added: ${cost.title}");
        }
      }

      // SUCCESS
      Get.snackbar("Success", "Payment request submitted successfully!",
          backgroundColor: Colors.green, colorText: Colors.white, duration: Duration(seconds: 3));

      Future.delayed(Duration(seconds: 1), () {
        Get.back(result: true);
      });

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
}*/






///
///
///
/// todo:: the done button api
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

      // Parse address
      final addressMap = serviceBookingData['address'] ?? {};
      if (addressMap is Map<String, dynamic>) {
        address.value = addressMap['en'] ?? addressMap['bn'] ?? '';
      } else {
        address.value = serviceBookingData['address']?.toString() ?? '';
      }

      // Parse booking date time
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

      // Parse initial cost
      initialCost.value = double.tryParse(serviceBookingData['startPrice']?.toString() ?? '0') ?? 0.0;

      // Parse existing attachments
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

      // Parse additional costs
      additionalCosts.clear();
      if (additionalCostsData != null && additionalCostsData is List) {
        for (final cost in additionalCostsData) {
          if (cost is Map<String, dynamic>) {
            final costName = cost['costName']?.toString() ?? 'Additional Cost';
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

  // ================== COST HANDLING ==================

  double calculateTotalPayment() {
    double total = initialCost.value;
    for (var cost in additionalCosts) {
      total += cost.price;
    }
    return total;
  }

  void addAdditionalCost(String name, double price) {
    additionalCosts.add(AdditionalCostModel(title: name, price: price));
    update();
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

    // Validate required fields
    if (completionDateController.text.isEmpty) {
      Get.snackbar("Warning", "Please select completion date",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (durationTimeController.text.isEmpty) {
      Get.snackbar("Warning", "Please enter duration time",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // Validate duration is a number
    final duration = double.tryParse(durationTimeController.text);
    if (duration == null) {
      Get.snackbar("Warning", "Please enter a valid number for duration",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isPaymentRequestLoading.value = true;

    try {
      // STEP 1: Upload NEW proof files (PUT) - only images
      if (mediaFiles.isNotEmpty) {
        final Map<String, File> files = {};
        int index = 0;

        // Filter only image files (not videos)
        final imageFiles = mediaFiles.where((file) => !file.isVideo).toList();

        for (final mediaFile in imageFiles) {
          files['attachment_$index'] = File(mediaFile.path);
          index++;
        }

        if (files.isNotEmpty) {
          log("Uploading ${files.length} proof files...");
          final NetworkResponse uploadResponse = await _networkCaller.multipartPutRequest(
            AppUrl.addNewProofFile(bookingId.value!),
            files: files,
          );

          if (!uploadResponse.isSuccess) {
            final errorMsg = uploadResponse.errorMessage ?? "Failed to upload proof files";
            Get.snackbar("Upload Failed", errorMsg,
                backgroundColor: Colors.red, colorText: Colors.white);
            isPaymentRequestLoading.value = false;
            return;
          }
          log("✅ Proof files uploaded successfully");
        }
      }

      // STEP 2: Submit additional costs (POST) - only if there are new ones
      if (additionalCosts.isNotEmpty) {
        log("Submitting ${additionalCosts.length} additional costs...");

        for (final cost in additionalCosts) {
          final costBody = {
            'serviceBookingId': bookingId.value!,
            'costName': cost.title,
            'price': cost.price.toString(),
          };

          final NetworkResponse costResponse = await _networkCaller.postRequest(
            AppUrl.addNewCost(bookingId.value!),
            body: costBody,
          );

          if (!costResponse.isSuccess) {
            final errorMsg = costResponse.errorMessage ?? "Failed to add cost: ${cost.title}";
            Get.snackbar("Cost Failed", errorMsg,
                backgroundColor: Colors.red, colorText: Colors.white);
            isPaymentRequestLoading.value = false;
            return;
          }
          log("✅ Cost added: ${cost.title}");
        }
      }

      // SUCCESS
      Get.snackbar(
          "Success",
          "Payment request submitted successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3)
      );

      // Close the screen after a delay
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



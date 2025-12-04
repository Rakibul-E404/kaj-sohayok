import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../gen/colors.gen.dart';
import '../models/get_provider_document_details_model.dart';
import '../routes/routes.dart';
import '../service/get_storage.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';

class SvpProfileScreenDocumentsTabController extends GetxController {
  TextEditingController servicesNameController = TextEditingController();
  TextEditingController yearsOfExperienceController = TextEditingController();
  TextEditingController initialPayableController = TextEditingController();
  TextEditingController introController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final RxBool loader = false.obs;

  /// Gallery media (Images & Videos) for Upload
  final RxList<XFile> selectedMedia = <XFile>[].obs;
  final int maxMedia = 50;

  final ImagePicker picker = ImagePicker();

  /// Video Controllers for gallery (both existing and new)
  final RxMap<String, VideoPlayerController> videoControllers =
      <String, VideoPlayerController>{}.obs;
  final RxSet<String> initializedVideos = <String>{}.obs;

  /// Existing attachments to delete
  final RxList<String> attachmentsToDelete = <String>[].obs;

  /// Pick Images
  Future<void> pickImages() async {
    int totalExisting =
        (providerDocumentDetailsModel
                .value
                ?.serviceProvider
                .documentAttachments
                ?.length ??
            0) -
        attachmentsToDelete.length;
    int totalNew = selectedMedia.length;
    int remaining = maxMedia - totalExisting - totalNew;

    if (remaining <= 0) {
      Get.snackbar(
        "Limit reached",
        "You can only upload $maxMedia media files in total.",
      );
      return;
    }

    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      var toAdd = images.take(remaining).toList();
      selectedMedia.addAll(toAdd);

      // Initialize video controllers for newly selected videos
      _initializeNewVideoControllers(toAdd);
    }
  }

  /// Pick Video
  Future<void> pickVideo() async {
    int totalExisting =
        (providerDocumentDetailsModel
                .value
                ?.serviceProvider
                .documentAttachments
                ?.length ??
            0) -
        attachmentsToDelete.length;
    int totalNew = selectedMedia.length;
    int remaining = maxMedia - totalExisting - totalNew;

    if (remaining <= 0) {
      Get.snackbar(
        "Limit reached",
        "You can only upload $maxMedia media files in total.",
      );
      return;
    }

    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      selectedMedia.add(video);

      // Initialize video controller for the new video
      _initializeNewVideoControllers([video]);
    }
  }

  /// Show media picker dialog
  void showMediaPickerDialog() {
    int totalExisting =
        (providerDocumentDetailsModel
                .value
                ?.serviceProvider
                .documentAttachments
                ?.length ??
            0) -
        attachmentsToDelete.length;
    int totalNew = selectedMedia.length;
    int remaining = maxMedia - totalExisting - totalNew;

    if (remaining <= 0) {
      Get.snackbar(
        "Limit reached",
        "You can only upload $maxMedia media files in total.",
      );
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Media',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick Images'),
                onTap: () {
                  Get.back();
                  pickImages();
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Pick Video'),
                onTap: () {
                  Get.back();
                  pickVideo();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initializeNewVideoControllers(List<XFile> files) {
    for (var file in files) {
      // Check if it's a video file
      final path = file.path.toLowerCase();
      if (path.endsWith('.mp4') ||
          path.endsWith('.mov') ||
          path.endsWith('.avi') ||
          path.endsWith('.mkv')) {
        final controller = VideoPlayerController.file(File(file.path));
        videoControllers[file.path] = controller;

        controller
            .initialize()
            .then((_) {
              initializedVideos.add(file.path);
              LoggerUtils.debug('New video initialized: ${file.path}');
            })
            .catchError((error) {
              LoggerUtils.debug(
                'Failed to initialize new video: ${file.path} | Error: $error',
              );
            });

        controller.addListener(() {
          videoControllers.refresh();
        });
      }
    }
  }

  @override
  void onInit() {
    fetchProviderDocument();
    super.onInit();
  }

  @override
  void onClose() {
    // Dispose all video controllers
    for (var controller in videoControllers.values) {
      controller.dispose();
    }
    videoControllers.clear();
    initializedVideos.clear();
    servicesNameController.dispose();
    yearsOfExperienceController.dispose();
    initialPayableController.dispose();
    introController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void _initializeExistingVideoPlayers() {
    final attachments =
        providerDocumentDetailsModel
            .value
            ?.serviceProvider
            .documentAttachments ??
        [];

    final videoAttachments = attachments
        .where(
          (a) =>
              a.attachmentType?.toLowerCase() == 'video' &&
              a.attachment?.isNotEmpty == true,
        )
        .toList();

    for (var att in videoAttachments) {
      final url = att.attachment!.trim();

      if (videoControllers.containsKey(url)) continue;

      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      videoControllers[url] = controller;

      controller
          .initialize()
          .then((_) {
            initializedVideos.add(url);
            LoggerUtils.debug('Video initialized: $url');
          })
          .catchError((error) {
            LoggerUtils.debug('Failed to load video: $url | Error: $error');
          });

      controller.addListener(() {
        videoControllers.refresh();
      });
    }
  }

  /// ======================> Fetch the Documents ======================>
  final Rxn<ProviderDocumentDetailsModel> providerDocumentDetailsModel =
      Rxn<ProviderDocumentDetailsModel>();

  Future<void> fetchProviderDocument() async {
    try {
      loader.value = true;
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';
      final NetworkResponse getResponse = await NetworkCaller().getRequest(
        AppUrl.getProviderDocumentDetails,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );
      if (getResponse.isSuccess) {
        providerDocumentDetailsModel.value =
            ProviderDocumentDetailsModel.fromJson(
              getResponse.jsonResponse?['data']['attributes'],
            );

        LoggerUtils.debug(
          'Document Attachments Length: ${providerDocumentDetailsModel.value?.serviceProvider.documentAttachments?.length}',
        );

        servicesNameController.text =
            providerDocumentDetailsModel.value?.serviceProvider.serviceName.en
                .toString() ??
            '';
        yearsOfExperienceController.text =
            providerDocumentDetailsModel
                .value
                ?.serviceProvider
                .yearsOfExperience
                .toString() ??
            '';
        initialPayableController.text =
            providerDocumentDetailsModel.value?.serviceProvider.startPrice
                .toString() ??
            '';
        descriptionController.text =
            providerDocumentDetailsModel.value?.serviceProvider.description.en
                .toString() ??
            '';
        introController.text =
            providerDocumentDetailsModel.value?.serviceProvider.introOrBio.en
                .toString() ??
            '';

        /// =========== Certificate Images ==============>
        imageFrontSide.value =
            providerDocumentDetailsModel
                .value
                ?.userProfile
                .frontSideCertificateImage
                .firstOrNull
                ?.attachmentUrl ??
            '';
        imageBackSide.value =
            providerDocumentDetailsModel
                .value
                ?.userProfile
                .backSideCertificateImage
                .firstOrNull
                ?.attachmentUrl ??
            '';
        imageSelfie.value =
            providerDocumentDetailsModel
                .value
                ?.userProfile
                .faceImageFromFrontCam
                .firstOrNull
                ?.attachmentUrl ??
            '';

        // Initialize video players for existing gallery videos
        _initializeExistingVideoPlayers();
      } else {
        Get.snackbar(
          'Failed',
          getResponse.jsonResponse?['message'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      LoggerUtils.debug("Exception : ${e.toString()}");
    } finally {
      loader.value = false;
    }
  }

  /// ================> Certificate Images ================>
  final RxString imageFrontSide = ''.obs;
  final RxString imageBackSide = ''.obs;
  final RxString imageSelfie = ''.obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage({
    required ImageSource source,
    required bool isFront,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        if (isFront) {
          imageFrontSide.value = image.path;
        } else {
          imageBackSide.value = image.path;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> captureSelfieWithFrontCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        imageSelfie.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture selfie: $e');
    }
  }

  void showImageSourceDialog({required bool isFront}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Get.back();
                  pickImage(source: ImageSource.camera, isFront: isFront);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery'),
                onTap: () {
                  Get.back();
                  pickImage(source: ImageSource.gallery, isFront: isFront);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ====================> Update the profile =================>
  Future<void> updateProviderDocuments({
    required String serviceProviderDetailsId,
  }) async {
    try {
      loader.value = true;

      Map<String, String> fields = {
        'serviceName': servicesNameController.text.trim(),
        'yearsOfExperience': yearsOfExperienceController.text.trim(),
        'startPrice': initialPayableController.text.trim(),
        'description': descriptionController.text.trim(),
        'introOrBio': introController.text.trim(),
      };

      final Map<String, File> files = {};

      // Add new gallery media (images/videos) - the field name from your Postman is 'attachmentsForGallery'
      for (int i = 0; i < selectedMedia.length; i++) {
        files['attachmentsForGallery'] = File(selectedMedia[i].path);
      }

      // Add auth header
      final String? token = await SecureStorageService().read(
        AppConstants.accessToken,
      );
      final Map<String, String> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Call multipartRequest
      final response = await NetworkCaller().multipartRequest(
        AppUrl.updateProviderDocuments(
          serviceProviderDetailsId: serviceProviderDetailsId,
        ),
        fields: fields,
        files: files,
        headers: headers,
        method: 'PUT',
      );

      LoggerUtils.debug(response.jsonResponse);
      LoggerUtils.debug(
        AppUrl.updateProviderDocuments(
          serviceProviderDetailsId: serviceProviderDetailsId,
        ),
      );
      if (response.isSuccess) {
        Get.snackbar('Success', 'Information updated successfully');

        // Refresh data
        await fetchProviderDocument();
        selectedMedia.clear();
        attachmentsToDelete.clear();

        Get.back(); // Go back to view screen
      } else {
        Get.snackbar(
          'Update Failed',
          response.jsonResponse?['message'] ??
              response.errorMessage ??
              'Unknown error',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update: $e');
      LoggerUtils.debug('Update error: $e');
    } finally {
      loader.value = false;
    }
  }

  void removeImage({required bool isFront}) {
    if (isFront) {
      imageFrontSide.value = '';
    } else {
      imageBackSide.value = '';
    }
  }

  void removeGalleryMedia(int index) {
    if (index >= 0 && index < selectedMedia.length) {
      final media = selectedMedia[index];
      // Dispose video controller if it's a video
      final controller = videoControllers[media.path];
      if (controller != null) {
        controller.dispose();
        videoControllers.remove(media.path);
        initializedVideos.remove(media.path);
      }
      selectedMedia.removeAt(index);
    }
  }

  Future<void> markAttachmentForDeletion(String attachmentId) async {
    // if (!attachmentsToDelete.contains(attachmentId)) {
    //   attachmentsToDelete.add(attachmentId);
    // }

    try {
      loader.value = true;

      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      final NetworkResponse getResponse = await NetworkCaller().deleteRequest(
        AppUrl.userDocumentDelete(id: attachmentId),
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );

      if (getResponse.isSuccess) {
        Get.snackbar(
          'Success',
          "Photo Deleted ",
          backgroundColor: AppColors.c778beb,
          colorText: Colors.white,
        );
        await fetchProviderDocument();
        Get.back();
      } else {
        Get.snackbar(
          'Update Failed',
          getResponse.jsonResponse?['message'] ??
              getResponse.errorMessage ??
              'Unknown error',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update: $e');
      LoggerUtils.debug('Update error: $e');
    } finally {
      loader.value = false;
    }
  }

  void unmarkAttachmentForDeletion(String attachmentId) {
    attachmentsToDelete.remove(attachmentId);
  }

  bool isAttachmentMarkedForDeletion(String attachmentId) {
    return attachmentsToDelete.contains(attachmentId);
  }

  bool isVideo(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.mp4') ||
        ext.endsWith('.mov') ||
        ext.endsWith('.avi') ||
        ext.endsWith('.mkv') ||
        ext.endsWith('.3gp') ||
        ext.endsWith('.webm');
  }
}

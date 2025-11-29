import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/svp_profile_screen_controller.dart';
import 'package:kaz_bd/controllers/user_profile_screen_controller.dart';
import 'package:kaz_bd/models/user_profile_model.dart';

import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';

class SvpEditProfileScreenController extends GetxController {
  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  final RxBool isLoading = false.obs;

  // Get the user profile controller
  final SvpProfileScreenController svpProfileScreenController =
  Get.find<SvpProfileScreenController>();

  // Track initial image path to detect changes
  String _initialImagePath = '';

  @override
  void onInit() {
    super.onInit();
    // Pre-fill the form with existing data
    _prefillFormData();
    // Store initial image path
    _initialImagePath = svpProfileScreenController.profileImage.value;
  }

  /// Pre-fill form with existing user data
  void _prefillFormData() {
    final userProfile = svpProfileScreenController.providerProfileModel.value;
    if (userProfile != null) {
      emailController.text = userProfile.email;
      nameController.text = userProfile.name;
      phoneNumberController.text = userProfile.phoneNumber;
      locationController.text = userProfile.location.en;
      dateOfBirthController.text = formatDateTime(userProfile.dob);
      genderController.text = userProfile.gender.toUpperCase();
    }
  }

  /// Check if user picked a new image
  bool _hasNewImage() {
    final currentPath = svpProfileScreenController.profileImage.value;

    // Check if:
    // 1. Path has changed from initial
    // 2. New path is not empty
    // 3. New path is local file (not network URL)
    // 4. File actually exists
    return currentPath != _initialImagePath &&
        currentPath.isNotEmpty &&
        !currentPath.startsWith('http') &&
        File(currentPath).existsSync();
  }

  /// Update profile picture separately
  Future<bool> _updateProfilePicture() async {
    try {
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      final String imagePath = svpProfileScreenController.profileImage.value;

      // Use multipart request for image upload
      final Map<String, File> files = {'profileImage': File(imagePath)};

      final NetworkResponse response = await NetworkCaller().multipartRequest(
        AppUrl.updateUserProfilePicture,
        files: files,
        headers: {'Authorization': 'Bearer $token'},
        method: 'PUT',
      );

      if (response.isSuccess) {
        LoggerUtils.debug('Profile picture updated successfully');
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to update profile picture: ${response.jsonResponse?['message'] ?? 'Unknown error'}',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      LoggerUtils.debug("Exception in _updateProfilePicture: ${e.toString()}");
      Get.snackbar(
        'Error',
        'Failed to update profile picture: $e',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Update profile info (text fields)
  Future<bool> _updateProfileInfo() async {
    try {
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      // Prepare JSON data for profile info
      final Map<String, dynamic> updateData = {
        'name': nameController.text.trim(),
        'phoneNumber': phoneNumberController.text.trim(),
        'location': locationController.text.trim(),
        'dob': dateOfBirthController.text.trim(),
        'gender': genderController.text.trim().toLowerCase(),
      };

      // Use PUT request with JSON body
      final NetworkResponse response = await NetworkCaller().putRequest(
        AppUrl.updateUserProfileInfo, // Separate endpoint
        body: updateData,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess) {
        LoggerUtils.debug('Profile info updated successfully');
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to update profile: ${response.jsonResponse?['message'] ?? 'Unknown error'}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      LoggerUtils.debug("Exception in _updateProfileInfo: ${e.toString()}");
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Main update profile function
  Future<void> updateProfile() async {
    try {
      // Validation
      if (nameController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your name',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (phoneNumberController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your phone number',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      bool profileInfoSuccess = false;
      bool profilePictureSuccess = false;

      // Check if there's a new image
      final bool hasNewImage = _hasNewImage();

      // Update profile info (always)
      profileInfoSuccess = await _updateProfileInfo();

      // Update profile picture (only if changed)
      if (hasNewImage) {
        profilePictureSuccess = await _updateProfilePicture();
      } else {
        profilePictureSuccess = true;
      }

      // Check overall success
      if (profileInfoSuccess && profilePictureSuccess) {
        // Refresh user profile data
        await svpProfileScreenController.fetchProviderProfile();
        Get.back();

        Get.snackbar(
          'Success',
          hasNewImage
              ? 'Profile and picture updated successfully'
              : 'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Go back to profile screen
      } else if (profileInfoSuccess && !profilePictureSuccess) {
        // Profile updated but image failed
        await svpProfileScreenController.fetchProviderProfile();
        Get.back();
      }
      // If profileInfoSuccess is false, error already shown
    } catch (e) {
      LoggerUtils.debug("Exception in updateProfile: ${e.toString()}");
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneNumberController.dispose();
    locationController.dispose();
    dateOfBirthController.dispose();
    genderController.dispose();
    super.onClose();
  }
}

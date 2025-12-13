// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:kaz_bd/gen/colors.gen.dart';

// class UserProfileScreenController extends GetxController {
//   /// Section : Profile Image Picker
//   final ImagePicker _picker = ImagePicker();

//   /// Instead of File, store path for efficiency
//   RxString pickedImagePath = ''.obs;

//   /// Pick image from given source (camera/gallery)
//   Future<void> pickImage({required ImageSource imagePickerSourceType}) async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: imagePickerSourceType,
//         maxWidth: 1024, // resize for performance
//         maxHeight: 1024,
//         imageQuality: 85, // compress
//       );

//       if (image != null) {
//         pickedImagePath.value = image.path;
//       } else {
//         Get.snackbar("Cancelled", "No image selected");
//       }
//     } catch (e) {
//       Get.snackbar("Error", "Failed to pick image: $e");
//     }
//   }

//   /// Show Camera / Gallery selection
//   void showImageSourceDialog() {
//     Get.dialog(
//       Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           padding: EdgeInsets.all(16.sp),
//           decoration: BoxDecoration(
//             color: AppColors.cFFFFFF,
//             borderRadius: BorderRadius.circular(10.r),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text("Camera"),
//                 onTap: () {
//                   Get.back();
//                   pickImage(imagePickerSourceType: ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo),
//                 title: const Text("Gallery"),
//                 onTap: () {
//                   Get.back();
//                   pickImage(imagePickerSourceType: ImageSource.gallery);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   ///Section : ------------------------///Language Selection///---------------------------
//   // Reactive variable to track the selected tab index
//   var languageSelectionTabIndex = 0.obs;

//   // Change the tab index
//   void changeLanguageTab(int index) {
//     languageSelectionTabIndex.value = index;
//   }

//   ///Section : -------------------------///Profile Options///-------------------------------
//   ///Reactive variable to track the selected tab index
//   var profileSectionTabIndex = 0.obs;

//   /// Change the Profile Section Tab Index
//   void changeProfileOptionsTab(int index) {
//     profileSectionTabIndex.value = index;
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/models/user_profile_model.dart';
import 'package:kaz_bd/service/socket_service.dart';

import '../routes/routes.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';
import 'message_screen_controller.dart';

class UserProfileScreenController extends GetxController
    with GetTickerProviderStateMixin {
  /// Section : Profile Image Picker
  final ImagePicker _picker = ImagePicker();

  /// Instead of File, store path for efficiency
  final RxString profileImage = ''.obs;
  final RxBool loader = false.obs;

  /// Pick image from given source (camera/gallery)
  Future<void> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        profileImage.value = image.path;
      } else {
        // Get.snackbar('Cancelled', 'No image selected');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  /// Show Camera / Gallery selection
  void showImageSourceDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cFFFFFF,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Get.back();
                  pickImage(source: ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  Get.back();
                  pickImage(source: ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ------------------- Language Selection -------------------
  late TabController languageTabController;
  var languageSelectionTabIndex = 0.obs;

  void changeLanguageTab(int index) {
    languageSelectionTabIndex.value = index;
  }

  /// ------------------- Profile Options Tabs -------------------
  late TabController profileOptionsTabController;
  var profileSectionTabIndex = 0.obs;

  void changeProfileOptionsTab(int index) {
    profileSectionTabIndex.value = index;
  }

  ///------------------ OnInit Load Function ---------------------
  @override
  void onInit() {
    super.onInit();

    /// Language Tab Controller
    languageTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: languageSelectionTabIndex.value,
    );
    languageTabController.addListener(() {
      changeLanguageTab(languageTabController.index);
    });

    /// Profile Options Tab Controller
    profileOptionsTabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: profileSectionTabIndex.value,
    );
    profileOptionsTabController.addListener(() {
      changeProfileOptionsTab(profileOptionsTabController.index);
    });

    /// ==================> Fetch the Profile =================>
    fetchUserProfile();
  }

  /// ===================> Logout ==================>

  Future<void> handleLogOut() async {
    try {
      LoggerUtils.debug('🚪 ===== LOGOUT STARTED =====');

      // 1. Clear MessageScreenController data FIRST
      if (Get.isRegistered<MessageScreenController>()) {
        LoggerUtils.debug('Step 1: Clearing MessageScreenController...');
        Get.find<MessageScreenController>().clearAllData();
      }

      // 2. Disconnect socket (also disables it)
      LoggerUtils.debug('Step 2: Disconnecting socket...');
      SocketServices().disconnect();

      // 3. Clear storage
      LoggerUtils.debug('Step 3: Clearing storage...');
      await SecureStorageService().clear();

      // 4. Wait for cleanup
      await Future.delayed(Duration(milliseconds: 300));

      // 5. Verify cleanup
      final token = await SecureStorageService().read(AppConstants.accessToken);
      LoggerUtils.debug('Verification - Token: ${token ?? "NULL"}');
      LoggerUtils.debug('Verification - Socket: ${SocketServices().socket}');

      LoggerUtils.debug('✅ Logout complete');

      // 6. Navigate
      Get.offAllNamed(Routes.onboardingScreen);
    } catch (e) {
      LoggerUtils.debug("Exception : ${e.toString()}");
      Get.offAllNamed(Routes.onboardingScreen);
    }
  }

  // Future<void> handleLogOut() async {
  //   try {
  //     loader.value = true;
  //
  //     await SecureStorageService().clear();
  //     SocketServices().reset();
  //     Get.offAllNamed(Routes.onboardingScreen);
  //   } catch (e) {
  //     // loader.value = false;
  //
  //     LoggerUtils.debug("Exception : ${e.toString()}");
  //   } finally {
  //     // clearTextFields();
  //     // loader.value = false;
  //   }
  // }

  /// ===================> USER profile fetch ===================>
  final Rxn<UserProfileModel> userProfileModel = Rxn<UserProfileModel>();

  Future<void> fetchUserProfile() async {
    try {
      loader.value = true;
      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';
      final NetworkResponse getResponse = await NetworkCaller().getRequest(
        AppUrl.fetchProfile,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );
      if (getResponse.isSuccess) {
        userProfileModel.value = UserProfileModel.fromJson(
          getResponse.jsonResponse?['data']['attributes'],
        );

        if (userProfileModel.value != null &&
            userProfileModel.value!.profileImage.imageUrl.contains(
              'amazonaws',
            )) {
          profileImage.value = userProfileModel.value!.profileImage.imageUrl;
        } else {
          profileImage.value =
              "${AppUrl.imageBaseUrl}${userProfileModel.value!.profileImage.imageUrl}";
        }
        // LoggerUtils.debug(uerProfileModel.value?.email);
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

  ///----------------------------- Dispost the controllers function --------------------------
  @override
  void onClose() {
    languageTabController.dispose();
    profileOptionsTabController.dispose();
    super.onClose();
  }
}

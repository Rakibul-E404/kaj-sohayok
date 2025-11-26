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

import '../routes/routes.dart';
import '../service/network_caller.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';

class UserProfileScreenController extends GetxController
    with GetTickerProviderStateMixin {
  /// Section : Profile Image Picker
  final ImagePicker _picker = ImagePicker();

  /// Instead of File, store path for efficiency
  RxString pickedImagePath = ''.obs;

  /// Pick image from given source (camera/gallery)
  Future<void> pickImage({required ImageSource imagePickerSourceType}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: imagePickerSourceType,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        pickedImagePath.value = image.path;
      } else {
        Get.snackbar("Cancelled", "No image selected");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
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
                  pickImage(imagePickerSourceType: ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  Get.back();
                  pickImage(imagePickerSourceType: ImageSource.gallery);
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
  }

  /// ===================> Logout ==================>
  final RxBool loader = false.obs;

  Future<void> handleLogOut() async {
    try {
      loader.value = true;

      await SecureStorageService().clear();
      Get.offAllNamed(Routes.signInScreen);
    } catch (e) {
      // loader.value = false;

      LoggerUtils.debug("Exception : ${e.toString()}");
    } finally {
      // clearTextFields();
      // loader.value = false;
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

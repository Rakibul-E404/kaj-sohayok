// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:kaz_bd/controllers/svp_profile_screen_controller.dart';

// import '../../../../gen/assets.gen.dart';
// import '../../../../gen/colors.gen.dart';

// class SvpProfileImageShowingWidget extends StatelessWidget {
//   SvpProfileImageShowingWidget({super.key});

//   final SvpProfileScreenController controller = Get.put(
//     SvpProfileScreenController(),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // 👇 Wrap with InkWell so user can tap image itself
//         Obx(() {
//           return InkWell(
//             onTap: () {
//               if (controller.svpPickedImagePath.isNotEmpty) {
//                 // Show full screen preview of picked image
//                 Get.dialog(
//                   Dialog(
//                     insetPadding: EdgeInsets.all(16.w),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12.r),
//                       child: InteractiveViewer(
//                         child: Image.file(
//                           File(controller.svpPickedImagePath.value),
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               } else {
//                 // Show default asset in fullscreen
//                 Get.dialog(
//                   Dialog(
//                     insetPadding: EdgeInsets.all(16.w),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12.r),
//                       child: InteractiveViewer(
//                         child: Image.asset(
//                           width: 1.sw,
//                           Assets.images.errorImage.path,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: AppColors.cd5dbf9, width: 2.sp),
//               ),
//               child: CircleAvatar(
//                 radius: 60.r,
//                 backgroundImage: controller.svpPickedImagePath.isNotEmpty
//                     ? FileImage(File(controller.svpPickedImagePath.value))
//                     : AssetImage(Assets.images.errorImage.path)
//                           as ImageProvider,
//               ),
//             ),
//           );
//         }),

//         // 👇 Edit Icon for selecting new image
//         Positioned(
//           bottom: 8.h,
//           right: 0.w,
//           child: InkWell(
//             onTap: () {
//               controller.showImageSourceDialog();
//             },
//             child: SvgPicture.asset(Assets.icons.editIcon),
//           ),
//         ),
//       ],
//     );
//   }
// }

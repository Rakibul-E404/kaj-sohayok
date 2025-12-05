// import 'package:dotted_line/dotted_line.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
// import 'package:kaz_bd/custom_widgets/custom_shimmer_effect.dart';
// import 'package:kaz_bd/custom_widgets/date_and_time_widget_tile.dart';

// import '../constants/text_font_style.dart';
// import '../utilities/app_url.dart';
// import 'custom_elevated_button.dart';
// import '../gen/colors.gen.dart';
// import '../helpers/ui_helpers.dart';

// class RecentJobRequestStatusWidget extends StatelessWidget {
//   final String userImage;
//   final String userName;
//   final String location;
//   final String dateTime;
//   final bool isJobRequestAccpted;
//   final bool isJobInProgress;
//   final bool isJobStatusCompleted;
//   final void Function()? onTap;
//   final void Function()? cancelOnTap;
//   final void Function()? acceptOnTap;
//   final void Function()? startWorkOnTap;
//   final void Function()? messageOnTap;
//   final void Function()? submitWorkButtonOnTap;
//   final void Function()? messageButtonOnTap;
//   RecentJobRequestStatusWidget({
//     super.key,
//     this.onTap,
//     required this.userImage,
//     required this.userName,
//     required this.location,
//     required this.dateTime,
//     this.cancelOnTap,
//     this.acceptOnTap,
//     this.isJobRequestAccpted = false,
//     this.startWorkOnTap,
//     this.messageOnTap,
//     this.isJobInProgress = false,
//     this.submitWorkButtonOnTap,
//     this.messageButtonOnTap,
//     this.isJobStatusCompleted = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: 1.sw,
//         padding: EdgeInsets.all(12.sp),
//         decoration: BoxDecoration(
//           color: AppColors.cFFFFFF,
//           border: Border.all(color: AppColors.ce6e6e6),
//           borderRadius: BorderRadius.circular(12.r),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.ca4b1f2.withAlpha(80),
//               blurRadius: 12.r,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ///Section : User Image
//             ///Section : User Name
//             Container(
//               padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
//               decoration: BoxDecoration(
//                 color: AppColors.cf1f3fd,
//                 borderRadius: BorderRadius.circular(4.r),
//               ),
//               child: Row(
//                 children: [
//                   ///Section : User Profile Image
//                   // CircleAvatar(
//                   //   radius: 24.r,
//                   //   backgroundImage: AssetImage(userImage),
//                   // ),

//                   /// --- Service Image ---
//                   Obx(() {
//                     // Get the first gallery attachment from service details if available
//                     String? imageUrl;
//                     if (detailsController?.galleryImages.isNotEmpty == true) {
//                       imageUrl =
//                           detailsController?.galleryImages.first.attachment;
//                     }

//                     // Show network image if URL is available, otherwise show placeholder
//                     if (imageUrl != null && imageUrl.isNotEmpty) {
//                       // Make sure the URL is properly formatted
//                       String fullImageUrl = imageUrl;
//                       if (!imageUrl.startsWith('http')) {
//                         // If it's a relative path, prepend the base URL
//                         fullImageUrl = '${AppUrl.imageBaseUrl}$imageUrl';
//                       }

//                       return ClipRRect(
//                         borderRadius: BorderRadius.circular(24.r),
//                         child: Image.network(
//                           fullImageUrl,
//                           height: 220.h,
//                           width: 1.sw,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             // If network image fails, show placeholder
//                             return CustomShimmerEffect(
//                               height: 220.h,
//                               width: 1.sw,
//                             );
//                           },
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return CustomShimmerEffect(
//                               height: 220.h,
//                               width: 1.sw,
//                             );
//                           },
//                         ),
//                       );
//                     } else {
//                       // Show placeholder if no image is available
//                       return ClipRRect(
//                         borderRadius: BorderRadius.circular(24.r),
//                         child: CustomShimmerEffect(height: 220.h, width: 1.sw),
//                       );
//                     }
//                   }),
//                   UIHelper.horizontalSpace(6.w),

//                   ///Section : User Name
//                   Expanded(
//                     child: Text(
//                       userName,
//                       style: TextFontStyle.headline16w500c000000StyleSatoshi,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             UIHelper.verticalSpace(14.h),

//             ///Section : Divider
//             DottedLine(
//               direction: Axis.horizontal,
//               lineLength: double.infinity,
//               lineThickness: 1.sp,
//               dashLength: 4.w,
//               dashGapLength: 4.w,
//               dashColor: AppColors.cb4b4b4,
//             ),
//             UIHelper.verticalSpace(12.h),

//             ///Section : Location
//             DateAndAddressWidgetTile(icon: Icons.location_on, title: location),

//             UIHelper.verticalSpace(6.h),

//             ///Section : Date And Time
//             DateAndAddressWidgetTile(icon: Icons.watch_later, title: dateTime),

//             UIHelper.verticalSpace(12.h),

//             ///Section : Divider
//             DottedLine(
//               direction: Axis.horizontal,
//               lineLength: double.infinity,
//               lineThickness: 1.sp,
//               dashLength: 4.w,
//               dashGapLength: 4.w,
//               dashColor: AppColors.cb4b4b4,
//             ),
//             UIHelper.verticalSpace(12.h),

//             ///Section : PendingTab -> Button -> Cancel/Accept
//             isJobRequestAccpted
//                 ? Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       CustomElevatedButton(
//                         onTap: startWorkOnTap,
//                         buttonWidth: 108.w,
//                         buttonHeight: 38.h,
//                         buttonTitle: "Start Work",
//                       ),
//                       UIHelper.horizontalSpace(12.w),
//                       CustomElevatedButton(
//                         onTap: messageOnTap,
//                         buttonWidth: 108.w,
//                         buttonHeight: 38.h,
//                         isButtonBorderUsed: true,
//                         buttonBorderWidth: 1.5.sp,
//                         buttonBorderColor: AppColors.c778beb,
//                         buttonTitle: "Message",
//                         textStyle:
//                             TextFontStyle.headline14w500c111111StyleSatoshi,
//                         buttonColor: AppColors.cFFFFFF,
//                       ),
//                     ],
//                   )
//                 : isJobInProgress
//                 ? Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       CustomElevatedButton(
//                         onTap: submitWorkButtonOnTap,
//                         buttonWidth: 108.w,
//                         buttonHeight: 38.h,
//                         buttonTitle: "Submit Work",
//                       ),
//                       UIHelper.horizontalSpace(12.w),
//                       CustomElevatedButton(
//                         onTap: messageButtonOnTap,
//                         buttonWidth: 108.w,
//                         buttonHeight: 38.h,
//                         isButtonBorderUsed: true,
//                         buttonBorderWidth: 1.5.sp,
//                         buttonBorderColor: AppColors.c778beb,
//                         buttonTitle: "Message",
//                         textStyle:
//                             TextFontStyle.headline14w500c111111StyleSatoshi,
//                         buttonColor: AppColors.cFFFFFF,
//                       ),
//                     ],
//                   )
//                 : isJobStatusCompleted
//                 ? SizedBox.shrink()
//                 : Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       CustomElevatedButton(
//                         onTap: cancelOnTap,
//                         buttonTitle: "Cancel",
//                         textStyle:
//                             TextFontStyle.headline14w500ce73d3dStyleSatoshi,
//                         buttonWidth: 108.w,
//                         buttonHeight: 38.h,
//                         buttonColor: AppColors.cfce9e9,
//                       ),
//                       UIHelper.horizontalSpace(12.w),
//                       CustomElevatedButton(
//                         onTap: acceptOnTap,
//                         buttonTitle: "Accept",
//                         buttonWidth: 108.w,
//                         buttonHeight: 38.h,
//                       ),
//                     ],
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/custom_widgets/custom_shimmer_effect.dart';
import 'package:kaz_bd/custom_widgets/date_and_time_widget_tile.dart';

import '../constants/text_font_style.dart';
import '../utilities/app_url.dart';
import 'custom_elevated_button.dart';
import '../gen/colors.gen.dart';
import '../helpers/ui_helpers.dart';

class RecentJobRequestStatusWidget extends StatelessWidget {
  final String? userImageUrl;
  final String userName;
  final String location;
  final String dateTime;
  final bool isJobRequestAccpted;
  final bool isJobInProgress;
  final bool isJobStatusCompleted;
  final void Function()? onTap;
  final void Function()? cancelOnTap;
  final void Function()? acceptOnTap;
  final void Function()? startWorkOnTap;
  final void Function()? messageOnTap;
  final void Function()? submitWorkButtonOnTap;
  final void Function()? messageButtonOnTap;

  RecentJobRequestStatusWidget({
    super.key,
    this.onTap,
    this.userImageUrl,
    required this.userName,
    required this.location,
    required this.dateTime,
    this.cancelOnTap,
    this.acceptOnTap,
    this.isJobRequestAccpted = false,
    this.startWorkOnTap,
    this.messageOnTap,
    this.isJobInProgress = false,
    this.submitWorkButtonOnTap,
    this.messageButtonOnTap,
    this.isJobStatusCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 1.sw,
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.cFFFFFF,
          border: Border.all(color: AppColors.ce6e6e6),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.ca4b1f2.withAlpha(80),
              blurRadius: 12.r,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ///Section : User Image & User Name
            Container(
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: AppColors.cf1f3fd,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                children: [
                  ///Section : User Profile Image
                  if (userImageUrl != null && userImageUrl!.isNotEmpty)
                    _buildNetworkAvatar(userImageUrl!)
                  else
                    _buildPlaceholderAvatar(),

                  UIHelper.horizontalSpace(6.w),

                  ///Section : User Name
                  Expanded(
                    child: Text(
                      userName,
                      style: TextFontStyle.headline16w500c000000StyleSatoshi,
                    ),
                  ),
                ],
              ),
            ),
            UIHelper.verticalSpace(14.h),

            ///Section : Divider
            DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 1.sp,
              dashLength: 4.w,
              dashGapLength: 4.w,
              dashColor: AppColors.cb4b4b4,
            ),
            UIHelper.verticalSpace(12.h),

            ///Section : Location
            DateAndAddressWidgetTile(icon: Icons.location_on, title: location),

            UIHelper.verticalSpace(6.h),

            ///Section : Date And Time
            DateAndAddressWidgetTile(icon: Icons.watch_later, title: dateTime),

            UIHelper.verticalSpace(12.h),

            ///Section : Divider
            DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 1.sp,
              dashLength: 4.w,
              dashGapLength: 4.w,
              dashColor: AppColors.cb4b4b4,
            ),
            UIHelper.verticalSpace(12.h),

            ///Section : PendingTab -> Button -> Cancel/Accept
            isJobRequestAccpted
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomElevatedButton(
                        onTap: startWorkOnTap,
                        buttonWidth: 108.w,
                        buttonHeight: 38.h,
                        buttonTitle: "Start Work",
                      ),
                      UIHelper.horizontalSpace(12.w),
                      CustomElevatedButton(
                        onTap: messageOnTap,
                        buttonWidth: 108.w,
                        buttonHeight: 38.h,
                        isButtonBorderUsed: true,
                        buttonBorderWidth: 1.5.sp,
                        buttonBorderColor: AppColors.c778beb,
                        buttonTitle: "Message",
                        textStyle:
                            TextFontStyle.headline14w500c111111StyleSatoshi,
                        buttonColor: AppColors.cFFFFFF,
                      ),
                    ],
                  )
                : isJobInProgress
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomElevatedButton(
                        onTap: submitWorkButtonOnTap,
                        buttonWidth: 108.w,
                        buttonHeight: 38.h,
                        buttonTitle: "Submit Work",
                      ),
                      UIHelper.horizontalSpace(12.w),
                      CustomElevatedButton(
                        onTap: messageButtonOnTap,
                        buttonWidth: 108.w,
                        buttonHeight: 38.h,
                        isButtonBorderUsed: true,
                        buttonBorderWidth: 1.5.sp,
                        buttonBorderColor: AppColors.c778beb,
                        buttonTitle: "Message",
                        textStyle:
                            TextFontStyle.headline14w500c111111StyleSatoshi,
                        buttonColor: AppColors.cFFFFFF,
                      ),
                    ],
                  )
                : isJobStatusCompleted
                ? const SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomElevatedButton(
                        onTap: cancelOnTap,
                        buttonTitle: "Cancel",
                        textStyle:
                            TextFontStyle.headline14w500ce73d3dStyleSatoshi,
                        buttonWidth: 108.w,
                        buttonHeight: 38.h,
                        buttonColor: AppColors.cfce9e9,
                      ),
                      UIHelper.horizontalSpace(12.w),
                      CustomElevatedButton(
                        onTap: acceptOnTap,
                        buttonTitle: "Accept",
                        buttonWidth: 108.w,
                        buttonHeight: 38.h,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // Method to build network avatar with error handling
  Widget _buildNetworkAvatar(String imageUrl) {
    // Construct the full URL if needed
    String fullImageUrl = imageUrl;
    if (!imageUrl.startsWith('http') && imageUrl.isNotEmpty) {
      fullImageUrl = '${AppUrl.imageBaseUrl}$imageUrl';
    }

    return CircleAvatar(
      radius: 24.r,
      backgroundColor: AppColors.cf1f3fd,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Image.network(
          fullImageUrl,
          width: 48.r,
          height: 48.r,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 48.r,
              height: 48.r,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.sp,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
        ),
      ),
    );
  }

  // Method to build placeholder avatar when no image is provided
  Widget _buildPlaceholderAvatar() {
    return CircleAvatar(
      radius: 24.r,
      backgroundColor: AppColors.cf1f3fd,
      child: _buildPlaceholderImage(),
    );
  }

  // Method to build placeholder image widget
  Widget _buildPlaceholderImage() {
    return Icon(Icons.person, size: 32.r, color: AppColors.c778beb);
  }
}

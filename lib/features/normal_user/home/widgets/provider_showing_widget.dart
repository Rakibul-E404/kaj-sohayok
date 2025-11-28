// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../../constants/text_font_style.dart';
// import '../../../../gen/assets.gen.dart';
// import '../../../../gen/colors.gen.dart';
// import '../../../../helpers/ui_helpers.dart';

// class ProviderWidget extends StatelessWidget {
//   final String imagePath;
//   final String providerTitle;
//   final double initialPayablePrice;
//   final double userRating;
//   final void Function()? onTap;
//   const ProviderWidget({
//     super.key,
//     required this.imagePath,
//     required this.providerTitle,
//     required this.initialPayablePrice,
//     required this.userRating,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: 140.w,
//         padding: EdgeInsets.all(10.w),
//         decoration: BoxDecoration(
//           color: AppColors.cFFFFFF,
//           borderRadius: BorderRadius.circular(12.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               spreadRadius: 1,
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ///Section : Image
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8.r),
//               child: CachedNetworkImage(
//                 imageUrl: imagePath,
//                 height: 90.h,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Container(
//                   height: 90.h,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: Icon(
//                     Icons.person,
//                     size: 40.sp,
//                     color: AppColors.c707070,
//                   ),
//                 ),
//                 errorWidget: (context, url, error) => Container(
//                   height: 90.h,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: Icon(
//                     Icons.person,
//                     size: 40.sp,
//                     color: AppColors.c707070,
//                   ),
//                 ),
//               ),
//             ),

//             ///Section : Divider
//             UIHelper.verticalSpace(8.h),

//             ///Section : Provider Name
//             Text(
//               providerTitle,
//               style: TextFontStyle.headline14w600c000000StyleSatoshi,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//             ),

//             ///Section : Divider
//             UIHelper.verticalSpace(4.h),

//             ///Section : Price
//             Text(
//               'From \$${initialPayablePrice.toStringAsFixed(2)}',
//               style: TextFontStyle.headline12w600c27ae52StyleSatoshi,
//             ),

//             ///Section : Divider
//             UIHelper.verticalSpace(4.h),

//             ///Section : Rating
//             Row(
//               children: [
//                 Icon(
//                   Icons.star,
//                   color: AppColors.cFFC107,
//                   size: 16.sp,
//                 ),
//                 UIHelper.horizontalSpace(4.w),
//                 Text(
//                   userRating.toStringAsFixed(1),
//                   style: TextFontStyle.headline12w400c707070StyleSatoshi,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

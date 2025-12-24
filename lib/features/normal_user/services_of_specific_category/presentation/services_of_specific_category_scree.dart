// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:kaz_bd/gen/colors.gen.dart';
// import 'package:kaz_bd/routes/routes.dart';
// import 'package:kaz_bd/utilities/logger_util.dart';
// import 'package:lottie/lottie.dart';

// import '../../../../constants/text_font_style.dart';
// import '../../../../controllers/service_of_specific_category_screen_controller.dart';
// import '../../../../custom_widgets/custom_shimmer_effect.dart';
// import '../../../../custom_widgets/custom_text_form_field.dart';
// import '../../../../gen/assets.gen.dart';
// import '../../../../helpers/ui_helpers.dart';
// import '../widget/specific_service_showing_widget.dart';

// class ServicesOfSpecificCategoryScreen extends StatefulWidget {
//   const ServicesOfSpecificCategoryScreen({super.key});

//   @override
//   State<ServicesOfSpecificCategoryScreen> createState() =>
//       _ServicesOfSpecificCategoryScreenState();
// }

// class _ServicesOfSpecificCategoryScreenState
//     extends State<ServicesOfSpecificCategoryScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   ServiceOfSpecificCategoryScreenController? itemsOfCategory;

//   @override
//   void initState() {
//     super.initState();
//     itemsOfCategory = Get.find<ServiceOfSpecificCategoryScreenController>();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent -
//                 200 && // Trigger 200 pixels before end
//         !itemsOfCategory!.isLoadingMore.value && // Only if not already loading
//         itemsOfCategory!.hasMoreData.value) {
//       // Only if there's more data
//       itemsOfCategory?.loadMoreServices();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final arguments = Get.arguments as Map<String, dynamic>?;

//     final categoryId = arguments?['categoryId'] ?? '';
//     // final latValue = arguments?['lat_value'] ?? '';
//     // final longValue = arguments?['long_value'] ?? '';
//     final categoryName =
//         arguments?['categoryName'] ?? 'failed_to_get_service_category_name'.tr;

//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   itemsOfCategory?.setCategoryData(
//     //     id: categoryId,
//     //     name: categoryName,
//     //     latValue: latValue,
//     //     longValue: longValue,
//     //   );
//     // });
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       itemsOfCategory?.setCategoryData(
//         id: categoryId,
//         name: categoryName,
//       );
//     });

//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackgroundColor,
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: AppColors.scaffoldBackgroundColor,
//         title: Obx(() {
//           return Text(
//             itemsOfCategory?.categoryName.value.isNotEmpty == true
//                 ? itemsOfCategory!.categoryName.value
//                 : categoryName,
//             style: TextFontStyle.headline18w700c000000StyleSatoshi,
//           );
//         }),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
//         child: Column(
//           children: [
//             ///Section : Search Bar
//             CustomFormField(
//               showVerticalDivider: false,
//               controller: _searchController,
//               prefixIcon: SvgPicture.asset(Assets.icons.searchIcon),
//               hintText: "${'search'.tr} $categoryName ${'services'.tr}",
//               onFieldSubmitted: (value) {
//                 itemsOfCategory?.performSearch(value);
//               },
//               onChanged: (value) {
//                 // Optional: Add debounce if you want real-time search
//                 // For now, we'll search on submit only to reduce API calls
//               },
//             ),
//             UIHelper.verticalSpace(16.h),

//             ///Section : Available Services
//             Expanded(
//               child: Obx(() {
//                 ///When Loading state is true
//                 if (itemsOfCategory?.isLoading.value == true) {
//                   return ListView(
//                     children: [
//                       ...List.generate(
//                         6,
//                         (index) => Padding(
//                           padding: EdgeInsets.only(bottom: 16.h),
//                           child: CustomShimmerEffect(
//                             height: 320.h,
//                             width: 1.sw,
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 }

//                 ///When There is no Data to Show
//                 if (itemsOfCategory?.specificCategoryList.isEmpty == true) {
//                   return Center(
//                     child: Lottie.asset(
//                       Assets.lottie.emptyScreen,
//                       fit: BoxFit.contain,
//                     ),
//                   );
//                 }

//                 return RefreshIndicator(
//                   onRefresh: () async {
//                     itemsOfCategory?.pageId.value = '1';
//                     await itemsOfCategory?.handleServiceFromSpecificCategory();
//                   },
//                   child: ListView.builder(
//                     controller: _scrollController,
//                     itemCount: itemsOfCategory!.specificCategoryList.length +
//                         (itemsOfCategory!.isLoadingMore.value
//                             ? 1
//                             : 0), // Add 1 for loading indicator if needed
//                     itemBuilder: (context, index) {
//                       // Check if we're on the last item and need to show a loading indicator
//                       if (index >=
//                           itemsOfCategory!.specificCategoryList.length) {
//                         // This is the loading indicator at the end
//                         return Padding(
//                           padding: EdgeInsets.symmetric(vertical: 16.h),
//                           child: Center(
//                             child: CircularProgressIndicator(),
//                           ),
//                         );
//                       }

//                       final service =
//                           itemsOfCategory!.specificCategoryList[index];

//                       // Extract service data from the model
//                       final String serviceName =
//                           service.serviceName?.en ?? 'service'.tr;
//                       final String providerName =
//                           service.providerId?.name ?? 'provider'.tr;
//                       final double rating = (service.rating ?? 0).toDouble();
//                       final double price = (service.startPrice ?? 0).toDouble();

//                       // Get image URL
//                       String? imageUrl;
//                       if (service.attachmentsForGallery != null &&
//                           service.attachmentsForGallery!.isNotEmpty) {
//                         imageUrl = service.attachmentsForGallery![0].attachment;
//                       }

//                       return Column(
//                         children: [
//                           SpecificServiceShowingWidget(
//                             seeDetailsOnTap: () {
//                               log("Specific Service Item taped at index : $index");
//                               log("Service Image Url : $imageUrl");
//                               Get.toNamed(
//                                 Routes.serviceDetailsScreen,
//                                 arguments: {
//                                   'providerID': service.providerId?.userId,
//                                   'serviceProviderID':
//                                       service.serviceProviderId,
//                                   'serviceName': serviceName,
//                                   'providerName': providerName,
//                                 },
//                               );
//                             },
//                             goToBookingsOnTap: () {
//                               log("Book Now Button Taped at Index : $index");
//                               log("Service Image Url : $imageUrl");
//                               Get.toNamed(Routes.bookingDateScreen, arguments: {
//                                 'providerID': service.providerId?.userId,
//                               });
//                             },
//                             serviceImagePath:
//                                 imageUrl ?? Assets.images.serviceImage.path,
//                             serviceName: serviceName,
//                             initialPayablePrice: price,
//                             serviceProviderImage:
//                                 service.providerId?.profileImage?.imageUrl ??
//                                     Assets.images.userImage.path,
//                             serviceProviderName: providerName,
//                             serviceProviderRating: rating,
//                           ),
//                           UIHelper.verticalSpace(16.h),
//                         ],
//                       );
//                     },
//                   ),
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

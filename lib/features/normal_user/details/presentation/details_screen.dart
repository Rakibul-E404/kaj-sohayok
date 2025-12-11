/**
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/app_constant_text.dart';
import 'package:kaz_bd/constants/app_enums.dart';
import 'package:kaz_bd/custom_widgets/custom_shimmer_effect.dart';
import 'package:kaz_bd/features/normal_user/details/sub_presentation/about_tab.dart';
import 'package:kaz_bd/features/normal_user/details/sub_presentation/gallery_tab.dart';
import 'package:kaz_bd/features/normal_user/details/sub_presentation/reviews_tab.dart';
import 'package:kaz_bd/custom_widgets/tab_showing_widget.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../controllers/details_screen_controller.dart';
import '../../../../controllers/get_nrm_user_service_provider_profile_info.dart';
import '../../../../controllers/normal_user_booking_service_provider_controller.dart';
import '../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../routes/routes.dart';
import '../../../../utilities/app_url.dart';
import '../widget/sliver_tab_bar_delegate_helper_widget.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with SingleTickerProviderStateMixin {
  // final DetailsScreenController detailsController = Get.put(
  //   DetailsScreenController(),
  // );

  DetailsScreenController? detailsController;
  GetNrmUserServiceProviderProfileInfoController? svpProfileInfoController;
  NormalUserBookingServiceProviderController?
  normalUserBookingServiceProviderController;

  late TabController tabController;
  late BookingStatusEnum? status;
  late bool hideBookServiceNowButton;
  late bool isRoutedFromBookingTab;

  @override
  void initState() {
    super.initState();
    detailsController = Get.find<DetailsScreenController>();
    svpProfileInfoController =
        Get.find<GetNrmUserServiceProviderProfileInfoController>();
    normalUserBookingServiceProviderController =
        Get.find<NormalUserBookingServiceProviderController>();
    tabController = TabController(length: 3, vsync: this);

    ///setting the accepted arguments initial value
    status = Get.arguments?["status"] as BookingStatusEnum?;

    hideBookServiceNowButton = _getButtonVisibility(status);

    ///hideBookServiceNowButton is a boolean type value it's value is being used to detarmine
    /// wither the routing has come from the bookings tab or not
    isRoutedFromBookingTab = hideBookServiceNowButton;
  }

  bool _getButtonVisibility(BookingStatusEnum? status) {
    switch (status) {
      case BookingStatusEnum.pending:
      case BookingStatusEnum.acceptedBooking:
      case BookingStatusEnum.inProgress:
      case BookingStatusEnum.paymentRequest:
      case BookingStatusEnum.canceled:
      case BookingStatusEnum.workCompleted:
        return true;
      default:
        return false;
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final providerId = arguments?['providerId'] ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      detailsController?.setServiceProviderId(svpId: providerId);
      svpProfileInfoController?.setServiceProviderId(svpId: providerId);
      normalUserBookingServiceProviderController?.setServiceProviderId(
        svpId: providerId,
      );

      // Call both APIs
      await detailsController?.showSpecificServiceDetails();
      await svpProfileInfoController?.getServiceProviderProfileInfoData();
      // await normalUserBookingServiceProviderController
      //     ?.getProviderBookingSlotAvailability();
    });

    log(
      "hideBookServiceNowButton Value --------------/////----- : $hideBookServiceNowButton",
    );

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        title: Text(
          "Details",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// --- Service Image ---
                  Obx(() {
                    if (detailsController?.isLoading.value == true) {
                      log('⏳ DETAILS SCREEN: Data is still loading, showing shimmer effect');
                      // Show loading placeholder while data is loading
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: CustomShimmerEffect(
                          height: 220.h,
                          width: 1.sw,
                        ),
                      );
                    }

                    // Get the first gallery attachment from service details if available
                    log('🔍 DETAILS SCREEN: Attempting to get service image');
                    String? imageUrl;
                    if (detailsController?.galleryImages.isNotEmpty == true) {
                      imageUrl =
                          detailsController?.galleryImages.first.attachment;
                      log('🖼️ DETAILS SCREEN: Found image URL: $imageUrl');
                    } else {
                      log('❌ DETAILS SCREEN: No gallery images available in controller');
                    }

                    // Show network image if URL is available, otherwise show placeholder
                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      // Make sure the URL is properly formatted
                      String fullImageUrl = imageUrl;
                      if (!imageUrl.startsWith('http')) {
                        // If it's a relative path, prepend the base URL
                        fullImageUrl = '${AppUrl.imageBaseUrl}$imageUrl';
                        log('🔗 DETAILS SCREEN: Prepending base URL - Full URL: $fullImageUrl');
                      } else {
                        log('🌐 DETAILS SCREEN: Image URL is already absolute - Full URL: $fullImageUrl');
                      }

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: Image.network(
                          fullImageUrl,
                          height: 220.h,
                          width: 1.sw,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            log('🚨 DETAILS SCREEN: Image loading error - Error: $error, Stack: $stackTrace');
                            // If network image fails, show error placeholder
                            return Container(
                              height: 220.h,
                              width: 1.sw,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(color: Colors.grey[300]!, width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    size: 50,
                                    color: Colors.grey[500],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              log('✅ DETAILS SCREEN: Image loaded successfully');
                              return child;
                            }
                            log('⏳ DETAILS SCREEN: Image loading progress: ${loadingProgress.expectedTotalBytes != null ? (loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) * 100 : 0}%');
                            return CustomShimmerEffect(
                              height: 220.h,
                              width: 1.sw,
                            );
                          },
                        ),
                      );
                    } else {
                      // Show placeholder if no image is available
                      log('❌ DETAILS SCREEN: No image URL available, showing placeholder');
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: Container(
                          height: 220.h,
                          width: 1.sw,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(color: Colors.grey[300]!, width: 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 50,
                                color: Colors.grey[500],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No Image Available',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }),
                  UIHelper.verticalSpace(24.h),

                  /// --- Service Name + Rating ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() {
                        if (detailsController?.isLoading.value == true) {
                          return CustomShimmerEffect(
                            height: 10.h,
                            width: 0.2.sw,
                          );
                        } else {
                          return Text(
                            detailsController?.serviceName ?? 'Service Name',
                            style:
                                TextFontStyle.headline18w700c000000StyleSatoshi,
                          );
                        }
                      }),
                      Obx(() {
                        if (detailsController?.isLoading.value == true) {
                          return CustomShimmerEffect(
                            height: 20.h,
                            width: 0.15.sw,
                          );
                        } else {
                          return Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.c778beb,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Obx(() {
                              return Row(
                                children: [
                                  Text(
                                    detailsController?.serviceRating
                                            .toString() ??
                                        "0",
                                    style: TextFontStyle
                                        .headline12w400cFFFFFFStyleSatoshi,
                                  ),
                                  UIHelper.horizontalSpace(4.w),
                                  Icon(
                                    Icons.star_rate_rounded,
                                    size: 18.sp,
                                    color: AppColors.cFFFFFF,
                                  ),
                                ],
                              );
                            }),
                          );
                        }
                      }),
                    ],
                  ),
                  UIHelper.verticalSpace(8.h),

                  /// --- Price ---
                  Obx(() {
                    if (detailsController?.isLoading.value == true) {
                      return CustomShimmerEffect(height: 20.h, width: 0.2.sw);
                    } else {
                      return RichText(
                        text: TextSpan(
                          style:
                              TextFontStyle.headline12w500c6a6a6aStyleSatoshi,
                          children: [
                            const TextSpan(text: "Start from "),
                            TextSpan(
                              text:
                                  "${AppText.bdTkSign}${detailsController?.startPrice ?? 0}",
                              style: TextFontStyle
                                  .headline18w700c778bebStyleSatoshi,
                            ),
                          ],
                        ),
                      );
                    }
                  }),
                  UIHelper.verticalSpace(8.h),

                  /// --- Bio ---
                  Obx(() {
                    if (detailsController?.isLoading.value == true) {
                      return CustomShimmerEffect(height: 60.h, width: 1.sw);
                    } else {
                      return Text(
                        detailsController?.serviceBio ?? 'Loading bio...',
                        style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                      );
                    }
                  }),
                  UIHelper.verticalSpace(24.h),
                ],
              ),
            ),
          ),

          /// --- Sticky TabBar ---
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverTabBarDelegateHelper(
              minHeight: 23.h,
              maxHeight: 23.h,
              child: Container(
                color: AppColors.scaffoldBackgroundColor,
                padding: EdgeInsets.symmetric(
                  horizontal: UIHelper.kDefaulutPadding(),
                ),
                child: TabBar(
                  controller: tabController,
                  labelStyle: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                  unselectedLabelColor: AppColors.c4d4d4d,
                  indicatorColor: AppColors.c778beb,
                  dividerColor: AppColors.c778beb,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 4.h,
                  tabs: const [
                    Tab(text: "About"),
                    Tab(text: "Gallery"),
                    Tab(text: "Reviews"),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabShowingWidget(
          tabController: tabController,
          controller: detailsController?.tabIndex,
          tabViews: [
            AboutTab(isRoutedFromBookingTab: isRoutedFromBookingTab),
            GalleryTab(),
            ReviewsTab(),
          ],
        ),
      ),

      /// --- Single Button (shared across all tabs) ---
      bottomNavigationBar: Obx(() {
        // Handle loading state
        if (detailsController?.isLoading.value == true) {
          return Container(
            width: 1.sw,
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            color: Colors.transparent,
            child: CustomShimmerEffect(height: 60.h, width: 1.sw),
          );
        }

        // Handle booking tab routing
        if (hideBookServiceNowButton) {
          return SizedBox.shrink();
        }

        // Show book service button
        return Container(
          width: 1.sw,
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          color: Colors.transparent,
          child: CustomElevatedButton(
            onTap: () {
              log(
                "------Provider ID At Details Screen : $providerId----------------",
              );
              log(
                '-----------DetailsScreen - Navigating to booking date screen with serviceProviderId: ${detailsController?.serviceProviderId.value}',
              );
              Get.toNamed(
                Routes.bookingDateScreen,
                arguments: {'providerId': detailsController?.serviceProviderId.value},
              );
            },
            buttonTitle: "Book Services Now",
          ),
        );
      }),
    );
  }
}
*/

///
///
///
/// todo:: it's rakibul adding funcitons to see the details from the accepted tab
///
///
///

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/app_constant_text.dart';
import 'package:kaz_bd/constants/app_enums.dart';
import 'package:kaz_bd/custom_widgets/custom_shimmer_effect.dart';
import 'package:kaz_bd/features/normal_user/details/sub_presentation/about_tab.dart';
import 'package:kaz_bd/features/normal_user/details/sub_presentation/gallery_tab.dart';
import 'package:kaz_bd/features/normal_user/details/sub_presentation/reviews_tab.dart';
import 'package:kaz_bd/custom_widgets/tab_showing_widget.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../controllers/details_screen_controller.dart';
import '../../../../controllers/get_nrm_user_service_provider_profile_info.dart';
import '../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../routes/routes.dart';
import '../../../../utilities/app_url.dart';
import '../widget/sliver_tab_bar_delegate_helper_widget.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with SingleTickerProviderStateMixin {
  DetailsScreenController? detailsController;
  GetNrmUserServiceProviderProfileInfoController? svpProfileInfoController;

  late TabController tabController;
  late BookingStatusEnum? status;
  late bool hideBookServiceNowButton;
  late bool isRoutedFromBookingTab;
  String serviceProviderID = '';
  String providerID = '';

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    detailsController = Get.find<DetailsScreenController>();
    svpProfileInfoController =
        Get.find<GetNrmUserServiceProviderProfileInfoController>();

    tabController = TabController(length: 3, vsync: this);

    // Get arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    serviceProviderID = arguments?['serviceProviderID']?.toString() ?? '';
    providerID = arguments?['providerID']?.toString() ?? '';
    status = arguments?["status"] as BookingStatusEnum?;

    hideBookServiceNowButton = _getButtonVisibility(status);
    isRoutedFromBookingTab = hideBookServiceNowButton;

    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    log('🎯 DetailsScreen Initialization');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    log('📦 Received arguments: $arguments');
    log('👤 Service Provider ID: $serviceProviderID');
    log('📊 Status: $status');
    log('🔘 Hide Button: $hideBookServiceNowButton');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Validate provider ID
    if (serviceProviderID.isEmpty) {
      log('❌ ERROR: Service Provider ID is empty!');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          'Service Provider ID is missing. Cannot load service details.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      });
      return;
    }

    // Set provider ID and fetch data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        log('🚀 Starting API calls with Provider ID: $serviceProviderID');

        // Set provider ID for both controllers
        detailsController?.setServiceProviderId(svpId: serviceProviderID);
        svpProfileInfoController?.setServiceProviderId(
            svpId: serviceProviderID);
        detailsController?.setProviderID(pvID: providerID);

        log('⏳ Fetching service details...');
        await detailsController?.showSpecificServiceDetails();

        log('⏳ Fetching provider profile info...');
        await svpProfileInfoController?.getServiceProviderProfileInfoData();

        log('✅ All API calls completed');
      } catch (e) {
        log('❌ Error in API calls: $e');
        Get.snackbar(
          'Error',
          'Failed to load data: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }

  bool _getButtonVisibility(BookingStatusEnum? status) {
    switch (status) {
      case BookingStatusEnum.pending:
      case BookingStatusEnum.acceptedBooking:
      case BookingStatusEnum.inProgress:
      case BookingStatusEnum.paymentRequest:
      case BookingStatusEnum.canceled:
      case BookingStatusEnum.workCompleted:
        return true;
      default:
        return false;
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        title: Text(
          "Details",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// --- Service Image ---
                  Obx(() {
                    String? imageUrl;
                    if (detailsController?.galleryImages.isNotEmpty == true) {
                      imageUrl =
                          detailsController?.galleryImages.first.attachment;
                    }

                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      String fullImageUrl = imageUrl;
                      if (!imageUrl.startsWith('http')) {
                        fullImageUrl = '${AppUrl.imageBaseUrl}$imageUrl';
                      }

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: Image.network(
                          fullImageUrl,
                          height: 220.h,
                          width: 1.sw,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return CustomShimmerEffect(
                              height: 220.h,
                              width: 1.sw,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return CustomShimmerEffect(
                              height: 220.h,
                              width: 1.sw,
                            );
                          },
                        ),
                      );
                    } else {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: CustomShimmerEffect(height: 220.h, width: 1.sw),
                      );
                    }
                  }),
                  UIHelper.verticalSpace(24.h),

                  /// --- Service Name + Rating ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() {
                        if (detailsController?.isLoading.value == true) {
                          return CustomShimmerEffect(
                            height: 10.h,
                            width: 0.2.sw,
                          );
                        } else {
                          return Text(
                            detailsController?.serviceName ?? 'Service Name',
                            style:
                                TextFontStyle.headline18w700c000000StyleSatoshi,
                          );
                        }
                      }),
                      Obx(() {
                        if (detailsController?.isLoading.value == true) {
                          return CustomShimmerEffect(
                            height: 20.h,
                            width: 0.15.sw,
                          );
                        } else {
                          return Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.c778beb,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  detailsController?.serviceRating.toString() ??
                                      "0",
                                  style: TextFontStyle
                                      .headline12w400cFFFFFFStyleSatoshi,
                                ),
                                UIHelper.horizontalSpace(4.w),
                                Icon(
                                  Icons.star_rate_rounded,
                                  size: 18.sp,
                                  color: AppColors.cFFFFFF,
                                ),
                              ],
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                  UIHelper.verticalSpace(8.h),

                  /// --- Price ---
                  Obx(() {
                    if (detailsController?.isLoading.value == true) {
                      return CustomShimmerEffect(height: 20.h, width: 0.2.sw);
                    } else {
                      return RichText(
                        text: TextSpan(
                          style:
                              TextFontStyle.headline12w500c6a6a6aStyleSatoshi,
                          children: [
                            const TextSpan(text: "Start from "),
                            TextSpan(
                              text:
                                  "${AppText.bdTkSign}${detailsController?.startPrice ?? 0}",
                              style: TextFontStyle
                                  .headline18w700c778bebStyleSatoshi,
                            ),
                          ],
                        ),
                      );
                    }
                  }),
                  UIHelper.verticalSpace(8.h),

                  /// --- Bio ---
                  Obx(() {
                    if (detailsController?.isLoading.value == true) {
                      return CustomShimmerEffect(height: 60.h, width: 1.sw);
                    } else {
                      return Text(
                        detailsController?.serviceBio ?? 'Loading bio...',
                        style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                      );
                    }
                  }),
                  UIHelper.verticalSpace(24.h),
                ],
              ),
            ),
          ),

          /// --- Sticky TabBar ---
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverTabBarDelegateHelper(
              minHeight: 23.h,
              maxHeight: 23.h,
              child: Container(
                color: AppColors.scaffoldBackgroundColor,
                padding: EdgeInsets.symmetric(
                  horizontal: UIHelper.kDefaulutPadding(),
                ),
                child: TabBar(
                  controller: tabController,
                  labelStyle: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                  unselectedLabelColor: AppColors.c4d4d4d,
                  indicatorColor: AppColors.c778beb,
                  dividerColor: AppColors.c778beb,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 4.h,
                  tabs: const [
                    Tab(text: "About"),
                    Tab(text: "Gallery"),
                    Tab(text: "Reviews"),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabShowingWidget(
          tabController: tabController,
          controller: detailsController?.tabIndex,
          tabViews: [
            AboutTab(isRoutedFromBookingTab: isRoutedFromBookingTab),
            GalleryTab(),
            ReviewsTab(),
          ],
        ),
      ),

      /// --- Bottom Button ---
      bottomNavigationBar: Obx(() {
        if (detailsController?.isLoading.value == true) {
          return Container(
            width: 1.sw,
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            color: Colors.transparent,
            child: CustomShimmerEffect(height: 60.h, width: 1.sw),
          );
        }

        if (hideBookServiceNowButton) {
          return SizedBox.shrink();
        }

        return Container(
          width: 1.sw,
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          color: Colors.transparent,
          child: CustomElevatedButton(
            onTap: () {
              if (detailsController?.providerID != null) {
                Get.toNamed(
                  Routes.bookingDateScreen,
                  arguments: {
                    // 'providerId': detailsController?.serviceProviderId.value
                    'providerID': detailsController?.providerID.value,
                  },
                );
              }
            },
            buttonTitle: "Book Services Now",
          ),
        );
      }),
    );
  }
}

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

      // Call both APIs
      await detailsController?.showSpecificServiceDetails();
      await svpProfileInfoController?.getServiceProviderProfileInfoData();
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
                    // Get the first gallery attachment from service details if available
                    String? imageUrl;
                    if (detailsController?.galleryImages.isNotEmpty == true) {
                      imageUrl =
                          detailsController?.galleryImages.first.attachment;
                    }

                    // Show network image if URL is available, otherwise show placeholder
                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      // Make sure the URL is properly formatted
                      String fullImageUrl = imageUrl;
                      if (!imageUrl.startsWith('http')) {
                        // If it's a relative path, prepend the base URL
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
                            // If network image fails, show placeholder
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
                      // Show placeholder if no image is available
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
              Get.toNamed(Routes.bookingDateScreen);
            },
            buttonTitle: "Book Services Now",
          ),
        );
      }),
    );
  }
}

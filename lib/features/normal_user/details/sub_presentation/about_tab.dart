import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/details_screen_controller.dart';
import 'package:kaz_bd/controllers/message_screen_controller.dart';
import 'package:kaz_bd/custom_widgets/custom_shimmer_effect.dart';
import 'package:kaz_bd/features/call/presentation/controller/call_controller.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/routes/routes.dart';
import 'package:kaz_bd/utilities/app_url.dart';
import 'package:kaz_bd/utilities/logger_util.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/custom_text_with_readmore_button.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../chat_list/model/chat_list_response_model.dart';

class AboutTab extends StatelessWidget {
  final bool isRoutedFromBookingTab;
  final String? providerId;

  const AboutTab(
      {super.key, required this.isRoutedFromBookingTab, this.providerId});

  @override
  Widget build(BuildContext context) {
    DetailsScreenController detailsScreenController =
        Get.find<DetailsScreenController>();
    String? imageUrl;
    String? fullImageUrl;
    return SingleChildScrollView(
      key: const PageStorageKey('about'),
      padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (detailsScreenController.isLoading.value == true) {
              return CustomShimmerEffect(height: 10.h, width: 0.4.sw);
            } else {
              return Text(
                'service_description'.tr,
                style: TextFontStyle.headline16w500c000000StyleSatoshi,
              );
            }
          }),
          UIHelper.verticalSpace(12.h),

          Obx(() {
            if (detailsScreenController.isLoading.value == true) {
              return CustomShimmerEffect(height: 60.h, width: 1.sw);
            } else {
              return CustomTextWidgetWithReadMoreButton(
                text: detailsScreenController.serviceDescription,
                trimLines: 3,
              );
            }
          }),
          UIHelper.verticalSpace(24.h),

          ///Section : Service Provider Image
          ///Section : Service Provider Name
          ///Section : Service Provider
          ///Section : Message
          ///Section : Call
          InkWell(
            onTap: () {
              Get.toNamed(Routes.serviceProviderProfileDetailsScreen);
            },
            child: Container(
              width: 1.sw,
              padding: EdgeInsets.all(12.sp),
              decoration: BoxDecoration(
                color: AppColors.cFFFFFF,
                border: Border.all(color: AppColors.cb4b4b4),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  ///Section : Service Provider Image
                  Obx(() {
                    if (detailsScreenController
                            .providerProfileImage?.isNotEmpty ==
                        true) {
                      imageUrl = detailsScreenController.providerProfileImage;
                    }

                    if (imageUrl != null && imageUrl!.isNotEmpty) {
                      fullImageUrl = imageUrl;

                      if (!imageUrl!.startsWith('http')) {
                        fullImageUrl = '${AppUrl.imageBaseUrl}$imageUrl';
                      }

                      return ClipOval(
                        child: Image.network(
                          fullImageUrl ?? '',
                          width: 40.w,
                          height: 40.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // If network image fails, show placeholder
                            return Image.asset(Assets.images.errorImage.path);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return CustomShimmerEffect(
                              height: 40.h,
                              width: 0.1.sw,
                            );
                          },
                        ),
                      );
                    } else {
                      // Show placeholder if no image is available
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: CustomShimmerEffect(height: 40.h, width: 0.1.sw),
                      );
                    }
                  }),

                  UIHelper.horizontalSpace(6.w),

                  ///Section : Service Provider Name
                  ///Section : Service Provider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///Section : Service Provider Name
                      Obx(() {
                        if (detailsScreenController.isLoading.value) {
                          return CustomShimmerEffect(
                            height: 10.h,
                            width: 0.4.sw,
                          );
                        } else {
                          return SizedBox(
                            width: 0.5.sw,
                            child: Text(
                              detailsScreenController.providerName ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextFontStyle
                                  .headline16w500c202020StyleSatoshi,
                            ),
                          );
                        }
                      }),
                      UIHelper.verticalSpace(2.h),

                      ///Section : Service Provider
                      Obx(() {
                        if (detailsScreenController.isLoading.value) {
                          return CustomShimmerEffect(
                            height: 10.h,
                            width: 0.4.sw,
                          );
                        } else {
                          return Text(
                            'service_provider'.tr,
                            style:
                                TextFontStyle.headline10w500c4d4d4dStyleSatoshi,
                          );
                        }
                      }),
                    ],
                  ),
                  Spacer(),

                  ///Section : Message
                  ///Section : Call
                  Row(
                    children: [
                      ///Section : Message
                      Obx(() {
                        if (detailsScreenController.isLoading.value) {
                          return ClipOval(
                            child: CustomShimmerEffect(
                              height: 40.h,
                              width: 40.w,
                            ),
                          );
                        } else {
                          return InkWell(
                            onTap: detailsScreenController.pvdApprovalStatus ==
                                    "pending"
                                ? null
                                : () {
                                    LoggerUtils.debug(
                                        "pvdApproval Value : ${detailsScreenController.pvdApprovalStatus}");
                                    Get.find<MessageScreenController>()
                                        .createMessage(
                                            participantId:
                                                detailsScreenController
                                                        .serviceDetails
                                                        .value
                                                        ?.providerId
                                                        ?.userId ??
                                                    '',
                                            name: detailsScreenController
                                                    .providerName ??
                                                "",
                                            imageUrl: detailsScreenController
                                                    .providerProfileImage ??
                                                '');
                                  },
                            child: Container(
                              padding: EdgeInsets.all(6.sp),
                              decoration: BoxDecoration(
                                color: isRoutedFromBookingTab
                                    ? AppColors.c778beb
                                    : AppColors.cbababa,
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(Assets.icons.messageIcon),
                            ),
                          );
                        }
                      }),
                      UIHelper.horizontalSpace(8.w),

                      ///Section : Call
                      Obx(() {
                        if (detailsScreenController.isLoading.value) {
                          return ClipOval(
                            child: CustomShimmerEffect(
                              height: 40.h,
                              width: 40.w,
                            ),
                          );
                        } else {
                          return Obx(() {
                            final isCallInProgress =
                                Get.find<CallController>().callState.value !=
                                    CallState.idle;

                            return InkWell(
                              onTap: isCallInProgress ||
                                      detailsScreenController
                                              .pvdApprovalStatus ==
                                          "pending"
                                  ? null
                                  : () {
                                      // Call the controller method

                                      LoggerUtils.debug(
                                          "pvdApproval Value : ${detailsScreenController.pvdApprovalStatus}");
                                      Get.find<CallController>()
                                          .initiateAudioCallOutsideInbox(
                                              receiverId:
                                                  detailsScreenController
                                                          .serviceDetails
                                                          .value
                                                          ?.providerId
                                                          ?.userId ??
                                                      '',
                                              name: detailsScreenController
                                                      .providerName ??
                                                  '',
                                              image: ProfileImageModel(
                                                  imageUrl:
                                                      fullImageUrl ?? ''));
                                    },
                              child: Icon(
                                Icons.call,
                                color: isCallInProgress
                                    ? AppColors.c999999.withOpacity(0.5)
                                    : AppColors.c999999,
                              ),
                            );
                          });
                        }
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          UIHelper.verticalSpace(30.h),
        ],
      ),
    );
  }
}

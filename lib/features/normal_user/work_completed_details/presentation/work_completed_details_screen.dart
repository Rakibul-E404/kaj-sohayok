import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/features/normal_user/work_completed_details/widgets/additional_cost_popup.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:video_player/video_player.dart';
import '../../../../custom_widgets/address_and_order_date_tile.dart';
import '../../../../custom_widgets/payment_summery_widget.dart';
import '../../../../custom_widgets/proof_of_work_showing_widget.dart';
import '../../../../custom_widgets/workCompleteDateAndTimeWidget.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../utilities/app_url.dart';
import '../controller/WorkCompletedDetailsController.dart';
import '../model/additional_cost_model.dart';
import 'package:kaz_bd/models/user_payment_history_details_model.dart'
    as details_model;
import 'package:kaz_bd/controllers/message_screen_controller.dart';
import 'package:kaz_bd/utilities/logger_util.dart';

class WorkCompletedDetailsScreen extends StatefulWidget {
  const WorkCompletedDetailsScreen({super.key});

  @override
  State<WorkCompletedDetailsScreen> createState() =>
      _WorkCompletedDetailsScreenState();
}

class _WorkCompletedDetailsScreenState
    extends State<WorkCompletedDetailsScreen> {
  late final WorkCompletedDetailsController _controller;
  final Map<String, VideoPlayerController> _videoControllers = {};
  final Set<String> _initializedVideos = {};

  @override
  void initState() {
    super.initState();
    _controller = Get.put(WorkCompletedDetailsController());
  }

  void _initializeVideoPlayers() {
    final paymentDetails = _controller.paymentDetails.value;
    if (paymentDetails?.serviceBooking?.attachments != null) {
      final videoAttachments = paymentDetails!.serviceBooking!.attachments!
          .where(
            (a) =>
                (a.attachmentType?.toLowerCase() == 'video') &&
                (a.attachment?.isNotEmpty == true),
          )
          .toList();

      log('🎥 [VIDEO] Found ${videoAttachments.length} video attachments');

      for (var att in videoAttachments) {
        final url = att.attachment!;
        final key = url;

        log('🎥 [VIDEO] Initializing video: $url');

        _videoControllers[key] = VideoPlayerController.networkUrl(
          Uri.parse(url.trim()),
        );

        _videoControllers[key]!.initialize().then((_) {
          if (mounted) {
            setState(() {
              _initializedVideos.add(key);
            });
            log('✅ [VIDEO] Initialized: $url');
          }
        }).catchError((error) {
          log('❌ [VIDEO] Failed to load: $url | Error: $error');
        });

        _videoControllers[key]!.addListener(() {
          if (mounted) setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      log('⚠️ [FORMAT] Date string is null or empty');
      return "N/A";
    }
    try {
      final parsedDate = DateTime.parse(dateStr);
      final formatted = DateFormat('dd-MM-yy').format(parsedDate);
      log('✅ [FORMAT] Date formatted: $dateStr -> $formatted');
      return formatted;
    } catch (e) {
      log('❌ [FORMAT] Error formatting date: $e');
      return "N/A";
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      log('⚠️ [FORMAT] DateTime string is null or empty');
      return "N/A";
    }
    try {
      final parsedDate = DateTime.parse(dateTimeStr);
      final formatted = DateFormat('MMM dd, yyyy  hh:mm a').format(parsedDate);
      log('✅ [FORMAT] DateTime formatted: $dateTimeStr -> $formatted');
      return formatted;
    } catch (e) {
      log('❌ [FORMAT] Error formatting dateTime: $e');
      return "N/A";
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildVideoPlayer(String videoUrl) {
    final controller = _videoControllers[videoUrl];
    final isInitialized = _initializedVideos.contains(videoUrl);

    if (controller == null || !isInitialized) {
      return Container(
        width: 1.sw,
        height: 200.h,
        decoration: BoxDecoration(
          color: AppColors.c000000.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.c778beb),
              UIHelper.verticalSpace(8.h),
              Text(
                'loading_video'.tr,
                style: TextFontStyle.headline12w400c727272StyleSatoshi,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 1.sw,
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: controller.value.isPlaying ? 0.0 : 0.8,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8.h,
              left: 8.w,
              right: 8.w,
              child: AnimatedOpacity(
                opacity: controller.value.isPlaying ? 0.3 : 0.8,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  height: 4.h,
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    padding: EdgeInsets.zero,
                    colors: VideoProgressColors(
                      playedColor: AppColors.c778beb,
                      bufferedColor: Colors.white.withOpacity(0.3),
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ),
            if (!controller.value.isPlaying)
              Positioned(
                bottom: 20.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _formatDuration(controller.value.duration),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      log('🖼️ [IMAGE URL] Empty image URL');
      return '';
    }

    String cleanUrl = imageUrl.trim();

    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      log('🖼️ [IMAGE URL] Full URL: $cleanUrl');
      return cleanUrl;
    }

    if (cleanUrl.toLowerCase().contains('amazonaws')) {
      if (!cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }
      log('🖼️ [IMAGE URL] AWS URL fixed: $cleanUrl');
      return cleanUrl;
    }

    if (cleanUrl.startsWith('/')) {
      cleanUrl = cleanUrl.substring(1);
    }

    final constructedUrl = '${AppUrl.imageBaseUrl}/$cleanUrl';
    log('🖼️ [IMAGE URL] Constructed: $constructedUrl');

    return constructedUrl;
  }

  Widget _buildNetworkImage(String imageUrl) {
    final url = _getImageUrl(imageUrl);

    if (url.isEmpty) {
      return Container(
        width: 1.sw,
        height: 200.h,
        color: AppColors.c778beb.withOpacity(0.1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                color: AppColors.c778beb,
                size: 40.sp,
              ),
              UIHelper.verticalSpace(8.h),
              Text(
                'no_image_available'.tr,
                style: TextFontStyle.headline12w400c727272StyleSatoshi,
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 1.sw,
        height: 200.h,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.c778beb.withOpacity(0.1),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.c778beb),
          ),
        ),
        errorWidget: (context, url, error) {
          log('❌ [IMAGE] Error loading: $error, URL: $url');
          return Container(
            width: 1.sw,
            height: 200.h,
            color: AppColors.c778beb.withOpacity(0.1),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    color: AppColors.c778beb,
                    size: 40.sp,
                  ),
                  UIHelper.verticalSpace(8.h),
                  Text(
                    'failed_to_load_image'.tr,
                    style: TextFontStyle.headline12w400c727272StyleSatoshi,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildProofOfWorkWidgets(
      details_model.UserPaymentHistoryDetailsModel paymentDetails) {
    final serviceBooking = paymentDetails.serviceBooking;
    final attachments = serviceBooking?.attachments;

    log('🖼️ [PROOF OF WORK] ========================================');
    log('🖼️ [PROOF OF WORK] Service Booking: ${serviceBooking != null ? "EXISTS" : "NULL"}');
    log('🖼️ [PROOF OF WORK] Attachments: ${attachments != null ? "EXISTS" : "NULL"}');
    log('🖼️ [PROOF OF WORK] Attachments Count: ${attachments?.length ?? 0}');

    if (attachments == null || attachments.isEmpty) {
      log('🖼️ [PROOF OF WORK] No attachments to display');
      return [
        ProofOfWorkShowingWidget(
          title: 'proof_of_work'.tr,
          child: Container(
            width: 1.sw,
            height: 150.h,
            decoration: BoxDecoration(
              color: AppColors.cf7f8fd,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.ce6e6e6),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 40.sp,
                    color: AppColors.c778beb,
                  ),
                  UIHelper.verticalSpace(12.h),
                  Text(
                    'no_proof_of_work_provided'.tr,
                    style: TextFontStyle.headline14w500c778bebStyleSatoshi,
                  ),
                  UIHelper.verticalSpace(4.h),
                  Text(
                    'service_provider_did_not_upload_image'.tr,
                    style: TextFontStyle.headline12w400c727272StyleSatoshi,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        UIHelper.verticalSpace(24.h),
      ];
    }

    for (var i = 0; i < attachments.length; i++) {
      final att = attachments[i];
      log('🖼️ [PROOF OF WORK] Attachment $i:');
      log('   - Type: ${att.attachmentType ?? "NULL"}');
      log('   - URL: ${att.attachment ?? "NULL"}');
      log('   - URL Length: ${att.attachment?.length ?? 0}');
    }

    final List<Widget> widgets = [];
    int imageCounter = 1;
    int videoCounter = 1;

    for (var att in attachments) {
      final attachmentType = att.attachmentType?.toLowerCase() ?? '';
      final attachmentUrl = att.attachment ?? '';

      if (attachmentUrl.isEmpty) {
        log('🖼️ [PROOF OF WORK] Skipping empty attachment URL');
        continue;
      }

      if (attachmentType == 'image') {
        log('🖼️ [PROOF OF WORK] Adding image #$imageCounter: $attachmentUrl');
        widgets.add(
          ProofOfWorkShowingWidget(
            title: "${'proof_of_work_image'.tr} $imageCounter",
            child: _buildNetworkImage(attachmentUrl),
          ),
        );
        widgets.add(UIHelper.verticalSpace(24.h));
        imageCounter++;
      } else if (attachmentType == 'video') {
        log('🎥 [PROOF OF WORK] Adding video #$videoCounter: $attachmentUrl');
        widgets.add(
          ProofOfWorkShowingWidget(
            title: "${'proof_of_work_video'.tr} $videoCounter",
            child: _buildVideoPlayer(attachmentUrl),
          ),
        );
        widgets.add(UIHelper.verticalSpace(24.h));
        videoCounter++;
      } else {
        log('⚠️ [PROOF OF WORK] Unknown attachment type: $attachmentType');
      }
    }

    log('🖼️ [PROOF OF WORK] Total widgets created: ${widgets.length}');
    log('🖼️ [PROOF OF WORK] Images: ${imageCounter - 1}, Videos: ${videoCounter - 1}');
    log('🖼️ [PROOF OF WORK] ========================================');

    return widgets;
  }

  Widget _buildServiceProviderProfileImage(
      details_model.ProfileImage? profileImage) {
    if (profileImage?.imageUrl == null || profileImage!.imageUrl!.isEmpty) {
      log('👤 [PROFILE] No profile image URL');
      return CircleAvatar(
        radius: 20.r,
        backgroundColor: AppColors.c778beb.withOpacity(0.1),
        child: Icon(
          Icons.person,
          color: AppColors.c778beb,
          size: 24.sp,
        ),
      );
    }

    final imageUrl = _getImageUrl(profileImage.imageUrl);
    log('👤 [PROFILE] Profile image URL: $imageUrl');

    return CircleAvatar(
      radius: 20.r,
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: 40.r,
          height: 40.r,
          placeholder: (context, url) => Container(
            color: AppColors.c778beb.withOpacity(0.1),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.c778beb,
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            log('❌ [PROFILE] Error loading: $error');
            return Container(
              color: AppColors.c778beb.withOpacity(0.1),
              child: Center(
                child: Icon(
                  Icons.person,
                  color: AppColors.c778beb,
                  size: 24.sp,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 🔴 EXTRACT PROVIDER USER ID (same logic as InProgressTab)
  String _getProviderUserId(
      details_model.UserPaymentHistoryDetailsModel? details) {
    final provider = details?.serviceBooking?.providerId;
    if (provider?.userId != null) {
      final id = provider!.userId.toString();
      log('✅ [WORK COMPLETED] Provider User ID from providerId._userId: $id');
      return id;
    }
    log('⚠️ [WORK COMPLETED] No Provider User ID found');
    return '';
  }

  // 🔴 MESSAGE NAVIGATION (identical to InProgressTab)
  void _navigateToMessage(
    String bookingId,
    String providerId,
    String providerName,
    String imageUrl,
  ) {
    log('💬 [WORK COMPLETED] Message button tapped for booking: $bookingId');
    log('   🆔 Provider ID: "$providerId"');
    log('   👤 Provider Name: "$providerName"');
    log('   🖼️ Image URL: "$imageUrl"');

    if (providerId.isEmpty) {
      log('❌ [WORK COMPLETED] Cannot send message: Provider ID is empty');
      Get.snackbar(
        'error'.tr,
        'cannot_send_message_provider_info_not_available'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final msgController = Get.find<MessageScreenController>();
      LoggerUtils.info(imageUrl);
      msgController.createMessage(
        participantId: providerId,
        name: providerName,
        imageUrl: imageUrl,
      );
      log('✅ [WORK COMPLETED] createMessage called successfully');
    } catch (e) {
      log('❌ [WORK COMPLETED] Error with MessageScreenController: $e');
      Get.snackbar(
        'error'.tr,
        'messaging_service_not_available'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'complete_details'.tr,
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  UIHelper.verticalSpace(16.h),
                  Text(
                    'loading_details'.tr,
                    style: TextFontStyle.headline12w400c727272StyleSatoshi,
                  ),
                ],
              ),
            );
          }

          if (_controller.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                    UIHelper.verticalSpace(16.h),
                    Text(
                      _controller.errorMessage.value,
                      style: TextFontStyle.headline16w500c000000StyleSatoshi,
                      textAlign: TextAlign.center,
                    ),
                    UIHelper.verticalSpace(20.h),
                    ElevatedButton(
                      onPressed: () => _controller.retry(),
                      child: Text('retry'.tr),
                    ),
                  ],
                ),
              ),
            );
          }

          final paymentDetails = _controller.paymentDetails.value;
          if (paymentDetails == null) {
            return Center(
              child: Text(
                'no_details_found'.tr,
                style: TextFontStyle.headline12w400c727272StyleSatoshi,
              ),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_videoControllers.isEmpty) {
              _initializeVideoPlayers();
            }
          });

          final serviceBooking = paymentDetails.serviceBooking;
          final provider = serviceBooking?.providerId;
          final apiAdditionalCosts = paymentDetails.additionalCosts ?? [];
          final initialCost = serviceBooking?.startPrice ?? 0.0;

          log('📊 [UI DATA] ========================================');
          log('📊 [UI DATA] Booking ID: ${serviceBooking?.serviceBookingId}');
          log('📊 [UI DATA] Completion Date: ${serviceBooking?.completionDate}');
          log('📊 [UI DATA] Duration: ${serviceBooking?.duration}');
          log('📊 [UI DATA] Provider: ${provider?.name}');
          log('📊 [UI DATA] Attachments: ${serviceBooking?.attachments?.length ?? 0}');
          log('📊 [UI DATA] Address: ${serviceBooking?.address?.en}');
          log('📊 [UI DATA] Booking Date: ${serviceBooking?.bookingDateTime}');
          log('📊 [UI DATA] Start Price: $initialCost');
          log('📊 [UI DATA] Additional Costs: ${apiAdditionalCosts.length}');
          log('📊 [UI DATA] ========================================');

          final List<AdditionalCostModel> additionalCosts = apiAdditionalCosts
              .map(
                (cost) => AdditionalCostModel(
                  title: cost.costName ?? 'additional_cost'.tr,
                  price: cost.price ?? 0.0,
                ),
              )
              .toList();

          final totalPayment = initialCost +
              additionalCosts.fold(0.0, (sum, cost) => sum + cost.price);

          // 🔴 Extract messaging data
          final bookingId = serviceBooking?.serviceBookingId ?? '';
          final providerId = _getProviderUserId(paymentDetails);
          final providerName = provider?.name ?? 'unknown_provider'.tr;
          final profileImageUrl = provider?.profileImage?.imageUrl ?? '';
          final imageUrl = _getImageUrl(profileImageUrl);

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'work_complete_information'.tr,
                    style: TextFontStyle.headline16w700c000000StyleSatoshi,
                  ),
                  UIHelper.verticalSpace(16.h),

                  WorkCompleteDateAndTimeWidget(
                    title: 'completation_date'.tr,
                    data: _formatDate(serviceBooking?.completionDate),
                  ),
                  UIHelper.verticalSpace(16.h),

                  WorkCompleteDateAndTimeWidget(
                    title: 'duration_time'.tr,
                    data: (serviceBooking?.duration?.isNotEmpty == true)
                        ? "${serviceBooking!.duration} ${'mins'.tr}"
                        : "N/A",
                    isIconVisible: false,
                  ),
                  UIHelper.verticalSpace(24.h),

                  Container(
                    width: 1.sw,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.ce6e6e6),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Column(
                      children: [
                        AddressAndOrderDateTile(
                          title: 'working_address'.tr,
                          icon: Icons.location_on,
                          data: serviceBooking?.address?.en ?? "N/A",
                        ),
                        UIHelper.verticalSpace(14.h),
                        AddressAndOrderDateTile(
                          title: 'booking_order_date'.tr,
                          icon: Icons.watch_later_rounded,
                          data:
                              _formatDateTime(serviceBooking?.bookingDateTime),
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(24.h),

                  ..._buildProofOfWorkWidgets(paymentDetails),

                  // 🔴 SERVICE PROVIDER CARD WITH MESSAGING
                  if (provider != null)
                    Container(
                      width: 1.sw,
                      padding: EdgeInsets.all(12.sp),
                      decoration: BoxDecoration(
                        color: AppColors.cf7f8fd,
                        border: Border.all(color: AppColors.cb4b4b4),
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ca4b1f2.withAlpha(80),
                            blurRadius: 12.r,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _buildServiceProviderProfileImage(
                              provider.profileImage),
                          UIHelper.horizontalSpace(6.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  providerName,
                                  style: TextFontStyle
                                      .headline16w500c202020StyleSatoshi,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                UIHelper.verticalSpace(2.h),
                                Text(
                                  'service_provider'.tr,
                                  style: TextFontStyle
                                      .headline10w500c4d4d4dStyleSatoshi,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              // 🔴 MESSAGE BUTTON (fully functional)
                              InkWell(
                                onTap: () {
                                  _navigateToMessage(
                                    bookingId,
                                    providerId,
                                    providerName,
                                    imageUrl,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(6.sp),
                                  decoration: BoxDecoration(
                                    color: AppColors.c778beb,
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgPicture.asset(
                                    Assets.icons.messageIcon,
                                    width: 18.w,
                                    height: 18.h,
                                  ),
                                ),
                              ),
                              UIHelper.horizontalSpace(8.w),
                              InkWell(
                                onTap: () => log("Call tapped"),
                                child: Container(
                                  padding: EdgeInsets.all(6.sp),
                                  decoration: BoxDecoration(
                                    color: AppColors.c778beb,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.call,
                                    color: AppColors.cFFFFFF,
                                    size: 18.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (provider != null) UIHelper.verticalSpace(24.h),

                  PaymentSummeryWidget(
                    initialCost: initialCost,
                    additionalCostList: additionalCosts,
                    totalPayment: totalPayment,
                    isTransactionIdCardVisible:
                        serviceBooking?.paymentTransactionId != null,
                    transactionID:
                        serviceBooking?.paymentTransactionId ?? "N/A",
                    isAddAdditionalCostButtonVisible: false,
                    onTap: () {
                      showAdditionalCostDialog(
                        context: context,
                        additionlCostSubmitOnTap: (String name, double price) {
                          Get.snackbar(
                            'info'.tr,
                            'read_only_additional_costs_cannot_be_modified'.tr,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                        },
                      );
                    },
                  ),
                  UIHelper.verticalSpace(55.h),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

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

import '../../../../controllers/message_screen_controller.dart';
import '../../../../custom_widgets/address_and_order_date_tile.dart';
import '../../../../custom_widgets/payment_summery_widget.dart';
import '../../../../custom_widgets/proof_of_work_showing_widget.dart';
import '../../../../custom_widgets/workCompleteDateAndTimeWidget.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../models/user_payment_history_details_model.dart'; // Adjust path if needed
import '../../../../routes/routes.dart';
import '../../../../utilities/app_url.dart';
import '../../../call/presentation/controller/call_controller.dart';
import '../../chat_list/model/chat_list_response_model.dart';
import '../model/additional_cost_model.dart';

class WorkCompletedDetailsScreen extends StatefulWidget {
  const WorkCompletedDetailsScreen({super.key});

  @override
  State<WorkCompletedDetailsScreen> createState() =>
      _WorkCompletedDetailsScreenState();
}

class _WorkCompletedDetailsScreenState
    extends State<WorkCompletedDetailsScreen> {
  late UserPaymentHistoryDetailsModel _paymentDetails;
  final Map<String, VideoPlayerController> _videoControllers = {};
  final Set<String> _initializedVideos = {};

  @override
  void initState() {
    super.initState();
    _paymentDetails = Get.arguments as UserPaymentHistoryDetailsModel;
    _initializeVideoPlayers();
  }

  void _initializeVideoPlayers() {
    final videoAttachments = _paymentDetails.serviceBooking?.attachments
            ?.where(
              (a) =>
                  (a.attachmentType?.toLowerCase() == 'video') &&
                  (a.attachment?.isNotEmpty == true),
            )
            .toList() ??
        [];

    for (var att in videoAttachments) {
      final url = att.attachment!;
      final key = url; // Use URL as unique key

      _videoControllers[key] = VideoPlayerController.networkUrl(
        Uri.parse(url.trim()),
      );

      _videoControllers[key]!.initialize().then((_) {
        if (mounted) {
          setState(() {
            _initializedVideos.add(key);
          });
          log('Video initialized: $url');
        }
      }).catchError((error) {
        log('Failed to load video: $url | Error: $error');
      });

      _videoControllers[key]!.addListener(() {
        if (mounted) setState(() {});
      });
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
    if (dateStr == null) return "N/A";
    try {
      return DateFormat('dd-MM-yy').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return "N/A";
    try {
      return DateFormat(
        'MMM dd, yyyy  hh:mm a',
      ).format(DateTime.parse(dateTimeStr));
    } catch (e) {
      return dateTimeStr;
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
          color: AppColors.c000000.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.c778beb),
              UIHelper.verticalSpace(8.h),
              Text(
                'Loading video...',
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

  List<Widget> _buildProofOfWorkWidgets() {
    final attachments = _paymentDetails.serviceBooking?.attachments ?? [];
    if (attachments.isEmpty) {
      return [
        ProofOfWorkShowingWidget(
          title: "Proof of Work",
          child: Center(
            child: Text(
              "No proof provided",
              style: TextFontStyle.headline12w400c727272StyleSatoshi,
            ),
          ),
        ),
        UIHelper.verticalSpace(24.h),
      ];
    }

    final List<Widget> widgets = [];

    final imageAttachments = attachments.where(
      (a) =>
          a.attachmentType?.toLowerCase() == 'image' &&
          a.attachment?.isNotEmpty == true,
    );

    for (var att in imageAttachments) {
      widgets.add(
        ProofOfWorkShowingWidget(
          title: "Proof of Image",
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: Image.network(
              att.attachment!,
              width: 1.sw,
              height: 200.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.c778beb,
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
        ),
      );
      widgets.add(UIHelper.verticalSpace(24.h));
    }

    final videoAttachments = attachments.where(
      (a) =>
          a.attachmentType?.toLowerCase() == 'video' &&
          a.attachment?.isNotEmpty == true,
    );

    for (var att in videoAttachments) {
      widgets.add(
        ProofOfWorkShowingWidget(
          title: "Proof of Video",
          child: _buildVideoPlayer(att.attachment!),
        ),
      );
      widgets.add(UIHelper.verticalSpace(24.h));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final serviceBooking = _paymentDetails.serviceBooking;
    final provider = serviceBooking?.providerId;
    final apiAdditionalCosts = _paymentDetails.additionalCosts ?? [];
    final initialCost = serviceBooking?.startPrice ?? 0.0;

    // Convert to UI model
    final List<AdditionalCostModel> additionalCosts = apiAdditionalCosts
        .map(
          (cost) => AdditionalCostModel(
            title: cost.costName ?? "Additional Cost",
            price: cost.price ?? 0.0,
          ),
        )
        .toList();

    final totalPayment = initialCost +
        additionalCosts.fold(0.0, (sum, cost) => sum + cost.price);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Complete Details",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Work Complete Information",
                  style: TextFontStyle.headline16w700c000000StyleSatoshi,
                ),
                UIHelper.verticalSpace(16.h),

                /// Completion Date
                WorkCompleteDateAndTimeWidget(
                  title: "Completion Date",
                  data: _formatDate(serviceBooking?.completionDate),
                ),
                UIHelper.verticalSpace(16.h),

                /// Duration
                WorkCompleteDateAndTimeWidget(
                  title: "Duration Time",
                  data: serviceBooking?.duration ?? "N/A",
                  isIconVisible: false,
                ),
                UIHelper.verticalSpace(24.h),

                /// Address & Booking Date
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
                        title: "Working Address",
                        icon: Icons.location_on,
                        data: serviceBooking?.address?.en ?? "N/A",
                      ),
                      UIHelper.verticalSpace(14.h),
                      AddressAndOrderDateTile(
                        title: "Booking Order Date",
                        icon: Icons.watch_later_rounded,
                        data: _formatDateTime(serviceBooking?.bookingDateTime),
                      ),
                    ],
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                /// Proof of Work (Images + Videos)
                ..._buildProofOfWorkWidgets(),

                /// Service Provider
                if (provider != null)
                  InkWell(
                    onTap: () {
                      // Get.toNamed(
                      //   Routes.serviceProviderProfileDetailsScreen,
                      //   arguments: provider,
                      // );
                    },
                    child: Container(
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
                          CircleAvatar(
                            radius: 20.r,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: CachedNetworkImage(
                                imageUrl:
                                    '${AppUrl.imageBaseUrl}${provider.profileImage?.imageUrl}',
                              ),
                            ),
                          ),
                          UIHelper.horizontalSpace(6.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.name ?? "Unknown Provider",
                                style: TextFontStyle
                                    .headline16w500c202020StyleSatoshi,
                              ),
                              UIHelper.verticalSpace(2.h),
                              Text(
                                "Services Provider",
                                style: TextFontStyle
                                    .headline10w500c4d4d4dStyleSatoshi,
                              ),
                            ],
                          ),
                          Spacer(),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.find<MessageScreenController>()
                                      .createMessage(
                                    participantId: provider.userId ?? '',
                                    name: provider.name ?? "Unknown Provider",
                                    imageUrl:
                                        '${AppUrl.imageBaseUrl}${provider.profileImage?.imageUrl}',
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(6.sp),
                                  decoration: BoxDecoration(
                                    color: AppColors.cbababa,
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgPicture.asset(
                                    Assets.icons.messageIcon,
                                  ),
                                ),
                              ),
                              UIHelper.horizontalSpace(8.w),
                              Obx(() {
                                final isCallInProgress =
                                    Get.find<CallController>()
                                            .callState
                                            .value !=
                                        CallState.idle;

                                return InkWell(
                                  onTap: isCallInProgress
                                      ? null
                                      : () {
                                          // Call the controller method
                                          Get.find<CallController>()
                                              .initiateAudioCallOutsideInbox(
                                                  receiverId:
                                                      provider.userId ?? '',
                                                  name: provider.name ??
                                                      "Unknown Provider",
                                                  image: ProfileImageModel(
                                                      imageUrl:
                                                          '${AppUrl.imageBaseUrl}${provider.profileImage?.imageUrl}'));
                                        },
                                  child: Icon(
                                    Icons.call,
                                    color: isCallInProgress
                                        ? AppColors.c999999.withOpacity(0.5)
                                        : AppColors.c999999,
                                  ),
                                );
                              })
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                if (provider != null) UIHelper.verticalSpace(24.h),

                /// Payment Summary
                /// Payment Summary
                PaymentSummeryWidget(
                  initialCost: initialCost,
                  additionalCostList: additionalCosts,
                  totalPayment: totalPayment,
                  isTransactionIdCardVisible:
                      serviceBooking?.paymentTransactionId != null,
                  transactionID: serviceBooking?.paymentTransactionId ?? "N/A",
                  isAddAdditionalCostButtonVisible: false,
                  // Hide button in read-only view
                  onTap: () {
                    showAdditionalCostDialog(
                      context: context,
                      additionlCostSubmitOnTap: (String name, double price) {
                        // This is a completed work view, so we just show info message
                        log('Additional cost view requested: $name = \$$price');
                        Get.snackbar(
                          'Info',
                          'This is a read-only view. Additional costs cannot be modified.',
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
        ),
      ),
    );
  }
}

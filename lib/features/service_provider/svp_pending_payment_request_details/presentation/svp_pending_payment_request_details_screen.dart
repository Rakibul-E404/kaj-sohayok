import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:video_player/video_player.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/payment_summery_widget.dart';
import '../../../../custom_widgets/proof_of_work_showing_widget.dart';
import '../../../../custom_widgets/work_address_and_date_widget.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../service/network_caller.dart';
import '../../../../service/network_response.dart';
import '../../../../service/secured_storage.dart';
import '../../../../utilities/app_constants.dart';
import '../../../../utilities/app_url.dart';
import '../../../normal_user/work_completed_details/model/additional_cost_model.dart';

class SvpPendingPaymentRequestDetailsScreen extends StatefulWidget {
  const SvpPendingPaymentRequestDetailsScreen({super.key});

  @override
  State<SvpPendingPaymentRequestDetailsScreen> createState() =>
      _SvpPendingPaymentRequestDetailsScreenState();
}

class _SvpPendingPaymentRequestDetailsScreenState
    extends State<SvpPendingPaymentRequestDetailsScreen> {
  final NetworkCaller _networkCaller = NetworkCaller();

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  Map<String, dynamic>? serviceBooking;
  List<dynamic> additionalCosts = [];

  String? bookingId;

  // Video player controllers
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _getBookingIdAndFetchDetails();
  }

  @override
  void dispose() {
    // Dispose all video controllers
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    super.dispose();
  }

  void _getBookingIdAndFetchDetails() {
    final args = Get.arguments as Map<String, dynamic>?;
    bookingId = args?['bookingId'] as String?;

    if (bookingId == null || bookingId!.isEmpty) {
      setState(() {
        hasError = true;
        errorMessage = 'Booking ID not found';
        isLoading = false;
      });
      return;
    }

    _fetchPaymentRequestDetails();
  }

  Future<void> _fetchPaymentRequestDetails() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });

      final token = await SecureStorageService().read(AppConstants.accessToken);

      if (token == null) {
        setState(() {
          hasError = true;
          errorMessage = 'authentication_required_login_again'.tr;
          isLoading = false;
        });
        return;
      }

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.providerPaymentRequestDetails(bookingId!),
        headers: {'Authorization': 'Bearer $token'},
      );

      log('Payment Details API Response: ${response.statusCode}');
      log('Response Body: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['code'] == 200 &&
            responseData['data'] != null &&
            responseData['data']['attributes'] != null) {
          final attributes = responseData['data']['attributes'];

          setState(() {
            serviceBooking = attributes['serviceBooking'] as Map<String, dynamic>?;
            additionalCosts = attributes['additionalCosts'] as List<dynamic>? ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            errorMessage = responseData['message'] ?? 'unexpected_response_format'.tr;
            isLoading = false;
          });
        }
      } else {
        final errorMsg = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'failed_to_load_payment_details'.tr;

        setState(() {
          hasError = true;
          errorMessage = errorMsg;
          isLoading = false;
        });

        if (response.statusCode == 401 || response.statusCode == 403) {
          await SecureStorageService().delete(AppConstants.accessToken);
          await SecureStorageService().delete(AppConstants.refreshToken);
          Get.offAllNamed('/login');
        }
      }
    } catch (e, stackTrace) {
      log('Error fetching payment details: $e',
          error: e, stackTrace: stackTrace);
      setState(() {
        hasError = true;
        errorMessage = 'network_error_check_again'.tr;
        isLoading = false;
      });
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'N/A';
    }

    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[dateTime.month - 1];
      final day = dateTime.day;
      final year = dateTime.year;
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour < 12 ? 'AM' : 'PM';
      return '$month $day, $year  ${hour.toString().padLeft(2, '0')}:$minute$period';
    } catch (e) {
      log('Error formatting date: $e');
      return dateTimeString;
    }
  }

  String _getAddress(dynamic address) {
    if (address == null) return 'address_not_available'.tr;
    if (address is Map<String, dynamic>) {
      return address['en'] ?? address['bn'] ?? 'address_not_available'.tr;
    }
    return address.toString();
  }

  String _formatCompletionDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final year = date.year.toString().substring(2);
      return '$month-$day-$year';
    } catch (e) {
      log('Error formatting completion date: $e');
      return dateString;
    }
  }

  List<Map<String, dynamic>> _getProofImages() {
    if (serviceBooking == null) return [];

    final attachments = serviceBooking!['attachments'] as List<dynamic>? ?? [];

    return attachments
        .where((attachment) =>
    attachment is Map<String, dynamic> &&
        (attachment['attachmentType'] == 'image' ||
            !_isVideoUrl(attachment['attachment'] as String? ?? '')))
        .map((attachment) => {
      'url': attachment['attachment'] as String? ?? '',
      'id': attachment['_attachmentId'] as String? ?? '',
      'type': 'image',
    })
        .where((image) => image['url']!.isNotEmpty)
        .toList();
  }

  bool _isVideoUrl(String url) {
    if (url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('.avi') ||
        lowerUrl.contains('.mkv') ||
        lowerUrl.contains('.wmv') ||
        lowerUrl.contains('.flv') ||
        lowerUrl.contains('.webm');
  }

  List<Map<String, dynamic>> _getAllMediaFiles() {
    if (serviceBooking == null) return [];

    final attachments = serviceBooking!['attachments'] as List<dynamic>? ?? [];

    return attachments
        .where((attachment) => attachment is Map<String, dynamic>)
        .map((attachment) {
      final url = attachment['attachment'] as String? ?? '';
      final id = attachment['_attachmentId'] as String? ?? '';
      var type = attachment['attachmentType'] as String? ?? 'image';

      // Auto-detect video from URL
      if (type == 'image' && _isVideoUrl(url)) {
        type = 'video';
      } else if (type == 'video' && !_isVideoUrl(url)) {
        type = _isVideoUrl(url) ? 'video' : 'image';
      }

      return {
        'url': url,
        'id': id,
        'type': type,
      };
    })
        .where((media) => media['url']!.isNotEmpty)
        .toList();
  }

  Future<VideoPlayerController?> _getOrCreateVideoController(String videoUrl) async {
    if (_videoControllers.containsKey(videoUrl)) {
      return _videoControllers[videoUrl];
    }

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _videoControllers[videoUrl] = controller;
      await controller.initialize();
      controller.setLooping(true);

      if (mounted) {
        setState(() {});
      }

      return controller;
    } catch (e) {
      log('Error initializing video player: $e');
      return null;
    }
  }

  void _showAllMediaFiles(BuildContext context) {
    final allMedia = _getAllMediaFiles();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Media Files (${allMedia.length})',
                      style: TextFontStyle.headline18w700c000000StyleSatoshi,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              // Media list
              Expanded(
                child: allMedia.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 60.h, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text(
                        'No media files found',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.all(20.w),
                  itemCount: allMedia.length,
                  separatorBuilder: (_, __) => UIHelper.verticalSpace(16.h),
                  itemBuilder: (context, index) {
                    final media = allMedia[index];
                    final isVideo = media['type'] == 'video';
                    final mediaUrl = media['url']!;

                    return _MediaItemCard(
                      mediaUrl: mediaUrl,
                      isVideo: isVideo,
                      index: index,
                      onGetController: _getOrCreateVideoController,
                      onOpenFullScreen: (url, isVid) {
                        if (isVid) {
                          _openVideoFullScreen(url, context);
                        } else {
                          _openImageFullScreen(url, allMedia, context);
                        }
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  void _openVideoFullScreen(String videoUrl, BuildContext context) async {
    final controller = await _getOrCreateVideoController(videoUrl);

    if (controller == null || !controller.value.isInitialized) {
      Get.snackbar(
        'Error',
        'Failed to load video',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Store the playing state before opening fullscreen
    final wasPlaying = controller.value.isPlaying;

    // Pause the video before opening fullscreen
    if (wasPlaying) {
      await controller.pause();
    }

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => _FullScreenVideoPlayer(
        controller: controller,
        videoUrl: videoUrl,
        wasPlayingBefore: wasPlaying,
      ),
    );
  }

  void _openImageFullScreen(String imageUrl, List<Map<String, dynamic>> allMedia, BuildContext context) {
    final imageUrls = allMedia
        .where((media) => media['type'] == 'image')
        .map((media) => media['url']!)
        .toList();

    final initialIndex = imageUrls.indexOf(imageUrl);

    if (initialIndex == -1) return;

    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: imageUrls.length,
              controller: PageController(initialPage: initialIndex),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: Image.network(
                      imageUrls[index],
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 60.h, color: Colors.white),
                              SizedBox(height: 16.h),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Text(
                '${initialIndex + 1} of ${imageUrls.length}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Payment Request Details",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.c000e08),
            UIHelper.verticalSpace(16.h),
            Text(
              'Loading payment details...',
              style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
            ),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50.h, color: Colors.red),
              UIHelper.verticalSpace(16.h),
              Text(
                errorMessage,
                style: TextFontStyle.headline10w400c6c606cStyleSatoshi
                    .copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              UIHelper.verticalSpace(16.h),
              ElevatedButton(
                onPressed: _fetchPaymentRequestDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.c000e08,
                  foregroundColor: Colors.white,
                ),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (serviceBooking == null) {
      return Center(
        child: Text(
          'No payment details available',
          style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
        ),
      );
    }

    return _buildDetailsContent();
  }

  Widget _buildDetailsContent() {
    final address = _getAddress(serviceBooking!['address']);
    final bookingDateTime = _formatDateTime(serviceBooking!['bookingDateTime'] as String?);
    final completionDate = serviceBooking!['completionDate'] as String?;
    final duration = serviceBooking!['duration'] as String? ?? '0';
    final startPrice = (serviceBooking!['startPrice'] as num?)?.toDouble() ?? 0.0;

    final proofImages = _getProofImages();
    final allMedia = _getAllMediaFiles();

    final additionalCostsList = additionalCosts.map((cost) {
      final costMap = cost as Map<String, dynamic>;
      return AdditionalCostModel(
        title: costMap['costName'] ?? 'Additional Cost',
        price: (costMap['price'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    final totalPayment = startPrice + additionalCostsList.fold<double>(
      0.0,
          (sum, item) => sum + item.price,
    );

    return RefreshIndicator(
      onRefresh: _fetchPaymentRequestDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: UIHelper.kDefaulutPadding(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WorkAddressAndDateWidget(
                address: address,
                dateTime: bookingDateTime,
              ),
              UIHelper.verticalSpace(16.h),

              Text(
                "Proof Of Work Complete Information",
                style: TextFontStyle.headline16w700c202020StyleSatoshi,
              ),
              UIHelper.verticalSpace(16.h),

              Container(
                width: 1.sw,
                padding: EdgeInsets.symmetric(
                  vertical: 8.h,
                  horizontal: 27.w,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.ce6e6e6),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Completion Date",
                      style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                    ),
                    UIHelper.verticalSpace(20.h),
                    Row(
                      children: [
                        Text(
                          completionDate != null
                              ? _formatCompletionDate(completionDate)
                              : "N/A",
                          style: TextFontStyle.headline16w700c202020StyleSatoshi,
                        ),
                        Spacer(),
                        Icon(Icons.date_range, color: AppColors.c858c94),
                      ],
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(16.h),

              Container(
                width: 1.sw,
                padding: EdgeInsets.symmetric(
                  vertical: 8.h,
                  horizontal: 27.w,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.ce6e6e6),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Duration Time",
                      style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                    ),
                    UIHelper.verticalSpace(20.h),
                    Text(
                      "$duration ${int.tryParse(duration) == 1 ? 'Day' : 'Days'}",
                      style: TextFontStyle.headline16w700c202020StyleSatoshi,
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(24.h),

              if (proofImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Proof of Images",
                          style: TextFontStyle.headline16w700c202020StyleSatoshi,
                        ),
                        if (allMedia.isNotEmpty)
                          TextButton.icon(
                            onPressed: () => _showAllMediaFiles(context),
                            icon: Icon(Icons.collections, size: 18.h),
                            label: Text(
                              'View All Media',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.c000e08,
                            ),
                          ),
                      ],
                    ),
                    UIHelper.verticalSpace(8.h),
                    ProofOfWorkShowingWidget(
                      title: "",
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: proofImages.length == 1 ? 1 : 2,
                                crossAxisSpacing: 4.w,
                                mainAxisSpacing: 4.h,
                                childAspectRatio: proofImages.length == 1 ? 16 / 9 : 1,
                              ),
                              itemCount: proofImages.length > 4 ? 4 : proofImages.length,
                              itemBuilder: (context, index) {
                                final isLastItem = index == 3 && proofImages.length > 4;

                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      proofImages[index]['url']!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 30.h,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                                  : null,
                                              color: AppColors.c000e08,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    if (isLastItem)
                                      Container(
                                        color: Colors.black.withOpacity(0.6),
                                        child: Center(
                                          child: Text(
                                            '+${proofImages.length - 4}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 32.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else if (allMedia.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Proof of Work",
                          style: TextFontStyle.headline16w700c202020StyleSatoshi,
                        ),
                        TextButton.icon(
                          onPressed: () => _showAllMediaFiles(context),
                          icon: Icon(Icons.collections, size: 18.h),
                          label: Text(
                            'View All Media',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.c000e08,
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(8.h),
                    ProofOfWorkShowingWidget(
                      title: "",
                      child: Container(
                        width: 1.sw,
                        height: 180.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.video_library,
                                size: 50.h,
                                color: AppColors.c000e08,
                              ),
                              UIHelper.verticalSpace(12.h),
                              Text(
                                'No images available',
                                style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                              ),
                              UIHelper.verticalSpace(8.h),
                              Text(
                                '${allMedia.length} media file${allMedia.length == 1 ? '' : 's'} available',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              UIHelper.verticalSpace(12.h),
                              ElevatedButton.icon(
                                onPressed: () => _showAllMediaFiles(context),
                                icon: Icon(Icons.play_circle_outline, size: 18.h),
                                label: Text('View Media Files'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.c000e08,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 12.h,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                ProofOfWorkShowingWidget(
                  title: "Proof of Work",
                  child: Container(
                    width: 1.sw,
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 50.h,
                            color: Colors.grey,
                          ),
                          UIHelper.verticalSpace(8.h),
                          Text(
                            'No proof files available',
                            style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              UIHelper.verticalSpace(24.h),

              PaymentSummeryWidget(
                initialCost: startPrice,
                additionalCostList: additionalCostsList,
                totalPayment: totalPayment,
              ),
              UIHelper.verticalSpace(24.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Separate StatefulWidget for Media Item Card
class _MediaItemCard extends StatefulWidget {
  final String mediaUrl;
  final bool isVideo;
  final int index;
  final Future<VideoPlayerController?> Function(String) onGetController;
  final void Function(String, bool) onOpenFullScreen;

  const _MediaItemCard({
    required this.mediaUrl,
    required this.isVideo,
    required this.index,
    required this.onGetController,
    required this.onOpenFullScreen,
  });

  @override
  State<_MediaItemCard> createState() => _MediaItemCardState();
}

class _MediaItemCardState extends State<_MediaItemCard> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _controller = await widget.onGetController(widget.mediaUrl);
    if (mounted && _controller != null) {
      _controller!.addListener(_videoListener);
      setState(() {
        _isInitialized = _controller!.value.isInitialized;
      });
    }
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.ce6e6e6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media preview
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: Container(
              width: 1.sw,
              height: 220.h,
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.isVideo)
                    _buildVideoPlayer()
                  else
                    Image.network(
                      widget.mediaUrl,
                      width: 1.sw,
                      height: 220.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, size: 50.h, color: Colors.grey),
                                SizedBox(height: 8.h),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                              color: AppColors.c000e08,
                            ),
                          ),
                        );
                      },
                    ),

                  // Video controls overlay
                  if (widget.isVideo && _isInitialized)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: AnimatedOpacity(
                              opacity: _controller!.value.isPlaying ? 0.0 : 1.0,
                              duration: Duration(milliseconds: 300),
                              child: Container(
                                padding: EdgeInsets.all(16.r),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _controller!.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 40.h,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Media info and actions
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isVideo
                      ? 'Tap the video to play/pause'
                      : 'Tap to view full size',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          widget.onOpenFullScreen(
                              widget.mediaUrl, widget.isVideo);
                        },
                        icon: Icon(
                          widget.isVideo ? Icons.fullscreen : Icons.zoom_in,
                          size: 18.h,
                        ),
                        label: Text(widget.isVideo
                            ? 'Full Screen'
                            : 'View Full Size'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.c000e08,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                        ),
                      ),
                    ),
                    if (widget.isVideo && _isInitialized)
                      SizedBox(width: 8.w),
                    if (widget.isVideo && _isInitialized)
                      Text(
                        '${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_controller == null || !_isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16.h),
              Text(
                'Loading video...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}

// ✅ Separate StatefulWidget for Fullscreen Video Player
class _FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String videoUrl;
  final bool wasPlayingBefore;

  const _FullScreenVideoPlayer({
    required this.controller,
    required this.videoUrl,
    required this.wasPlayingBefore,
  });

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_videoListener);
    // Auto-play when entering fullscreen
    widget.controller.play();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    super.dispose();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
      } else {
        widget.controller.play();
      }
      _showControls = true;
    });

    // Auto-hide controls after 3 seconds when playing
    if (widget.controller.value.isPlaying) {
      Future.delayed(Duration(seconds: 3), () {
        if (mounted && widget.controller.value.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio,
                  child: VideoPlayer(widget.controller),
                ),
              ),
            ),

            // Close button
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    widget.controller.pause();
                    Navigator.pop(context);
                    // Resume previous state
                    if (widget.wasPlayingBefore) {
                      widget.controller.play();
                    }
                  },
                ),
              ),
            ),

            // Play/Pause button
            Positioned.fill(
              child: Center(
                child: AnimatedOpacity(
                  opacity:
                  widget.controller.value.isPlaying && !_showControls
                      ? 0.0
                      : 1.0,
                  duration: Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      padding: EdgeInsets.all(24.r),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 60.h,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Video progress controls
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      widget.controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: AppColors.c000e08,
                        bufferedColor: Colors.white30,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(
                              widget.controller.value.position),
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          _formatDuration(
                              widget.controller.value.duration),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
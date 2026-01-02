/**


import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
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

  @override
  void initState() {
    super.initState();
    _getBookingIdAndFetchDetails();
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
        attachment['attachmentType'] == 'image')
        .map((attachment) => {
      'url': attachment['attachment'] as String? ?? '',
      'id': attachment['_attachmentId'] as String? ?? '',
      'type': 'image',
    })
        .where((image) => image['url']!.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> _getAllMediaFiles() {
    if (serviceBooking == null) return [];

    final attachments = serviceBooking!['attachments'] as List<dynamic>? ?? [];

    return attachments
        .where((attachment) => attachment is Map<String, dynamic>)
        .map((attachment) => {
      'url': attachment['attachment'] as String? ?? '',
      'id': attachment['_attachmentId'] as String? ?? '',
      'type': attachment['attachmentType'] as String? ?? 'image',
    })
        .where((media) => media['url']!.isNotEmpty)
        .toList();
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
                      'All Media Files',
                      style: TextFontStyle.headline18w700c000000StyleSatoshi,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              // Media list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.all(20.w),
                  itemCount: allMedia.length,
                  separatorBuilder: (_, __) => UIHelper.verticalSpace(16.h),
                  itemBuilder: (context, index) {
                    final media = allMedia[index];
                    final isVideo = media['type'] == 'video';

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.ce6e6e6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Media preview
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12.r),
                            ),
                            child: Stack(
                              children: [
                                if (isVideo)
                                  Container(
                                    width: 1.sw,
                                    height: 200.h,
                                    color: Colors.black,
                                    child: Center(
                                      child: Icon(
                                        Icons.play_circle_outline,
                                        size: 60.h,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                else
                                  Image.network(
                                    media['url']!,
                                    width: 1.sw,
                                    height: 200.h,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 1.sw,
                                        height: 200.h,
                                        color: Colors.grey.shade200,
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 50.h,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 1.sw,
                                        height: 200.h,
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
                                // Type badge
                                Positioned(
                                  top: 8.h,
                                  right: 8.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isVideo
                                          ? Colors.red.withOpacity(0.8)
                                          : Colors.blue.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isVideo ? Icons.videocam : Icons.image,
                                          size: 16.h,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          isVideo ? 'Video' : 'Image',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Media info
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${isVideo ? 'Video' : 'Image'} ${index + 1}',
                                    style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    // You can add view/download functionality here
                                    log('View media: ${media['url']}');
                                  },
                                  icon: Icon(Icons.open_in_new, size: 18.h),
                                  label: Text('View'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.c000e08,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
    // Extract data from serviceBooking
    final address = _getAddress(serviceBooking!['address']);
    final bookingDateTime = _formatDateTime(serviceBooking!['bookingDateTime'] as String?);
    final completionDate = serviceBooking!['completionDate'] as String?;
    final duration = serviceBooking!['duration'] as String? ?? '0';
    final startPrice = (serviceBooking!['startPrice'] as num?)?.toDouble() ?? 0.0;

    // Get proof images
    final proofImages = _getProofImages();

    // Convert additional costs to AdditionalCostModel list
    final additionalCostsList = additionalCosts.map((cost) {
      final costMap = cost as Map<String, dynamic>;
      return AdditionalCostModel(
        title: costMap['costName'] ?? 'Additional Cost',
        price: (costMap['price'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    // Calculate total payment: startPrice + sum of all additional costs
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
              ///Section : Working Address & Booking Order Date
              WorkAddressAndDateWidget(
                address: address,
                dateTime: bookingDateTime,
              ),
              UIHelper.verticalSpace(24.h),

              ///Section : Text -> work complete information
              Text(
                "Proof Of Work Complete Information",
                style: TextFontStyle.headline16w700c202020StyleSatoshi,
              ),
              UIHelper.verticalSpace(16.h),

              ///Section : Completion Date
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

              ///Section : Duration Time Section
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

              ///Section : Proof Of Work Images
              if (proofImages.isNotEmpty)
                GestureDetector(
                  onTap: () => _showAllMediaFiles(context),
                  child: ProofOfWorkShowingWidget(
                    title: "Proof of Image",
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
                                  // Overlay for remaining images count
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
                )
              else
                ProofOfWorkShowingWidget(
                  title: "Proof of Image",
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
                            'No proof image available',
                            style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              UIHelper.verticalSpace(24.h),

              ///Section : Payment Summary
              PaymentSummeryWidget(
                initialCost: startPrice,
                additionalCostList: additionalCostsList,
                totalPayment: totalPayment,
              ),
              // UIHelper.verticalSpace(24.h),
              //
              // ///Section : Pending Payment Button
              // CustomElevatedButton(
              //   onTap: () {
              //     log("Pending Payment Button Tapped for booking: $bookingId");
              //     // Add your payment action here
              //   },
              //   buttonColor: AppColors.cd5dbf9,
              //   buttonTitle: "Pending Payment",
              //   textStyle: TextFontStyle.headline16w700c989898StyleSatoshi,
              // ),
              UIHelper.verticalSpace(24.h),
            ],
          ),
        ),
      ),
    );
  }
}




*/










import 'dart:developer';
import 'package:chewie/chewie.dart';
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

  @override
  void initState() {
    super.initState();
    _getBookingIdAndFetchDetails();
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
        attachment['attachmentType'] == 'image')
        .map((attachment) => {
      'url': attachment['attachment'] as String? ?? '',
      'id': attachment['_attachmentId'] as String? ?? '',
      'type': 'image',
    })
        .where((image) => image['url']!.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> _getAllMediaFiles() {
    if (serviceBooking == null) return [];

    final attachments = serviceBooking!['attachments'] as List<dynamic>? ?? [];

    return attachments
        .where((attachment) => attachment is Map<String, dynamic>)
        .map((attachment) => {
      'url': attachment['attachment'] as String? ?? '',
      'id': attachment['_attachmentId'] as String? ?? '',
      'type': attachment['attachmentType'] as String? ?? 'image',
    })
        .where((media) => media['url']!.isNotEmpty)
        .toList();
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
                      'All Media Files',
                      style: TextFontStyle.headline18w700c000000StyleSatoshi,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              // Media list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.all(20.w),
                  itemCount: allMedia.length,
                  separatorBuilder: (_, __) => UIHelper.verticalSpace(16.h),
                  itemBuilder: (context, index) {
                    final media = allMedia[index];
                    final isVideo = media['type'] == 'video';

                    return _MediaFileItem(
                      media: media,
                      isVideo: isVideo,
                    );
                  },
                ),
              ),
            ],
          ),
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
    // Extract data from serviceBooking
    final address = _getAddress(serviceBooking!['address']);
    final bookingDateTime = _formatDateTime(serviceBooking!['bookingDateTime'] as String?);
    final completionDate = serviceBooking!['completionDate'] as String?;
    final duration = serviceBooking!['duration'] as String? ?? '0';
    final startPrice = (serviceBooking!['startPrice'] as num?)?.toDouble() ?? 0.0;

    // Get proof images
    final proofImages = _getProofImages();

    // Convert additional costs to AdditionalCostModel list
    final additionalCostsList = additionalCosts.map((cost) {
      final costMap = cost as Map<String, dynamic>;
      return AdditionalCostModel(
        title: costMap['costName'] ?? 'Additional Cost',
        price: (costMap['price'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    // Calculate total payment: startPrice + sum of all additional costs
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
              ///Section : Working Address & Booking Order Date
              WorkAddressAndDateWidget(
                address: address,
                dateTime: bookingDateTime,
              ),
              UIHelper.verticalSpace(24.h),

              ///Section : Text -> work complete information
              Text(
                "Proof Of Work Complete Information",
                style: TextFontStyle.headline16w700c202020StyleSatoshi,
              ),
              UIHelper.verticalSpace(16.h),

              ///Section : Completion Date
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

              ///Section : Duration Time Section
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

              ///Section : Proof Of Work Images
              if (proofImages.isNotEmpty)
                GestureDetector(
                  onTap: () => _showAllMediaFiles(context),
                  child: ProofOfWorkShowingWidget(
                    title: "Proof of Image",
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
                                  // Overlay for remaining images count
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
                )
              else
                ProofOfWorkShowingWidget(
                  title: "Proof of Image",
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
                            'No proof image available',
                            style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              UIHelper.verticalSpace(24.h),

              ///Section : Payment Summary
              PaymentSummeryWidget(
                initialCost: startPrice,
                additionalCostList: additionalCostsList,
                totalPayment: totalPayment,
              ),
              // UIHelper.verticalSpace(24.h),
              //
              // ///Section : Pending Payment Button
              // CustomElevatedButton(
              //   onTap: () {
              //     log("Pending Payment Button Tapped for booking: $bookingId");
              //     // Add your payment action here
              //   },
              //   buttonColor: AppColors.cd5dbf9,
              //   buttonTitle: "Pending Payment",
              //   textStyle: TextFontStyle.headline16w700c989898StyleSatoshi,
              // ),
              UIHelper.verticalSpace(24.h),
            ],
          ),
        ),
      ),
    );
  }
}



class _MediaFileItem extends StatefulWidget {
  final Map<String, dynamic> media;
  final bool isVideo;

  const _MediaFileItem({
    required this.media,
    required this.isVideo,
  });

  @override
  State<_MediaFileItem> createState() => _MediaFileItemState();
}

class _MediaFileItemState extends State<_MediaFileItem> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  get index => null;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.media['url']!),
      );

      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.c000e08,
          handleColor: AppColors.c000e08,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: Colors.grey.shade500,
        ),
        placeholder: Container(
          color: Colors.grey.shade200,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.c000e08,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 50.h),
                SizedBox(height: 10.h),
                Text(
                  'Error loading video',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      log('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaUrl = widget.media['url']!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.ce6e6e6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(12.r),
            ),
            child: Stack(
              children: [
                if (widget.isVideo)
                  Container(
                    width: 1.sw,
                    height: 200.h,
                    color: Colors.black,
                    child: _isVideoInitialized && _chewieController != null
                        ? Chewie(
                      controller: _chewieController!,
                    )
                        : Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Image.network(
                    mediaUrl,
                    width: 1.sw,
                    height: 200.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 1.sw,
                        height: 200.h,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.broken_image,
                          size: 50.h,
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 1.sw,
                        height: 200.h,
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
                // Type badge
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isVideo
                          ? Colors.red.withOpacity(0.8)
                          : Colors.blue.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isVideo ? Icons.videocam : Icons.image,
                          size: 16.h,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          widget.isVideo ? 'Video' : 'Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Media info
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.isVideo ? 'Video' : 'Image'} ${index + 1}',
                    style: TextFontStyle.headline14w500c4d4d4dStyleSatoshi,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // You can add view/download functionality here
                    log('View media: ${mediaUrl}');
                    // Optionally open in browser
                    if (widget.isVideo) {
                      // Show video in full screen
                      _chewieController?.enterFullScreen();
                    }
                  },
                  icon: Icon(Icons.open_in_new, size: 18.h),
                  label: Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.c000e08,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}













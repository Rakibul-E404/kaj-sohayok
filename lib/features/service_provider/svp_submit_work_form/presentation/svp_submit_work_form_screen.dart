
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import '../../../../constants/appList.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/payment_summery_widget.dart';
import '../../../../custom_widgets/proof_of_image_uploading_widget.dart';
import '../../../../controllers/svp_submit_work_form_screen_controller.dart';
import '../../../../custom_widgets/work_address_and_date_widget.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../custom_widgets/more_info_widget_tile.dart';
import '../../../normal_user/work_completed_details/widgets/additional_cost_popup.dart';

class SvpSubmitWorkFormScreen extends StatefulWidget {
  const SvpSubmitWorkFormScreen({super.key});

  @override
  State<SvpSubmitWorkFormScreen> createState() => _SvpSubmitWorkFormScreenState();
}

class _SvpSubmitWorkFormScreenState extends State<SvpSubmitWorkFormScreen> {
  SvpSubmitWorkFormScreenController controller = Get.put(
    SvpSubmitWorkFormScreenController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Submit Work Form",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: UIHelper.kDefaulutPadding(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Section : Working Address & Booking Order Date
                WorkAddressAndDateWidget(
                  address: "Rampura Dhaka, Bangladesh",
                  dateTime: "Jun 17, 2025  09:31AM",
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Text -> Proof Of Work Complete Information
                Text(
                  "Proof Of Work Complete Information",
                  style: TextFontStyle.headline16w700c202020StyleSatoshi,
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Completion Date
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(), // today by default
                      firstDate: DateTime(2000), // earliest date
                      lastDate: DateTime(2100), // latest date
                    );

                    if (picked != null) {
                      final formatted = DateFormat('MM-dd-yyyy').format(picked);
                      controller.completionDateController.text = formatted;
                    }
                  },
                  child: MoreInfoWidgetTile(
                    title: "Completion Date",
                    hintText: "Select Date",
                    isEnabled: false,
                    controller: controller.completionDateController,
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Duration Time
                MoreInfoWidgetTile(
                  title: "Duration Time",
                  hintText: "Type Day's In Numbers",
                  keyboardType: TextInputType.number,
                  controller: controller.durationTimeController,
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Proof of Image Upload
                Obx(() {
                  return ProofOfImageUploadWidget(
                    onTap: () {
                      log("Browse Button Tapped - Image");
                      controller.showImageSourceDialog();
                    },
                    removeImageOnTap: () {
                      controller.removeImage();
                    },
                    imagePath: controller.selectedImage.value,
                    title: "Proof of Image",
                  );
                }),
                UIHelper.verticalSpace(24.h),

                ///Section : Proof of Video Upload
                Obx(() {
                  return controller.selectedVideo.value.isEmpty
                      ? ProofOfImageUploadWidget(
                    onTap: () {
                      log("Browse Button Tapped - Video");
                      controller.showVideoSourceDialog();
                    },
                    removeImageOnTap: () {
                      controller.removeVideo();
                    },
                    imagePath: controller.selectedVideo.value,
                    title: "Proof of Video",
                  )
                      : Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title for video section
                        Text(
                          "Proof of Video",
                          style: TextFontStyle.headline16w700c202020StyleSatoshi,
                        ),
                        UIHelper.verticalSpace(12.h),

                        // Video preview container with remove button
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              // Video Player
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: VideoPlayerWidget(controller.selectedVideo.value),
                              ),
                              UIHelper.verticalSpace(12.h),

                              // Remove button at the bottom of container
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () {
                                    controller.removeVideo();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      "Remove",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                UIHelper.verticalSpace(24.h),

                ///Section : Payment Summary
                PaymentSummeryWidget(
                  onTap: () {
                    showAdditionalCostDialog(
                      context: context,
                      additionlCostSubmitOnTap: () {
                        Get.back();
                      },
                    );
                  },
                  initialCost: 30,
                  additionalCostList: AppList.additionalCosts,
                  totalPayment:
                  30 +
                      AppList.additionalCosts.fold(
                        0,
                            (sum, item) => sum + item.price,
                      ),
                  isAddAdditionalCostButtonVisible: true,
                ),
                UIHelper.verticalSpace(32.h),

                ///Section : Payment Request Button
                CustomElevatedButton(
                  onTap: () {
                    log("Button Tapped -> Payment Request!");
                  },
                  buttonTitle: "Payment Request",
                ),
                UIHelper.verticalSpace(32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}







///
///
///
/// todo:: getting the api data and merging the image-video field
///
///
///



//
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
// import 'package:kaz_bd/helpers/ui_helpers.dart';
// import '../../../../constants/appList.dart';
// import '../../../../constants/text_font_style.dart';
// import '../../../../custom_widgets/payment_summery_widget.dart';
// import '../../../../custom_widgets/proof_of_image_uploading_widget.dart';
// import '../../../../controllers/svp_submit_work_form_screen_controller.dart';
// import '../../../../custom_widgets/work_address_and_date_widget.dart';
// import '../../../../gen/colors.gen.dart';
// import '../../../../custom_widgets/more_info_widget_tile.dart';
// import '../../../../service/network_caller.dart';
// import '../../../../service/network_response.dart';
// import '../../../../service/secured_storage.dart';
// import '../../../../utilities/app_constants.dart';
// import '../../../../utilities/app_url.dart';
//
// class SvpSubmitWorkFormScreen extends StatefulWidget {
//   const SvpSubmitWorkFormScreen({super.key});
//
//   @override
//   State<SvpSubmitWorkFormScreen> createState() => _SvpSubmitWorkFormScreenState();
// }
//
// class _SvpSubmitWorkFormScreenState extends State<SvpSubmitWorkFormScreen> {
//   SvpSubmitWorkFormScreenController controller = Get.put(
//     SvpSubmitWorkFormScreenController(),
//   );
//
//   final NetworkCaller _networkCaller = NetworkCaller();
//   String? bookingId;
//   bool isLoading = true;
//   bool hasError = false;
//   String errorMessage = '';
//   Map<String, dynamic> workSubmitData = {};
//
//   @override
//   void initState() {
//     super.initState();
//
//     final arguments = Get.arguments as Map<String, dynamic>?;
//     bookingId = arguments?["bookingId"] as String? ?? '';
//
//     if (bookingId != null && bookingId!.isNotEmpty) {
//       fetchWorkSubmitFormData();
//     } else {
//       setState(() {
//         isLoading = false;
//         hasError = true;
//         errorMessage = 'Booking ID not found';
//       });
//     }
//   }
//
//   Future<void> fetchWorkSubmitFormData() async {
//     if (bookingId == null || bookingId!.isEmpty) return;
//
//     setState(() {
//       isLoading = true;
//       hasError = false;
//       errorMessage = '';
//     });
//
//     try {
//       final token = await SecureStorageService().read(AppConstants.accessToken);
//
//       if (token == null) {
//         setState(() {
//           isLoading = false;
//           hasError = true;
//           errorMessage = 'Authentication required. Please login again.';
//         });
//         return;
//       }
//
//       final NetworkResponse response = await _networkCaller.getRequest(
//         AppUrl.providerWorkSubmitForm(bookingId!),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.isSuccess && response.jsonResponse != null) {
//         final responseData = response.jsonResponse!;
//
//         if (responseData['code'] == 200 && responseData['data'] != null) {
//           final data = responseData['data']['attributes'] as Map<String, dynamic>? ?? {};
//
//           setState(() {
//             workSubmitData = data;
//             isLoading = false;
//           });
//
//           _updateControllerWithData(data);
//         } else {
//           setState(() {
//             isLoading = false;
//             hasError = true;
//             errorMessage = responseData['message'] ?? 'Failed to load work submit form data';
//           });
//         }
//       } else {
//         final errorMsg = response.jsonResponse?['message'] ??
//             response.errorMessage ??
//             'Failed to load work submit form data';
//
//         setState(() {
//           isLoading = false;
//           hasError = true;
//           errorMessage = errorMsg;
//         });
//
//         if (response.statusCode == 401 || response.statusCode == 403) {
//           await SecureStorageService().delete(AppConstants.accessToken);
//           await SecureStorageService().delete(AppConstants.refreshToken);
//         }
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         hasError = true;
//         errorMessage = 'Network error. Please check your connection.';
//       });
//     }
//   }
//
//   void _updateControllerWithData(Map<String, dynamic> data) {
//     final durationTime = data['duration']?.toString() ?? '';
//     if (durationTime.isNotEmpty) {
//       controller.durationTimeController.text = durationTime;
//     }
//
//     final completionDate = data['completionDate'] as String?;
//     if (completionDate != null && completionDate.isNotEmpty) {
//       try {
//         final dateTime = DateTime.parse(completionDate).toLocal();
//         final formatted = DateFormat('MM-dd-yyyy').format(dateTime);
//         controller.completionDateController.text = formatted;
//       } catch (e) {
//         log('Error parsing completion date: $e');
//       }
//     }
//   }
//
//   String getAddress() {
//     final address = workSubmitData['address'] as Map<String, dynamic>?;
//     if (address == null) return 'Address not available';
//     return address['en'] ?? address['bn'] ?? 'Address not available';
//   }
//
//   String getDateTime() {
//     final bookingDateTime = workSubmitData['bookingDateTime'] as String? ?? '';
//     if (bookingDateTime.isEmpty) return 'Date not available';
//
//     try {
//       final dateTime = DateTime.parse(bookingDateTime).toLocal();
//       final months = [
//         'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//       ];
//       final month = months[dateTime.month - 1];
//       final day = dateTime.day;
//       final year = dateTime.year;
//       final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
//       final minute = dateTime.minute.toString().padLeft(2, '0');
//       final period = dateTime.hour < 12 ? 'AM' : 'PM';
//       return '$month $day, $year  ${hour.toString().padLeft(2, '0')}:$minute$period';
//     } catch (e) {
//       return bookingDateTime;
//     }
//   }
//
//   double getInitialCost() {
//     return (workSubmitData['startPrice'] as num?)?.toDouble() ?? 30.0;
//   }
//
//   // ✅ FIXED: Now returns List<AdditionalCostModel>
//   List<AdditionalCostModel> getAdditionalCosts() {
//     final additionalCosts = workSubmitData['additionalCosts'] as List<dynamic>?;
//
//     if (additionalCosts != null && additionalCosts.isNotEmpty) {
//       return _createAdditionalCostModels(additionalCosts);
//     }
//
//     return [];
//   }
//
//   // ✅ FIXED: Always returns List<AdditionalCostModel>
//   List<AdditionalCostModel> _createAdditionalCostModels(List<dynamic> apiCosts) {
//     final List<AdditionalCostModel> models = [];
//
//     for (var item in apiCosts) {
//       if (item is Map<String, dynamic>) {
//         final name = item['name']?.toString() ?? 'Additional Cost';
//         final price = (item['price'] as num?)?.toDouble() ?? 0.0;
//         models.add(AdditionalCostModel(name: name, price: price));
//       }
//       // Skip non-Map items to avoid crashes
//     }
//
//     return models;
//   }
//
//   double getTotalPayment() {
//     double total = getInitialCost();
//     for (var cost in getAdditionalCosts()) {
//       total += cost.price;
//     }
//     return total;
//   }
//
//   Widget _buildLoading() {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(20.h),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: AppColors.c000e08),
//             UIHelper.verticalSpace(16.h),
//             Text(
//               'Loading work submit form...',
//               style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildError() {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(20.h),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 50.h, color: Colors.red),
//             UIHelper.verticalSpace(16.h),
//             Text(
//               errorMessage,
//               style: TextFontStyle.headline10w400c6c606cStyleSatoshi.copyWith(color: Colors.red),
//               textAlign: TextAlign.center,
//             ),
//             UIHelper.verticalSpace(16.h),
//             CustomElevatedButton(
//               onTap: fetchWorkSubmitFormData,
//               buttonTitle: "Retry",
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showAdditionalCostDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(
//           'Add Additional Cost',
//           style: TextFontStyle.headline16w700c000000StyleSatoshi,
//         ),
//         content: Text(
//           'Additional cost functionality will be implemented here.',
//           style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text(
//               'Cancel',
//               style: TextFontStyle.headline14w500c606060StyleSatoshi,
//             ),
//           ),
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text(
//               'Add',
//               style: TextFontStyle.headline14w500c000000StyleSatoshi,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPaymentSummary() {
//     try {
//       final additionalCosts = getAdditionalCosts(); // ✅ Now List<AdditionalCostModel>
//
//       return PaymentSummeryWidget(
//         onTap: () {
//           _showAdditionalCostDialog(context);
//         },
//         initialCost: getInitialCost(),
//         additionalCostList: additionalCosts, // ✅ Correct type
//         totalPayment: getTotalPayment(),
//         isAddAdditionalCostButtonVisible: true,
//       );
//     } catch (e) {
//       log('Error building PaymentSummeryWidget: $e');
//       return Container(
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.red.shade50,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(color: Colors.red.shade200),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Error loading payment summary',
//               style: TextFontStyle.headline14w500c000000StyleSatoshi.copyWith(color: Colors.red),
//             ),
//             UIHelper.verticalSpace(8.h),
//             Text(
//               'Please check your connection and try again.',
//               style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   Widget _buildContent() {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: UIHelper.kDefaulutPadding(),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             WorkAddressAndDateWidget(
//               address: getAddress(),
//               dateTime: getDateTime(),
//             ),
//             UIHelper.verticalSpace(24.h),
//
//             Text(
//               "Proof Of Work Complete Information",
//               style: TextFontStyle.headline16w700c202020StyleSatoshi,
//             ),
//             UIHelper.verticalSpace(16.h),
//
//             InkWell(
//               onTap: () async {
//                 final DateTime? picked = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2100),
//                 );
//
//                 if (picked != null) {
//                   final formatted = DateFormat('MM-dd-yyyy').format(picked);
//                   controller.completionDateController.text = formatted;
//                 }
//               },
//               child: MoreInfoWidgetTile(
//                 title: "Completion Date",
//                 hintText: "Select Date",
//                 isEnabled: false,
//                 controller: controller.completionDateController,
//               ),
//             ),
//             UIHelper.verticalSpace(16.h),
//
//             MoreInfoWidgetTile(
//               title: "Duration Time",
//               hintText: "Type Day's In Numbers",
//               keyboardType: TextInputType.number,
//               controller: controller.durationTimeController,
//             ),
//             UIHelper.verticalSpace(24.h),
//
//             Obx(() {
//               return Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(16.w),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12.r),
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       spreadRadius: 1,
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Proof of Work Completion",
//                       style: TextFontStyle.headline16w700c202020StyleSatoshi,
//                     ),
//                     UIHelper.verticalSpace(12.h),
//
//                     Text(
//                       "Upload Images",
//                       style: TextFontStyle.headline14w500c000000StyleSatoshi,
//                     ),
//                     UIHelper.verticalSpace(8.h),
//                     ProofOfImageUploadWidget(
//                       onTap: () {
//                         log("Browse Button Tapped - Image");
//                         controller.showImageSourceDialog();
//                       },
//                       removeImageOnTap: () {
//                         controller.removeImage();
//                       },
//                       imagePath: controller.selectedImage.value,
//                       title: "Select Image",
//                     ),
//                     UIHelper.verticalSpace(16.h),
//
//                     Text(
//                       "Upload Video",
//                       style: TextFontStyle.headline14w500c000000StyleSatoshi,
//                     ),
//                     UIHelper.verticalSpace(8.h),
//                     Container(
//                       padding: EdgeInsets.all(12.w),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(
//                           color: Colors.grey.shade300,
//                           width: 1,
//                         ),
//                         color: Colors.white,
//                       ),
//                       child: Column(
//                         children: [
//                           if (controller.selectedVideo.value.isEmpty)
//                             Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         "No video selected",
//                                         style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
//                                       ),
//                                     ),
//                                     CustomElevatedButton(
//                                       onTap: () {
//                                         log("Browse Button Tapped - Video");
//                                         controller.showVideoSourceDialog();
//                                       },
//                                       buttonTitle: "Browse",
//                                       buttonWidth: 100.w,
//                                       buttonHeight: 40.h,
//                                       buttonColor: AppColors.c000e08,
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             )
//                           else
//                             Column(
//                               children: [
//                                 Container(
//                                   padding: EdgeInsets.all(12.w),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade100,
//                                     borderRadius: BorderRadius.circular(8.r),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.videocam, color: AppColors.c000e08),
//                                       UIHelper.horizontalSpace(8.w),
//                                       Expanded(
//                                         child: Text(
//                                           "Video selected",
//                                           style: TextFontStyle.headline14w500c000000StyleSatoshi,
//                                         ),
//                                       ),
//                                       IconButton(
//                                         onPressed: () {
//                                           controller.removeVideo();
//                                         },
//                                         icon: Icon(Icons.delete, color: Colors.red),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 UIHelper.verticalSpace(8.h),
//                                 Text(
//                                   "Tap 'Browse' to change video",
//                                   style: TextFontStyle.headline10w400c6c606cStyleSatoshi,
//                                 ),
//                                 UIHelper.verticalSpace(8.h),
//                                 CustomElevatedButton(
//                                   onTap: () {
//                                     log("Browse Button Tapped - Video");
//                                     controller.showVideoSourceDialog();
//                                   },
//                                   buttonTitle: "Browse",
//                                   buttonWidth: 100.w,
//                                   buttonHeight: 40.h,
//                                   buttonColor: AppColors.c000e08,
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//             UIHelper.verticalSpace(24.h),
//
//             _buildPaymentSummary(),
//             UIHelper.verticalSpace(32.h),
//
//             CustomElevatedButton(
//               onTap: () {
//                 log("Button Tapped -> Submit Work Form!");
//                 _submitWorkForm();
//               },
//               buttonTitle: "Submit Work Form",
//             ),
//             UIHelper.verticalSpace(32.h),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _submitWorkForm() async {
//     try {
//       Get.dialog(
//         const Center(child: CircularProgressIndicator()),
//         barrierDismissible: false,
//       );
//
//       final token = await SecureStorageService().read(AppConstants.accessToken);
//
//       if (token == null) {
//         Get.back();
//         Get.snackbar(
//           'Error',
//           'Authentication required',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         return;
//       }
//
//       final formData = {
//         'bookingId': bookingId,
//         'completionDate': controller.completionDateController.text,
//         'durationTime': controller.durationTimeController.text,
//         'totalPayment': getTotalPayment().toString(),
//       };
//
//       final additionalCosts = getAdditionalCosts();
//       for (int i = 0; i < additionalCosts.length; i++) {
//         final cost = additionalCosts[i];
//         formData['additionalCosts[$i][name]'] = cost.name;
//         formData['additionalCosts[$i][price]'] = cost.price.toString();
//       }
//
//       final NetworkResponse response = await _networkCaller.postRequest(
//         AppUrl.providerWorkSubmitForm(bookingId!), // or use a separate submit endpoint
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: formData,
//       );
//
//       Get.back();
//
//       if (response.isSuccess && response.jsonResponse != null) {
//         final responseData = response.jsonResponse!;
//
//         if (responseData['code'] == 200 || responseData['success'] == true) {
//           Get.snackbar(
//             'Success',
//             'Work form submitted successfully!',
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//           );
//           Get.back();
//         } else {
//           Get.snackbar(
//             'Error',
//             responseData['message'] ?? 'Failed to submit work form',
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//           );
//         }
//       } else {
//         Get.snackbar(
//           'Error',
//           response.errorMessage ?? 'Failed to submit work form',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       Get.back();
//       Get.snackbar(
//         'Error',
//         'Failed to submit work form: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: Text(
//           "Submit Work Form",
//           style: TextFontStyle.headline18w700c000000StyleSatoshi,
//         ),
//         centerTitle: true,
//         backgroundColor: AppColors.scaffoldBackgroundColor,
//       ),
//       body: SafeArea(
//         child: isLoading
//             ? _buildLoading()
//             : hasError
//             ? _buildError()
//             : _buildContent(),
//       ),
//     );
//   }
// }
//
// // // ✅ Keep this — it's used everywhere
// // class AdditionalCostModel {
// //   final String name;
// //   final double price;
// //
// //   AdditionalCostModel({required this.name, required this.price});
// // }
//
//
//
//
//
// class AdditionalCostModel {
//   final String name;
//   final double price;
//
//   AdditionalCostModel({required this.name, required this.price});
//
// }




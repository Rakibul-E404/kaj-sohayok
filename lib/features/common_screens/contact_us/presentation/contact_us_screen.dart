import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/utilities/logger_util.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';
import '../widgets/contact_tile_widget.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the contact data from arguments
    final dynamic contactDataRaw = Get.arguments?['data'];

    // Handle the case where the API returns an empty attributes array
    Map<String, dynamic>? contactData;
    if (contactDataRaw is Map<String, dynamic>) {
      // Check if it's the API response format with attributes array
      final List<dynamic>? attributes = contactDataRaw['data']?['attributes'];
      if (attributes != null && attributes.isNotEmpty) {
        // Use the first item in attributes if available
        contactData = attributes[0] is Map<String, dynamic>
            ? Map<String, dynamic>.from(attributes[0])
            : null;
      } else {
        // No data available, set contactData to null
        contactData = null;
      }
    } else if (contactDataRaw is Map<dynamic, dynamic>) {
      // Handle dynamic map format
      final List<dynamic>? attributes = contactDataRaw['data']?['attributes'];
      if (attributes != null && attributes.isNotEmpty) {
        contactData = attributes[0] is Map<dynamic, dynamic>
            ? Map<String, dynamic>.from(attributes[0])
            : null;
      } else {
        contactData = null;
      }
    } else {
      contactData = null;
    }

    // Log the received data for debugging
    LoggerUtils.error(contactData);

    // Extract data with fallbacks
    final String email = contactData?['email']?.toString().trim() ?? '';
    final String phone = contactData?['phoneNumber']?.toString().trim() ?? '';
    final String detailsOverview =
        contactData?['detailsOverview']?.toString().trim() ?? '';

    // Helper function to parse phone numbers
    List<String> _parsePhoneNumbers(String phoneString) {
      if (phoneString.isEmpty) return [];
      return phoneString
          .split(',')
          .map((num) => num.trim())
          .where((num) => num.isNotEmpty)
          .toList();
    }

    // Parse multiple phone numbers
    final List<String> phoneNumbers = _parsePhoneNumbers(phone);

    /// Launch email client
    Future<void> _launchEmail() async {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {'subject': 'Support Request - KaajBD'},
      );
      if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch email: $emailUri');
      }
    }

    /// Launch phone dialer with specific number
    Future<void> _launchPhone(String phoneNumber) async {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (!await launchUrl(phoneUri)) {
        debugPrint('Could not launch phone: $phoneUri');
      }
    }

    /// Show phone number selection dialog
    void _showPhoneSelectionDialog(BuildContext context) {
      if (phoneNumbers.isEmpty) return;

      if (phoneNumbers.length == 1) {
        // If only one number, call directly
        _launchPhone(phoneNumbers[0]);
      } else {
        // Show dialog for multiple numbers
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'select_phone_number'.tr,
              style: TextFontStyle.headline16w500c000000StyleSatoshi,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: phoneNumbers.map((number) {
                return ListTile(
                  leading: Icon(Icons.phone, color: AppColors.c778beb),
                  title: Text(
                    number,
                    style: TextFontStyle.headline14w400c000000StyleSatoshi,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _launchPhone(number);
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'cancel'.tr,
                  style: TextFontStyle.headline14w400c000000StyleSatoshi,
                ),
              ),
            ],
          ),
        );
      }
    }

    /// Build display text for phone numbers
    String _buildPhoneDisplayText() {
      if (phoneNumbers.isEmpty) return 'No phone number available';

      if (phoneNumbers.length == 1) {
        return phoneNumbers[0];
      } else {
        // Show first number and indicate more available
        return '${phoneNumbers[0]} (+${phoneNumbers.length - 1} more)';
      }
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'contact_us'.tr,
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // // 👇 Header (Optional, can be removed if not in Figma)
                // Text(
                //   'we_here_to_help'.tr,
                //   style: TextStyle(
                //     fontSize: 20.sp,
                //     fontWeight: FontWeight.w700,
                //     color: Colors.black,
                //   ),
                // ),
                // SizedBox(height: 8.h),
                // Text(
                //   'have_ques_or_need'.tr,
                //   style: TextStyle(
                //     fontSize: 15.sp,
                //     color: Colors.grey[600],
                //     height: 1.4,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
                // SizedBox(height: 24.h),

                // 👇 Description / Details Overview (From API)
                if (detailsOverview.isNotEmpty) ...[
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 6.r,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Text(
                      detailsOverview,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                Row(
                  children: [
                    // 👇 Email Tile
                    Expanded(
                      child: ContactTileWidget(
                        onTap: email.isNotEmpty ? _launchEmail : null,
                        icon: Icons.email_outlined,
                        data: email.isNotEmpty ? email : 'No email available',
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // 👇 Phone Tile
                    Expanded(
                      child: ContactTileWidget(
                        onTap: phoneNumbers.isNotEmpty
                            ? () => _showPhoneSelectionDialog(context)
                            : null,
                        icon: Icons.phone_outlined,
                        data: _buildPhoneDisplayText(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                Container(
                  width: 1.sw,
                  padding: EdgeInsets.all(10.sp),
                  decoration: BoxDecoration(
                    color: AppColors.cf1f3fd,
                    border: Border.all(color: AppColors.c92a2ef),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10.sp),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 194, 203, 248),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Image.asset(
                        width: 20.w,
                        height: 20.h,
                        fit: BoxFit.cover,
                        Assets.images.emailIconImage.path,
                      ),
                    ),
                    title: Text(
                      "Facebook",
                      style: TextFontStyle.headline14w400c000000StyleSatoshi,
                    ),
                    subtitle: Text(
                      "Email",
                      style: TextFontStyle.headline14w400c000000StyleSatoshi,
                    ),
                  ),
                ),

                // Add some bottom padding for visual balance
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

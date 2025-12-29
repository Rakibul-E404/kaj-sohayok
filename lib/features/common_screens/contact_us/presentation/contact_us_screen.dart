import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
    final Map<String, dynamic>? contactData = Get.arguments?['data'];

    // Log the received data for debugging
    LoggerUtils.error(contactData);

    // Extract data with fallbacks
    final String email =
        contactData?['email']?.toString().trim() ?? 'Kaajbdofficial@gmail.com';
    final String phone =
        contactData?['phoneNumber']?.toString().trim() ?? '+8801996655';
    final String detailsOverview =
        contactData?['detailsOverview']?.toString().trim() ?? '';

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

    /// Launch phone dialer
    Future<void> _launchPhone() async {
      final Uri phoneUri = Uri(scheme: 'tel', path: phone);
      if (!await launchUrl(phoneUri)) {
        debugPrint('Could not launch phone: $phoneUri');
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
                // 👇 Header (Optional, can be removed if not in Figma)
                Text(
                  'we_here_to_help'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'have_ques_or_need'.tr,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),

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
                          color: Colors.grey.withValues(alpha:  0.1),
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

                // 👇 Email Tile
                ContactTileWidget(
                  onTap: _launchEmail,
                  icon: Icons.email_outlined,
                  data: email,
                ),
                SizedBox(height: 16.h),

                // 👇 Phone Tile
                ContactTileWidget(
                  onTap: _launchPhone,
                  icon: Icons.phone_outlined,
                  data: phone,
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

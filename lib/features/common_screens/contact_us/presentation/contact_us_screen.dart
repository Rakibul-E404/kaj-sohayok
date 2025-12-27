import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/html_wrapper.dart';
import '../../../../gen/colors.gen.dart';
import '../widgets/contact_tile_widget.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static const String _supportEmail = 'Kaajbdofficial@gmail.com';
  static const String _supportPhone = '+8801996655'; // Optional: include if available

  /// Launch email client
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {'subject': 'Support Request - KaajBD'},
    );
    if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch email: $emailUri');
    }
  }

  /// Launch phone dialer
  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: _supportPhone);
    if (!await launchUrl(phoneUri)) {
      debugPrint('Could not launch phone: $phoneUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? bodyText = Get.arguments?['data'];

    // Default rich HTML content with styled email and description
    final String defaultHtmlContent = '''
      <div style="font-family: 'Roboto', sans-serif; color: #333; line-height: 1.6; font-size: 16px;">
        <p>
          Thank you for using <strong>KaajBD</strong>! We’re here to assist you with any questions, 
          feedback, or support you may need.
        </p>
        <p>
          Whether you’re experiencing an issue, have a suggestion for improvement, 
          or simply want to say hello — don’t hesitate to reach out.
        </p>
        <p style="margin-top: 20px; padding-top: 16px; border-top: 1px solid #eee;">
          <strong>📧 Primary Contact Email:</strong><br/>
          <a href="mailto:$_supportEmail?subject=Support%20Request%20-%20KaajBD" 
             style="color: #1976D2; text-decoration: none; font-weight: 600;">
            $_supportEmail
          </a>
        </p>
        <p style="margin-top: 12px; font-size: 14px; color: #666;">
          We typically respond within 24–48 business hours.
        </p>
      </div>
    ''';

    final String effectiveHtml = (bodyText?.trim().isNotEmpty == true)
        ? bodyText!
        : defaultHtmlContent;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👇 Informative header text
                Text(
                  'We’re here to help!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Have questions or need assistance? Reach out to our support team.',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24.h),

                // 👇 Dynamic or default HTML content
                HtmlWrapper(htmlContent: effectiveHtml),

                // Optional: Always show email as a tappable tile (even with custom HTML)
                // Uncomment below if you want consistent contact actions
                /*
                if (bodyText?.trim().isEmpty == true) ...[
                  SizedBox(height: 32.h),
                  ContactTileWidget(
                    onTap: _launchEmail,
                    icon: Icons.email_outlined,
                    data: _supportEmail,
                  ),
                  SizedBox(height: 16.h),
                  ContactTileWidget(
                    onTap: _launchPhone,
                    icon: Icons.phone_outlined,
                    data: _supportPhone,
                  ),
                ],
                */
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/html_wrapper.dart';
import '../../../../gen/colors.gen.dart';
import '../widgets/contact_tile_widget.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  /// function to launch email
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(emailUri)) {
      throw Exception('Could not launch $emailUri');
    }
  }

  /// function to launch phone dialer
  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      throw Exception('${'could_not_launch'.tr} $phoneUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String bodyText = Get.arguments['data'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'contact_us'.tr,
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: HtmlWrapper(htmlContent: bodyText),
            // child: Column(
            //   children: [
            //     /// Email Section
            //     ContactTileWidget(
            //       onTap: () => _launchEmail("support.info@gmail.com"),
            //       icon: Icons.email,
            //       data: "support.info@gmail.com",
            //     ),
            //     UIHelper.verticalSpace(32.h),
            //
            //     /// Divider
            //     const Divider(),
            //     UIHelper.verticalSpace(32.h),
            //
            //     /// Phone Section
            //     ContactTileWidget(
            //       onTap: () => _launchPhone("+8801996655"),
            //       icon: Icons.phone,
            //       data: "+8801996655",
            //     ),
            //     UIHelper.verticalSpace(32.h),
            //   ],
            // ),
          ),
        ),
      ),
    );
  }
}

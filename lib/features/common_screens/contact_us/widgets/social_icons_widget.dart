import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../utilities/logger_util.dart';

class SocialIconsWidget extends StatelessWidget {
  final String socialHandalerName;
  final void Function()? onTap;
  final String iconPath;
  final String? url;

  const SocialIconsWidget({
    super.key,
    required this.socialHandalerName,
    this.onTap,
    required this.iconPath,
    this.url,
  });

  Future<void> _launchURL(BuildContext context) async {
    if (url == null || url!.isEmpty) {
      onTap?.call();
      return;
    }

    try {
      // Format the URL to ensure it has https://
      String formattedUrl = url!;

      // Add https:// if missing
      if (!formattedUrl.startsWith('http://') &&
          !formattedUrl.startsWith('https://')) {
        formattedUrl = 'https://$formattedUrl';
      }

      final Uri uri = Uri.parse(formattedUrl);

      LoggerUtils.debug('Attempting to launch URL: $formattedUrl');

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        LoggerUtils.debug('Successfully launched URL: $formattedUrl');
      } else {
        // Try alternative methods
        LoggerUtils.error('canLaunchUrl returned false for: $formattedUrl');

        // Try to launch directly as a string
        try {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          // Show error message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Could not open link. Please check if you have a browser app installed.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          LoggerUtils.error('Could not launch $formattedUrl: $e');
        }
      }
    } catch (e) {
      LoggerUtils.error('Error in _launchURL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.cf1f3fd,
        border: Border.all(color: AppColors.c92a2ef),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListTile(
        onTap: () {
          if (url != null) {
            _launchURL(context);
          } else {
            onTap?.call();
          }
        },
        leading: Container(
          width: 40.w,
          height: 40.h,
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 194, 203, 248),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: SvgPicture.asset(iconPath),
        ),
        title: Text(
          socialHandalerName,
          style: TextFontStyle.headline14w400c000000StyleSatoshi,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 24.sp,
        ),
      ),
    );
  }
}

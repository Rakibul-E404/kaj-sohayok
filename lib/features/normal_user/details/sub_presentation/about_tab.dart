import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/routes/routes.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../custom_widgets/custom_text_with_readmore_button.dart';
import '../../../../helpers/ui_helpers.dart';

class AboutTab extends StatelessWidget {
  final bool isRoutedFromBookingTab;
  const AboutTab({super.key, required this.isRoutedFromBookingTab});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('about'),
      padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Services Description",
            style: TextFontStyle.headline16w500c000000StyleSatoshi,
          ),
          UIHelper.verticalSpace(12.h),

          CustomTextWidgetWithReadMoreButton(
            text:
                "Home Cleaning – Professional and eco-friendly cleaning for "
                "every corner of your home. From regular upkeep to deep cleaning,"
                "we make your space fresh, spotless, and ready to enjoy.",
            trimLines: 3,
          ),
          UIHelper.verticalSpace(24.h),

          ///Section : Service Provider Image
          ///Section : Service Provider Name
          ///Section : Service Provider
          ///Section : Message
          ///Section : Call
          InkWell(
            onTap: () {
              Get.toNamed(Routes.serviceProviderProfileDetailsScreen);
            },
            child: Container(
              width: 1.sw,
              padding: EdgeInsets.all(12.sp),
              decoration: BoxDecoration(
                color: AppColors.cFFFFFF,
                border: Border.all(color: AppColors.cb4b4b4),
                borderRadius: BorderRadius.circular(8.r),
              ),

              child: Row(
                children: [
                  ///Section : Service Provider Image
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: AssetImage(Assets.images.userImage.path),
                  ),
                  UIHelper.horizontalSpace(6.w),

                  ///Section : Service Provider Name
                  ///Section : Service Provider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///Section : Service Provider Name
                      Text(
                        "Ripon Mia",
                        style: TextFontStyle.headline16w500c202020StyleSatoshi,
                      ),
                      UIHelper.verticalSpace(2.h),

                      ///Section : Service Provider
                      Text(
                        "Services Provider",
                        style: TextFontStyle.headline10w500c4d4d4dStyleSatoshi,
                      ),
                    ],
                  ),
                  Spacer(),

                  ///Section : Message
                  ///Section : Call
                  Row(
                    children: [
                      ///Section : Message
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.all(6.sp),
                          decoration: BoxDecoration(
                            color: isRoutedFromBookingTab
                                ? AppColors.c778beb
                                : AppColors.cbababa,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(Assets.icons.messageIcon),
                        ),
                      ),
                      UIHelper.horizontalSpace(8.w),

                      ///Section : Call
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.all(6.sp),
                          decoration: BoxDecoration(
                            color: isRoutedFromBookingTab
                                ? AppColors.c778beb
                                : AppColors.cbababa,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.call, color: AppColors.cFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          UIHelper.verticalSpace(30.h),
        ],
      ),
    );
  }
}

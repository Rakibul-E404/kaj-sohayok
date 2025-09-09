import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../helpers/custom_text_form_field.dart';
import '../../../../helpers/ui_helpers.dart';

class ServicesOfSpecificCategoryScreen extends StatelessWidget {
  const ServicesOfSpecificCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        title: Text(
          "Services Of Specific Category",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              children: [
                ///Section : Search Bar
                CustomFormField(
                  showVerticalDivider: false,

                  prefixIcon: SvgPicture.asset(Assets.icons.searchIcon),
                  hintText: "Services Of Specific Category",
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : Available Services
                Container(
                  width: 1.sw,
                  padding: EdgeInsets.all(10.sp),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.c778beb),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      ///Section: Service Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: Image.asset(
                          Assets.images.specificServiceImage.path,
                          height: 112.w,
                          width: 1.sw,
                          fit: BoxFit.contain,
                        ),
                      ),
                      UIHelper.verticalSpace(14.h),

                      ///Section : Service Name
                      ///Section : Service Pricec
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Home cleaning",
                            style:
                                TextFontStyle.headline14w700c000000StyleSatoshi,
                          ),
                          RichText(
                            text: TextSpan(
                              style: TextFontStyle
                                  .headline12w500c6a6a6aStyleSatoshi, // base style
                              children: [
                                const TextSpan(text: "Start from "),
                                TextSpan(
                                  text: "\$30.0",
                                  style: TextFontStyle
                                      .headline10w400c999999StyleSatoshi
                                      .copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.c000000,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      UIHelper.verticalSpace(8.h),

                      ///Section : Dotted Divider
                      DottedLine(
                        direction: Axis.horizontal,
                        lineLength: double.infinity,
                        lineThickness: 1.sp,
                        dashLength: 4.w,
                        dashGapLength: 4.w,
                        dashColor: Colors.grey,
                      ),

                      ///Section : User Image
                      ///Section : User Name
                      ///Section : User Rating
                      ///Section : Button -> Book Now
                      Row(
                        children: [
                          ///Section : User Image
                          CircleAvatar(
                            radius: 32.r,
                            backgroundImage: AssetImage(
                              Assets.images.doneImage.path,
                            ),
                          ),
                          UIHelper.horizontalSpace(6.w),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

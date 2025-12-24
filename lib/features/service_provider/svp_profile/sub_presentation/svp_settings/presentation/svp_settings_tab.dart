import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../constants/appList.dart';
import '../../../../../../constants/text_font_style.dart';
import '../../../../../../controllers/privacy_terms_controller.dart';
import '../../../../../../controllers/svp_profile_screen_controller.dart';
import '../../../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../custom_widgets/settings_option_tile_widget.dart';

class SvpSettingsTab extends StatelessWidget {
  const SvpSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final SvpProfileScreenController svpProfileScreenController =
        Get.find<SvpProfileScreenController>();
    final PrivacyTermsController privacyTermsController = Get.put(
      PrivacyTermsController(),
    );
    return ListView.separated(
      itemCount: AppList.settingsOptionsList.length,
      separatorBuilder: (context, index) => UIHelper.verticalSpace(10.h),
      itemBuilder: (context, index) {
        final data = AppList.settingsOptionsList[index];
        return SettingsOptionTileWidget(
          onTap: () {
            index == 0
                ? Get.toNamed(Routes.changePasswordScreen)
                : index == 1
                    ? Get.toNamed(
                        Routes.privacyPolicyScreen,
                        arguments: {
                          'data': privacyTermsController.privacyPolicy.value,
                        },
                      )
                    : index == 2
                        ? Get.toNamed(
                            Routes.termsAndConditionsScreen,
                            arguments: {
                              'data':
                                  privacyTermsController.termsCondition.value,
                            },
                          )
                        : index == 3
                            ? Get.toNamed(
                                Routes.aboutUsScreen,
                                arguments: {
                                  'data': privacyTermsController.aboutUs.value
                                },
                              )
                            : index == 4
                                ? Get.toNamed(
                                    Routes.contactUsScreen,
                                    arguments: {
                                      'data':
                                          privacyTermsController.contactUs.value
                                    },
                                  )
                                : index == 5
                                    ? Get.bottomSheet(
                                        backgroundColor: AppColors.cFFFFFF,
                                        Container(
                                          width: 1.sw,
                                          padding: EdgeInsets.all(30.sp),
                                          child: Column(
                                            children: [
                                              ///Section : Bottom Sheet Mini Divider
                                              Container(
                                                height: 6.h,
                                                width: 50.w,
                                                decoration: BoxDecoration(
                                                  color: AppColors.cb5b5b5,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.r),
                                                ),
                                              ),
                                              UIHelper.verticalSpace(24.h),

                                              ///Section : Logout Image
                                              Image.asset(
                                                height: 130.h,
                                                width: 130.w,
                                                fit: BoxFit.contain,
                                                Assets.images.logOutImage.path,
                                              ),
                                              UIHelper.verticalSpace(24.h),

                                              ///Section : Text -> Logout Text...
                                              Text(
                                                'logout'.tr,
                                                style: TextFontStyle
                                                    .headline18w700c000000StyleSatoshi,
                                              ),
                                              UIHelper.verticalSpace(10.h),
                                              Text(
                                                'are_you_sure_you_want_to_logout'
                                                    .tr,
                                                style: TextFontStyle
                                                    .headline14w400c494949StyleSatoshi,
                                              ),
                                              UIHelper.verticalSpace(24.h),

                                              ///Section : Button -> No
                                              ///Section : Button -> Yes
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ///Section : Button -> No
                                                  CustomElevatedButton(
                                                    onTap: () {
                                                      Get.back();
                                                    },
                                                    buttonWidth: 136.w,
                                                    isButtonBorderUsed: true,
                                                    buttonBorderColor:
                                                        AppColors.c778beb,
                                                    buttonBorderWidth: 1.5.sp,
                                                    buttonColor:
                                                        Colors.transparent,
                                                    buttonTitle: 'no'.tr,
                                                    textStyle: TextFontStyle
                                                        .headline14w500c000000StyleSatoshi,
                                                  ),
                                                  UIHelper.horizontalSpace(
                                                      16.w),
                                                  CustomElevatedButton(
                                                    onTap: () {
                                                      Get.back();
                                                      svpProfileScreenController
                                                          .handleLogOut();
                                                    },
                                                    buttonWidth: 136.w,
                                                    buttonTitle: 'yes'.tr,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : null;
          },
          prefixIcon: data.icon,
          title: data.optionName,
          isLast: index == AppList.settingsOptionsList.length - 1,
        );
      },
    );
  }
}

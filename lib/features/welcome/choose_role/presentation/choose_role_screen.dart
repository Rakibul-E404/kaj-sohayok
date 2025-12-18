import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';
import 'package:kaz_bd/service/get_storage.dart';

import '../../../../utilities/app_constants.dart';
import '../../../../utilities/enum.dart';
import '../widgets/role_selecting_card.dart';

class ChooseRoleScreen extends StatelessWidget {
  const ChooseRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              children: [
                ///Section : TextButton -> Skip
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      log("Skip Button Taped!");
                      Get.toNamed(Routes.signInScreen);
                    },
                    child: Text(
                      'skip'.tr,
                      style: TextFontStyle.headline20w700c4d4d4dStyleSatoshi
                          .copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                UIHelper.verticalSpace(20.h),

                ///Section -> Text : Choose your role below
                Text(
                  'choose_role'.tr,
                  style: TextFontStyle.headline24w700c202020StyleSatoshi,
                ),
                UIHelper.verticalSpace(14.h),

                ///Section : Text -> please select an one option to start your journey
                Text(
                  'select_an_option'.tr,
                  style: TextFontStyle.headline12w700c4d4d4dStyleSatoshi,
                ),
                UIHelper.verticalSpace(28.h),

                ///Section : Bellow Icon
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        fit: BoxFit.cover,
                        width: 54.w,
                        height: 54.h,
                        Assets.images.belowIndicator.path,
                      ),
                      UIHelper.horizontalSpace(65.w),
                    ],
                  ),
                ),
                UIHelper.verticalSpace(24.h),

                ///Section : Join As a User
                RoleSelectingCard(
                  onTap: () async {
                    await GetStorageModel().saveString(
                      AppConstants.currentRole,
                      UserRole.user.name,
                    );
                    Get.toNamed(Routes.signUpScreen);
                  },
                  showBorder: true,
                  userTypeIcon: Assets.icons.personIconWhiteBackground,
                  cardTitle: 'join_as_user'.tr,
                  userType: appUserType.buyer,
                ),
                UIHelper.verticalSpace(16.h),

                ///Section : join as a services provider
                RoleSelectingCard(
                  onTap: () async {
                    await GetStorageModel().saveString(
                      AppConstants.currentRole,
                      UserRole.provider.name,
                    );
                    // Get.toNamed(Routes.signUpScreen);
                    Get.toNamed(Routes.joinAsServiceProviderScreen);
                  },
                  userTypeIcon: Assets.icons.serviceProviderLogo,
                  cardTitle: 'join_as_provider'.tr,
                  userType: appUserType.seller,
                ),
                UIHelper.verticalSpace(16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///Section : User Types as enum
// ignore: camel_case_types
enum appUserType { buyer, seller }

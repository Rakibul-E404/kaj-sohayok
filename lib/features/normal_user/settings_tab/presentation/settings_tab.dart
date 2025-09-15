import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kaz_bd/constants/appList.dart';
import 'package:kaz_bd/features/normal_user/settings_tab/widgets/settings_option_tile_widget.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';
import 'package:kaz_bd/routes/routes.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
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
                ? Get.toNamed(Routes.changePasswordScreen)
                : index == 2
                ? Get.toNamed(Routes.changePasswordScreen)
                : index == 3
                ? Get.toNamed(Routes.changePasswordScreen)
                : index == 4
                ? Get.toNamed(Routes.changePasswordScreen)
                : index == 5
                ? Get.toNamed(Routes.changePasswordScreen)
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

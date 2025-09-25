import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/custom_widgets/custom_elevated_button.dart';
import 'package:kaz_bd/custom_widgets/dotted_line_divider_widget.dart';
import 'package:kaz_bd/gen/assets.gen.dart';

import '../../../../../../constants/text_font_style.dart';
import '../../../../../../custom_widgets/date_and_time_widget_tile.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../../helpers/ui_helpers.dart';
import '../widgets/svp_bookings_canceled_card.dart';

class SvpBookingsCanceledTab extends StatelessWidget {
  const SvpBookingsCanceledTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          itemCount: 10,
          separatorBuilder: (context, index) => UIHelper.verticalSpace(24.h),

          itemBuilder: (context, index) {
            return SvpBookingsCanceledCard(
              cancelButtonOnTap: () {
                log("Button Taped -> Cancel");
              },
              userImage: Assets.images.userImage.path,
              userName: "Chowdhur Md. Imtiazul Islam",
              location: "Rampura Dhaka, Bangladesh",
              dateTime: "Jun 17, 2025  09:31AM",
            );
          },
        ),
      ),
    );
  }
}

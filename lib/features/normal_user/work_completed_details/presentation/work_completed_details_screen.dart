import 'package:flutter/material.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../gen/colors.gen.dart';

class WorkCompletedDetailsScreen extends StatelessWidget {
  const WorkCompletedDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Complete Details",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Work Complete Information ",
                  style: TextFontStyle.headline16w700c000000StyleSatoshi,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

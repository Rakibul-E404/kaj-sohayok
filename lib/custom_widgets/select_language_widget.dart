// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import '../constants/text_font_style.dart';
// import '../gen/colors.gen.dart';

// class SelectLanguage extends StatelessWidget {
//   const SelectLanguage({
//     super.key,
//     required TabController tabController,
//     required this.leftTabTitle,
//     required this.rightTabTitle,
//     required this.tabIndex,
//     required this.onTabChange,
//   }) : _tabController = tabController;

//   final TabController _tabController;
//   final String leftTabTitle;
//   final String rightTabTitle;

//   /// Reactive variable to track the selected tab
//   final RxInt tabIndex;

//   /// Function to call when tab changes
//   final void Function(int index) onTabChange;

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Obx(() {
//         return Container(
//           width: 100.w,
//           decoration: BoxDecoration(
//             border: Border.all(color: AppColors.c778beb),
//             borderRadius: BorderRadius.circular(100.r),
//           ),
//           child: TabBar(
//             splashFactory: NoSplash.splashFactory,
//             controller: _tabController,
//             onTap: onTabChange,
//             labelPadding: EdgeInsets.zero,
//             indicatorColor: Colors.transparent,
//             indicatorWeight: 0,
//             indicatorSize: TabBarIndicatorSize.tab,
//             dividerColor: Colors.transparent,
//             indicator: BoxDecoration(
//               color: AppColors.c778beb,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(tabIndex.value == 0 ? 100.r : 0.r),
//                 bottomLeft: Radius.circular(tabIndex.value == 0 ? 100.r : 0.r),
//                 topRight: Radius.circular(tabIndex.value == 1 ? 100.r : 0.r),
//                 bottomRight: Radius.circular(tabIndex.value == 1 ? 100.r : 0.r),
//               ),
//             ),
//             labelColor: Colors.amber,
//             unselectedLabelColor: Colors.black,
//             tabs: [
//               Tab(
//                 child: Align(
//                   alignment: Alignment.center,
//                   child: Obx(() {
//                     return Text(
//                       leftTabTitle,
//                       style: TextFontStyle.headline10w700cFFFFFFStyleSatoshi
//                           .copyWith(
//                         color: tabIndex.value == 0
//                             ? AppColors.cFFFFFF
//                             : AppColors.c000000,
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//               Tab(
//                 child: Align(
//                   alignment: Alignment.center,
//                   child: Obx(() {
//                     log("Tab Index : ${tabIndex.value}");
//                     return Text(
//                       rightTabTitle,
//                       style: TextFontStyle.headline10w700cFFFFFFStyleSatoshi
//                           .copyWith(
//                         color: tabIndex.value == 0
//                             ? AppColors.c000000
//                             : AppColors.cFFFFFF,
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../constants/text_font_style.dart';
import '../gen/colors.gen.dart';

class SelectLanguage extends StatelessWidget {
  const SelectLanguage({
    super.key,
    required TabController tabController,
    required this.leftTabTitle,
    required this.rightTabTitle,
    required this.tabIndex,
    required this.onTabChange,
  }) : _tabController = tabController;

  final TabController _tabController;
  final String leftTabTitle;
  final String rightTabTitle;

  /// Reactive variable to track the selected tab
  final RxInt tabIndex;

  /// Function to call when tab changes
  final void Function(int index) onTabChange;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Obx(() {
        return Container(
          width: 100.w,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.c778beb, width: 2.sp),
            borderRadius: BorderRadius.circular(100.r),
            color:
                AppColors.cFFFFFF, // Background color for the entire container
          ),
          child: TabBar(
            splashFactory: NoSplash.splashFactory,
            controller: _tabController,
            onTap: onTabChange,
            labelPadding: EdgeInsets.zero,
            indicatorColor: Colors.transparent,
            indicatorWeight: 0,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: AppColors.c778beb, // Selected tab background color
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(tabIndex.value == 0 ? 100.r : 0.r),
                bottomLeft: Radius.circular(tabIndex.value == 0 ? 100.r : 0.r),
                topRight: Radius.circular(tabIndex.value == 1 ? 100.r : 0.r),
                bottomRight: Radius.circular(tabIndex.value == 1 ? 100.r : 0.r),
              ),
            ),
            tabs: [
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(100.r),
                      bottomLeft: Radius.circular(100.r),
                    ),
                    color: tabIndex.value == 0
                        ? Colors.transparent // Let indicator handle the color
                        : AppColors.cFFFFFF, // Unselected background
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      leftTabTitle,
                      style: TextFontStyle.headline10w700cFFFFFFStyleSatoshi
                          .copyWith(
                        color: tabIndex.value == 0
                            ? AppColors.cFFFFFF // Selected text color
                            : AppColors.c000000, // Unselected text color
                      ),
                    ),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(100.r),
                      bottomRight: Radius.circular(100.r),
                    ),
                    color: tabIndex.value == 1
                        ? Colors.transparent // Let indicator handle the color
                        : AppColors.cFFFFFF, // Unselected background
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      rightTabTitle,
                      style: TextFontStyle.headline10w700cFFFFFFStyleSatoshi
                          .copyWith(
                        color: tabIndex.value == 1
                            ? AppColors.cFFFFFF // Selected text color
                            : AppColors.c000000, // Unselected text color
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

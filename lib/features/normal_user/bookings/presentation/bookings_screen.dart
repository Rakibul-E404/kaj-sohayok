import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/features/normal_user/bookings/sub_presentation/work_completed/presentation/work_completed_tab.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../constants/text_font_style.dart';
import '../sub_presentation/accepted_booking/presentation/accepted_booking_tab.dart';
import '../sub_presentation/in_progress/presentation/in_progress_tab.dart';
import '../sub_presentation/payment_request/presentation/payment_request_tab.dart';
import '../sub_presentation/pending/presentation/pending_tab.dart';
import '../sub_presentation/services_canceled/presentation/services_canceled_tab.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'my_bookings'.tr,
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: DefaultTabController(
            length: 6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  isScrollable: true, // Make tabs scrollable
                  padding: EdgeInsets.zero,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(child: Text('pending'.tr)),
                    Tab(child: Text('accepted_booking'.tr)),
                    Tab(child: Text('in_progress'.tr)),
                    Tab(child: Text('payment_request'.tr)),
                    Tab(child: Text('canceled'.tr)),
                    Tab(child: Text('work_completed'.tr)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      ///Section : Pending Tab
                      PendingTab(),

                      ///Section : Accepted Booking Tab
                      AcceptedBookingTab(),

                      ///Section : In Progress Tab
                      InProgressTab(),

                      ///Section : Payment Request Tab
                      PaymentRequestTab(),

                      ///Section : Canceled Tab
                      ServicesCanceledTab(),

                      ///Section : Work Completed Tab
                      WorkCompletedTab(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 90,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../svp_in_progress/presentation/svp_in_progress_screen.dart';
import '../sub_presentation/svp_accepted_bookings/presentation/svp_accepted_bookings_tab.dart';
import '../sub_presentation/svp_bookings_canceled/presentation/svp_bookings_canceled_screen.dart';
import '../sub_presentation/svp_bookings_in_progress/presentation/svp_bookings_in_progress_tab.dart';
import '../sub_presentation/svp_job_request/presentation/svp_job_request_tab.dart';
import '../sub_presentation/svp_payment_request/presentation/svp_payment_request_tab.dart';
import '../sub_presentation/svp_work_completed/presentation/svp_work_completed_tab.dart';

class SvpBookingsScreen extends StatelessWidget {
  const SvpBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "My Bookings",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
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
                    Tab(child: Text('Job Request')),
                    Tab(child: Text('Accepted Booking')),
                    Tab(child: Text('In Progress')),
                    Tab(child: Text('Payment Request')),
                    Tab(child: Text('Canceled')),
                    Tab(child: Text('Work Completed')),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),

                    children: [
                      ///Section : Job Reques
                      SvpJobRequestTab(),

                      ///Section : Accepted Booking Tab
                      SvpAcceptedBookingsTab(),

                      ///Section : In Progress Tab
                      SvpBookingsInProgressTab(),

                      ///Section : Payment Request Tab
                      SvpPaymentRequestTab(),

                      ///Section : Canceled Tab
                      SvpBookingsCanceledTab(),

                      ///Section : Work Completed Tab
                      SvpWorkCompletedTab(),
                    ],
                  ),
                ),
                SizedBox(height: 120,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../helpers/ui_helpers.dart';
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
          'my_bookings'.tr,
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
                    Tab(child: Text('job_request'.tr)),
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
                SizedBox(
                  height: 120,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/








///
///
///
/// todo::: upper is imtiaz vai's code <<<<DON'T DROP THAT>>>>
///
///
///




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../helpers/ui_helpers.dart';
import '../sub_presentation/svp_accepted_bookings/presentation/svp_accepted_bookings_tab.dart';
import '../sub_presentation/svp_bookings_canceled/presentation/svp_bookings_canceled_screen.dart';
import '../sub_presentation/svp_bookings_in_progress/presentation/svp_bookings_in_progress_tab.dart';
import '../sub_presentation/svp_job_request/presentation/svp_job_request_tab.dart';
import '../sub_presentation/svp_payment_request/presentation/svp_payment_request_tab.dart';
import '../sub_presentation/svp_work_completed/presentation/svp_work_completed_tab.dart';

class SvpBookingsScreen extends StatefulWidget {
  const SvpBookingsScreen({super.key});

  @override
  State<SvpBookingsScreen> createState() => _SvpBookingsScreenState();
}

class _SvpBookingsScreenState extends State<SvpBookingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // Default to "Job Request" tab (index 0)
    int initialIndex = 0;

    // Check if arguments were passed (e.g., from payment success)
    final args = Get.arguments;
    if (args is Map? && args != null && args.containsKey('initialTabIndex')) {
      final tabIndex = args['initialTabIndex'];
      if (tabIndex is int && tabIndex >= 0 && tabIndex < 6) {
        initialIndex = tabIndex;
      }
    }

    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tab Bar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                padding: EdgeInsets.zero,
                tabAlignment: TabAlignment.start,
                indicatorColor: Colors.blue, // Optional: customize indicator
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Job Request'),
                  Tab(text: 'Accepted Booking'),
                  Tab(text: 'In Progress'),
                  Tab(text: 'Payment Request'),
                  Tab(text: 'Canceled'),
                  Tab(text: 'Work Completed'),
                ],
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    SvpJobRequestTab(),
                    SvpAcceptedBookingsTab(),
                    SvpBookingsInProgressTab(),
                    SvpPaymentRequestTab(),
                    SvpBookingsCanceledTab(),
                    SvpWorkCompletedTab(),
                  ],
                ),
              ),

              // Spacer at bottom (as in your original)
              SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}


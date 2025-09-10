import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/controllers/details_screen_controller.dart';
import 'package:kaz_bd/features/normal_user/details/widget/about_tab.dart';
import 'package:kaz_bd/features/normal_user/details/widget/gallery_tab.dart';
import 'package:kaz_bd/features/normal_user/details/widget/reviews_tab.dart';

class TabShowingWidget extends StatefulWidget {
  const TabShowingWidget({super.key, required this.tabController});

  final TabController tabController;

  @override
  State<TabShowingWidget> createState() => _TabShowingWidgetState();
}

class _TabShowingWidgetState extends State<TabShowingWidget> {
  final DetailsScreenController controller = Get.put(DetailsScreenController());

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(() {
      if (!widget.tabController.indexIsChanging) {
        controller.changeTab(widget.tabController.index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabController,
      children: [
        /// --- About Tab ---
        AboutTab(),

        /// --- Gallery Tab ---
        GalleryTab(),

        /// --- Reviews Tab ---
        ReviewsTab(),
      ],
    );
  }
}

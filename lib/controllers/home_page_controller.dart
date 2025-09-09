import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePageController extends GetxController {
  var currentPage = 0.obs;

  final PageController pageController = PageController();

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void disposeController() {
    pageController.dispose();
  }
}

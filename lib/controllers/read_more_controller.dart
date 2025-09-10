import 'package:get/get.dart';

class ReadMoreController extends GetxController {
  var isExpanded = false.obs;

  void toggle() => isExpanded.value = !isExpanded.value;
}

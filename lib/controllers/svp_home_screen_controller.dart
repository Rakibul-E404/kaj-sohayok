import 'package:get/get.dart';

import '../constants/appList.dart';

class SvpHomeScreenController extends GetxController {
  // Reactive selectedPeriod
  var selectedPeriod = 'Weekly'.obs;

  // Computed property: total income
  double get totalIncome {
    return AppList.chartData[selectedPeriod.value]!.fold(
      0.0,
      (sum, item) => sum + item.value,
    );
  }

  String get formattedIncome {
    return '\$${totalIncome.toStringAsFixed(0)}';
  }

  double get maxValue {
    return selectedPeriod.value == 'Weekly' ? 20000 : 60000;
  }
}

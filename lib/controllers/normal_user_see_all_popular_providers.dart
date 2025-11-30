import 'package:get/get.dart';

class NormalUserSeeAllPopularProvidersController extends GetxController {
  // Add any data you need for the popular providers
  var providers = <dynamic>[].obs; // You might want to use a proper model class
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize or load data if needed
    loadPopularProviders();
  }

  Future<void> loadPopularProviders() async {
    // Add your logic to load popular providers from API or any data source
    isLoading.value = true;

    // Simulating API call
    await Future.delayed(const Duration(seconds: 1));

    // This is just a placeholder - replace with actual data from your API
    providers.assignAll(List.generate(10, (index) => index));
    isLoading.value = false;
  }
}

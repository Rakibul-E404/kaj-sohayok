// import 'dart:developer';

// import 'package:get/get.dart';
// import 'package:kaz_bd/service/network_caller.dart';
// import 'package:kaz_bd/service/network_response.dart';
// import 'package:kaz_bd/utilities/app_constants.dart';
// import 'package:kaz_bd/utilities/app_url.dart';

// import '../features/service_provider/svp_home/model/service_provider_home_view_model.dart';
// import '../service/secured_storage.dart';

// class SvpHomeScreenController extends GetxController {
//   // Reactive variables
//   var selectedPeriod = 'weekly'.obs; // Changed to lowercase to match API
//   var isHomeDataLoading = false.obs; // Changed name to match the error
//   var homeData = <ServiceProviderHomeViewModel>[].obs; // Changed to list to match the other implementation

//   // API error handling
//   var errorMessage = ''.obs;
//   var hasError = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     getServiceProviderHomeData(); // Changed method name to match the other implementation
//   }

//   // Fetch home data from API
//   Future<void> getServiceProviderHomeData() async {
//     try {
//       isHomeDataLoading(true); // Changed to match error
//       hasError(false);
//       errorMessage('');

//       final String token =
//           await SecureStorageService().read(AppConstants.accessToken) ?? '';

//       final NetworkResponse response = await NetworkCaller().getRequest(
//         AppUrl.getServiceProviderHomeData, // Added to AppUrl in previous implementation
//         headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
//       );

//       if (response.isSuccess && response.jsonResponse != null) {
//         final result = ServiceProviderHomeViewModel.fromJson(response.jsonResponse!);

//         if (result.success == true && result.data?.attributes != null) {
//           // Update selected period to match the API response
//           if (result.data?.attributes?.type != null) {
//             selectedPeriod.value = result.data!.attributes!.type!;
//           }

//           // Store the data
//           homeData.clear();
//           homeData.add(result);

//           log('Service Provider Home Data loaded successfully');
//         } else {
//           hasError(true);
//           errorMessage.value = result.message ?? 'Failed to load data';
//           log('Error: ${result.message}');
//         }
//       } else {
//         hasError(true);
//         errorMessage.value = 'Network error: ${response.errorMessage}';
//         log('Network error: ${response.errorMessage}');
//       }
//     } catch (e) {
//       hasError(true);
//       errorMessage.value = 'Exception: $e';
//       log('Exception in getServiceProviderHomeData: $e');
//     } finally {
//       isHomeDataLoading(false); // Changed to match error
//     }
//   }

//   // Computed properties based on API data
//   double get totalIncome {
//     if (homeData.isNotEmpty && homeData.first.data?.attributes?.totalIncome != null) {
//       return homeData.first.data!.attributes!.totalIncome!.toDouble();
//     }
//     return 0.0;
//   }

//   String get formattedIncome {
//     return '\$${totalIncome.toStringAsFixed(0)}';
//   }

//   // Get chart data for the selected period
//   List<ChartDatum> get chartData {
//     if (homeData.isNotEmpty && homeData.first.data?.attributes?.chartData != null) {
//       return homeData.first.data!.attributes!.chartData!;
//     }
//     return [];
//   }

//   // Get max value for chart scaling
//   double get maxValue {
//     if (chartData.isEmpty) return 100.0;

//     try {
//       final maxIncome = chartData
//           .map((e) => (e.income ?? 0).toDouble())
//           .where((value) => value.isFinite)  // Filter out infinite and NaN values
//           .reduce((a, b) => a > b ? a : b);

//       // Ensure we return a valid number
//       if (!maxIncome.isFinite) {
//         return 100.0;
//       }

//       // Add some padding (20%) to the max value
//       return (maxIncome * 1.2).toDouble();
//     } catch (e) {
//       // If there's an error (e.g., all values are 0 or invalid), return a default value
//       return 100.0;
//     }
//   }

//   // Get stats
//   Stats? get stats {
//     if (homeData.isNotEmpty && homeData.first.data?.attributes?.stats != null) {
//       return homeData.first.data!.attributes!.stats;
//     }
//     return null;
//   }

//   // Get recent job requests
//   List<RecentJobRequest> get recentJobRequests {
//     if (homeData.isNotEmpty && homeData.first.data?.attributes?.recentJobRequests != null) {
//       return homeData.first.data!.attributes!.recentJobRequests!;
//     }
//     return [];
//   }

//   // Get the status count for the job cards
//   int get totalRequests {
//     return stats?.totalRequests ?? 0;
//   }

//   int get accepted {
//     return stats?.accepted ?? 0;
//   }

//   int get inProgress {
//     return stats?.inProgress ?? 0;
//   }

//   int get completed {
//     return stats?.completed ?? 0;
//   }

//   // Refresh data
//   Future<void> refreshData() async {
//     await getServiceProviderHomeData();
//   }

//   // Change period and reload data (if needed)
//   void changePeriod(String period) {
//     selectedPeriod.value = period;
//     getServiceProviderHomeData();
//   }
// }

import 'dart:developer';

import 'package:get/get.dart';
import 'package:kaz_bd/service/network_caller.dart';
import 'package:kaz_bd/service/network_response.dart';
import 'package:kaz_bd/utilities/app_constants.dart';
import 'package:kaz_bd/utilities/app_url.dart';
import 'package:kaz_bd/utilities/logger_util.dart';

import '../features/service_provider/svp_home/model/service_provider_home_view_model.dart';
import '../service/secured_storage.dart';

class SvpHomeScreenController extends GetxController {
  // Reactive variables
  var selectedPeriod = 'weekly'.obs; // Changed to lowercase to match API
  var isHomeDataLoading = false.obs; // Changed name to match the error
  var homeData = <ServiceProviderHomeViewModel>[]
      .obs; // Changed to list to match the other implementation

  // API error handling
  var errorMessage = ''.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    getServiceProviderHomeData(); // Changed method name to match the other implementation
  }

  // Fetch home data from API
  Future<void> getServiceProviderHomeData() async {
    try {
      isHomeDataLoading(true); // Changed to match error
      hasError(false);
      errorMessage('');

      final String token =
          await SecureStorageService().read(AppConstants.accessToken) ?? '';

      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.getServiceProviderHomeData(dataType: selectedPeriod.value),
        // Use dynamic data type
        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final result = ServiceProviderHomeViewModel.fromJson(
          response.jsonResponse!,
        );
        if (result.success == true && result.data?.attributes != null) {
          // Update selected period to match the API response
          if (result.data?.attributes?.type != null) {
            selectedPeriod.value = result.data!.attributes!.type!;
          }

          // Store the data
          homeData.clear();
          homeData.add(result);

          log('Service Provider Home Data loaded successfully');
        } else {
          hasError(true);
          errorMessage.value = result.message ?? 'Failed to load data';
          log('Error: ${result.message}');
        }
      } else {
        hasError(true);
        errorMessage.value = 'Network error: ${response.errorMessage}';
        log('Network error: ${response.errorMessage}');
      }
    } catch (e) {
      hasError(true);
      errorMessage.value = 'Exception: $e';
      log('Exception in getServiceProviderHomeData: $e');
      LoggerUtils.debug('Check Imtiaz Bhai issue');
      LoggerUtils.debug('Exception in getServiceProviderHomeData: $e');
    } finally {
      isHomeDataLoading(false); // Changed to match error
    }
  }

  // Computed properties based on API data
  double get totalIncome {
    if (homeData.isNotEmpty &&
        homeData.first.data?.attributes?.totalIncome != null) {
      return homeData.first.data!.attributes!.totalIncome!.toDouble();
    }
    return 0.0;
  }

  String get formattedIncome {
    return '\$${totalIncome.toStringAsFixed(0)}';
  }

  // Get chart data for the selected period
  List<ChartDatum> get chartData {
    if (homeData.isNotEmpty &&
        homeData.first.data?.attributes?.chartData != null) {
      return homeData.first.data!.attributes!.chartData!;
    }
    return [];
  }

  // Get max value for chart scaling - FIXED VERSION
  double get maxValue {
    if (chartData.isEmpty) return 100.0;

    try {
      // Get all income values
      final incomeValues = chartData
          .map((e) => (e.income ?? 0).toDouble())
          .where((value) => value.isFinite)
          .toList();

      // Check if we have any values
      if (incomeValues.isEmpty) return 100.0;

      // Find the maximum value
      double maxIncome = incomeValues.reduce((a, b) => a > b ? a : b);

      // If maxIncome is 0 or negative, return default value
      if (maxIncome <= 0) return 100.0;

      // Ensure we return a valid number
      if (!maxIncome.isFinite) {
        return 100.0;
      }

      // Add some padding (20%) to the max value
      return (maxIncome * 1.2).toDouble();
    } catch (e) {
      // If there's an error (e.g., all values are 0 or invalid), return a default value
      return 100.0;
    }
  }

  // Get stats
  Stats? get stats {
    if (homeData.isNotEmpty && homeData.first.data?.attributes?.stats != null) {
      return homeData.first.data!.attributes!.stats;
    }
    return null;
  }

  // Get recent job requests
  List<RecentJobRequest> get recentJobRequests {
    if (homeData.isNotEmpty &&
        homeData.first.data?.attributes?.recentJobRequests != null) {
      return homeData.first.data!.attributes!.recentJobRequests!;
    }
    return [];
  }

  // Get the status count for the job cards
  int get totalRequests {
    return stats?.totalRequests ?? 0;
  }

  int get accepted {
    return stats?.accepted ?? 0;
  }

  int get inProgress {
    return stats?.inProgress ?? 0;
  }

  int get completed {
    return stats?.completed ?? 0;
  }

  // Refresh data
  Future<void> refreshData() async {
    await getServiceProviderHomeData();
  }

  // Change period and reload data (if needed)
  void changePeriod(String period) {
    selectedPeriod.value = period;
    getServiceProviderHomeData();
  }
}

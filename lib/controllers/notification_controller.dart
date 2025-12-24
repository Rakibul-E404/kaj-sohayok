// notification_controller.dart
import 'package:get/get.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/secured_storage.dart';
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';
import '../features/common_screens/notification/model/notification_model.dart';

class NotificationController extends GetxController {
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxList<NotificationModel> _notificationList = <NotificationModel>[].obs;

  // Public getters (immutable)
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  List<NotificationModel> get notificationList => _notificationList.toList();

  @override
  void onInit() {
    fetchNotification();
    super.onInit();
  }

  Future<void> fetchNotification({bool isRefresh = false}) async {
    if (!isRefresh) {
      _isLoading.value = true;
      _hasError.value = false;
    }

    try {
      final String? token = await SecureStorageService().read(AppConstants.accessToken);
      if (token == null) {
        _hasError.value = true;
        return;
      }

      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.notification,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess) {
        final results = response.jsonResponse?['data']?['attributes']?['results'];
        if (results is List) {
          final notifications = results
              .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
              .toList();
          _notificationList.assignAll(notifications);
        } else {
          _notificationList.clear();
        }
        _hasError.value = false;
      } else {
        _hasError.value = true;
        LoggerUtils.debug("API Error: ${response.errorMessage}");
      }
    } catch (e) {
      _hasError.value = true;
      LoggerUtils.debug("Exception: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  void retry() {
    fetchNotification();
  }
}
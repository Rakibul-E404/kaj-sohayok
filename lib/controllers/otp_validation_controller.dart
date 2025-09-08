import 'dart:async';
import 'package:get/get.dart';

class OtpValidationController extends GetxController {
  var pin = ''.obs;

  // Timer
  var secondsRemaining = 30.obs;
  Timer? _timer;
  RxBool isOtpExpired = false.obs;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  // Validate OTP
  String? validatePin(String? value) {
    if (value == null || value.isEmpty) return 'OTP cannot be empty';
    return value == '222222' ? null : 'OTP is incorrect';
  }

  // Called when OTP completed
  void onCompleted(String value) {
    pin.value = value;
    print('Entered OTP: $value');
  }

  // Start countdown timer
  void startTimer() {
    _timer?.cancel();
    secondsRemaining.value = 30;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
        isOtpExpired.value = true;
      }
    });
  }

  // Dispose timer
  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

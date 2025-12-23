// lib/services/fcm_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../gen/colors.gen.dart';
import 'get_storage.dart';


// This MUST be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {

    // Request permission
    await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);

    // Get FCM token
    final String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    // Handle background messages
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title}');
      // You can show a snackbar or dialog here
      if (message.notification != null  ) {
        Get.snackbar(
          message.notification?.title ?? 'Notification',
          message.notification?.body ?? '',
          backgroundColor: Colors.white.withOpacity(0.98),
          colorText: Colors.black87,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          borderRadius: 14,
          boxShadows: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppColors.c778beb, shape: BoxShape.circle),
            child: const Icon(Icons.notifications, color: Colors.white, size: 18),
          ),
          leftBarIndicatorColor: AppColors.c778beb,
          snackPosition: SnackPosition.TOP,
          forwardAnimationCurve: Curves.elasticOut,
          reverseAnimationCurve: Curves.easeOut,
          onTap: (_) => _handleNotificationClick(message.data),
        );
      }
    });

    // Handle notification clicks when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data);
    });

    // Check if app was opened from notification
    final RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage.data);
    }
  }

  static void _handleNotificationClick(Map<String, dynamic> data) {
    // Navigate based on notification data
    final type = data['type'] ?? '';
    debugPrint(data.toString());

    debugPrint('Notification clicked with type: $type');

    // Add a small delay to ensure app is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      // switch (type) {
      //   case 'topup':
      //     Get.offAll(() => TopUpDashboard());
      //     break;
      //   case 'history':
      //     Get.offAll(() => HistoryHomePage());
      //     break;
      //   case 'market':
      //     Get.offAll(() => const MarketDashboard());
      //     break;
      //   default:
      //     Get.offAll(() => const MainBottomNavScreen());
      // }
    });
  }

  static Future<String> getToken() async {
    try {
      return await _firebaseMessaging.getToken() ?? '';
    } catch (e) {
      return '';
    }
  }
}

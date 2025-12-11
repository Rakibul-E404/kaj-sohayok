import 'dart:async';

// ignore: library_prefixes
import 'package:kaz_bd/service/secured_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utilities/app_constants.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';

class SocketServices {
  static final SocketServices _instance = SocketServices._internal();

  factory SocketServices() => _instance;

  SocketServices._internal();

  IO.Socket? socket;
  String accessToken = '';

  Future<void> init() async {
    if (socket != null && socket!.connected) {
      return;
    }
    accessToken =
        await SecureStorageService().read(AppConstants.accessToken) ?? '';
    _connect();
  }

  // Ensure the socket is initialized and connected before proceeding.
  Future<void> checkSocketInitialized() async {
    if (socket == null || !socket!.connected) {
      LoggerUtils.debug(
          "⚠️ Socket not initialized or connected, calling `init()`...");
      await init(); // Wait for the socket connection to initialize
      await _waitForConnection(); // Ensure the socket is connected
    }
  }

  // Wait until the socket is connected before proceeding.
  Future<void> _waitForConnection() async {
    // Wait until the socket is connected before proceeding
    if (socket != null) {
      await Future.doWhile(() async {
        if (socket!.connected) {
          return false;
        } else {
          await Future<dynamic>.delayed(const Duration(milliseconds: 500));
          return true;
        }
      });
    }
  }

  void _connect() {
    socket = IO.io(
      AppUrl.socketBaseUrl,
      IO.OptionBuilder()
          .setTransports(<String>['websocket'])
          .setExtraHeaders(<String, dynamic>{
            "authorization": 'Bearer $accessToken',
            "token": accessToken
          })
          .setReconnectionAttempts(15)
          .build(),
    );
    // Log the connection event
    socket!.onConnect((_) {
      LoggerUtils.debug('✅ Socket connected');
    });

    // Log when socket disconnects
    socket!.onDisconnect((_) {
      LoggerUtils.debug('⚠️ Socket disconnected, retrying...');
    });

    // Log connection errors
    socket!.onConnectError((dynamic err) {
      LoggerUtils.debug('❌ Socket connection error: $err');
    });

    // Log general socket errors
    socket!.onError((dynamic err) {
      LoggerUtils.debug('🚨 Socket error: $err');
    });

    // Log reconnection attempts
    socket!.onReconnectAttempt((dynamic attempt) {
      LoggerUtils.debug('🔁 Reconnection attempt #$attempt');
    });

    // Log reconnection success
    socket!.onReconnect((dynamic attempt) {
      LoggerUtils.debug('✅ Reconnected after $attempt attempts');
    });

    // Log reconnection errors
    socket!.onReconnectError((dynamic err) {
      LoggerUtils.debug('❌ Reconnection error: $err');
    });

    // Log when reconnection fails
    socket!.onReconnectFailed((dynamic data) {
      LoggerUtils.debug('❌ Failed to reconnect : ${data}');
    });

    // Log incoming messages from server
    socket!.on('message', (data) {
      LoggerUtils.debug('💬 Message received: $data');
    });
  }

  // Emit event after ensuring socket is connected.
  Future<void> emit(String event, dynamic data) async {
    await checkSocketInitialized(); // Ensure the socket is connected first
    if (socket != null && socket!.connected) {
      socket!.emit(event, data);
      LoggerUtils.debug('📤 Emit: $event \nData: $data');
    } else {
      LoggerUtils.debug("⚠️ Cannot emit, socket not connected.");
    }
  }

  // Emit event after ensuring socket is connected.

  dynamic emitAsync(String event, dynamic data) async {
    await checkSocketInitialized(); // Ensure the socket is connected first

    if (socket != null && socket!.connected) {
      try {
        var emitWithAckAsync = await socket!.emitWithAckAsync(event, data);
        LoggerUtils.debug(
            '📤Async Emit: $event \nData: $data \nResponse: $emitWithAckAsync');

        // Return the response so it can be used where this function is called
        return await emitWithAckAsync;
      } catch (e) {
        LoggerUtils.debug('⚠️ Emit error: $e');
        return null;
      }
    } else {
      LoggerUtils.debug("⚠️ Cannot emit, socket not connected.");
      return null;
    }
  }


  // Listen to event after ensuring socket is connected.
  Future<void> listen(String event, void Function(dynamic) callback) async {
    await checkSocketInitialized(); // Ensure the socket is connected first
    if (socket != null && socket!.connected) {
      socket!.on(event, (dynamic data) {
        callback(data); // Call the callback with the data received
        LoggerUtils.debug('📥 Received $event: $data');
      });
    } else {
      LoggerUtils.debug("⚠️ Cannot listen, socket not connected.");
    }
  }

  void disconnect() {
    socket?.dispose();
    LoggerUtils.debug('🔌 Socket disconnected');
  }
}

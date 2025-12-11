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

  // Track all active listeners
  final Set<String> _activeListeners = {};

  // Flag to prevent operations during/after logout
  bool _isDisabled = false;

  void reset() {
    // LoggerUtils.debug('🔄 Resetting socket...');

    // Set disabled flag first
    _isDisabled = true;

    // Remove all listeners
    _removeAllListeners();

    if (socket != null) {
      try {
        socket!.disconnect();
        socket!.dispose();
      } catch (e) {
        // LoggerUtils.debug('Error during socket reset: $e');
      }
      socket = null; // ✅ FIXED: was socket == null
    }

    accessToken = '';
    // LoggerUtils.debug('✅ Socket fully reset');
  }

  // Remove all active listeners
  void _removeAllListeners() {
    if (socket != null && _activeListeners.isNotEmpty) {
      // LoggerUtils.debug('🗑️ Removing ${_activeListeners.length} listeners');
      for (final event in _activeListeners) {
        try {
          socket!.off(event);
        } catch (e) {
          // LoggerUtils.debug('Error removing listener $event: $e');
        }
      }

      // Clear all built-in listeners too
      try {
        socket!.clearListeners();
      } catch (e) {
        LoggerUtils.debug('Error clearing listeners: $e');
      }
    }
    _activeListeners.clear();
  }

  Future<void> init() async {
    // Block if disabled (after logout)
    if (_isDisabled) {
      // LoggerUtils.warning('🚫 Socket is disabled - cannot init');
      return;
    }

    final newToken =
        await SecureStorageService().read(AppConstants.accessToken) ?? '';

    // If no token, don't connect
    if (newToken.isEmpty) {
      // LoggerUtils.warning('❌ No token - cannot connect socket');
      return;
    }

    // Reset if token changed
    if (newToken != accessToken && accessToken.isNotEmpty) {
      // LoggerUtils.debug('🔄 Token changed - resetting socket');
      reset();
      // Re-enable after reset for new user
      _isDisabled = false;
    }

    accessToken = newToken;

    // LoggerUtils.warning({
    //   "token": 'Socket token: ${accessToken.substring(0, 20)}...',
    //   "socket": socket,
    //   "isConnected": socket?.connected
    // });

    if (socket != null && socket!.connected) {
      // LoggerUtils.debug('Socket already connected');
      return;
    }

    _connect();
  }

  // Ensure the socket is initialized and connected before proceeding.
  Future<void> checkSocketInitialized() async {
    if (_isDisabled) {
      LoggerUtils.warning(
          '🚫 Socket disabled - checkSocketInitialized blocked');
      return;
    }

    if (socket == null || !socket!.connected) {
      LoggerUtils.debug(
          "⚠️ Socket not initialized or connected, calling `init()`...");
      await init();
      await _waitForConnection();
    }
  }

  // Wait until the socket is connected before proceeding.
  Future<void> _waitForConnection() async {
    if (_isDisabled) return;

    if (socket != null) {
      int attempts = 0;
      await Future.doWhile(() async {
        if (_isDisabled || attempts > 10) {
          return false;
        }
        if (socket!.connected) {
          return false;
        } else {
          attempts++;
          await Future<dynamic>.delayed(const Duration(milliseconds: 500));
          return true;
        }
      });
    }
  }

  void _connect() {
    if (accessToken.isEmpty || _isDisabled) {
      LoggerUtils.warning('❌ Cannot connect - no token or disabled');
      return;
    }

    try {
      socket = IO.io(
        AppUrl.socketBaseUrl,
        IO.OptionBuilder()
            .setTransports(<String>['websocket'])
            .setExtraHeaders(<String, dynamic>{
              "authorization": 'Bearer $accessToken',
              "token": accessToken
            })
            .enableForceNew() // this fixes things ==================>
            .setReconnectionAttempts(0) // Disable auto-reconnect
            .disableAutoConnect()
            .build(),
      );

      // Manually connect
      socket!.connect();

      // Log the connection event
      socket!.onConnect((_) {
        if (_isDisabled) {
          LoggerUtils.warning('⚠️ Connected while disabled - disconnecting');
          socket?.disconnect();
          return;
        }
        LoggerUtils.debug(
            '✅ Socket connected ${accessToken.substring(0, 20)}...');
      });

      // Log when socket disconnects
      socket!.onDisconnect((_) {
        LoggerUtils.debug('⚠️ Socket disconnected');
      });

      // Log connection errors
      socket!.onConnectError((dynamic err) {
        LoggerUtils.debug('❌ Socket connection error: $err');
      });

      // Log general socket errors
      socket!.onError((dynamic err) {
        LoggerUtils.debug('🚨 Socket error: $err');
      });

      // Log reconnection attempts (should not happen)
      socket!.onReconnectAttempt((dynamic attempt) {
        LoggerUtils.warning('🔁 Unexpected reconnection attempt #$attempt');
      });

      // Log reconnection success
      socket!.onReconnect((dynamic attempt) {
        LoggerUtils.warning(
            '✅ Unexpected reconnection after $attempt attempts');
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
        if (_isDisabled) return;
        LoggerUtils.debug('💬 Message received: $data');
      });
    } catch (e) {
      LoggerUtils.debug('❌ Error connecting socket: $e');
    }
  }

  // Emit event after ensuring socket is connected.
  Future<void> emit(String event, dynamic data) async {
    if (_isDisabled) {
      LoggerUtils.warning('🚫 emit() blocked - socket disabled');
      return;
    }

    await checkSocketInitialized();
    if (socket != null && socket!.connected) {
      socket!.emit(event, data);
      LoggerUtils.debug('📤 Emit: $event \nData: $data');
    } else {
      LoggerUtils.debug("⚠️ Cannot emit, socket not connected.");
    }
  }

  // Emit event after ensuring socket is connected.
  dynamic emitAsync(String event, dynamic data) async {
    if (_isDisabled) {
      LoggerUtils.warning('🚫 emitAsync() blocked - socket disabled');
      return null;
    }

    await checkSocketInitialized();

    if (socket != null && socket!.connected) {
      try {
        var emitWithAckAsync = await socket!.emitWithAckAsync(event, data);
        LoggerUtils.debug(
            '📤Async Emit: $event \nData: $data \nResponse: $emitWithAckAsync');
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
    if (_isDisabled) {
      LoggerUtils.warning('🚫 listen() blocked for event: $event');
      return;
    }

    await checkSocketInitialized();
    if (socket != null && socket!.connected) {
      // Remove existing listener if any
      if (_activeListeners.contains(event)) {
        socket!.off(event);
        LoggerUtils.debug('🔄 Replacing existing listener: $event');
      }

      // Track this listener
      _activeListeners.add(event);

      socket!.on(event, (dynamic data) {
        if (_isDisabled) return; // Don't process if disabled
        callback(data);
        LoggerUtils.debug('📥 Received $event: $data');
      });
    } else {
      LoggerUtils.debug("⚠️ Cannot listen, socket not connected.");
    }
  }

  void disconnect() {
    LoggerUtils.debug('🔌 Disconnecting socket...');

    // Disable socket
    _isDisabled = true;

    // Remove all listeners
    _removeAllListeners();

    // Disconnect
    if (socket != null) {
      try {
        socket!.disconnect();
        socket!.dispose();
      } catch (e) {
        LoggerUtils.debug('Error disconnecting: $e');
      }
      socket = null;
    }

    accessToken = '';
    LoggerUtils.debug('✅ Socket disconnected');
  }

  // Call this when logging in with new user
  void enable() {
    LoggerUtils.debug('🔓 Socket re-enabled');
    _isDisabled = false;
  }
}

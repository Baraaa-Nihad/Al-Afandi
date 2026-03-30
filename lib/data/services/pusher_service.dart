import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/utils/method.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/data/services/app_notification_helper.dart';
import 'package:ovoride/data/services/local_storage_service.dart';
import 'package:ovoride/data/services/notification_controller.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PusherManager {
  static final PusherManager _instance = PusherManager._internal();
  factory PusherManager() => _instance;
  PusherManager._internal();

  final ApiClient apiClient = ApiClient(sharedPreferences: Get.find());
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  final List<void Function(PusherEvent)> _listeners = [];
  final List<void Function(String state)> _connectionStateListeners = [];

  bool _isConnecting = false;
  String _channelName = "";

  Future<void> subscribeToChannel(String channelName) async {
    if (pusher.getChannel(channelName) != null) {
      printX("Already subscribed: $channelName");
      return;
    }

    try {
      if (!isConnected()) {
        await checkAndInitIfNeeded(
          _channelName.isEmpty ? channelName : _channelName,
        );
      }
      await pusher.subscribe(channelName: channelName);
      printX("Subscribed to extra channel: $channelName");
    } catch (e) {
      printX("Error subscribing to $channelName: $e");
    }
  }

  Future<void> init(String channelName) async {
    if (_isConnecting) return;
    _isConnecting = true;
    _channelName = channelName;

    final apiKey = apiClient.getPushConfig().appKey ?? "";
    final cluster = apiClient.getPushConfig().cluster ?? "";

    await _disconnect();

    await pusher.init(
      apiKey: apiKey,
      cluster: cluster,
      onConnectionStateChange: _onConnectionStateChange,
      onEvent: _dispatchEvent,
      onError: (msg, code, e) => printE("Pusher Error: $msg"),
      onSubscriptionError: (msg, e) => printE("Subscription Error: $msg"),
      onSubscriptionSucceeded: (channel, data) =>
          printX("Subscribed: $channel"),
      onAuthorizer: onAuthorizer,
      onDecryptionFailure: (_, __) {},
      onMemberAdded: (_, __) {},
      onMemberRemoved: (_, __) {},
    );

    await _connect(channelName);
    _isConnecting = false;
  }

  Future<void> _connect(String channelName) async {
    if (isConnected()) {
      await _subscribe(channelName);
      return;
    }

    for (int i = 0; i < 3; i++) {
      try {
        printX("Connecting... (${i + 1}/3)");
        await pusher.connect();
        await Future.delayed(const Duration(seconds: 2));

        if (isConnected()) {
          printX("Connected");
          await _subscribe(channelName);
          return;
        }
      } catch (e) {
        printE("Connect failed: $e");
        if (i < 2) {
          await Future.delayed(const Duration(seconds: 3));
        }
      }
    }
    printE("Connection failed");
  }

  Future<void> _subscribe(String channelName) async {
    if (pusher.getChannel(channelName) != null) {
      printX("Already subscribed");
      return;
    }
    try {
      await pusher.subscribe(channelName: channelName);
    } catch (e) {
      printE("Subscribe error: $e");
    }
  }

  Future<void> _disconnect() async {
    try {
      if (pusher.connectionState.toLowerCase() != 'disconnected') {
        await pusher.disconnect();
      }
    } catch (_) {}
  }

  void _onConnectionStateChange(String current, String previous) {
    printX("State: $previous -> $current");
    _notifyConnectionStateListeners(current.toUpperCase());

    if (current.toLowerCase() == 'disconnected' &&
        previous.toLowerCase() == 'connected' &&
        !_isConnecting) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!isConnected() && !_isConnecting) {
          _connect(_channelName);
        }
      });
    }
  }

  void _dispatchEvent(PusherEvent event) {
    for (var listener in _listeners) {
      try {
        listener(event);
      } catch (e) {
        printE("Error in pusher listener for ${event.eventName}: $e");
      }
    }

    unawaited(_storeRealtimeNotification(event));
  }

  Future<void> _storeRealtimeNotification(PusherEvent event) async {
    try {
      final notification = AppNotificationHelper.fromPusherEvent(event);
      if (notification == null) {
        return;
      }

      Get.find<LocalStorageService>().addNotificationModel(notification);

      if (Get.isRegistered<NotificationController>()) {
        await Get.find<NotificationController>().getNotifications();
      }
    } catch (e) {
      printE("Error processing real-time notification: $e");
    }
  }

  void addListener(void Function(PusherEvent) listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void addConnectionStateListener(void Function(String state) listener) {
    if (!_connectionStateListeners.contains(listener)) {
      _connectionStateListeners.add(listener);
    }
    try {
      listener(currentConnectionState);
    } catch (e) {
      printE("Error syncing initial connection state: $e");
    }
  }

  void removeListener(void Function(PusherEvent) listener) {
    _listeners.remove(listener);
  }

  void removeConnectionStateListener(void Function(String state) listener) {
    _connectionStateListeners.remove(listener);
  }

  bool isConnected() => pusher.connectionState.toLowerCase() == 'connected';

  String get currentConnectionState {
    final String state = pusher.connectionState.trim();
    if (state.isEmpty) {
      return 'DISCONNECTED';
    }
    return state.toUpperCase();
  }

  Future<void> checkAndInitIfNeeded(String channelName) async {
    if (_isConnecting) return;

    if (!isConnected()) {
      await init(channelName);
    } else if (pusher.getChannel(channelName) == null) {
      await _subscribe(channelName);
    }
  }

  Future<Map<String, dynamic>?> onAuthorizer(
    String channelName,
    String socketId,
    options,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role =
          prefs.getString(SharedPreferenceHelper.userRoleKey) ?? 'driver';
      final pusherEndpoint = role == 'rider'
          ? 'pusher/auth'
          : 'driver/pusher/auth';
      final String authUrl =
          "${UrlContainer.baseUrl}$pusherEndpoint/$socketId/$channelName";
      final Map<String, String> body = {
        "socket_id": socketId,
        "channel_name": channelName,
      };

      final ResponseModel response = await apiClient.request(
        authUrl,
        Method.postMethod,
        body,
        passHeader: true,
      );
      if (response.statusCode == 200) {
        var res = response.responseJson;
        if (res is String) {
          try {
            res = jsonDecode(res);
          } catch (_) {}
        }
        if (res is Map) {
          if (res.containsKey('auth')) {
            return _normalizeAuthPayload(res);
          }
          if (res.containsKey('data') && res['data'] is Map) {
            return _normalizeAuthPayload(
              Map<String, dynamic>.from(res['data']),
            );
          }
        }
        return null;
      }
    } catch (e) {
      printE("Auth error: $e");
    }
    return null;
  }

  void _notifyConnectionStateListeners(String state) {
    for (final listener in _connectionStateListeners) {
      try {
        listener(state);
      } catch (e) {
        printE("Error updating connection state listener: $e");
      }
    }
  }

  Map<String, dynamic>? _normalizeAuthPayload(Map<dynamic, dynamic> payload) {
    final auth = payload['auth']?.toString();
    if (auth == null || auth.isEmpty) {
      return null;
    }

    final Map<String, dynamic> normalized = {"auth": auth};
    final channelData = payload['channel_data'];
    final sharedSecret = payload['shared_secret'];

    if (channelData != null) {
      normalized['channel_data'] = channelData is String
          ? channelData
          : jsonEncode(channelData);
    }
    if (sharedSecret != null && sharedSecret.toString().isNotEmpty) {
      normalized['shared_secret'] = sharedSecret.toString();
    }

    return normalized;
  }
}

import 'package:get/get.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/utils/method.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherManager {
  static final PusherManager _instance = PusherManager._internal();
  factory PusherManager() => _instance;
  PusherManager._internal();

  final ApiClient apiClient = ApiClient(sharedPreferences: Get.find());
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  final List<void Function(PusherEvent)> _listeners = [];

  bool _isConnecting = false;
  String _channelName = "";

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
      onError: (msg, code, e) => printE("❌ Pusher Error: $msg"),
      onSubscriptionError: (msg, e) => printE("⚠️ Sub Error: $msg"),
      onSubscriptionSucceeded: (channel, data) => printX("✅ Subscribed: $channel"),
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
        printX("🔌 Connecting... (${i + 1}/3)");
        await pusher.connect();
        await Future.delayed(const Duration(seconds: 2));

        if (isConnected()) {
          printX("✅ Connected");
          await _subscribe(channelName);
          return;
        }
      } catch (e) {
        printE("⚠️ Connect failed: $e");
        if (i < 2) await Future.delayed(const Duration(seconds: 3));
      }
    }
    printE("❌ Connection failed");
  }

  Future<void> _subscribe(String channelName) async {
    if (pusher.getChannel(channelName) != null) {
      printX("✅ Already subscribed");
      return;
    }
    try {
      await pusher.subscribe(channelName: channelName);
    } catch (e) {
      printE("⚠️ Subscribe error: $e");
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
    printX("🔁 State: $previous → $current");
    if (current.toLowerCase() == 'disconnected' && previous.toLowerCase() == 'connected' && !_isConnecting) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!isConnected() && !_isConnecting) _connect(_channelName);
      });
    }
  }

  void _dispatchEvent(PusherEvent event) {
    for (var listener in _listeners) {
      listener(event);
    }
  }

  void addListener(void Function(PusherEvent) listener) {
    if (!_listeners.contains(listener)) _listeners.add(listener);
  }

  void removeListener(void Function(PusherEvent) listener) {
    _listeners.remove(listener);
  }

  bool isConnected() => pusher.connectionState.toLowerCase() == 'connected';

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
      final role = prefs.getString(SharedPreferenceHelper.userRoleKey) ?? 'driver';
      final pusherEndpoint = role == 'rider' ? 'pusher/auth/' : 'driver/pusher/auth/';
      String authUrl = "\${UrlContainer.baseUrl}\${pusherEndpoint}\$socketId/\$channelName";
      ResponseModel response = await apiClient.request(
        authUrl,
        Method.postMethod,
        null,
        passHeader: true,
      );
      if (response.statusCode == 200) return response.responseJson;
    } catch (e) {
      printE("Auth error: $e");
    }
    return null;
  }
}

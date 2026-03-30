import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart' as getx;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/method.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/model/notification/notification_model.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/data/services/app_notification_helper.dart';
import 'package:ovoride/data/services/local_storage_service.dart';
import 'package:ovoride/data/services/notification_controller.dart';

import '../../firebase_options.dart';

final FlutterLocalNotificationsPlugin _backgroundNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
bool _backgroundNotificationsInitialized = false;

@pragma('vm:entry-point')
Future<void> _messageHandler(RemoteMessage message) async {
  final String? remark = AppNotificationHelper.extractRemark(
    Map<String, dynamic>.from(message.data),
  );
  printX(
    'Push background handler received messageId=${message.messageId} remark=$remark',
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final NotificationModel? notification =
      AppNotificationHelper.fromRemoteMessage(message);
  if (notification != null) {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await LocalStorageService.addNotificationModelToPreferences(
      preferences,
      notification,
    );
  }

  await _ensureBackgroundNotificationsInitialized();
  await _showBackgroundNotification(message);
}

class PushNotificationService {
  static StreamSubscription<String>? _tokenRefreshSubscription;

  ApiClient apiClient;

  PushNotificationService({required this.apiClient});

  static Future<void> registerTokenRefreshListener({
    required FirebaseMessaging firebaseMessaging,
    required Future<void> Function(String token) onTokenRefresh,
  }) async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = firebaseMessaging.onTokenRefresh.listen((
      String fcmDeviceToken,
    ) async {
      try {
        printX('FCM token refreshed: $fcmDeviceToken');
        await onTokenRefresh(fcmDeviceToken);
      } catch (e) {
        printX('Error handling token refresh: $e');
      }
    });
  }

  Future<void> setupInteractedMessage() async {
    FirebaseMessaging.onBackgroundMessage(_messageHandler);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    await _requestPermissions();

    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    printX('Push permission status: ${settings.authorizationStatus.name}');

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      printX('onMessageOpenedApp ${message.toMap()}');
      await _persistNotificationFromRemoteMessage(message);
      await _handleNotificationNavigation(
        Map<String, dynamic>.from(message.data),
      );
    });

    final RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      printX('getInitialMessage ${initialMessage.toMap()}');
      await _persistNotificationFromRemoteMessage(initialMessage);
      await _handleNotificationNavigation(
        Map<String, dynamic>.from(initialMessage.data),
      );
    }

    await enableIOSNotifications();
    await registerNotificationListeners();
  }

  Future<void> registerNotificationListeners() async {
    final AndroidNotificationChannel channel = androidNotificationChannel();
    final AndroidNotificationChannel bidChannel = bidNotificationChannel();
    final AndroidNotificationChannel newRideChannel =
        newRideNotificationChannel();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(bidChannel);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(newRideChannel);

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationResponse,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      try {
        final String? remark = AppNotificationHelper.extractRemark(
          Map<String, dynamic>.from(message.data),
        );
        printX(
          'Foreground FCM received messageId=${message.messageId} remark=$remark',
        );
        await _persistNotificationFromRemoteMessage(message);
        await _showLocalNotification(
          plugin: flutterLocalNotificationsPlugin,
          message: message,
        );
      } catch (e) {
        printX('Error handling foreground notification: $e');
      }
    });
  }

  AndroidNotificationChannel bidNotificationChannel() =>
      _bidNotificationChannel;

  AndroidNotificationChannel newRideNotificationChannel() =>
      _newRideNotificationChannel;

  AndroidNotificationChannel androidNotificationChannel() =>
      _defaultNotificationChannel;

  Future<void> enableIOSNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _requestPermissions() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<bool> sendUserToken() async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    final String role =
        apiClient.sharedPreferences.getString(
          SharedPreferenceHelper.userRoleKey,
        ) ??
        'driver';
    final String currentStoredToken =
        apiClient.sharedPreferences.getString(
          SharedPreferenceHelper.fcmDeviceKey,
        ) ??
        '';

    printX(
      'Registering FCM token for role=$role currentStoredToken=$currentStoredToken',
    );

    final String? fcmDeviceToken = await firebaseMessaging.getToken();
    printX('Resolved FCM token for role=$role token=$fcmDeviceToken');

    if (fcmDeviceToken == null || fcmDeviceToken.isEmpty) {
      printX('FCM token resolution failed for role=$role');
      return false;
    }

    if (currentStoredToken != fcmDeviceToken) {
      await apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.fcmDeviceKey,
        fcmDeviceToken,
      );
    }

    final bool success = await sendUpdatedToken(fcmDeviceToken);
    printX('FCM token send result for role=$role success=$success');

    await registerTokenRefreshListener(
      firebaseMessaging: firebaseMessaging,
      onTokenRefresh: (String refreshedToken) async {
        final String currentToken =
            apiClient.sharedPreferences.getString(
              SharedPreferenceHelper.fcmDeviceKey,
            ) ??
            '';
        if (currentToken == refreshedToken) {
          return;
        }

        await apiClient.sharedPreferences.setString(
          SharedPreferenceHelper.fcmDeviceKey,
          refreshedToken,
        );
        await sendUpdatedToken(refreshedToken);
      },
    );

    return success;
  }

  Future<bool> sendUpdatedToken(String deviceToken) async {
    try {
      final String role =
          apiClient.sharedPreferences.getString(
            SharedPreferenceHelper.userRoleKey,
          ) ??
          'driver';
      final String url =
          '${UrlContainer.baseUrl}${role == "rider" ? UrlContainer.riderDeviceTokenEndPoint : UrlContainer.deviceTokenEndPoint}';
      final Map<String, String> map = {'token': deviceToken};
      final ResponseModel response = await apiClient.request(
        url,
        Method.postMethod,
        map,
        passHeader: true,
      );
      printX(
        'FCM token registration status: ${response.statusCode} for role: $role',
      );
      return response.statusCode == 200;
    } catch (e) {
      printX('Error sending token: $e');
      return false;
    }
  }

  Future<void> _persistNotificationFromRemoteMessage(
    RemoteMessage message,
  ) async {
    final NotificationModel? notification =
        AppNotificationHelper.fromRemoteMessage(message);
    if (notification == null) {
      return;
    }

    apiClient.addNotificationModel(notification);
    _refreshNotificationController();
  }

  static Future<void> showRealtimeNotification(
    NotificationModel notification,
  ) async {
    final String? title = notification.title;
    final String? body = notification.body;
    final Map<String, dynamic> payload = Map<String, dynamic>.from(
      notification.payload ?? <String, dynamic>{},
    );

    if (notification.remark != null && notification.remark!.isNotEmpty) {
      payload.putIfAbsent('remark', () => notification.remark!);
    }
    if (notification.rideId != null && notification.rideId!.isNotEmpty) {
      payload.putIfAbsent('ride_id', () => notification.rideId!);
    }
    if (title != null && title.isNotEmpty) {
      payload.putIfAbsent('title', () => title);
    }
    if (body != null && body.isNotEmpty) {
      payload.putIfAbsent('body', () => body);
    }

    await _ensureBackgroundNotificationsInitialized();
    await _showNotification(
      plugin: _backgroundNotificationsPlugin,
      title: title,
      body: body,
      payload: payload,
      imageUrl: notification.image,
    );
  }
}

Future<void> _ensureBackgroundNotificationsInitialized() async {
  if (_backgroundNotificationsInitialized) {
    return;
  }

  const InitializationSettings initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  await _backgroundNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: _handleLocalNotificationResponse,
  );

  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _backgroundNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
  await androidImplementation?.createNotificationChannel(
    _defaultNotificationChannel,
  );
  await androidImplementation?.createNotificationChannel(
    _bidNotificationChannel,
  );
  await androidImplementation?.createNotificationChannel(
    _newRideNotificationChannel,
  );

  _backgroundNotificationsInitialized = true;
}

Future<void> _showBackgroundNotification(RemoteMessage message) async {
  try {
    await _showLocalNotification(
      plugin: _backgroundNotificationsPlugin,
      message: message,
    );
  } catch (e) {
    printX('Error handling background notification: $e');
  }
}

Future<void> _showLocalNotification({
  required FlutterLocalNotificationsPlugin plugin,
  required RemoteMessage message,
}) async {
  final Map<String, dynamic> rawPayload = Map<String, dynamic>.from(
    message.data,
  );
  final String? remark = AppNotificationHelper.extractRemark(rawPayload);
  final String? title = AppNotificationHelper.extractNotificationTitle(
    message: message,
    data: rawPayload,
    remark: remark,
  );
  final String? body = AppNotificationHelper.extractNotificationBody(
    message: message,
    data: rawPayload,
    remark: remark,
  );

  if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
    return;
  }

  final Map<String, dynamic> payload = Map<String, dynamic>.from(rawPayload);
  if (title != null && title.isNotEmpty) {
    payload.putIfAbsent('title', () => title);
  }
  if (body != null && body.isNotEmpty) {
    payload.putIfAbsent('body', () => body);
  }
  if (remark != null && remark.isNotEmpty) {
    payload.putIfAbsent('remark', () => remark);
  }

  final String? rideId = AppNotificationHelper.extractRideId(payload);
  if (rideId != null && rideId.isNotEmpty) {
    payload.putIfAbsent('ride_id', () => rideId);
  }

  final String? imageUrl = AppNotificationHelper.extractImage(
    message: message,
    data: rawPayload,
  );

  await _showNotification(
    plugin: plugin,
    title: title,
    body: body,
    payload: payload,
    imageUrl: imageUrl,
  );
}

Future<void> _showNotification({
  required FlutterLocalNotificationsPlugin plugin,
  required String? title,
  required String? body,
  required Map<String, dynamic> payload,
  String? imageUrl,
}) async {
  final String? remark = AppNotificationHelper.extractRemark(payload);
  final bool isNewRide = AppNotificationHelper.isNewRideType(remark);
  final bool isBid =
      remark != null && (remark.contains('bid') || remark.contains('new_bid'));

  final BigPictureStyleInformation? bigPictureStyle =
      await _buildBigPictureStyleFromUrl(
        imageUrl: imageUrl,
        title: title,
        body: body,
      );

  final AndroidNotificationChannel androidChannel = isNewRide
      ? _newRideNotificationChannel
      : (isBid ? _bidNotificationChannel : _defaultNotificationChannel);
  final String? notificationSound = (isNewRide || isBid) ? 'bid_sound' : null;
  final Priority notificationPriority = isNewRide
      ? Priority.max
      : Priority.high;
  final Importance notificationImportance = isNewRide
      ? Importance.max
      : Importance.high;

  await plugin.show(
    _notificationIdFromPayload(payload),
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        androidChannel.id,
        androidChannel.name,
        channelDescription: androidChannel.description,
        icon: '@mipmap/ic_launcher',
        category: isNewRide ? AndroidNotificationCategory.call : null,
        sound: notificationSound == null
            ? null
            : const RawResourceAndroidNotificationSound('bid_sound'),
        playSound: true,
        enableVibration: true,
        enableLights: true,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        priority: notificationPriority,
        importance: notificationImportance,
        styleInformation: bigPictureStyle ?? const BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(
        sound: notificationSound == null ? null : 'bid_sound.caf',
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
      ),
    ),
    payload: jsonEncode(payload),
  );
}

Future<void> _handleLocalNotificationResponse(
  NotificationResponse response,
) async {
  try {
    final String? payloadString = response.payload;
    if (payloadString == null || payloadString.isEmpty) {
      return;
    }

    final dynamic decoded = jsonDecode(payloadString);
    if (decoded is! Map) {
      return;
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);
    printX('Notification clicked with payload=$data');
    await _handleNotificationNavigation(data);
  } catch (e) {
    printX('Error on notification click: $e');
  }
}

Future<void> _handleNotificationNavigation(Map<String, dynamic> data) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final String role =
      preferences.getString(SharedPreferenceHelper.userRoleKey) ?? 'driver';
  final String? remark = AppNotificationHelper.extractRemark(data);
  final String? rideId = AppNotificationHelper.extractRideId(data);

  printX('Routing notification for role=$role remark=$remark rideId=$rideId');

  if (rideId != null && rideId.isNotEmpty) {
    final String route = role == 'driver'
        ? RouteHelper.driverRideDetailsScreen
        : RouteHelper.riderRideDetailsScreen;
    getx.Get.toNamed(route, arguments: rideId);
    return;
  }

  if (remark != null && remark.contains('-')) {
    final List<String> parts = remark.split('-');
    if (parts.length == 2) {
      getx.Get.toNamed(parts[0], arguments: parts[1]);
      return;
    }
  }

  if (role == 'driver' && AppNotificationHelper.isNewRideType(remark)) {
    getx.Get.offAllNamed(RouteHelper.dashboard);
    return;
  }

  getx.Get.toNamed(RouteHelper.notificationScreen);
}

void _refreshNotificationController() {
  if (getx.Get.isRegistered<NotificationController>()) {
    getx.Get.find<NotificationController>().getNotifications();
  }
}

Future<BigPictureStyleInformation?> _buildBigPictureStyleFromUrl({
  required String? imageUrl,
  required String? title,
  required String? body,
}) async {
  if (imageUrl == null || imageUrl.isEmpty) {
    return null;
  }

  try {
    final Dio dio = Dio();
    final Response<List<int>> response = await dio.get<List<int>>(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    final Uint8List bytes = Uint8List.fromList(response.data!);
    final String localImagePath = await _storeNotificationImage(bytes);
    return BigPictureStyleInformation(
      FilePathAndroidBitmap(localImagePath),
      contentTitle: title,
      summaryText: body,
    );
  } catch (e) {
    printX('Failed to download notification image: $e');
    return null;
  }
}

int _notificationIdFromPayload(Map<String, dynamic> payload) {
  final String? rideId = AppNotificationHelper.extractRideId(payload);
  final String? remark = AppNotificationHelper.extractRemark(payload);
  final String seed =
      '${rideId ?? ''}|${remark ?? ''}|${DateTime.now().millisecondsSinceEpoch}';
  return seed.hashCode & 0x7fffffff;
}

Future<String> _storeNotificationImage(Uint8List bytes) async {
  final Directory directory = await getTemporaryDirectory();
  final String imagePath = '${directory.path}/notification_image.png';
  final File file = File(imagePath);
  await file.writeAsBytes(bytes);
  return imagePath;
}

const AndroidNotificationChannel _bidNotificationChannel =
    AndroidNotificationChannel(
      'bid_channel',
      'إشعارات العروض',
      description: 'القناة دي مخصصة لعروض المشاوير والتفاوض على السعر.',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('bid_sound'),
      importance: Importance.max,
      enableVibration: true,
    );

const AndroidNotificationChannel _newRideNotificationChannel =
    AndroidNotificationChannel(
      'new_ride_channel',
      'إشعارات المشاوير الجديدة',
      description: 'القناة دي مخصصة لطلبات المشاوير الجديدة.',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('bid_sound'),
      importance: Importance.max,
      enableVibration: true,
      enableLights: true,
    );

const AndroidNotificationChannel _defaultNotificationChannel =
    AndroidNotificationChannel(
      'high_importance_channel',
      'إشعارات مهمة',
      description: 'القناة دي مخصصة للإشعارات المهمة.',
      playSound: true,
      enableVibration: true,
      enableLights: true,
      importance: Importance.high,
    );

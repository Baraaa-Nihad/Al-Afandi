import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/helper/shared_preference_helper.dart';
import '../../core/utils/method.dart';
import '../../firebase_options.dart';
import 'api_client.dart';
import 'package:get/get.dart' as getx;

Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class PushNotificationService {
  ApiClient apiClient;
  PushNotificationService({required this.apiClient});

  Future<void> setupInteractedMessage() async {
    FirebaseMessaging.onBackgroundMessage(_messageHandler);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await _requestPermissions();

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      printX('onMessageOpenedApp ${message.toMap()}');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      printX('onMessage ${event.toMap()}');
    });

    await enableIOSNotifications();
    await registerNotificationListeners();
  }

  Future<void> registerNotificationListeners() async {
    // تعريف القنوات
    AndroidNotificationChannel channel = androidNotificationChannel();
    AndroidNotificationChannel bChannel = bidNotificationChannel();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // تسجيل القنوات في النظام (أندرويد)
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(bChannel);

    var androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSSettings = const DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    var initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    // إعداد النقر على الإشعار والتوجيه
    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        try {
          String? payloadString = response.payload;
          if (payloadString != null && payloadString.isNotEmpty) {
            Map<String, dynamic> data = jsonDecode(payloadString);

            String? remark = data['remark'] ?? data['for_app'];
            String? rideId = data['ride_id']?.toString();

            printX('Notification Clicked: Remark: $remark, RideID: $rideId');

            if (remark != null) {
              // إذا كان الإشعار يخص عرض سعر جديد أو قبول عرض
              if (remark.contains('bid') || remark.contains('new_bid')) {
                getx.Get.toNamed(RouteHelper.riderRideDetailsScreen, arguments: rideId);
              }
              // التنسيق التقليدي (route-id)
              else if (remark.contains('-')) {
                String route = remark.split('-')[0];
                String id = remark.split('-')[1];
                getx.Get.toNamed(route, arguments: id);
              }
            }
          }
        } catch (e) {
          printX('Error on Notification Click: $e');
        }
      },
    );

    // الاستماع للإشعارات أثناء فتح التطبيق
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
      RemoteNotification? notification = message!.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        // فحص هل الإشعار يخص المزايدة لاختيار القناة والصوت
        String? remark = message.data['remark'] ?? message.data['for_app'];
        bool isBid = remark != null && (remark.contains('bid') || remark.contains('new_bid'));

        late BigPictureStyleInformation bigPictureStyle;
        if (android?.imageUrl != null) {
          Dio dio = Dio();
          Response<List<int>> response = await dio.get<List<int>>(
            android!.imageUrl!,
            options: Options(responseType: ResponseType.bytes),
          );
          Uint8List bytes = Uint8List.fromList(response.data!);
          final String localImagePath = await _saveImageLocally(bytes);
          bigPictureStyle = BigPictureStyleInformation(
            FilePathAndroidBitmap(localImagePath),
            contentTitle: notification.title,
            summaryText: notification.body,
          );
        }

        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              isBid ? bChannel.id : channel.id,
              isBid ? bChannel.name : channel.name,
              channelDescription: isBid ? bChannel.description : channel.description,
              icon: '@mipmap/ic_launcher',
              // إذا كانت مزايدة نستخدم الصوت المخصص، غير ذلك نستخدم الافتراضي
              sound: isBid ? const RawResourceAndroidNotificationSound('bid_sound') : null,
              playSound: true,
              enableVibration: true,
              enableLights: true,
              fullScreenIntent: true,
              priority: Priority.high,
              importance: Importance.high,
              styleInformation: android?.imageUrl != null ? bigPictureStyle : const BigTextStyleInformation(''),
            ),
            iOS: DarwinNotificationDetails(
              sound: isBid ? 'bid_sound.caf' : null,
              presentSound: true,
              presentAlert: true,
              presentBadge: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });
  }

  // القناة الخاصة بالمزايدات بصوت مختلف
  AndroidNotificationChannel bidNotificationChannel() => const AndroidNotificationChannel(
        'bid_channel',
        'Bidding Notifications',
        description: 'This channel is used for ride bidding and price negotiations.',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('bid_sound'),
        importance: Importance.max,
        enableVibration: true,
      );

  // القناة الافتراضية
  AndroidNotificationChannel androidNotificationChannel() => const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        playSound: true,
        enableVibration: true,
        enableLights: true,
        importance: Importance.high,
      );

  Future<void> enableIOSNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _requestPermissions() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<String> _saveImageLocally(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/notification_image.png';
    final file = File(imagePath);
    await file.writeAsBytes(bytes);
    return imagePath;
  }

  Future<bool> sendUserToken() async {
    String deviceToken = apiClient.sharedPreferences.getString(SharedPreferenceHelper.fcmDeviceKey) ?? '';
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    bool success = false;

    if (deviceToken.isEmpty) {
      firebaseMessaging.getToken().then((fcmDeviceToken) async {
        if (fcmDeviceToken != null) {
          success = await sendUpdatedToken(fcmDeviceToken);
        }
      });
    } else {
      firebaseMessaging.onTokenRefresh.listen((fcmDeviceToken) async {
        if (deviceToken != fcmDeviceToken) {
          apiClient.sharedPreferences.setString(SharedPreferenceHelper.fcmDeviceKey, fcmDeviceToken);
          success = await sendUpdatedToken(fcmDeviceToken);
        }
      });
    }
    return success;
  }

  Future<bool> sendUpdatedToken(String deviceToken) async {
    final role = apiClient.sharedPreferences.getString(SharedPreferenceHelper.userRoleKey) ?? 'driver';
    // ملاحظة: تأكد من تعريف UrlContainer أو استبداله بالرابط المباشر
    // String url = '${UrlContainer.baseUrl}${role == "rider" ? UrlContainer.riderDeviceTokenEndPoint : UrlContainer.deviceTokenEndPoint}';
    // Map<String, String> map = {'token': deviceToken};
    // await apiClient.request(url, Method.postMethod, map, passHeader: true);
    return true;
  }
}

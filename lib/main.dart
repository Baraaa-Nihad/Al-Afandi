import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/utils/audio_utils.dart';
import 'package:ovoride/core/utils/my_images.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/messages.dart';
import 'package:ovoride/data/controller/shared/localization/localization_controller.dart';
import 'package:ovoride/core/di_service/di_services.dart' as di_service;
import 'package:ovoride/data/services/running_ride_service.dart';
import 'package:ovoride/presentation/screens/driver/dashboard/forground_task_widget.dart';
import 'package:ovoride/data/services/forground_location_service.dart';
import 'package:ovoride/data/services/push_notification_service.dart';
import 'package:ovoride/environment.dart';
import 'data/services/api_client.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:toastification/toastification.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiClient.init();

  Map<String, Map<String, String>> languages = await di_service.init();

  MyUtils.allScreen();
  MyUtils().stopLandscape();
  AudioUtils();

  try {
    await PushNotificationService(apiClient: Get.find()).setupInteractedMessage();
  } catch (e) {
    printX(e);
  }

  HttpOverrides.global = MyHttpOverrides();

  // From rider — reset ride state on launch
  RunningRideService.instance.setIsRunning(false);

  tz.initializeTimeZones();

  // From driver — background location
  FlutterForegroundTask.initCommunicationPort();

  // From rider — warm up maps for better performance
  GoogleMapsFlutterAndroid().warmup();

  runApp(OvoApp(languages: languages));
}

// Driver background task entry point
@pragma('vm:entry-point')
void startForgroundTask() {
  FlutterForegroundTask.setTaskHandler(ForgroundLocationService());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => false;
  }
}

class OvoApp extends StatefulWidget {
  final Map<String, Map<String, String>> languages;
  const OvoApp({super.key, required this.languages});

  @override
  State<OvoApp> createState() => _OvoAppState();
}

class _OvoAppState extends State<OvoApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MyUtils.precacheImagesFromPathList(
      context,
      [MyImages.backgroundImage, MyImages.logoWhite, MyImages.noDataImage],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (localizeController) => ToastificationWrapper(
        config: ToastificationConfig(maxToastLimit: 10),
        child: GetMaterialApp(
          title: Environment.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'Cairo'),
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
          initialRoute: RouteHelper.splashScreen,
          getPages: RouteHelper().routes,
          locale: localizeController.locale,
          translations: Messages(languages: widget.languages),
          fallbackLocale: Locale(
            localizeController.locale.languageCode,
            localizeController.locale.countryCode,
          ),
          // Driver — foreground task wrapper (only active for driver role)
          builder: (context, child) => ForGroundTaskWidget(
            key: foregroundTaskKey,
            onWillStart: () => Future.value(true),
            callback: startForgroundTask,
            child: child ?? Container(),
          ),
        ),
      ),
    );
  }
}

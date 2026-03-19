import 'dart:convert';
import 'package:get/get.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/audio_utils.dart';
import 'package:ovoride/data/controller/driver/dashboard/ride_queue_manager.dart';
import 'package:ovoride/data/model/global/pusher/pusher_event_response_model.dart';
import 'package:ovoride/data/model/global/app/ride_model.dart';
import 'package:ovoride/data/services/pusher_service.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/data/controller/driver/dashboard/dashboard_controller.dart';

class GlobalPusherController extends GetxController {
  ApiClient apiClient;
  DashBoardController dashBoardController;

  GlobalPusherController({
    required this.apiClient,
    required this.dashBoardController,
  });

  @override
  void onInit() {
    super.onInit();
    PusherManager().addListener(onEvent);
  }

  List<String> activeEventList = [
    "bid_accept",
    "cash_payment_request",
    "online_payment_received",
  ];
  String connectionState = "DISCONNECTED"; // الحالة الافتراضية

// داخل دالة onInit أو دالة الربط مع Pusher
  void updateConnectionState(String state) {
    connectionState = state;
    update(); // لتحديث الواجهة فوراً
    printX("Pusher State Changed to: $state");
  }

  void onEvent(PusherEvent event) {
    try {
      printX("Global pusher event: ${event.eventName}");
      if (event.data == null || event.eventName == "" || event.data.toString() == "{}") return;

      final eventName = event.eventName.toLowerCase();

      // --- التعديل الجوهري لحدث الطلبات الجديدة ---
      if (eventName == "new_ride" && !isRideDetailsPage()) {
        // 1. تشغيل صوت التنبيه فوراً
        AudioUtils.playAudio(apiClient.getNotificationAudio());

        // 2. فك تشفير البيانات القادمة من Pusher
        PusherResponseModel model = PusherResponseModel.fromJson(
          jsonDecode(event.data),
        );

        final modifyData = PusherResponseModel(
          eventName: eventName,
          channelName: event.channelName,
          data: model.data,
        );

        final newRide = modifyData.data?.ride;

        if (newRide != null) {
          // 3. تحديث واجهة الداشبورد فوراً (إضافة الطلب للقائمة بالأنيميشن)
          dashBoardController.addNewRideDirectly(newRide);

          // 4. تحديث المبالغ في الواجهة
          dashBoardController.updateMainAmount(
            double.tryParse(newRide.amount.toString() ?? "0.00") ?? 0,
          );
        }

        // 5. إدارة طابور المنبثقات (Popups) كما هي
        final queueManager = Get.isRegistered<RideQueueManager>() ? Get.find<RideQueueManager>() : Get.put(RideQueueManager());

        queueManager.addRideToQueue(
          RideQueueItem(
            ride: newRide ?? RideModel(id: "-1"),
            currency: apiClient.getCurrency(),
            currencySym: apiClient.getCurrency(isSymbol: true),
            dashboardController: dashBoardController,
          ),
        );

        // 6. مزامنة صامتة مع السيرفر لضمان دقة البيانات 100%
        dashBoardController.initialData(shouldLoad: false);
      }

      // التحقق من رفض المزايدة (Bid Reject)
      if (eventName == "bid_reject" && !isRideDetailsPage()) {
        dashBoardController.initialData(shouldLoad: false);
      }

      // الانتقال لصفحة التفاصيل عند قبول المزايدة أو الدفع
      if (activeEventList.contains(eventName) && !isRideDetailsPage()) {
        PusherResponseModel model = PusherResponseModel.fromJson(
          jsonDecode(event.data),
        );
        final pusherData = PusherResponseModel(
          eventName: eventName,
          channelName: event.channelName,
          data: model.data,
        );

        Get.toNamed(
          RouteHelper.driverRideDetailsScreen,
          arguments: pusherData.data?.ride?.id,
        );
      }
    } catch (e) {
      printE("Error handling event ${event.eventName}: $e");
    }
  }

  bool isRideDetailsPage() {
    return Get.currentRoute == RouteHelper.driverRideDetailsScreen;
  }

  @override
  void onClose() {
    PusherManager().removeListener(onEvent);
    super.onClose();
  }

  Future<void> ensureConnection({String? channelName}) async {
    try {
      var userId = apiClient.sharedPreferences.getString(
            SharedPreferenceHelper.userIdKey,
          ) ??
          '';
      await PusherManager().checkAndInitIfNeeded(
        channelName ?? "private-rider-driver-$userId",
      );
    } catch (e) {
      printX("Error ensuring connection: $e");
    }
  }
}

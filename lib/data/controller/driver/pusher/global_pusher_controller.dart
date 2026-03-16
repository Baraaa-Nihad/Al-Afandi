import 'dart:convert';

import 'package:get/get.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/audio_utils.dart';
import 'package:ovoride/data/controller/driver/dashboard/dashboard_controller.dart';
import 'package:ovoride/data/controller/driver/dashboard/ride_queue_manager.dart';
import 'package:ovoride/data/model/global/pusher/pusher_event_response_model.dart';
import 'package:ovoride/data/model/global/app/ride_model.dart';
import 'package:ovoride/data/services/pusher_service.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/data/services/api_client.dart';

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

  void onEvent(PusherEvent event) {
    try {
      printX("Global pusher event: ${event.eventName}");
      if (event.data == null || event.eventName == "" || event.data.toString() == "{}") return;

      final eventName = event.eventName.toLowerCase();

      //Dashbaod New Ride Popup and Rides Management
      if (eventName == "new_ride" && !isRideDetailsPage()) {
        AudioUtils.playAudio(apiClient.getNotificationAudio());
        PusherResponseModel model = PusherResponseModel.fromJson(
          jsonDecode(event.data),
        );
        final modifyData = PusherResponseModel(
          eventName: eventName,
          channelName: event.channelName,
          data: model.data,
        );

        dashBoardController.updateMainAmount(
          double.tryParse(modifyData.data?.ride?.amount.toString() ?? "0.00") ?? 0,
        );

        // Get or create RideQueueManager
        final queueManager = Get.isRegistered<RideQueueManager>() ? Get.find<RideQueueManager>() : Get.put(RideQueueManager());

        // Add ride to queue
        queueManager.addRideToQueue(
          RideQueueItem(
            ride: modifyData.data?.ride ?? RideModel(id: "-1"),
            currency: Get.find<ApiClient>().getCurrency(),
            currencySym: Get.find<ApiClient>().getCurrency(isSymbol: true),
            dashboardController: dashBoardController,
          ),
        );
        dashBoardController.initialData(shouldLoad: false);
      }
      //Check Customer reject my bid
      if (eventName == "bid_reject" && !isRideDetailsPage()) {
        dashBoardController.initialData(shouldLoad: false);
      }
      //Go to Ride Details Page Payment Complete
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

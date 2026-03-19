import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'dart:convert';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/app_status.dart';
import 'package:ovoride/core/utils/audio_utils.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:ovoride/data/controller/rider/ride/ride_details/ride_details_controller.dart';
import 'package:ovoride/data/model/general_setting/general_setting_response_model.dart';
import 'package:ovoride/data/model/global/pusher/pusher_event_response_model.dart';
import 'package:ovoride/data/services/pusher_service.dart';
import 'package:ovoride/presentation/components/dialog/show_custom_bid_dialog.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:get/get.dart';
import 'package:ovoride/data/controller/rider/ride/ride_meassage/ride_meassage_controller.dart';
import 'package:ovoride/data/services/api_client.dart';

class PusherRideController extends GetxController {
  ApiClient apiClient;
  RideMessageController rideMessageController;
  RideDetailsController rideDetailsController;
  String rideID;
  PusherRideController({
    required this.apiClient,
    required this.rideMessageController,
    required this.rideDetailsController,
    required this.rideID,
  });

  @override
  void onInit() {
    super.onInit();
    PusherManager().addListener(onEvent);
  }

  PusherConfig pusherConfig = PusherConfig();

  /// دالة الاشتراك في قناة الرحلة لضمان وصول العروض لحظياً
  Future<void> subscribeToRide(String rideId, Function(dynamic) onUpdate) async {
    try {
      this.rideID = rideId; // تحديث الـ ID الحالي
      String channelName = "ride.$rideId"; // تنسيق القناة الخاص بالرحلة

      // الاشتراك في القناة عبر المدير
      await PusherManager().subscribeToChannel(channelName);

      // ربط التحديث التلقائي
      // ملاحظة: الـ listener الأصلي (onEvent) سيتكفل بالباقي
      // ولكن نمرر التحديث لضمان مزامنة الـ UI
      printX("Subscribed to Ride Channel: $channelName");
    } catch (e) {
      printX("Error subscribing to ride channel: $e");
    }
  }

  /// Handle incoming Pusher events
  void onEvent(PusherEvent event) {
    try {
      printD('Pusher Channel: ${event.channelName}');
      printD('Pusher Event: ${event.eventName}');
      if (event.data == null) return;

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(event.data);
      } catch (e) {
        printX('Invalid JSON: $e');
        return;
      }

      final model = PusherResponseModel.fromJson(data);
      final modifiedEvent = PusherResponseModel(
        eventName: event.eventName,
        channelName: event.channelName,
        data: model.data,
      );

      updateEvent(modifiedEvent);
    } catch (e) {
      printX('onEvent error: $e');
    }
  }

  /// Update UI or state based on event name
  void updateEvent(PusherResponseModel event) {
    final eventName = event.eventName?.toLowerCase();
    printX('Handling event: $eventName');

    switch (eventName) {
      case 'online_payment_received':
        _handleOnlinePayment(event);
        break;

      case 'message_received':
        _handleMessageReceived(event);
        break;

      case 'live_location':
        _handleLiveLocation(event);
        break;

      case 'new_bid':
        _handleNewBid(event);
        break;

      case 'bid_reject':
        rideDetailsController.updateBidCount(true);
        break;

      case 'cash_payment_received':
        _handleCashPayment(event);
        break;

      case 'pick_up':
      case 'ride_end':
      case 'bid_accept':
        _updateRideIfAvailable(event);
        break;

      default:
        _updateRideIfAvailable(event);
        break;
    }
  }

  /// Handlers for each event type

  void _handleOnlinePayment(PusherResponseModel event) {
    printX('Online payment received for ride: ${event.data?.rideId}');
    Get.offAndToNamed(
      RouteHelper.rideReviewScreen,
      arguments: event.data?.rideId ?? '',
    );
  }

  void _handleMessageReceived(PusherResponseModel eventResponse) {
    if (eventResponse.data?.message != null) {
      if (eventResponse.data!.ride != null && eventResponse.data!.ride!.id != rideID) {
        printX('Message for different ride: ${eventResponse.data!.ride!.id}, current ride: $rideID');
        return;
      }
      if (isRideDetailsPage()) {
        if (rideDetailsController.repo.apiClient.isNotificationAudioEnable()) {
          MyUtils.vibrate();
        }
      }

      rideMessageController.addEventMessage(eventResponse.data!.message!);
    }
  }

  void _handleLiveLocation(PusherResponseModel eventResponse) {
    if (eventResponse.data!.ride != null && eventResponse.data!.ride!.id != rideID) {
      printX('Message for different ride: ${eventResponse.data!.ride!.id}, current ride: $rideID');
      return;
    }
    if (rideDetailsController.ride.status == AppStatus.RIDE_ACTIVE.toString() || rideDetailsController.ride.status == AppStatus.RIDE_RUNNING.toString()) {
      final lat = StringConverter.formatDouble(eventResponse.data?.driverLatitude ?? '0', precision: 10);
      final lng = StringConverter.formatDouble(eventResponse.data?.driverLongitude ?? '0', precision: 10);
      rideDetailsController.mapController.updateDriverLocation(
        latLng: LatLng(lat, lng),
        isRunning: false,
      );
    }
  }

  void _handleNewBid(PusherResponseModel eventResponse) {
    if (eventResponse.data!.bid != null && eventResponse.data!.bid!.rideId != rideID) {
      printX('Message for different ride: ${eventResponse.data!.bid!.rideId}, current ride: $rideID');
      return;
    }
    final bid = eventResponse.data?.bid;
    if (bid != null) {
      AudioUtils.playAudio(apiClient.getNotificationAudio());
      if (rideDetailsController.repo.apiClient.isNotificationAudioEnable()) {
        MyUtils.vibrate();
      }

      CustomBidDialog.newBid(
        bid: bid,
        currency: rideDetailsController.currencySym,
        driverImagePath: '${rideDetailsController.driverImagePath}/${bid.driver?.avatar}',
        serviceImagePath: '${rideDetailsController.serviceImagePath}/${eventResponse.data?.service?.image}',
        totalRideCompleted: eventResponse.data?.driverTotalRide ?? '0',
      );
    }
    rideDetailsController.updateBidCount(false);
  }

  void _handleCashPayment(PusherResponseModel event) {
    rideDetailsController.updatePaymentRequested(isRequested: false);
    _updateRideIfAvailable(event);
  }

  void _updateRideIfAvailable(PusherResponseModel eventResponse) {
    if (eventResponse.data!.ride != null && eventResponse.data!.ride!.id != rideID) {
      printX('Message for different ride: ${eventResponse.data!.ride!.id}, current ride: $rideID');
      return;
    }
    final ride = eventResponse.data?.ride;
    if (ride != null) {
      rideDetailsController.updateRide(ride);
    }
  }

  /// Utility
  bool isRideDetailsPage() => Get.currentRoute == RouteHelper.riderRideDetailsScreen;

  @override
  void onClose() {
    PusherManager().removeListener(onEvent);
    super.onClose();
  }

  Future<void> ensureConnection({String? channelName}) async {
    try {
      var userId = apiClient.sharedPreferences.getString(SharedPreferenceHelper.userIdKey) ?? '';
      await PusherManager().checkAndInitIfNeeded(channelName ?? "private-rider-user-$userId");
    } catch (e) {
      printX("Error ensuring connection: $e");
    }
  }
}

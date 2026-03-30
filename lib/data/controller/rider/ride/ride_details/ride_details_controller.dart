import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:ovoride/data/controller/driver/pusher/pusher_ride_controller.dart';
import 'package:ovoride/data/controller/rider/map/ride_map_controller.dart';
import 'package:ovoride/data/model/authorization/authorization_response_model.dart';
import 'package:ovoride/data/model/rider/bid/bid_list_response_model.dart';
import 'package:ovoride/data/model/global/app/review_model.dart';
import 'package:ovoride/data/model/global/app/ride_model.dart';
import 'package:ovoride/data/model/global/bid/bid_model.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/model/rider/ride/ride_details_response_model.dart';
import 'package:ovoride/data/repo/rider/ride/ride_repo.dart';
import 'package:ovoride/presentation/components/snack_bar/show_custom_snackbar.dart';

class RideDetailsController extends GetxController {
  RideRepo repo;
  RideMapController mapController;
  RideDetailsController({required this.repo, required this.mapController});

  RideModel ride = RideModel(id: '-1');
  String currency = '';
  String currencySym = '';
  bool isLoading = true;
  bool isPaymentRequested = false;
  LatLng pickupLatLng = const LatLng(0, 0);
  LatLng destinationLatLng = const LatLng(0, 0);
  String rideId = '-1';
  String serviceImagePath = '';
  String brandImagePath = '';
  String driverImagePath = '';
  String driverTotalCompletedRide = '';
  List<String> tipsList = [];

  TextEditingController tipsController = TextEditingController();

  void updateTips(String amount) {
    tipsController.text = amount;
    update();
  }

  void updatePaymentRequested({bool isRequested = true}) {
    isPaymentRequested = isRequested;
    update();
  }

  void updateRide(RideModel updatedRide) {
    ride = updatedRide;
    update();
    printD('Updated ride: $ride');
  }

  // دالة الربط مع Pusher لضمان تحديث العروض والبيانات لحظياً
  void subscribeToPusher() {
    try {
      if (Get.isRegistered<PusherRideController>()) {
        final pusherController = Get.find<PusherRideController>();
        pusherController.subscribeToRide(rideId, (eventData) {
          // عند وصول أي حدث من السيرفر (عرض جديد أو تحديث حالة)
          getRideBidList(rideId);
          getRideDetails(rideId, shouldLoading: false);
          printX('Pusher: Ride $rideId updated successfully.');
        });
      }
    } catch (e) {
      printX('Pusher Subscription Silent Error: $e');
    }
  }

  void initialData(String id) async {
    currency = repo.apiClient.getCurrency();
    currencySym = repo.apiClient.getCurrency(isSymbol: true);
    rideId = id;
    totalBids = 0;
    bids = [];
    cancelReasonController.text = '';
    isLoading = true;
    isPaymentRequested = false;
    tipsList = repo.apiClient.getTipsList();
    update();

    await Future.wait([getRideBidList(id), getRideDetails(id)]);

    // تفعيل الاستماع للبوشر بعد تحميل البيانات الأولية
    subscribeToPusher();

    isLoading = false;
    update();
  }

  // باقي الدوال الأصلية كما هي دون تعديل لضمان استقرار الكود
  Future<void> getRideDetails(String id, {bool shouldLoading = true}) async {
    currency = repo.apiClient.getCurrency();
    currencySym = repo.apiClient.getCurrency(isSymbol: true);
    rideId = id;

    bids = [];
    isLoading = shouldLoading;
    update();

    ResponseModel responseModel = await repo.getRideDetails(id);
    if (responseModel.statusCode == 200) {
      RideDetailsResponseModel model = RideDetailsResponseModel.fromJson(
        (responseModel.responseJson),
      );
      if (model.status == MyStrings.success) {
        RideModel? tempRide = model.data?.ride;
        if (tempRide != null) {
          ride = tempRide;
          driverTotalCompletedRide = model.data?.driverTotalRide ?? '';
          pickupLatLng = LatLng(
            StringConverter.formatDouble(
              tempRide.pickupLatitude.toString(),
              precision: 16,
            ),
            StringConverter.formatDouble(
              tempRide.pickupLongitude.toString(),
              precision: 16,
            ),
          );
          destinationLatLng = LatLng(
            StringConverter.formatDouble(
              tempRide.destinationLatitude.toString(),
              precision: 16,
            ),
            StringConverter.formatDouble(
              tempRide.destinationLongitude.toString(),
              precision: 14,
            ),
          );
        }
        serviceImagePath =
            '${UrlContainer.domainUrl}/${model.data?.serviceImagePath ?? ''}';
        brandImagePath =
            '${UrlContainer.domainUrl}/${model.data?.brandImagePath ?? ''}';
        driverImagePath =
            '${UrlContainer.domainUrl}/${model.data?.driverImagePath}';

        update();
        mapController.loadMap(
          pickup: pickupLatLng,
          destination: destinationLatLng,
          isRunning: ride.status == "3",
        );
      } else {
        Get.back();
        CustomSnackBar.error(
          errorList: model.message ?? [MyStrings.somethingWentWrong],
        );
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
    isLoading = false;
    update();
  }

  List<BidModel> bids = [];
  List<BidModel> tempBids = [];
  int totalBids = 0;
  Future<void> getRideBidList(String id) async {
    try {
      ResponseModel responseModel = await repo.getRideBidList(id: id);
      if (responseModel.statusCode == 200) {
        BidListResponseModel model = BidListResponseModel.fromJson(
          (responseModel.responseJson),
        );
        if (model.status == "success") {
          bids = model.data?.bids ?? [];
          totalBids = bids.length;
          update();
        }
      }
    } catch (e) {
      printX(e);
    }
  }

  void updateTempBid({required BidModel bid, bool isRemoved = false}) {
    if (isRemoved) {
      tempBids.remove(bid);
    } else {
      tempBids.add(bid);
    }
    update();
  }

  void updateBidCount(bool remove) {
    if (totalBids > 0 && remove) {
      totalBids--;
    } else {
      totalBids++;
    }
    update();
  }

  bool isAcceptLoading = false;
  String selectedId = '-1';
  Future<void> acceptBid(String id, {VoidCallback? onSuccess}) async {
    isAcceptLoading = true;
    selectedId = id;
    update();
    try {
      ResponseModel responseModel = await repo.acceptBid(bidId: id);
      if (responseModel.statusCode == 200) {
        RideDetailsResponseModel model = RideDetailsResponseModel.fromJson(
          (responseModel.responseJson),
        );
        if (model.status == "success") {
          await getRideDetails(ride.id ?? "", shouldLoading: false);
          onSuccess?.call();
        } else {
          CustomSnackBar.error(
            errorList: model.message ?? [MyStrings.somethingWentWrong],
            dismissAll: false,
          );
        }
      } else {
        CustomSnackBar.error(
          errorList: [responseModel.message],
          dismissAll: false,
        );
      }
    } catch (e) {
      printX(e);
    }
    selectedId = '-1';
    isAcceptLoading = false;
    update();
  }

  bool isRejectLoading = false;
  Future<void> rejectBid(String id, {VoidCallback? onSuccess}) async {
    isRejectLoading = true;
    selectedId = id;
    update();
    try {
      ResponseModel responseModel = await repo.rejectBid(id: id);
      if (responseModel.statusCode == 200) {
        RideDetailsResponseModel model = RideDetailsResponseModel.fromJson(
          (responseModel.responseJson),
        );
        if (model.status == "success") {
          await getRideDetails(ride.id ?? "", shouldLoading: false);
          onSuccess?.call();
        } else {
          CustomSnackBar.error(
            errorList: model.message ?? [MyStrings.somethingWentWrong],
            dismissAll: false,
          );
        }
      } else {
        CustomSnackBar.error(
          errorList: [responseModel.message],
          dismissAll: false,
        );
      }
    } catch (e) {
      printX(e);
    }
    isRejectLoading = false;
    selectedId = '-1';
    update();
  }

  TextEditingController sosMsgController = TextEditingController();
  bool isSosLoading = false;
  Future<void> sos(String id) async {
    isSosLoading = true;
    update();
    Position position = await MyUtils.getCurrentPosition();
    try {
      ResponseModel responseModel = await repo.sos(
        id: ride.id ?? "-1",
        msg: sosMsgController.text,
        latLng: LatLng(position.latitude, position.longitude),
      );
      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(
          (responseModel.responseJson),
        );
        if (model.status == "success") {
          sosMsgController.text = '';
          update();
          CustomSnackBar.success(
            successList: model.message ?? [MyStrings.requestSuccess],
          );
        }
      }
    } catch (e) {
      printX(e);
    }
    isSosLoading = false;
    update();
  }

  bool isCancelLoading = false;
  TextEditingController cancelReasonController = TextEditingController();
  Future<void> cancelRide() async {
    isCancelLoading = true;
    update();
    try {
      ResponseModel responseModel = await repo.cancelRide(
        id: ride.id ?? "-1",
        reason: cancelReasonController.text,
      );
      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(
          (responseModel.responseJson),
        );
        if (model.status == "success") {
          await getRideDetails(rideId, shouldLoading: false);
          Get.offAllNamed(RouteHelper.riderDashboard);
          CustomSnackBar.success(
            successList: model.message ?? [MyStrings.requestSuccess],
          );
        }
      }
    } catch (e) {
      printX(e);
    }
    isCancelLoading = false;
    update();
  }

  double rating = 0.0;
  TextEditingController reviewMsgController = TextEditingController();
  bool isReviewLoading = false;
  Future<void> reviewRide(String rideId) async {
    isReviewLoading = true;
    update();
    try {
      ResponseModel responseModel = await repo.reviewRide(
        rideId: rideId,
        rating: rating.toString(),
        review: reviewMsgController.text,
      );
      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(
          (responseModel.responseJson),
        );
        if (model.status == MyStrings.success) {
          ride.driverReview = UserReview(
            rating: rating.toString(),
            review: reviewMsgController.text,
          );
          reviewMsgController.text = '';
          rating = 0.0;
          update();
          Get.back();
          CustomSnackBar.success(successList: model.message ?? []);
        }
      }
    } catch (e) {
      printX(e);
    }
    isReviewLoading = false;
    update();
  }

  void updateRating(double rate) {
    rating = rate;
    update();
  }
}

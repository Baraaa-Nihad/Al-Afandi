import 'dart:async'; // ضروري للـ Timer
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/data/model/authorization/authorization_response_model.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/model/global/app/ride_model.dart';
import 'package:ovoride/data/model/dashboard/dashboard_response_model.dart';
import 'package:ovoride/data/model/global/user/global_driver_model.dart';
import 'package:ovoride/data/repo/driver/dashboard/dashboard_repo.dart';
import 'package:ovoride/environment.dart';
import 'package:ovoride/presentation/components/snack_bar/show_custom_snackbar.dart';
import 'package:ovoride/presentation/screens/driver/dashboard/forground_task_widget.dart';
import 'package:ovoride/core/utils/url_container.dart';

class DashBoardController extends GetxController {
  DashBoardRepo repo;
  DashBoardController({required this.repo});
  TextEditingController bidAmountController = TextEditingController();

  String? profileImageUrl;
  bool isLoading = true;
  Position? currentPosition;
  String currentAddress = "${MyStrings.loading.tr}...";
  bool userOnline = false;
  String? nextPageUrl;
  int page = 0;
  bool isDriverVerified = true;
  bool isVehicleVerified = true;

  bool isVehicleVerificationPending = false;
  bool isDriverVerificationPending = false;

  String currency = '';
  String currencySym = '';
  String userImagePath = '';

  List<RideModel> rideList = [];
  List<RideModel> pendingRidesList = [];
  RideModel? runningRide;
  GlobalDriverInfoModel driver = GlobalDriverInfoModel(id: '-1');

  // مؤقت للتحديث التلقائي الصامت
  Timer? _periodicTimer;

  @override
  void onInit() {
    super.onInit();
    // تشغيل التحديث التلقائي كل 15 ثانية لضمان السرعة دون الحاجة لضغط ريفرش
    _startAutoSync();
  }

  @override
  void onClose() {
    _periodicTimer?.cancel();
    super.onClose();
  }

  void addNewRideDirectly(RideModel newRide) {
    // نضيف شرط الـ userOnline لضمان عدم ظهور طلبات والسائق "أوفلاين"
    if (!userOnline) return;

    bool exists = rideList.any((element) => element.id == newRide.id);
    if (!exists) {
      rideList.insert(0, newRide);
      update();
    }
  }

  // دالة التحديث التلقائي (السر في السرعة)
  void _startAutoSync() {
    _periodicTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      // نحدث فقط إذا كان السائق أونلاين ولا يوجد تحميل حالي
      if (userOnline && !isLoading) {
        loadData(shouldLoad: false);
      }
    });
  }

  // تحديث البيانات عند وصول إشارة Socket (اختياري لو فعلت Pusher)
  void handleNewRideFromSocket(RideModel newRide) {
    bool exists = rideList.any((r) => r.id == newRide.id);
    if (!exists) {
      rideList.insert(0, newRide);
      update();
    }
  }

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad;
    page = 0;
    nextPageUrl = null;
    bidAmountController.text = '';
    currency = repo.apiClient.getCurrency();
    currencySym = repo.apiClient.getCurrency(isSymbol: true);
    update();
    await Future.wait([fetchLocation(), loadData(shouldLoad: shouldLoad)]);
    isLoading = false;
    update();
  }

  Future<void> fetchLocation() async {
    bool hasPermission = await MyUtils.checkAppLocationPermission(
      onsuccess: () => initialData(),
    );
    if (hasPermission) {
      getCurrentLocationAddress();
    }
  }

  Future<void> getCurrentLocationAddress() async {
    try {
      final GeolocatorPlatform geolocator = GeolocatorPlatform.instance;
      currentPosition = await geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      if (currentPosition != null) {
        if (Environment.addressPickerFromGoogleMapApi) {
          currentAddress =
              await repo.getActualAddress(
                currentPosition!.latitude,
                currentPosition!.longitude,
              ) ??
              'موقع غير معروف';
        } else {
          final placemarks = await placemarkFromCoordinates(
            currentPosition!.latitude,
            currentPosition!.longitude,
          );
          if (placemarks.isNotEmpty) {
            currentAddress = _formatAddress(placemarks.first);
          }
        }
      }
      update();
    } catch (e) {
      printX("Location Error: $e");
    }
  }

  String _formatAddress(Placemark placemark) {
    return [
      placemark.street ?? '',
      placemark.subLocality ?? '',
      placemark.locality ?? '',
      placemark.country ?? '',
    ].where((part) => part.isNotEmpty).join(', ');
  }

  Future<void> loadData({bool shouldLoad = true}) async {
    try {
      if (shouldLoad) {
        page = page + 1;
        if (page == 1) {
          isLoading = true;
          update();
        }
      } else {
        // في حالة التحديث التلقائي الصامت، نبقى في الصفحة الأولى لمزامنة الجديد
        page = 1;
      }

      ResponseModel responseModel = await repo.getDashboardData(
        page: page.toString(),
      );

      if (responseModel.statusCode == 200) {
        DashBoardRideResponseModel model = DashBoardRideResponseModel.fromJson(
          responseModel.responseJson,
        );
        if (model.status == MyStrings.success) {
          nextPageUrl = model.data?.ride?.nextPageUrl;
          userImagePath =
              '${UrlContainer.domainUrl}/${model.data?.userImagePath}';

          if (page == 1) {
            rideList.clear();
          }

          rideList.addAll(model.data?.ride?.data ?? []);
          pendingRidesList = model.data?.pendingRides ?? [];

          isDriverVerified = model.data?.driverInfo?.dv == "1";
          isVehicleVerified = model.data?.driverInfo?.vv == "1";
          isVehicleVerificationPending = model.data?.driverInfo?.vv == "2";
          isDriverVerificationPending = model.data?.driverInfo?.dv == "2";

          userOnline = model.data?.driverInfo?.onlineStatus == "1";
          startForegroundTask();

          repo.apiClient.setOnlineStatus(userOnline);
          driver = model.data?.driverInfo ?? GlobalDriverInfoModel(id: '-1');
          runningRide = model.data?.runningRide;

          profileImageUrl =
              "${UrlContainer.domainUrl}/${model.data?.driverImagePath}/${model.data?.driverInfo?.image}";

          update();
        }
      }
    } catch (e) {
      printX("LoadData Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  bool hasNext() {
    return nextPageUrl != null &&
        nextPageUrl!.isNotEmpty &&
        nextPageUrl != 'null';
  }

  bool isSendBidLoading = false;
  Future<void> sendBid(
    String rideId, {
    String? amount,
    VoidCallback? onActon,
  }) async {
    isSendBidLoading = true;
    update();
    try {
      ResponseModel responseModel = await repo.createBid(
        amount: amount ?? "",
        id: rideId,
      );
      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(
          responseModel.responseJson,
        );
        if (model.status == "success") {
          if (onActon != null) onActon();
          Get.toNamed(
            RouteHelper.driverRideDetailsScreen,
            arguments: rideId,
          )?.then((v) => initialData(shouldLoad: false));
        } else {
          CustomSnackBar.error(
            errorList: model.message ?? [MyStrings.somethingWentWrong],
          );
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e);
    }
    isSendBidLoading = false;
    update();
  }

  void updateMainAmount(double amount) {
    bidAmountController.text = StringConverter.formatNumber(amount.toString());
    update();
  }

  Future<void> onlineStatusSubmit() async {
    try {
      isChangingOnlineStatusLoading = true;
      update();
      ResponseModel responseModel = await repo.onlineStatus(
        lat: currentPosition?.latitude.toString() ?? "",
        long: currentPosition?.longitude.toString() ?? "",
      );
      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(
          responseModel.responseJson,
        );
        if (model.status == MyStrings.success) {
          userOnline = model.data?.online.toString() == 'true';
          repo.apiClient.setOnlineStatus(userOnline);
          startForegroundTask();
          await loadData(shouldLoad: true);
        }
      }
    } catch (e) {
      printE(e);
    } finally {
      isChangingOnlineStatusLoading = false;
      update();
    }
  }

  bool isChangingOnlineStatusLoading = false;
  Future<void> startForegroundTask() async {
    try {
      if (userOnline) {
        await foregroundTaskKey.currentState?.startForegroundTask();
      } else {
        await foregroundTaskKey.currentState?.stopForegroundTask();
      }
    } catch (e) {
      printE(e);
    }
  }

  Future<void> changeOnlineStatus(bool value) async {
    bool hasPermission = await MyUtils.checkAppLocationPermission(
      onsuccess: () async => await onlineStatusSubmit(),
    );
    if (hasPermission) {
      userOnline = value;
      update();
      await onlineStatusSubmit();
    }
  }
}

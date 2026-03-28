import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/messages.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/controller/shared/localization/localization_controller.dart';
import 'package:ovoride/data/model/authorization/authorization_response_model.dart';
import 'package:ovoride/data/model/general_setting/general_setting_response_model.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/repo/shared/auth/general_setting_repo.dart';
import 'package:ovoride/presentation/components/snack_bar/show_custom_snackbar.dart';

class SplashController extends GetxController {
  GeneralSettingRepo repo;
  LocalizationController localizationController;

  SplashController({
    required this.repo,
    required this.localizationController,
  });

  bool isLoading = true;
  bool noInternet = false;
  bool isMaintenance = false;

  Future<void> gotoNextPage() async {
    await loadLanguage();

    bool isRemember = repo.apiClient.sharedPreferences.getBool(
          SharedPreferenceHelper.rememberMeKey,
        ) ??
        false;

    noInternet = false;
    update();

    await initSharedData();

    /// ✅ طلب الموقع بعد السبلاش مباشرة
    await _requestLocationPermissionAndCache();

    getGSData(isRemember);
  }

  void getGSData(bool isRemember) async {
    ResponseModel response = await repo.getGeneralSetting();

    bool isOnboardAlreadyDisplayed = repo.apiClient.sharedPreferences.getBool(
          SharedPreferenceHelper.onBoardKey,
        ) ??
        false;

    String? savedRole = repo.apiClient.sharedPreferences.getString(
      SharedPreferenceHelper.userRoleKey,
    );
    bool hasRole = savedRole != null && savedRole.isNotEmpty;

    if (response.statusCode == 200) {
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(
        response.responseJson,
      );

      if (model.status?.toLowerCase() == MyStrings.success) {
        isMaintenance = model.data?.generalSetting?.maintenanceMode == "1";
        repo.apiClient.storeGeneralSetting(model);
        repo.apiClient.storePushSetting(
          model.data?.generalSetting?.pushConfig ?? PusherConfig(),
        );
        repo.apiClient.storeNotificationAudio(
          "${UrlContainer.domainUrl}/${model.data?.notificationAudioPath}/${model.data?.generalSetting?.notificationAudio ?? ""}",
        );
      } else {
        if (model.remark == "maintenance_mode") {
          Future.delayed(const Duration(seconds: 1), () {
            Get.offAndToNamed(RouteHelper.maintenanceScreen);
          });
          return;
        } else {
          CustomSnackBar.error(
            errorList: model.message ?? [MyStrings.somethingWentWrong],
          );
        }
      }
    } else {
      if (response.statusCode == 503) {
        noInternet = true;
        update();
      }
      CustomSnackBar.error(errorList: [response.message]);
    }

    isLoading = false;
    update();

    if (noInternet) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (isOnboardAlreadyDisplayed == false) {
        Get.offAndToNamed(RouteHelper.onboardScreen);
      } else if (!hasRole) {
        Get.offAndToNamed(RouteHelper.userRoleScreen);
      } else if (isRemember) {
        if (savedRole == 'driver') {
          Get.offAndToNamed(RouteHelper.dashboard);
        } else {
          Get.offAndToNamed(RouteHelper.riderDashboard);
        }
      } else {
        Get.offAndToNamed(RouteHelper.userRoleScreen);
      }
    });
  }

  Future<bool> initSharedData() {
    if (!repo.apiClient.sharedPreferences.containsKey(
      SharedPreferenceHelper.countryCode,
    )) {
      return repo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.countryCode,
        localizationController.defaultLanguage.countryCode,
      );
    }

    if (!repo.apiClient.sharedPreferences.containsKey(
      SharedPreferenceHelper.languageCode,
    )) {
      return repo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.languageCode,
        localizationController.defaultLanguage.languageCode,
      );
    }

    return Future.value(true);
  }

  Future<void> loadLanguage() async {
    localizationController.loadCurrentLanguage();
    String languageCode = localizationController.locale.languageCode;
    ResponseModel response = await repo.getLanguage(languageCode);

    if (response.statusCode == 200) {
      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(
        response.responseJson,
      );

      if (model.remark == "maintenance_mode") {
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAndToNamed(RouteHelper.maintenanceScreen);
        });
        return;
      }

      try {
        Map<String, Map<String, String>> language = {};
        var resJson = response.responseJson;
        saveLanguageList(jsonEncode(resJson));
        var value = resJson['data']['file'].toString() == '[]' ? {} : resJson['data']['file'];

        Map<String, String> json = {};
        printX(value);

        value.forEach((key, value) {
          json[key] = value.toString();
        });

        language['${localizationController.locale.languageCode}_${localizationController.locale.countryCode}'] = json;

        Get.addTranslations(Messages(languages: language).keys);
      } catch (e) {
        if (kDebugMode) {
          CustomSnackBar.error(errorList: [e.toString()]);
        }
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  void saveLanguageList(String languageJson) async {
    await repo.apiClient.sharedPreferences.setString(
      SharedPreferenceHelper.languageListKey,
      languageJson,
    );
  }

  /// =========================
  /// ✅ Location after splash
  /// =========================
  Future<void> _requestLocationPermissionAndCache() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await repo.apiClient.sharedPreferences.setBool(
          'location_service_enabled',
          false,
        );
        return;
      }

      await repo.apiClient.sharedPreferences.setBool(
        'location_service_enabled',
        true,
      );

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        await repo.apiClient.sharedPreferences.setString(
          'location_permission_status',
          'denied',
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        await repo.apiClient.sharedPreferences.setString(
          'location_permission_status',
          'denied_forever',
        );
        return;
      }

      await repo.apiClient.sharedPreferences.setString(
        'location_permission_status',
        'granted',
      );

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      await repo.apiClient.sharedPreferences.setDouble(
        'user_current_latitude',
        position.latitude,
      );
      await repo.apiClient.sharedPreferences.setDouble(
        'user_current_longitude',
        position.longitude,
      );

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          final streetAddress = [
            place.street,
            place.subLocality,
          ].where((e) => (e ?? '').trim().isNotEmpty).join(', ');

          final city = (place.locality ?? '').trim();
          final state = (place.administrativeArea ?? '').trim();
          final zip = (place.postalCode ?? '').trim();
          final country = (place.country ?? '').trim();

          final fullAddress = [
            if (streetAddress.isNotEmpty) streetAddress,
            if (city.isNotEmpty) city,
            if (state.isNotEmpty) state,
          ].join('، ');

          await repo.apiClient.sharedPreferences.setString(
            'user_current_address',
            fullAddress,
          );
          await repo.apiClient.sharedPreferences.setString(
            'user_current_city',
            city,
          );
          await repo.apiClient.sharedPreferences.setString(
            'user_current_state',
            state,
          );
          await repo.apiClient.sharedPreferences.setString(
            'user_current_zip',
            zip,
          );
          await repo.apiClient.sharedPreferences.setString(
            'user_current_country',
            country,
          );
          await repo.apiClient.sharedPreferences.setString(
            'user_current_street_address',
            streetAddress,
          );
        }
      } catch (_) {
        // تجاهل فشل reverse geocoding وخلي الإحداثيات محفوظة
      }
    } catch (_) {
      // لا نوقف التطبيق بسبب الموقع
    }
  }
}

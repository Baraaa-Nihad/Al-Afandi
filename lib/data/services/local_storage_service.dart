import 'dart:convert';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/utils/app_status.dart';
import 'package:ovoride/data/model/country_model/country_model.dart';
import 'package:ovoride/data/model/general_setting/general_setting_response_model.dart';
import 'package:ovoride/data/model/notification/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences sharedPreferences;

  LocalStorageService({required this.sharedPreferences});
  void storeNotifications(List<String> notificationsJsonList, {String? role}) {
    sharedPreferences.setStringList(
      _resolveNotificationStorageKey(sharedPreferences, role: role),
      notificationsJsonList,
    );
  }

  // جلب قائمة الإشعارات المخزنة
  List<String> getStoredNotifications({String? role}) {
    return _readStoredNotifications(sharedPreferences, role: role);
  }

  // إضافة إشعار واحد جديد للقائمة (Update)
  void addNewNotification(String notificationJson, {String? role}) {
    List<String> currentList = getStoredNotifications(role: role);
    currentList.insert(
      0,
      notificationJson,
    ); // إضافته في البداية ليظهر كأحدث إشعار

    // الاحتفاظ بآخر 50 إشعاراً فقط لضمان سرعة التطبيق
    if (currentList.length > 50) {
      currentList = currentList.sublist(0, 50);
    }
    storeNotifications(currentList, role: role);
  }

  // مسح جميع الإشعارات
  void clearNotifications({String? role}) {
    sharedPreferences.remove(
      _resolveNotificationStorageKey(sharedPreferences, role: role),
    );
  }

  void addNotificationModel(NotificationModel notification, {String? role}) {
    _storeNotificationModel(sharedPreferences, notification, role: role);
  }

  static Future<void> addNotificationModelToPreferences(
    SharedPreferences sharedPreferences,
    NotificationModel notification, {
    String? role,
  }) {
    _storeNotificationModel(sharedPreferences, notification, role: role);
    return Future<void>.value();
  }

  static void _storeNotificationModel(
    SharedPreferences sharedPreferences,
    NotificationModel notification, {
    String? role,
  }) {
    List<String> currentList = _readStoredNotifications(
      sharedPreferences,
      role: role,
    );

    final bool alreadyExists = currentList.any((String rawNotification) {
      final NotificationModel? existing = _parseStoredNotification(
        rawNotification,
      );
      return existing?.fingerprint == notification.fingerprint;
    });

    if (alreadyExists) {
      return;
    }

    currentList.insert(0, jsonEncode(notification.toJson()));
    if (currentList.length > 50) {
      currentList = currentList.sublist(0, 50);
    }

    sharedPreferences.setStringList(
      _resolveNotificationStorageKey(sharedPreferences, role: role),
      currentList,
    );
  }

  static List<String> _readStoredNotifications(
    SharedPreferences sharedPreferences, {
    String? role,
  }) {
    final String scopedKey = _resolveNotificationStorageKey(
      sharedPreferences,
      role: role,
    );
    final List<String>? scopedList = sharedPreferences.getStringList(scopedKey);
    if (scopedList != null) {
      return List<String>.from(scopedList);
    }

    return List<String>.from(
      sharedPreferences.getStringList(
            SharedPreferenceHelper.notificationListKey,
          ) ??
          <String>[],
    );
  }

  static String _resolveNotificationStorageKey(
    SharedPreferences sharedPreferences, {
    String? role,
  }) {
    final String resolvedRole =
        role ??
        sharedPreferences.getString(SharedPreferenceHelper.userRoleKey) ??
        'driver';
    return '${SharedPreferenceHelper.notificationListKey}_$resolvedRole';
  }

  static NotificationModel? _parseStoredNotification(String rawNotification) {
    try {
      final dynamic decoded = jsonDecode(rawNotification);
      if (decoded is! Map) {
        return null;
      }

      return NotificationModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  // Token Management
  String getToken() {
    return sharedPreferences.getString(SharedPreferenceHelper.accessTokenKey) ??
        '';
  }

  String getTokenType() {
    return sharedPreferences.getString(
          SharedPreferenceHelper.accessTokenType,
        ) ??
        'Bearer';
  }

  void saveToken(String token, String type) {
    sharedPreferences.setString(SharedPreferenceHelper.accessTokenKey, token);
    sharedPreferences.setString(SharedPreferenceHelper.accessTokenType, type);
  }

  void removeToken() {
    sharedPreferences.remove(SharedPreferenceHelper.accessTokenKey);
  }

  // Remember Me Functionality
  void setRememberMe(bool value) {
    sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, value);
  }

  bool getRememberMe() {
    return sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ??
        false;
  }

  // General Settings
  void storeGeneralSetting(GeneralSettingResponseModel model) {
    String json = jsonEncode(model.toJson());
    sharedPreferences.setString(SharedPreferenceHelper.generalSettingKey, json);
  }

  GeneralSettingResponseModel getGeneralSettings() {
    String pre =
        sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ??
        '{}';
    try {
      return GeneralSettingResponseModel.fromJson(jsonDecode(pre));
    } catch (e) {
      return GeneralSettingResponseModel();
    }
  }

  // Pusher Configuration
  void storePushSetting(PusherConfig pusherConfig) {
    String json = jsonEncode(pusherConfig.toJson());
    sharedPreferences.setString(
      SharedPreferenceHelper.pusherConfigSettingKey,
      json,
    );
  }

  PusherConfig getPushConfig() {
    String pre =
        sharedPreferences.getString(
          SharedPreferenceHelper.pusherConfigSettingKey,
        ) ??
        '{}';
    try {
      return PusherConfig.fromJson(jsonDecode(pre));
    } catch (e) {
      return PusherConfig();
    }
  }

  // Notification Audio
  void storeNotificationAudio(String notificationAudioPath) {
    sharedPreferences.setString(
      SharedPreferenceHelper.notificationAudioKey,
      notificationAudioPath,
    );
  }

  String getNotificationAudio() {
    return sharedPreferences.getString(
          SharedPreferenceHelper.notificationAudioKey,
        ) ??
        '';
  }

  void storeNotificationAudioEnable(bool isEnable) {
    sharedPreferences.setString(
      SharedPreferenceHelper.notificationAudioEnableKey,
      isEnable ? '1' : '0',
    );
  }

  bool isNotificationAudioEnable() {
    String pre =
        sharedPreferences.getString(
          SharedPreferenceHelper.notificationAudioEnableKey,
        ) ??
        '1';
    return pre == '1';
  }

  // User Information
  String getUserEmail() {
    return sharedPreferences.getString(SharedPreferenceHelper.userEmailKey) ??
        '';
  }

  String getUserName() {
    return sharedPreferences.getString(SharedPreferenceHelper.userNameKey) ??
        '';
  }

  String getUserID() {
    return sharedPreferences.getString(SharedPreferenceHelper.userIdKey) ?? '';
  }

  String getUserPhone() {
    String phone =
        sharedPreferences.getString(
          SharedPreferenceHelper.userPhoneNumberKey,
        ) ??
        '';
    return phone;
  }

  // Utility Methods

  void storeCurrentTab(String tab) {
    sharedPreferences.setString(SharedPreferenceHelper.currentTabKey, tab);
  }

  String getCurrentTab() {
    return sharedPreferences.getString(SharedPreferenceHelper.currentTabKey) ??
        '1';
  }

  String getMinimumRideDistance() {
    GeneralSettingResponseModel model = getGeneralSettings();
    return model.data?.generalSetting?.minDistance ?? '';
  }

  List<String> getTipsList() {
    GeneralSettingResponseModel model = getGeneralSettings();
    return model.data?.generalSetting?.tipsSuggestAmount ?? [];
  }

  bool isGoogleLoginEnabled() {
    GeneralSettingResponseModel model = getGeneralSettings();
    return model.data?.generalSetting?.googleLogin == '1';
  }

  bool isAppleLoginEnabled() {
    GeneralSettingResponseModel model = getGeneralSettings();
    return model.data?.generalSetting?.appleLogin == '1';
  }

  String getSocialCredentialsRedirectUrl() {
    GeneralSettingResponseModel model = getGeneralSettings();
    return model.data?.socialLoginRedirect ?? "";
  }

  String getCurrency({bool isSymbol = false}) {
    GeneralSettingResponseModel model = getGeneralSettings();
    return isSymbol
        ? model.data?.generalSetting?.curSym ?? ''
        : model.data?.generalSetting?.curText ?? '';
  }

  List<Countries> getOperatingCountries() {
    GeneralSettingResponseModel model = getGeneralSettings();
    return model.data?.generalSetting?.operatingCountry ?? [];
  }

  bool getPasswordStrengthStatus() {
    GeneralSettingResponseModel model = getGeneralSettings();
    return model.data?.generalSetting?.securePassword == '1';
  }

  bool isMultiLanguageEnabled() {
    GeneralSettingResponseModel model = getGeneralSettings();
    return model.data?.generalSetting?.multiLanguage == '1';
  }

  String getTemplateName() {
    GeneralSettingResponseModel model = getGeneralSettings();
    return model.data?.generalSetting?.activeTemplate ?? '';
  }

  bool isAgreePolicyEnabled() {
    GeneralSettingResponseModel model = getGeneralSettings();
    return model.data?.generalSetting?.agree == '1';
  }

  String getDistanceUnit() {
    GeneralSettingResponseModel model = getGeneralSettings();
    return model.data?.generalSetting?.distanceUnit ??
        AppStatus.DISTANCE_UNIT_KM;
  }

  bool getUserOnlineStatus() {
    return sharedPreferences.getBool(
          SharedPreferenceHelper.userOnlineStatusKey,
        ) ??
        false;
  }

  void setOnlineStatus(bool status) {
    sharedPreferences.setBool(
      SharedPreferenceHelper.userOnlineStatusKey,
      status,
    );
  }

  bool isLoggedIn() {
    printD(getToken());
    return getToken() != "";
  }
}

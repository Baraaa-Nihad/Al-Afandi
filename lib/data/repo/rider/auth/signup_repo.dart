import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/core/utils/method.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/model/rider/auth/registration_response_model.dart';
import 'package:ovoride/data/model/auth/sign_up_model/sign_up_model.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/data/services/push_notification_service.dart';

class RegistrationRepo {
  ApiClient apiClient;

  RegistrationRepo({required this.apiClient});

  Future<RegistrationResponseModel> registerUser(SignUpModel model) async {
    final map = modelToMap(model);
    String url = '${UrlContainer.baseUrl}${UrlContainer.riderRegisterEndPoint}';
    final res = await apiClient.request(
      url,
      Method.postMethod,
      map,
      passHeader: true,
      isOnlyAcceptType: true,
    );
    log("res.responseJson ${res.responseJson}");
    RegistrationResponseModel responseModel =
        RegistrationResponseModel.fromJson(res.responseJson);
    return responseModel;
  }

  Map<String, dynamic> modelToMap(SignUpModel model) {
    Map<String, dynamic> bodyFields = {
      'firstname': model.firstName,
      'lastname': model.lastName,
      'email': model.email,
      'agree': model.agree.toString() == 'true' ? 'true' : '',
      'password': model.password,
      'password_confirmation': model.password,
    };
    if (model.refference.isNotEmpty) {
      bodyFields['refer_name'] = model.refference;
    }
    return bodyFields;
  }

  Future<dynamic> getCountryList() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.countryEndPoint}';
    ResponseModel model = await apiClient.request(url, Method.getMethod, null);
    return model;
  }

  Future<bool> sendUserToken() async {
    String deviceToken;
    if (apiClient.sharedPreferences.containsKey(
      SharedPreferenceHelper.fcmDeviceKey,
    )) {
      deviceToken =
          apiClient.sharedPreferences.getString(
            SharedPreferenceHelper.fcmDeviceKey,
          ) ??
          '';
    } else {
      deviceToken = '';
    }

    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    bool success = false;
    if (deviceToken.isEmpty) {
      final fcmDeviceToken = await firebaseMessaging.getToken();
      if (fcmDeviceToken == null || fcmDeviceToken.isEmpty) {
        return false;
      }

      await apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.fcmDeviceKey,
        fcmDeviceToken,
      );
      success = await sendUpdatedToken(fcmDeviceToken);
    } else {
      success = true;
    }

    await PushNotificationService.registerTokenRefreshListener(
      firebaseMessaging: firebaseMessaging,
      onTokenRefresh: (fcmDeviceToken) async {
        final currentToken =
            apiClient.sharedPreferences.getString(
              SharedPreferenceHelper.fcmDeviceKey,
            ) ??
            '';
        if (currentToken == fcmDeviceToken) {
          return;
        }

        await apiClient.sharedPreferences.setString(
          SharedPreferenceHelper.fcmDeviceKey,
          fcmDeviceToken,
        );
        await sendUpdatedToken(fcmDeviceToken);
      },
    );

    return success;
  }

  Future<bool> sendUpdatedToken(String deviceToken) async {
    String url =
        '${UrlContainer.baseUrl}${UrlContainer.riderDeviceTokenEndPoint}';
    Map<String, String> map = deviceTokenMap(deviceToken);

    final response = await apiClient.request(
      url,
      Method.postMethod,
      map,
      passHeader: true,
    );
    return response.statusCode == 200;
  }

  Map<String, String> deviceTokenMap(String deviceToken) {
    Map<String, String> map = {'token': deviceToken.toString()};
    return map;
  }

  Future<ResponseModel> socialLoginUser({
    String accessToken = '',
    String? provider,
  }) async {
    Map<String, String>? map;

    if (provider == 'google') {
      map = {'token': accessToken, 'provider': "google"};
    }

    String url = '${UrlContainer.baseUrl}${UrlContainer.socialLoginEndPoint}';

    ResponseModel model = await apiClient.request(
      url,
      Method.postMethod,
      map,
      passHeader: false,
    );

    return model;
  }
}

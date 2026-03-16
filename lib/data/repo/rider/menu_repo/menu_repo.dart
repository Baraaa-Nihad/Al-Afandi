import 'package:get/get.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/method.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/model/authorization/authorization_response_model.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/presentation/components/snack_bar/show_custom_snackbar.dart';

class MenuRepo {
  ApiClient apiClient;

  MenuRepo({required this.apiClient});

  Future<ResponseModel> logout() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.riderLogoutUrl}';

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    await clearSharedPrefData();
    return responseModel;
  }

  Future deleteAccount() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.riderUserDeleteEndPoint}';

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      null,
      passHeader: true,
    );
    if (responseModel.statusCode == 200) {
      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson((responseModel.responseJson));
      if (model.status == "success") {
        clearSharedPrefData();
        Get.offAllNamed(RouteHelper.loginScreen);
        CustomSnackBar.success(
          successList: model.message ?? ["Account deleted successfully"],
        );
      } else {
        CustomSnackBar.error(
          errorList: model.message ?? [MyStrings.somethingWentWrong],
        );
      }
    } else {
      CustomSnackBar.error(errorList: [MyStrings.somethingWentWrong]);
    }
  }

  Future<void> clearSharedPrefData() async {
    await apiClient.sharedPreferences.setString(
      SharedPreferenceHelper.userNameKey,
      '',
    );
    await apiClient.sharedPreferences.setString(
      SharedPreferenceHelper.userEmailKey,
      '',
    );
    await apiClient.sharedPreferences.setString(
      SharedPreferenceHelper.accessTokenType,
      '',
    );
    await apiClient.sharedPreferences.setString(
      SharedPreferenceHelper.accessTokenKey,
      '',
    );
    await apiClient.sharedPreferences.setBool(
      SharedPreferenceHelper.rememberMeKey,
      false,
    );
    return Future.value();
  }
}

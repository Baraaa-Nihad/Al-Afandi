import 'package:ovoride/core/utils/method.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/model/rider/auth/authorization_response_model.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/presentation/components/snack_bar/show_custom_snackbar.dart';

class SmsEmailVerificationRepo {
  ApiClient apiClient;

  SmsEmailVerificationRepo({required this.apiClient});

  Future<ResponseModel> verify(
    String code, {
    bool isEmail = true,
    bool isTFA = false,
  }) async {
    final map = {'code': code};

    String url = '${UrlContainer.baseUrl}${isEmail ? 'verify-email' : 'verify-mobile'}';
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      map,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> sendAuthorizationRequest() async {
    String url = '${UrlContainer.baseUrl}${'authorization'}';
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<bool> resendVerifyCode({required bool isEmail}) async {
    final url = '${UrlContainer.baseUrl}${'resend-verify/'}${isEmail ? 'email' : 'mobile'}';
    ResponseModel response = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );

    if (response.statusCode == 200) {
      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(
        (response.responseJson),
      );

      if (model.status == 'error') {
        CustomSnackBar.error(
          errorList: model.message ?? [MyStrings.resendCodeFail],
        );
        return false;
      } else {
        CustomSnackBar.success(
          successList: model.message ?? [MyStrings.successfullyCodeResend],
        );
        return true;
      }
    } else {
      return false;
    }
  }
}

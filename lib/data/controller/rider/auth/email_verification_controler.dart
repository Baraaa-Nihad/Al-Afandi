import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/data/model/rider/auth/authorization_response_model.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/repo/rider/auth/sms_email_verification_repo.dart';
import 'package:ovoride/presentation/components/snack_bar/show_custom_snackbar.dart';

class EmailVerificationController extends GetxController {
  SmsEmailVerificationRepo repo;
  EmailVerificationController({required this.repo});

  bool needSmsVerification = false;
  bool isProfileCompleteEnable = false;

  String currentText = "";
  String userEmail = "";
  bool needTwoFactor = false;
  bool submitLoading = false;
  bool isLoading = true;
  bool resendLoading = false;

  Future<void> loadData() async {
    isLoading = true;
    update();

    try {
      userEmail = repo.apiClient.getUserEmail();

      ResponseModel responseModel = await repo.sendAuthorizationRequest();

      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(
          (responseModel.responseJson),
        );

        if (model.status == 'error') {
          CustomSnackBar.error(
            errorList: model.message ?? [MyStrings.somethingWentWrong],
          );
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: [MyStrings.somethingWentWrong]);
    }

    isLoading = false;
    update();
  }

  Future<void> verifyEmail(String text) async {
    if (text.isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.otpFieldEmptyMsg]);
      return;
    }

    submitLoading = true;
    update();

    ResponseModel responseModel = await repo.verify(text);

    if (responseModel.statusCode == 200) {
      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(
        (responseModel.responseJson),
      );
      if (model.status == MyStrings.success) {
        RouteHelper.checkRiderStatusAndGoToNextStep(model.data?.user);
        CustomSnackBar.success(
          successList: model.message ?? [(MyStrings.emailVerificationSuccess)],
        );
      } else {
        CustomSnackBar.error(
          errorList: model.message ?? [MyStrings.somethingWentWrong],
        );
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    submitLoading = false;
    update();
  }

  Future<void> sendCodeAgain() async {
    resendLoading = true;
    update();
    await repo.resendVerifyCode(isEmail: true);
    resendLoading = false;
    update();
  }
}

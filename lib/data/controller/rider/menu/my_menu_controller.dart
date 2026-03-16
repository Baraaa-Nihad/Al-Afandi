import 'package:get/get.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/data/model/general_setting/general_setting_response_model.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/repo/shared/auth/general_setting_repo.dart';
import 'package:ovoride/data/repo/rider/menu_repo/menu_repo.dart';
import 'package:ovoride/presentation/components/snack_bar/show_custom_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/helper/shared_preference_helper.dart';

class MyMenuController extends GetxController {
  MenuRepo menuRepo;
  GeneralSettingRepo repo;
  MyMenuController({required this.menuRepo, required this.repo});

  bool logoutLoading = false;
  bool isLoading = true;
  bool isDeleteBtnLoading = false;
  bool noInternet = false;

  bool balTransferEnable = true;
  bool langSwitchEnable = true;

  void loadData() async {
    isLoading = true;
    update();
    await configureMenuItem();
    isLoading = false;
    update();
  }

  Future<void> deleteAccount() async {
    isDeleteBtnLoading = true;
    update();

    await menuRepo.deleteAccount();

    isDeleteBtnLoading = false;
    update();
  }

  Future<void> logout() async {
    logoutLoading = true;
    update();

    await menuRepo.logout();
    CustomSnackBar.success(successList: [MyStrings.logoutSuccessMsg]);

    logoutLoading = false;
    update();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharedPreferenceHelper.userRoleKey);
    Get.offAllNamed(RouteHelper.userRoleScreen);
  }

  bool isTransferEnable = true;
  bool isWithdrawEnable = true;
  bool isInvoiceEnable = true;

  Future<void> configureMenuItem() async {
    update();

    ResponseModel response = await repo.getGeneralSetting();

    if (response.statusCode == 200) {
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson((response.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        bool langStatus = model.data?.generalSetting?.multiLanguage == '0' ? false : true;
        langSwitchEnable = langStatus;
        repo.apiClient.storeGeneralSetting(model);
        update();
      } else {
        List<String> message = [MyStrings.somethingWentWrong];
        CustomSnackBar.error(errorList: model.message ?? message);
        return;
      }
    } else {
      if (response.statusCode == 503) {
        //noInternet=true;
        update();
      }
      CustomSnackBar.error(errorList: [response.message]);
      return;
    }
  }

  //
}

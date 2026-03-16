import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/services/api_client.dart';

import 'package:ovoride/core/utils/method.dart';

class WithdrawHistoryRepo {
  ApiClient apiClient;
  WithdrawHistoryRepo({required this.apiClient});

  Future<ResponseModel> getWithdrawHistoryData(
    int page, {
    String searchText = "",
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.withdrawHistoryUrl}?page=$page&search=$searchText";

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }
}

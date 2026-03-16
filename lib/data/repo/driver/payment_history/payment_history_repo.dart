import 'package:ovoride/core/utils/method.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/services/api_client.dart';

class PaymentHistoryRepo {
  ApiClient apiClient;
  PaymentHistoryRepo({required this.apiClient});

  Future<ResponseModel> getPaymentHistory(String page) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.paymentHistory}?page=$page";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }
}

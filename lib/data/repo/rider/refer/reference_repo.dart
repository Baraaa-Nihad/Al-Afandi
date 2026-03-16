import 'package:ovoride/core/utils/method.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/services/api_client.dart';

class ReferenceRepo {
  ApiClient apiClient;
  ReferenceRepo({required this.apiClient});

  Future<ResponseModel> getReferData() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.reference}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }
}

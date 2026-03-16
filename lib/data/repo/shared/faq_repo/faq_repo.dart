import 'package:ovoride/core/utils/method.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/services/api_client.dart';

class FaqRepo {
  ApiClient apiClient;
  FaqRepo({required this.apiClient});

  Future<dynamic> loadFaq() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.faqEndPoint}';
    final response = await apiClient.request(url, Method.getMethod, null);
    return response;
  }
}

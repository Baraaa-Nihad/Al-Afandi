import 'package:ovoride/core/utils/method.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/services/api_client.dart';

class ReviewRepo {
  ApiClient apiClient;
  ReviewRepo({required this.apiClient});

  Future<ResponseModel> getReviews() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.reviewHistoryEndPoint}";
    final response = await apiClient.request(
      url,
      Method.getMethod,
      {},
      passHeader: true,
    );
    return response;
  }

  Future<ResponseModel> getReviewByUserId(String userId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.reviewByUserHistoryEndPoint}/$userId";
    final response = await apiClient.request(
      url,
      Method.getMethod,
      {},
      passHeader: true,
    );
    return response;
  }
}

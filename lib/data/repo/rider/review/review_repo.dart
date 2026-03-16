import 'package:ovoride/core/utils/method.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/services/api_client.dart';

class ReviewRepo {
  ApiClient apiClient;
  ReviewRepo({required this.apiClient});

  Future<ResponseModel> getReviews({required String id}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.riderGetDriverReview}/$id";
    final response = await apiClient.request(
      url,
      Method.getMethod,
      {},
      passHeader: true,
    );
    return response;
  }

  Future<ResponseModel> getMyReviews() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.riderReviewRide}";
    final response = await apiClient.request(
      url,
      Method.getMethod,
      {},
      passHeader: true,
    );
    return response;
  }

  Future<ResponseModel> getRideDetails(String id) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.riderRideDetails}/$id";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> reviewRide({
    required String rideId,
    required String review,
    required String rating,
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.riderReviewRide}/$rideId";
    Map<String, String> params = {'review': review, 'rating': rating};
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );
    return responseModel;
  }
}

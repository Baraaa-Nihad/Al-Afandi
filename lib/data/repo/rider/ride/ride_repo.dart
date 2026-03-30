import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ovoride/core/utils/method.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/services/api_client.dart';

class RideRepo {
  ApiClient apiClient;
  RideRepo({required this.apiClient});

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

  // دالة التفاوض (Counter Offer)
  Future<ResponseModel> counterOffer({
    required String bidId,
    required String amount,
  }) async {
    // تأكد من وجود counterOffer داخل UrlContainer
    String url = "${UrlContainer.baseUrl}${UrlContainer.counterOffer}/$bidId";
    Map<String, String> params = {'amount': amount};

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getRideList({
    required String rideType,
    required String status,
    String page = '1',
  }) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.riderRideList}?ride_type=$rideType&status=$status&page=$page";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getRideMessageList({
    required String id,
    required String page,
  }) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.riderRideMessageList}/$id?page=$page";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getRideBidList({required String id}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.rideBidList}/$id";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> acceptBid({required String bidId}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.acceptBid}/$bidId";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> rejectBid({required String id}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.rejectBid}/$id";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> sos({
    required String id,
    required String msg,
    required LatLng latLng,
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.sosRide}/$id";
    Map<String, String> params = {
      'message': msg,
      'latitude': latLng.latitude.toString(),
      'longitude': latLng.longitude.toString(),
    };
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> cancelRide({
    required String id,
    required String reason,
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.riderCancelRide}/$id";
    Map<String, String> params = {'cancel_reason': reason};
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> reviewRide({
    required String rideId,
    required String review,
    required String rating,
  }) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.riderReviewRide}/$rideId";
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

import 'package:ovoride/data/model/global/user/global_user_model.dart';

class RiderLoginResponseModel {
  String? remark;
  String? status;
  List<String>? message;
  RiderLoginData? data;

  RiderLoginResponseModel({this.remark, this.status, this.message, this.data});

  factory RiderLoginResponseModel.fromJson(Map<String, dynamic> json) => RiderLoginResponseModel(
        remark: json["remark"],
        status: json["status"],
        message: json["message"] == null ? [] : List<String>.from(json["message"]!.map((x) => x)),
        data: json["data"] == null ? null : RiderLoginData.fromJson(json["data"]),
      );
}

class RiderLoginData {
  String? accessToken;
  GlobalUser? user;
  String? tokenType;

  RiderLoginData({this.accessToken, this.user, this.tokenType});

  factory RiderLoginData.fromJson(Map<String, dynamic> json) => RiderLoginData(
        accessToken: json["access_token"],
        user: json["user"] == null ? null : GlobalUser.fromJson(json["user"]),
        tokenType: json["token_type"],
      );
}

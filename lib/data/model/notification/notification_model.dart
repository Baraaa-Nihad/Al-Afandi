class NotificationModel {
  String? title;
  String? body;
  String? time;
  bool isRead;
  String? image;
  String? rideId;

  NotificationModel({
    this.title,
    this.body,
    this.time,
    this.isRead = false,
    this.image,
    this.rideId,
  });

  // تحويل البيانات من JSON (القادمة من السيرفر أو التخزين المحلي) إلى Object
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'],
      body: json['body'],
      time: json['time'],
      isRead: json['is_read'] ?? false,
      image: json['image'],
      rideId: json['ride_id'],
    );
  }

  // تحويل الـ Object إلى JSON لتخزينه في Local Storage
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'time': time,
      'is_read': isRead,
      'image': image,
      'ride_id': rideId,
    };
  }
}

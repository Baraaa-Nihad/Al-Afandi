import 'dart:convert';

class NotificationModel {
  String? title;
  String? body;
  String? time;
  bool isRead;
  String? image;
  String? rideId;
  String? remark;
  Map<String, dynamic>? payload;

  NotificationModel({
    this.title,
    this.body,
    this.time,
    this.isRead = false,
    this.image,
    this.rideId,
    this.remark,
    this.payload,
  });

  // تحويل البيانات من JSON (القادمة من السيرفر أو التخزين المحلي) إلى Object
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: _readText(json['title']),
      body: _readText(json['body']) ?? _readText(json['message']),
      time: _readText(json['time']),
      isRead: _readBool(json['is_read']),
      image: _readText(json['image']),
      rideId: _readText(json['ride_id']),
      remark: _readText(json['remark']),
      payload: _readPayload(json['payload']),
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
      'remark': remark,
      'payload': payload,
    };
  }

  String get fingerprint =>
      '${remark ?? ''}|${rideId ?? ''}|${title ?? ''}|${body ?? ''}';

  static String? _readText(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Map) {
      final String? nestedText =
          _readText(value['title']) ??
          _readText(value['body']) ??
          _readText(value['message']) ??
          _readText(value['text']);

      return nestedText ?? jsonEncode(value);
    }

    if (value is List) {
      return jsonEncode(value);
    }

    final String text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }

  static bool _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final String? text = _readText(value)?.toLowerCase();
    return text == '1' || text == 'true' || text == 'yes';
  }

  static Map<String, dynamic>? _readPayload(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }

    if (value is Map) {
      return value.map(
        (key, dynamic entryValue) => MapEntry(key.toString(), entryValue),
      );
    }

    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty ||
          trimmed == '{}' ||
          trimmed.toLowerCase() == 'null') {
        return null;
      }

      try {
        final dynamic decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          return decoded.map(
            (key, dynamic entryValue) => MapEntry(key.toString(), entryValue),
          );
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }
}

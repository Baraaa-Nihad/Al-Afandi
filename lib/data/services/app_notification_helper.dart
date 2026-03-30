import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:ovoride/data/model/notification/notification_model.dart';

class AppNotificationHelper {
  static const String newRideRemark = 'new_ride';
  static const String legacyRideRequestRemark = 'ride_request';

  static NotificationModel? fromRemoteMessage(RemoteMessage message) {
    final Map<String, dynamic> payload = _asMap(message.data);
    final String? remark = extractRemark(payload);
    final String? title = extractNotificationTitle(
      message: message,
      data: payload,
      remark: remark,
    );
    final String? body = extractNotificationBody(
      message: message,
      data: payload,
      remark: remark,
    );

    if (_isEmptyText(title) && _isEmptyText(body)) {
      return null;
    }

    return NotificationModel(
      title: title,
      body: body,
      time: DateTime.now().toString(),
      isRead: false,
      image: extractImage(message: message, data: payload),
      rideId: extractRideId(payload),
      remark: remark,
      payload: payload,
    );
  }

  static NotificationModel? fromPusherEvent(PusherEvent event) {
    final String eventName = event.eventName.trim();
    if (eventName.isEmpty || eventName.toLowerCase().startsWith('pusher:')) {
      return null;
    }

    final Map<String, dynamic> payload = _asMap(event.data);
    if (payload.isEmpty) {
      return null;
    }

    payload.putIfAbsent('event_name', () => event.eventName);
    payload.putIfAbsent('channel_name', () => event.channelName);

    final String? remark = extractRemark(payload) ?? normalizeRemark(_sanitizeText(eventName));
    final String? title = extractNotificationTitle(
      data: payload,
      remark: remark,
      fallbackEventName: eventName,
    );
    final String? body = extractNotificationBody(
      data: payload,
      remark: remark,
      fallbackEventName: eventName,
    );

    if (_isEmptyText(title) || _isEmptyText(body)) {
      return null;
    }

    return NotificationModel(
      title: title,
      body: body,
      time: DateTime.now().toString(),
      isRead: false,
      image: extractImage(data: payload),
      rideId: extractRideId(payload),
      remark: remark,
      payload: payload,
    );
  }

  static String? extractRemark(Map<String, dynamic> data) {
    return normalizeRemark(_firstText([
      data['remark'],
      data['for_app'],
      data['event_name'],
      data['eventName'],
      _nestedValue(data, ['data', 'remark']),
      _nestedValue(data, ['data', 'for_app']),
    ]));
  }

  static bool isNewRideType(String? value) {
    final String? normalized = normalizeRemark(value);
    return normalized == newRideRemark;
  }

  static String? normalizeRemark(String? value) {
    final String? normalized = _sanitizeText(value)?.toLowerCase();
    switch (normalized) {
      case legacyRideRequestRemark:
        return newRideRemark;
      default:
        return normalized;
    }
  }

  static String? extractRideId(Map<String, dynamic> data) {
    return _firstText([
      data['ride_id'],
      data['rideId'],
      _nestedValue(data, ['data', 'ride_id']),
      _nestedValue(data, ['data', 'rideId']),
      _nestedValue(data, ['ride', 'id']),
      _nestedValue(data, ['data', 'ride', 'id']),
      _nestedValue(data, ['bid', 'ride_id']),
      _nestedValue(data, ['bid', 'rideId']),
      _nestedValue(data, ['data', 'bid', 'ride_id']),
      _nestedValue(data, ['data', 'bid', 'rideId']),
      _nestedValue(data, ['message', 'ride_id']),
      _nestedValue(data, ['message', 'rideId']),
      _nestedValue(data, ['data', 'message', 'ride_id']),
      _nestedValue(data, ['data', 'message', 'rideId']),
    ]);
  }

  static String? extractNotificationTitle({
    RemoteMessage? message,
    required Map<String, dynamic> data,
    String? remark,
    String? fallbackEventName,
  }) {
    return _firstText([
          message?.notification?.title,
          data['title'],
          data['push_title'],
          _nestedValue(data, ['notification', 'title']),
          _nestedValue(data, ['data', 'title']),
          _nestedValue(data, ['data', 'push_title']),
        ]) ??
        _defaultTitle(remark ?? fallbackEventName);
  }

  static String? extractNotificationBody({
    RemoteMessage? message,
    required Map<String, dynamic> data,
    String? remark,
    String? fallbackEventName,
  }) {
    return _firstText([
          message?.notification?.body,
          data['body'],
          data['message'],
          data['push_message'],
          _nestedValue(data, ['message', 'message']),
          _nestedValue(data, ['message', 'body']),
          _nestedValue(data, ['data', 'body']),
          _nestedValue(data, ['data', 'message']),
          _nestedValue(data, ['data', 'push_message']),
          _nestedValue(data, ['data', 'message', 'message']),
        ]) ??
        _defaultBody(remark ?? fallbackEventName);
  }

  static String? extractImage({
    RemoteMessage? message,
    required Map<String, dynamic> data,
  }) {
    return _firstText([
      message?.notification?.android?.imageUrl,
      message?.notification?.apple?.imageUrl,
      data['image'],
      _nestedValue(data, ['data', 'image']),
      _nestedValue(data, ['message', 'image']),
      _nestedValue(data, ['data', 'message', 'image']),
    ]);
  }

  static Map<String, dynamic> _asMap(dynamic value) {
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
      if (trimmed.isEmpty || trimmed == '{}' || trimmed.toLowerCase() == 'null') {
        return {};
      }

      try {
        final dynamic decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          return decoded.map(
            (key, dynamic entryValue) => MapEntry(key.toString(), entryValue),
          );
        }
      } catch (_) {
        return {'message': trimmed};
      }
    }

    return {};
  }

  static dynamic _nestedValue(Map<String, dynamic> data, List<String> path) {
    dynamic current = data;
    for (final String segment in path) {
      if (current is Map && current.containsKey(segment)) {
        current = current[segment];
      } else {
        return null;
      }
    }
    return current;
  }

  static String? _firstText(List<dynamic> values) {
    for (final dynamic value in values) {
      final String? text = _textFromDynamic(value);
      if (!_isEmptyText(text)) {
        return text;
      }
    }
    return null;
  }

  static String? _textFromDynamic(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Map) {
      return _firstText([
        value['title'],
        value['body'],
        value['message'],
        value['text'],
      ]);
    }

    return _sanitizeText(value.toString());
  }

  static String? _sanitizeText(String? value) {
    if (value == null) {
      return null;
    }

    final String text = value.trim();
    if (text.isEmpty || text == '{}' || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }

  static bool _isEmptyText(String? value) => _sanitizeText(value) == null;

  static String? _defaultTitle(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'new_ride':
      case 'ride_request':
        return 'طلب مشوار جديد';
      case 'new_bid':
        return 'تم استلام عرض جديد';
      case 'bid_accept':
        return 'تم قبول العرض';
      case 'bid_reject':
        return 'تم رفض العرض';
      case 'cash_payment_request':
        return 'تم طلب الدفع كاش';
      case 'online_payment_received':
        return 'تم استلام الدفع الإلكتروني';
      case 'cash_payment_received':
        return 'تم استلام الدفع الكاش';
      case 'ride_end':
        return 'المشوار خلص';
      case 'pick_up':
        return 'السواق وصل';
      default:
        final String? normalized = _sanitizeText(type);
        return normalized == null ? null : _humanize(normalized);
    }
  }

  static String? _defaultBody(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'new_ride':
      case 'ride_request':
        return 'راكب طلب مشوار جديد.';
      case 'new_bid':
        return 'كابتن بعت عرض جديد على مشوارك.';
      case 'bid_accept':
        return 'الراكب وافق على عرضك.';
      case 'bid_reject':
        return 'الراكب رفض عرضك.';
      case 'cash_payment_request':
        return 'في مشوار مستني تأكيد الدفع كاش.';
      case 'online_payment_received':
        return 'تم استلام الدفع الإلكتروني للمشوار.';
      case 'cash_payment_received':
        return 'تم استلام الدفع الكاش للمشوار.';
      case 'ride_end':
        return 'المشوار بتاعك خلص.';
      case 'pick_up':
        return 'السواق وصل لنقطة الركوب.';
      default:
        return null;
    }
  }

  static String _humanize(String value) {
    return value
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .map(
          (String part) => '${part[0].toUpperCase()}${part.length > 1 ? part.substring(1) : ''}',
        )
        .join(' ');
  }
}

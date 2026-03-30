import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ovoride/data/model/notification/notification_model.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/data/services/local_storage_service.dart';

class NotificationController extends GetxController
    with WidgetsBindingObserver {
  LocalStorageService localStorageService;
  ApiClient apiClient;

  NotificationController({
    required this.localStorageService,
    required this.apiClient,
  });

  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    getNotifications();
    super.onInit();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getNotifications();
    }
  }

  Future<void> getNotifications() async {
    try {
      isLoading = true;
      update();

      final List<String> storedData = localStorageService
          .getStoredNotifications();
      final List<NotificationModel> parsedNotifications = [];

      for (final rawNotification in storedData) {
        final notification = _parseNotification(rawNotification);
        if (notification != null && _shouldShowNotification(notification)) {
          parsedNotifications.add(notification);
        }
      }

      notifications = parsedNotifications;

      localStorageService.storeNotifications(
        notifications.map((e) => jsonEncode(e.toJson())).toList(),
      );
    } catch (_) {
      notifications = [];
    }

    isLoading = false;
    update();
  }

  void markAsRead(int index) {
    notifications[index].isRead = true;

    final List<String> updatedList = notifications
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    localStorageService.storeNotifications(updatedList);

    update();
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  bool _shouldShowNotification(NotificationModel notification) {
    final String title = notification.title?.trim().toLowerCase() ?? '';
    final String body = notification.body?.trim() ?? '';

    if (title.isEmpty || title.startsWith('pusher:')) {
      return false;
    }

    return body.isNotEmpty && body != '{}' && body.toLowerCase() != 'null';
  }

  NotificationModel? _parseNotification(String rawNotification) {
    try {
      final dynamic decoded = jsonDecode(rawNotification);
      if (decoded is! Map) {
        return null;
      }

      return NotificationModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }
}

import 'package:get/get.dart';
import 'package:ovoride/data/model/notification/notification_model.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/data/services/local_storage_service.dart';
import 'dart:convert';

class NotificationController extends GetxController {
  LocalStorageService localStorageService;
  ApiClient apiClient;

  NotificationController({required this.localStorageService, required this.apiClient});

  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void onInit() {
    getNotifications(); // الآن الدالة معرفة بالأسفل
    super.onInit();
  }

  // 1. جلب الإشعارات (من التخزين المحلي أولاً ثم السيرفر)
  Future<void> getNotifications() async {
    isLoading = true;
    update();

    // أولاً: جلب البيانات المخزنة محلياً لسرعة العرض (أفضل من أوبر)
    List<String> storedData = localStorageService.getStoredNotifications();
    notifications = storedData.map((e) => NotificationModel.fromJson(jsonDecode(e))).toList();

    isLoading = false;
    update();

    // ثانياً: يمكنك هنا إضافة طلب API لجلب الإشعارات الجديدة من السيرفر وتحديث القائمة
  }

  // 2. تحديد كـ مقروء
  void markAsRead(int index) {
    notifications[index].isRead = true;

    // تحديث التخزين المحلي بالحالة الجديدة
    List<String> updatedList = notifications.map((e) => jsonEncode(e.toJson())).toList();
    localStorageService.storeNotifications(updatedList);

    update();
  }

  // 3. حساب عدد الإشعارات غير المقروءة للـ Badge
  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/data/services/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // لون خلفية هادئ
      appBar: AppBar(
        title: const Text("الإشعارات", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<NotificationController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          }

          if (controller.notifications.isEmpty) {
            return const Center(
              child: Text("لا توجد إشعارات حالياً في الأفندي"),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(15),
            itemCount: controller.notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = controller.notifications[index];
              return Container(
                decoration: BoxDecoration(
                  color: item.isRead ? Colors.white : const Color(0xFFF3E5F5), // لون بنفسجي خفيف لغير المقروء
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.notifications_active, color: Colors.white),
                  ),
                  title: Text(item.title ?? "تنبيه جديد", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.body ?? ""),
                  trailing: Text(item.time ?? "", style: const TextStyle(fontSize: 10)),
                  onTap: () => controller.markAsRead(index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

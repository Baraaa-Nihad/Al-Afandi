import 'package:flutter/material.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/model/notification/notification_model.dart';
import 'package:ovoride/data/services/notification_controller.dart';
import 'package:ovoride/presentation/components/app-bar/custom_appbar.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: const CustomAppBar(
        title: 'الإشعارات',
        isTitleCenter: true,
        elevation: 0.3,
      ),
      body: GetBuilder<NotificationController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: MyColor.primaryColor),
            );
          }

          if (controller.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: Dimensions.screenPadding,
                child: Text(
                  'لا توجد إشعارات حالياً',
                  style: regularDefault.copyWith(
                    color: MyColor.bodyMutedTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: Dimensions.screenPadding,
            itemCount: controller.notifications.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: Dimensions.space12),
            itemBuilder: (context, index) {
              final NotificationModel item = controller.notifications[index];
              return _NotificationCard(
                item: item,
                onTap: () => controller.markAsRead(index),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final NotificationModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final _NotificationViewData viewData = _buildViewData(item);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.moreRadius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(Dimensions.space16),
          decoration: BoxDecoration(
            color: item.isRead
                ? MyColor.getCardBgColor()
                : MyColor.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(Dimensions.moreRadius),
            border: Border.all(
              color: item.isRead
                  ? MyColor.neutral200
                  : MyColor.primaryColor.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: MyColor.neutral900.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!item.isRead) ...[
                            Container(
                              width: Dimensions.space8,
                              height: Dimensions.space8,
                              margin: const EdgeInsets.only(
                                top: Dimensions.space8,
                              ),
                              decoration: const BoxDecoration(
                                color: MyColor.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: Dimensions.space8),
                          ],
                          Expanded(
                            child: Text(
                              viewData.title,
                              textAlign: TextAlign.right,
                              style:
                                  (item.isRead ? semiBoldDefault : boldDefault)
                                      .copyWith(
                                        color: MyColor.getHeadingTextColor(),
                                        fontSize: Dimensions.fontLarge,
                                      ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.space6),
                      Text(
                        viewData.body,
                        textAlign: TextAlign.right,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: regularDefault.copyWith(
                          color: item.isRead
                              ? MyColor.bodyTextColor
                              : MyColor.getHeadingTextColor(),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: Dimensions.space10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            viewData.timeLabel,
                            textAlign: TextAlign.right,
                            style: mediumSmall.copyWith(
                              color: MyColor.bodyMutedTextColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.space8,
                              vertical: Dimensions.space4,
                            ),
                            decoration: BoxDecoration(
                              color: item.isRead
                                  ? MyColor.neutral100
                                  : MyColor.primaryColor.withValues(
                                      alpha: 0.14,
                                    ),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius25,
                              ),
                            ),
                            child: Text(
                              item.isRead ? 'تمت القراءة' : 'جديد',
                              style: mediumSmall.copyWith(
                                color: item.isRead
                                    ? MyColor.bodyMutedTextColor
                                    : MyColor.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.space12),
              Container(
                width: Dimensions.space50,
                height: Dimensions.space50,
                decoration: BoxDecoration(
                  color: item.isRead
                      ? MyColor.neutral100
                      : MyColor.primaryColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isRead
                      ? Icons.notifications_none_rounded
                      : Icons.notifications_active_rounded,
                  color: item.isRead
                      ? MyColor.bodyMutedTextColor
                      : MyColor.primaryColor,
                  size: Dimensions.space25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationViewData {
  const _NotificationViewData({
    required this.title,
    required this.body,
    required this.timeLabel,
  });

  final String title;
  final String body;
  final String timeLabel;
}

_NotificationViewData _buildViewData(NotificationModel item) {
  final String rawTitle = _normalizeInlineText(item.title);
  final String rawBody = _normalizeBlockText(item.body);
  final String? extractedTitle = _extractLabeledValue(rawBody, const [
    'title',
    'العنوان',
  ]);
  final String? extractedBody = _extractLabeledValue(rawBody, const [
    'message',
    'الرسالة',
    'body',
  ]);
  final bool hasGenericTitle = _isGenericNotificationTitle(rawTitle);

  final String title = (extractedTitle?.isNotEmpty ?? false)
      ? extractedTitle!
      : rawTitle.isNotEmpty && !hasGenericTitle
      ? rawTitle
      : 'تنبيه جديد';

  String body = extractedBody ?? _stripNotificationLabels(rawBody);
  if (body.isEmpty && rawBody.isNotEmpty) {
    body = rawBody;
  }

  if (body.isEmpty && rawTitle.isNotEmpty && !hasGenericTitle) {
    body = rawTitle;
  }

  return _NotificationViewData(
    title: title,
    body: body.isEmpty ? 'لا يوجد وصف لهذا الإشعار' : body,
    timeLabel: _formatNotificationTime(item.time),
  );
}

String _normalizeInlineText(String? value) {
  return (value ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _normalizeBlockText(String? value) {
  return (value ?? '')
      .replaceAll('\r\n', '\n')
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\n{2,}'), '\n')
      .trim();
}

String? _extractLabeledValue(String text, List<String> labels) {
  for (final String label in labels) {
    final String pattern =
        RegExp.escape(label) +
        r'\s*[:：]\s*(.+?)(?=(?:\n|\r|\s)+(?:title|message|body|العنوان|الرسالة)\s*[:：]|$)';
    final RegExp expression = RegExp(
      pattern,
      caseSensitive: false,
      dotAll: true,
    );
    final Match? match = expression.firstMatch(text);
    if (match == null) {
      continue;
    }

    final String candidate = _normalizeInlineText(match.group(1));
    if (candidate.isNotEmpty) {
      return candidate;
    }
  }

  return null;
}

String _stripNotificationLabels(String text) {
  final List<String> lines = text
      .split('\n')
      .map(_normalizeInlineText)
      .where((line) => line.isNotEmpty)
      .where(
        (line) => !RegExp(
          r'^(title|message|body|العنوان|الرسالة)\s*[:：]',
          caseSensitive: false,
        ).hasMatch(line),
      )
      .toList();

  return lines.join('\n').trim();
}

bool _isGenericNotificationTitle(String title) {
  final String normalized = title.toLowerCase();
  const List<String> genericTitles = [
    'الأفندي',
    'ovoride',
    'notification',
    'تنبيه جديد',
    'إشعار جديد',
  ];

  return normalized.isEmpty ||
      genericTitles.any(
        (String genericTitle) => normalized == genericTitle.toLowerCase(),
      );
}

String _formatNotificationTime(String? rawTime) {
  if (rawTime == null || rawTime.trim().isEmpty) {
    return '';
  }

  final DateTime? parsedTime = DateTime.tryParse(rawTime.trim());
  if (parsedTime == null) {
    return _normalizeInlineText(rawTime);
  }

  final DateTime localTime = parsedTime.toLocal();
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime notificationDay = DateTime(
    localTime.year,
    localTime.month,
    localTime.day,
  );
  final int dayDifference = today.difference(notificationDay).inDays;
  final String timeLabel = _formatArabicTime(localTime);

  if (dayDifference == 0) {
    return 'اليوم، $timeLabel';
  }

  if (dayDifference == 1) {
    return 'أمس، $timeLabel';
  }

  return '${localTime.day} ${_arabicMonthName(localTime.month)} ${localTime.year}، $timeLabel';
}

String _formatArabicTime(DateTime dateTime) {
  final int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final String minute = dateTime.minute.toString().padLeft(2, '0');
  final String suffix = dateTime.hour >= 12 ? 'م' : 'ص';
  return '$hour:$minute $suffix';
}

String _arabicMonthName(int month) {
  const List<String> months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  if (month < 1 || month > months.length) {
    return '';
  }

  return months[month - 1];
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/services/arabic_numbers.dart';

class CardColumn extends StatelessWidget {
  final String header;
  final String body;
  final bool alignmentEnd;
  final bool alignmentCenter;
  final bool isDate;
  final Color? textColor;
  String? subBody;
  TextStyle? headerTextStyle;
  TextStyle? bodyTextStyle;
  TextStyle? subBodyTextStyle;
  bool? isOnlyHeader;
  bool? isOnlyBody;
  final int bodyMaxLine;
  double? space = 5;
  final int maxLine;

  CardColumn({
    super.key,
    this.maxLine = 1,
    this.bodyMaxLine = 1,
    this.alignmentEnd = false,
    required this.header,
    this.isDate = false,
    this.textColor,
    this.headerTextStyle,
    this.bodyTextStyle,
    required this.body,
    this.subBody,
    this.isOnlyHeader = false,
    this.isOnlyBody = false,
    this.alignmentCenter = false,
    this.space,
  });
  String formatDuration(String rawMinutes) {
    // تنظيف النص من أي كلمات مثل Min وتحويله لرقم
    double totalMinutes = double.tryParse(rawMinutes.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    int hours = totalMinutes ~/ 60; // القسمة الصحيحة للحصول على الساعات
    int minutes = (totalMinutes % 60).toInt(); // باقي القسمة للحصول على الدقائق

    if (hours > 0) {
      return "$hours ساعة و $minutes دقيقة".toArabicNumbers();
    } else {
      return "$minutes دقيقة".toArabicNumbers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isOnlyHeader!
        ? Column(
            crossAxisAlignment: alignmentEnd
                ? CrossAxisAlignment.end
                : alignmentCenter
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
            children: [
              Text(
                header.tr,
                style: headerTextStyle ??
                    regularSmall.copyWith(
                      color: MyColor.getGreyText(),
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: space),
            ],
          )
        : Column(
            crossAxisAlignment: alignmentEnd
                ? CrossAxisAlignment.end
                : alignmentCenter
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
            children: [
              Text(
                header.tr,
                style: headerTextStyle ??
                    regularSmall.copyWith(
                      color: MyColor.getTextColor().withValues(alpha: 0.6),
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: maxLine,
              ),
              SizedBox(height: space),
              // داخل الـ Widget الخاص بك:
              Text(
                // نتحقق إذا كان النص يحتوي على دقائق لنقوم بتحويله
                body.toLowerCase().contains('min') || double.tryParse(body) != null ? formatDuration(body) : body.tr,
                maxLines: bodyMaxLine,
                style: isDate
                    ? regularDefault.copyWith(
                        fontStyle: FontStyle.italic,
                        color: textColor ?? MyColor.getTextColor(),
                        fontSize: Dimensions.fontSmall,
                      )
                    : bodyTextStyle ??
                        regularSmall.copyWith(
                          color: textColor ?? MyColor.getTextColor(),
                          fontWeight: FontWeight.w500,
                        ),
                overflow: TextOverflow.ellipsis,
                textAlign: alignmentEnd ? TextAlign.end : TextAlign.start,
              ),
              const SizedBox(height: Dimensions.space5),
              subBody != null
                  ? Text(
                      subBody!.tr,
                      maxLines: bodyMaxLine,
                      style: isDate
                          ? regularDefault.copyWith(
                              fontStyle: FontStyle.italic,
                              color: textColor ?? MyColor.getTextColor(),
                              fontSize: Dimensions.fontSmall,
                            )
                          : subBodyTextStyle ??
                              regularSmall.copyWith(
                                color: textColor ??
                                    MyColor.getTextColor().withValues(
                                      alpha: 0.5,
                                    ),
                                fontWeight: FontWeight.w500,
                              ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox.shrink(),
            ],
          );
  }
}

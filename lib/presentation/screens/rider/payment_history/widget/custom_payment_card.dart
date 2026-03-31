import 'package:flutter/material.dart';
import 'package:ovoride/core/helper/date_converter.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/presentation/components/divider/custom_divider.dart';
import 'package:get/get.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/data/controller/rider/payment_history/payment_history_controller.dart';
import 'package:ovoride/presentation/components/animated_widget/expanded_widget.dart';
import 'package:ovoride/presentation/components/column_widget/card_column.dart';

class RiderCustomPaymentCard extends StatelessWidget {
  final int index;
  final int expandIndex;

  const RiderCustomPaymentCard({
    super.key,
    required this.index,
    required this.expandIndex,
  });
// 1. دالة استخراج التاريخ فقط بتنسيق 2020_11_30
  String _formatOnlyDate(String dateStr) {
    try {
      DateTime dt = DateTime.tryParse(dateStr) ?? DateTime.now();
      // استخراج اليوم والشهر والسنة يدوياً لضمان الدقة
      String day = dt.day.toString().padLeft(2, '0');
      String month = dt.month.toString().padLeft(2, '0');
      String year = dt.year.toString();

      return _toArabic("${year}/${month}/${day}");
    } catch (e) {
      return "";
    }
  }

// 2. دالة استخراج الوقت الصحيح (صباحاً/مساءً)
  String _formatArabicTime(String dateStr) {
    try {
      DateTime dt = DateTime.tryParse(dateStr) ?? DateTime.now();
      int hour = dt.hour;
      String period = "صباحاً";

      if (hour >= 12) {
        period = "مساءً";
        if (hour > 12) hour -= 12;
      } else if (hour == 0) {
        hour = 12;
      }

      String minute = dt.minute.toString().padLeft(2, '0');
      return _toArabic("$hour:$minute $period");
    } catch (e) {
      return "";
    }
  }

  // دالة تحويل الأرقام إلى العربية (المشرقية) بشكل احترافي
  String _toArabic(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentHistoryController>(
      builder: (controller) {
        final payment = controller.transactionList[index];
        bool isExpanded = controller.expandIndex == index;

        return GestureDetector(
          onTap: () => controller.changeExpandIndex(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: Dimensions.space5),
            decoration: BoxDecoration(
              color: MyColor.getCardBgColor(),
              borderRadius: BorderRadius.circular(Dimensions.moreRadius),
              boxShadow: MyUtils.getCardShadow(),
              border: Border.all(
                color: isExpanded ? MyColor.primaryColor.withOpacity(0.3) : Colors.transparent,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.moreRadius),
              child: Stack(
                children: [
                  // أيقونة خلفية مائية جمالية
                  Positioned(
                    left: -15,
                    top: -15,
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 100,
                      color: MyColor.primaryColor.withOpacity(0.03),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.space16),
                    child: Column(
                      children: [
                        // القسم العلوي: المبلغ والحالة
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(Dimensions.space10),
                                  decoration: BoxDecoration(
                                    color: MyColor.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.payments_rounded, color: MyColor.primaryColor, size: 20),
                                ),
                                const SizedBox(width: Dimensions.space12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _toArabic("${controller.currencySym}${StringConverter.formatNumber(payment.amount.toString())}"),
                                      style: boldExtraLarge.copyWith(color: MyColor.getHeadingTextColor(), fontSize: 20),
                                    ),
                                    Text(
                                      _toArabic(payment.ride?.uid ?? ''),
                                      style: regularSmall.copyWith(color: MyColor.getBodyTextColor().withOpacity(0.6)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildStatusBadge(payment),
                                spaceDown(Dimensions.space8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // --- السطر الأول: التاريخ فقط ---
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatOnlyDate('${payment.createdAt}'), // دالة مخصصة للتاريخ فقط بالصيغة المطلوبة
                                          style: regularSmall.copyWith(
                                            color: MyColor.getHeadingTextColor().withOpacity(0.8),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(Icons.calendar_month_outlined, size: 14, color: MyColor.primaryColor.withOpacity(0.7)),
                                      ],
                                    ),

                                    const SizedBox(height: 6), // مسافة بسيطة ومنظمة

                                    // --- السطر الثاني: الوقت الصحيح فقط ---
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatArabicTime('${payment.createdAt}'), // استخراج الوقت الحقيقي من نفس المصدر
                                          style: regularSmall.copyWith(
                                            color: MyColor.getBodyTextColor().withOpacity(0.6),
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(Icons.access_time_rounded, size: 14, color: MyColor.primaryColor.withOpacity(0.5)),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),

                        ExpandedSection(
                          expand: isExpanded,
                          child: Column(
                            children: [
                              const CustomDivider(space: Dimensions.space15),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.space5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // نقطة الركوب
                                    _buildModernLocationRow(
                                      icon: Icons.radio_button_checked_rounded,
                                      color: Colors.green,
                                      label: MyStrings.pickUpLocation,
                                      value: payment.ride?.pickupLocation ?? "",
                                    ),

                                    // الخط المنقط (الآن سيأتي في المنتصف تماماً)
                                    _buildStepLine(),

                                    // نقطة الوصول
                                    _buildModernLocationRow(
                                      icon: Icons.location_on_rounded,
                                      color: MyColor.primaryColor,
                                      label: MyStrings.destination,
                                      value: payment.ride?.destination ?? "",
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: Dimensions.space15),

                              // كارت المعلومات الصغير (المسافة والوقت)
                              Container(
                                padding: const EdgeInsets.all(Dimensions.space12),
                                decoration: BoxDecoration(
                                  color: MyColor.getScreenBgColor().withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                                  border: Border.all(color: MyColor.primaryColor.withOpacity(0.05)),
                                ),
                                child: Row(
                                  children: [
                                    _buildInfoTile(
                                      Icons.directions_run_rounded,
                                      MyStrings.distance,
                                      _toArabic('${payment.ride?.getDistance()} ${MyUtils.getDistanceLabel(distance: payment.ride?.distance, unit: Get.find<ApiClient>().getDistanceUnit())}'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 22, // نفس عرض الأيقونة لضمان التوسط
      alignment: Alignment.center,
      child: Column(
        children: List.generate(
            4,
            (index) => Container(
                  width: 2,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 1.5),
                  decoration: BoxDecoration(
                    color: MyColor.primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
      ),
    );
  }

  Widget _buildModernLocationRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    bool isTop = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عمود الأيقونة والخط
        SizedBox(
          width: 22, // عرض ثابت للأيقونة
          child: Icon(icon, size: 22, color: color),
        ),
        const SizedBox(width: 15), // المسافة بين الأيقونة والنص
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: regularSmall.copyWith(
                  color: MyColor.getBodyTextColor().withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                maxLines: 2,
                style: boldDefault.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ويجت جانبي لبناء حالة الدفع بشكل فخم
  Widget _buildStatusBadge(dynamic payment) {
    Color statusColor = MyUtils.paymentStatusColor(payment.paymentType ?? '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 0.8),
      ),
      child: Text(
        MyUtils.paymentStatus(payment.paymentType ?? '1'),
        style: boldDefault.copyWith(fontSize: 12, color: statusColor),
      ),
    );
  }

  // ويجت لبناء صف الموقع مع الأيقونة
  Widget _buildLocationRow({required IconData icon, required Color color, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: regularSmall.copyWith(color: MyColor.getBodyTextColor().withOpacity(0.5))),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: regularDefault.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ويجت لعرض المسافة والوقت بشكل مبسط
  Widget _buildInfoTile(IconData icon, String title, String value, {bool isEnd = false}) {
    return Expanded(
      child: Row(
        mainAxisAlignment: isEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: MyColor.getBodyTextColor().withOpacity(0.4)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(title, style: regularSmall.copyWith(fontSize: 10, color: MyColor.getBodyTextColor().withOpacity(0.5))),
              Text(value, style: boldDefault.copyWith(fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

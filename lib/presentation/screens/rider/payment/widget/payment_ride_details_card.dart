import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:ovoride/data/model/global/app/ride_model.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/data/services/arabic_numbers.dart';
import 'package:ovoride/presentation/components/card/custom_app_card.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/presentation/components/image/my_network_image_widget.dart';
import 'package:ovoride/presentation/components/timeline/custom_time_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentRideDetailsCard extends StatelessWidget {
  final RideModel ride;
  final String currency;
  final String driverImageUrl;

  const PaymentRideDetailsCard({
    super.key,
    required this.ride,
    required this.currency,
    required this.driverImageUrl,
  });

  String _driverName() {
    final firstName = ride.driver?.firstname?.trim() ?? '';
    final lastName = ride.driver?.lastname?.trim() ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? 'السائق' : fullName;
  }

  DateTime _parseToLocalDate(String? rawTime) {
    final parsed = DateTime.tryParse(rawTime ?? '');
    if (parsed == null) return DateTime.now();

    return parsed.isUtc ? parsed.add(const Duration(hours: 3)) : parsed;
  }

  String _formattedAmount() {
    final amount = StringConverter.formatNumber(ride.amount.toString());
    return '$amount $currency'.toArabicNumbers();
  }

  String _formattedRating() {
    return '${ride.driver?.avgRating ?? '0.0'}'.toArabicNumbers();
  }

  String _formattedDistance() {
    final unit = MyUtils.getDistanceLabel(
      distance: ride.distance,
      unit: Get.find<ApiClient>().getDistanceUnit(),
    );
    return '${ride.getDistance()} $unit'.toArabicNumbers();
  }

  String _formattedDuration() {
    final start = DateTime.tryParse('${ride.startTime}');
    final end = DateTime.tryParse('${ride.endTime}');

    if (start == null || end == null) {
      return '--'.toArabicNumbers();
    }

    final difference = end.difference(start);

    if (difference.isNegative) {
      return '--'.toArabicNumbers();
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    String formatHours(int value) {
      if (value == 0) return '';
      if (value == 1) return 'ساعة';
      if (value == 2) return 'ساعتين';
      if (value >= 3 && value <= 10) return '$value ساعات';
      return '$value ساعة';
    }

    String formatMinutes(int value) {
      if (value == 0) return '';
      if (value == 1) return 'دقيقة';
      if (value == 2) return 'دقيقتين';
      if (value >= 3 && value <= 10) return '$value دقائق';
      return '$value دقيقة';
    }

    if (hours > 0 && minutes > 0) {
      return '${formatHours(hours)} و ${formatMinutes(minutes)}'.toArabicNumbers();
    }

    if (hours > 0) {
      return formatHours(hours).toArabicNumbers();
    }

    if (minutes > 0) {
      return formatMinutes(minutes).toArabicNumbers();
    }

    return '٠ دقيقة'.toArabicNumbers();
  }

  String _arabicMonth(int month) {
    const months = <String>[
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
    return months[(month - 1).clamp(0, 11)];
  }

  String _formatArabicDate(DateTime date) {
    final int hour24 = date.hour;
    final int minute = date.minute;
    final int hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final String period = hour24 >= 12 ? 'م' : 'ص';

    final String formatted = '${date.day} ${_arabicMonth(date.month)} ${date.year} - $hour12:${minute.toString().padLeft(2, '0')} $period';

    return formatted.toArabicNumbers();
  }

  String _formattedCompletedDate() {
    final localDate = _parseToLocalDate(ride.endTime);
    return _formatArabicDate(localDate);
  }

  void _printDateToTest() {
    print('ride.endTime raw = ${ride.endTime}');
    final parsedDate = DateTime.tryParse('${ride.endTime}');
    print('parsedDate = $parsedDate');
    print('isUtc = ${parsedDate?.isUtc}');
    print('toLocal = ${parsedDate?.toLocal()}');
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    Color? iconColor,
    Color? textColor,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor ?? MyColor.getScreenBgColor(),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: borderColor ?? MyColor.getRideSubTitleColor().withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor ?? MyColor.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: regularDefault.copyWith(
              color: textColor ?? MyColor.rideTitle,
              fontWeight: FontWeight.w600,
              fontSize: Dimensions.fontSmall + 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: boldLarge.copyWith(
        color: MyColor.rideTitle,
        fontSize: Dimensions.fontLarge,
        fontWeight: FontWeight.w700,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSoftDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            MyColor.getRideSubTitleColor().withOpacity(0.12),
            MyColor.getRideSubTitleColor().withOpacity(0.18),
            MyColor.getRideSubTitleColor().withOpacity(0.12),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FBF6),
        borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
        border: Border.all(color: const Color(0xFFBFE4C7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // لضمان توسط العناصر عمودياً
        children: [
          // --- العمود الأول: المعلومات (التفاصيل) ---
          Expanded(
            flex: 3, // نُعطي مساحة أكبر للتفاصيل
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // السطر الأول: أيقونة الحالة + النص
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F7EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E9E4D), size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        MyStrings.rideCompleted.tr,
                        style: boldDefault.copyWith(color: const Color(0xFF2B6E3F), fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // السطر الثاني: التاريخ (نص لوحده لمنع الزحمة)
                Text(
                  _formattedCompletedDate().toArabicNumbers(),
                  style: regularDefault.copyWith(color: MyColor.bodyTextColor, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // السطر الثالث: الشيبس (المسافة والوقت)
                // استخدمنا Wrap بدلاً من Row لمنع الـ Overflow إذا كانت الشاشة صغيرة
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildInfoChip(
                      icon: Icons.access_time_filled_rounded,
                      text: _formattedDuration().replaceAll('min', 'دقيقة').toArabicNumbers(),
                      iconColor: MyColor.getRideSubTitleColor(),
                      textColor: MyColor.bodyTextColor,
                      backgroundColor: Colors.white,
                    ),
                    _buildInfoChip(
                      icon: Icons.near_me_rounded,
                      text: _formattedDistance().toArabicNumbers(),
                      iconColor: MyColor.primaryColor,
                      textColor: MyColor.primaryColor,
                      backgroundColor: MyColor.primaryColor.withOpacity(0.06),
                      borderColor: MyColor.primaryColor.withOpacity(0.14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10), // مسافة أمان بين العمودين

          // --- العمود الثاني: كارت المبلغ المميز ---
          Flexible(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [MyColor.primaryColor, MyColor.primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: MyColor.primaryColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'المبلغ',
                    style: regularDefault.copyWith(color: Colors.white.withOpacity(0.9), fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    // يضمن أن المبلغ سيصغر حجمه ولن يخرج عن الكارت
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formattedAmount().toArabicNumbers(),
                      style: boldLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomAppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: MyColor.getScreenBgColor().withOpacity(0.55),
                borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
                border: Border.all(
                  color: MyColor.getRideSubTitleColor().withOpacity(0.06),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 👈 الصورة (يمين)
                  MyImageWidget(
                    imageUrl: driverImageUrl,
                    height: 58,
                    width: 58,
                    isProfile: true,
                  ),

                  const SizedBox(width: 12),

                  // 👈 الاسم + التقييم
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // الاسم
                        Text(
                          _driverName(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: boldExtraLarge.copyWith(
                            color: MyColor.rideTitle,
                            fontSize: Dimensions.fontLarge + 2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ⭐ التقييم
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: MyColor.colorYellow,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formattedRating(),
                              style: regularDefault.copyWith(
                                color: MyColor.getRideSubTitleColor(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            spaceDown(24),
            _buildSoftDivider(),
            _buildStatusCard(),
            spaceDown(22),
            CustomTimeLine(
              indicatorPosition: 0.12,
              dashColor: MyColor.neutral300.withOpacity(0.65),
              firstWidget: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(MyStrings.pickUpLocation.tr),
                    spaceDown(8),
                    Text(
                      (ride.pickupLocation ?? '').toArabicNumbers(),
                      textAlign: TextAlign.right,
                      style: regularDefault.copyWith(
                        color: MyColor.getRideSubTitleColor(),
                        fontSize: Dimensions.fontDefault,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    spaceDown(20),
                  ],
                ),
              ),
              secondWidget: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(MyStrings.destination.tr),
                    spaceDown(8),
                    Text(
                      (ride.destination ?? '').toArabicNumbers(),
                      textAlign: TextAlign.right,
                      style: regularDefault.copyWith(
                        color: MyColor.getRideSubTitleColor(),
                        fontSize: Dimensions.fontDefault,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            spaceDown(22),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

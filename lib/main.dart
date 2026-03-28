import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide GetNumUtils;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/model/global/app/ride_model.dart';
import 'package:ovoride/presentation/components/image/my_network_image_widget.dart';

class NewRideCardWidget extends StatelessWidget {
  final bool isActive;
  final String currency;
  final String driverImagePath;
  final RideModel ride;
  final VoidCallback press;

  const NewRideCardWidget({
    super.key,
    required this.isActive,
    required this.press,
    required this.currency,
    required this.ride,
    required this.driverImagePath,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد هل المشوار جديد أم شغال (بناءً على isActive أو ride.isRunning)
    bool isNewRequest = !isActive;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: MyColor.getCardBgColor(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isNewRequest ? MyColor.primaryColor.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
        // الحواف الملونة فقط للطلبات الجديدة
        border: isNewRequest ? Border.all(color: MyColor.primaryColor, width: 1.5) : Border.all(color: Colors.transparent, width: 0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // المحتوى الداخلي للكارت (يبقى كما هو لتوحيد الهوية)
            _buildTopSection(),
            _buildRouteSection(),
            _buildStatsSection(),
            _buildActionButton(isNewRequest),
          ],
        ),
      ),
    )
        // --- هنا السحر: الأنيميشن والرجاج للجديد فقط ---
        .animate(
          target: isNewRequest ? 1 : 0, // يعمل فقط إذا كان الطلب جديداً
          onPlay: (controller) {
            if (isNewRequest) {
              // محاكاة الرجة القوية مكررة
              _triggerVibration();
              controller.repeat();
            }
          },
        )
        // أنيميشن "الوميض الخارجي" (Outer Glow) بدلاً من النبض
        .boxShadow(
          begin: const BoxShadow(color: Colors.transparent, blurRadius: 0),
          end: BoxShadow(color: MyColor.primaryColor.withOpacity(0.5), blurRadius: 20),
          duration: 1.seconds,
          curve: Curves.easeInOutSine,
        )
        .then()
        .boxShadow(
          begin: BoxShadow(color: MyColor.primaryColor.withOpacity(0.5), blurRadius: 20),
          end: const BoxShadow(color: Colors.transparent, blurRadius: 0),
        );
  }

  // دالة لتشغيل الرجة بشكل يضمن عملها
  void _triggerVibration() async {
    // نكرر الرجة 3 مرات سريعة لضمان انتباه السائق
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  // --- تقسيم الوجت لسهولة القراءة ---

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          MyImageWidget(imageUrl: driverImagePath, height: 55, width: 55, radius: 15, isProfile: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${ride.user?.firstname} ${ride.user?.lastname}'.toTitleCase(), style: boldMediumLarge.copyWith(fontSize: 18)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text("4.9", style: regularDefault.copyWith(color: MyColor.bodyMutedTextColor)),
                  ],
                ),
              ],
            ),
          ),
          _buildPriceSection(),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            const Icon(Icons.monetization_on, color: Colors.green, size: 20),
            const SizedBox(width: 6),
            Text("$currency${StringConverter.formatNumber(ride.amount.toString())}", style: boldExtraLarge.copyWith(color: MyColor.primaryColor, fontSize: 22)),
          ],
        ),
        Text("العـرض", style: regularSmall.copyWith(color: MyColor.bodyMutedTextColor)),
      ],
    );
  }

  Widget _buildRouteSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      color: MyColor.primaryColor.withOpacity(0.03),
      child: Column(
        children: [
          _buildLocationRow(Icons.circle, Colors.green, MyStrings.pickUpLocation.tr, ride.pickupLocation ?? ''),
          const SizedBox(height: 5),
          _buildLocationRow(Icons.location_on, Colors.red, MyStrings.destination.tr, ride.destination ?? ''),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.access_time_filled, "${ride.duration}", "الوقت"),
          _buildStatItem(Icons.map, "${ride.getDistance()} كم", "المسافة"),
          _buildStatItem(Icons.person, "${ride.numberOfPassenger}", "ركاب"),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isNew) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: press,
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColor.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: isNew ? 5 : 0,
          ),
          child: Text(
            isNew ? "تقديم عرض (فاصل)" : "تفاصيل المشوار",
            style: boldMediumLarge.copyWith(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }

  // دوال مساعدة للوجتات الصغيرة
  Widget _buildLocationRow(IconData icon, Color color, String label, String address) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 12),
        Expanded(child: Text(address, style: boldDefault.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(children: [Icon(icon, size: 14), const SizedBox(width: 5), Text(value, style: boldDefault)]),
        Text(label, style: regularSmall.copyWith(fontSize: 10)),
      ],
    );
  }
}

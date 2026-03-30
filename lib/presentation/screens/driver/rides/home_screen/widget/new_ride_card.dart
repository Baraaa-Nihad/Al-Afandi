import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/model/global/app/ride_model.dart';
import 'package:ovoride/presentation/components/image/my_network_image_widget.dart';

class NewRideCardWidget extends StatelessWidget {
  final bool isActive; // تمت إعادتها للعمل مع HomeScreen
  final String currency;
  final String driverImagePath;
  final RideModel ride;
  final VoidCallback press;

  const NewRideCardWidget({
    super.key,
    required this.isActive, // مطلوبة الآن
    required this.press,
    required this.currency,
    required this.ride,
    required this.driverImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: ride.isRunning
            ? MyColor.primaryColor.withValues(alpha: 0.05)
            : MyColor.getCardBgColor(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: isActive
            ? Border.all(
                color: MyColor.primaryColor.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // --- الجزء العلوي: معلومات المستخدم والسعر ---
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  MyImageWidget(
                    imageUrl: driverImagePath,
                    height: 55,
                    width: 55,
                    radius: 15,
                    isProfile: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ride.user?.firstname} ${ride.user?.lastname}'
                              .toTitleCase(),
                          style: boldMediumLarge.copyWith(fontSize: 18),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "4.9",
                              style: regularDefault.copyWith(
                                color: MyColor.bodyMutedTextColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  "نشط",
                                  style: regularSmall.copyWith(
                                    color: Colors.green,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize
                            .min, // مهمة جداً ليكون النص والأيقونة متلاصقين
                        children: [
                          // إضافة أيقونة مصاري خضراء لتسهيل الفهم بصرياً على المستخدم
                          const Icon(
                            Icons.monetization_on,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 6,
                          ), // مسافة بسيطة بين الأيقونة والمبلغ
                          Text(
                            "$currency${StringConverter.formatNumber(ride.amount.toString())}",
                            style: boldExtraLarge.copyWith(
                              color: MyColor.primaryColor,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "العـرض", // تم تعديلها بناءً على طلبك السابق
                        style: regularSmall.copyWith(
                          color: MyColor.bodyMutedTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- قسم المسار: من - إلى ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              color: MyColor.getPrimaryColor().withValues(alpha: 0.03),
              child: Column(
                children: [
                  _buildModernLocationRow(
                    icon: Icons.circle,
                    iconColor: Colors.green,
                    label: MyStrings.pickUpLocation.tr,
                    address: ride.pickupLocation ?? '',
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 10,
                        child: VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  _buildModernLocationRow(
                    icon: Icons.location_on,
                    iconColor: Colors.red,
                    label: MyStrings.destination.tr,
                    address: ride.destination ?? '',
                  ),
                ],
              ),
            ),

            // --- الإحصائيات: الوقت، المسافة، الركاب ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    Icons.access_time_filled,
                    "${ride.duration}",
                    "الوقت المتوقع للوصول",
                  ),
                  _buildStatItem(
                    Icons.map,
                    "${ride.getDistance()} كم",
                    "المسافة",
                  ),
                  _buildStatItem(
                    Icons.person,
                    "${ride.numberOfPassenger}",
                    "عدد الركاب",
                  ),
                ],
              ),
            ),

            Padding(
                  padding: const EdgeInsets.all(15),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: press,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "فاصل ",
                        style: boldMediumLarge.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  // استبدل السطر القديم بهذا
                )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(
                  duration: const Duration(seconds: 3),
                  color: Colors.white24,
                ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildModernLocationRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: regularSmall.copyWith(
                  color: MyColor.bodyMutedTextColor,
                  fontSize: 11,
                ),
              ),
              Text(
                address,
                style: boldDefault.copyWith(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: MyColor.primaryColor.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 5),
            Text(value, style: boldDefault.copyWith(fontSize: 13)),
          ],
        ),
        Text(
          label,
          style: regularSmall.copyWith(
            fontSize: 10,
            color: MyColor.bodyMutedTextColor,
          ),
        ),
      ],
    );
  }
}

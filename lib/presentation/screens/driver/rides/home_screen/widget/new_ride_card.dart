import 'package:ovoride/core/helper/date_converter.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:ovoride/data/model/global/app/ride_model.dart'; // تأكد من المسار الصحيح
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/presentation/components/card/custom_app_card.dart';
import 'package:ovoride/presentation/components/image/my_network_image_widget.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/presentation/components/dotted_border/dotted_border.dart';
import 'package:ovoride/presentation/components/timeline/custom_time_line.dart';
import 'package:flutter_animate/flutter_animate.dart'; // أضفنا مكتبة الأنيميشن

class NewRideCardWidget extends StatelessWidget {
  final bool isActive;
  final String currency;
  final String driverImagePath;
  final RideModel ride;
  final VoidCallback press;
  final bool isShowMapButton;

  const NewRideCardWidget({
    super.key,
    required this.isActive,
    required this.press,
    required this.currency,
    required this.ride,
    required this.driverImagePath,
    this.isShowMapButton = false,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد لون الحالة بناءً على الـ RideModel
    Color statusColor = _getStatusColor(ride.status);
    String statusText = _getStatusText(ride.status);

    return GestureDetector(
      onTap: press,
      child: CustomAppCard(
        // تمييز الكرت إذا كان قيد التشغيل (Running)
        backgroundColor: ride.isRunning ? MyColor.primaryColor.withOpacity(0.05) : MyColor.getCardBgColor(),
        child: Stack(
          // استخدمنا Stack لإضافة وسم الحالة في الزاوية
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          MyImageWidget(
                            imageUrl: driverImagePath,
                            height: 45,
                            width: 45,
                            radius: 22,
                            isProfile: true,
                          ),
                          const SizedBox(width: Dimensions.space10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${ride.user?.firstname} ${ride.user?.lastname}'.toTitleCase(),
                                  overflow: TextOverflow.ellipsis,
                                  style: boldMediumLarge,
                                ),
                                spaceDown(Dimensions.space5),
                                Row(
                                  children: [
                                    Text(
                                      "${ride.duration}, ${ride.getDistance()} ${MyUtils.getDistanceLabel(distance: ride.distance, unit: Get.find<ApiClient>().getDistanceUnit())}",
                                      style: boldDefault.copyWith(
                                        color: MyColor.primaryColor,
                                        fontSize: Dimensions.fontDefault,
                                        fontWeight: FontWeight.w700,
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

                    // السعر مع تأثير نبض (Pulse) إذا كان الطلب جديداً
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.group, color: MyColor.primaryColor, size: 18),
                            const SizedBox(width: 2),
                            Text(
                              "${ride.numberOfPassenger}",
                              style: boldLarge.copyWith(color: MyColor.primaryColor),
                            ),
                          ],
                        ),
                        Text(
                          "$currency${StringConverter.formatNumber(ride.amount.toString())}",
                          style: boldLarge.copyWith(
                            fontSize: Dimensions.fontExtraLarge,
                            color: MyColor.rideTitle,
                          ),
                        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms, color: MyColor.primaryColor.withOpacity(0.3)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: Dimensions.space20),

                // التايم لاين الخاص بالرحلة
                CustomTimeLine(
                  indicatorPosition: 0.1,
                  dashColor: MyColor.neutral300,
                  firstWidget: _buildLocationStep(MyStrings.pickUpLocation.tr, ride.pickupLocation ?? '', ride.startTime),
                  secondWidget: _buildLocationStep(MyStrings.destination.tr, ride.destination ?? '', ride.endTime),
                ),

                spaceDown(Dimensions.space10),
                const DottedLine(),
                spaceDown(Dimensions.space15),

                // صندوق السعر الموصى به
                _buildRecommendedPriceBox(),

                const SizedBox(height: Dimensions.space10),
              ],
            ),

            // وسم الحالة (Badge) في أعلى اليمين/اليسار
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: statusColor.withOpacity(0.5), width: 0.5)),
                child: Text(
                  statusText.tr,
                  style: regularSmall.copyWith(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1, end: 0); // أنيميشن عند ظهور الكرت لأول مرة
  }

  // --- Helper Methods ---

  Widget _buildLocationStep(String title, String address, String? time) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: boldLarge.copyWith(fontSize: Dimensions.fontTitleLarge)),
          spaceDown(Dimensions.space5),
          Text(address, style: regularDefault.copyWith(color: MyColor.getBodyTextColor()), maxLines: 2, overflow: TextOverflow.ellipsis),
          if (time != null) ...[
            spaceDown(Dimensions.space8),
            Text(
              DateConverter.estimatedDate(DateTime.tryParse(time) ?? DateTime.now()),
              style: regularDefault.copyWith(color: MyColor.bodyMutedTextColor, fontSize: Dimensions.fontSmall),
            ),
          ],
          spaceDown(Dimensions.space15),
        ],
      ),
    );
  }

  Widget _buildRecommendedPriceBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.space10),
      decoration: BoxDecoration(
        color: MyColor.bodyTextBgColor,
        borderRadius: BorderRadius.circular(Dimensions.space5),
      ),
      child: Text(
        MyStrings.recommendedPrice.rKv({
          "priceKey": "$currency${StringConverter.formatNumber(ride.recommendAmount.toString())}",
          "distanceKey": "${ride.getDistance()} ${MyUtils.getDistanceLabel(distance: ride.distance, unit: Get.find<ApiClient>().getDistanceUnit())}",
        }).tr,
        style: regularDefault.copyWith(color: MyColor.getBodyTextColor()),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "1":
        return Colors.orange; // Pending
      case "2":
        return Colors.blue; // Accepted/Bid
      case "3":
        return Colors.green; // Running
      case "9":
        return Colors.red; // Canceled
      default:
        return MyColor.primaryColor;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case "1":
        return MyStrings.pending.tr;
      case "3":
        return MyStrings.running.tr;
      case "9":
        return MyStrings.canceled.tr;
      default:
        return "";
    }
  }
}

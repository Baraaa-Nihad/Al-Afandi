import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/app_status.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_icons.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/data/controller/driver/ride/all_ride/all_ride_controller.dart';
import 'package:ovoride/data/model/global/ride/ride_model.dart';
import 'package:ovoride/presentation/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:ovoride/presentation/components/buttons/rounded_button.dart';
import 'package:ovoride/presentation/components/image/my_local_image_widget.dart';
import 'package:ovoride/presentation/components/image/my_network_image_widget.dart';
import 'package:ovoride/presentation/screens/driver/ride_history/widget/pick_up_from_activity_bottom_sheet.dart';
import 'package:ovoride/presentation/components/timeline/custom_time_line.dart';

// Extension لتحويل الأرقام لضمان توحيد الشكل في التطبيق
extension ArabicNumbers on String {
  String toArabicNumbers() {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = this;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }
}

class RideInfoCard extends StatefulWidget {
  final String currency;
  final RideModel ride;
  final AllRideController controller;

  const RideInfoCard({
    super.key,
    required this.currency,
    required this.ride,
    required this.controller,
  });

  @override
  State<RideInfoCard> createState() => _RideInfoCardState();
}

class _RideInfoCardState extends State<RideInfoCard> with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    Color statusColor = MyUtils.getRideStatusColor(widget.ride.status ?? '9');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: Dimensions.space10),
      decoration: BoxDecoration(
        color: MyColor.getCardBgColor(),
        borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isExpanded ? statusColor.withOpacity(0.3) : MyColor.borderColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
          onTap: () => setState(() => isExpanded = !isExpanded),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.space15),
            child: Column(
              children: [
                // --- الحالة المختصرة (عرض الراكب والسعر) ---
                _buildCollapsedHeader(statusColor),

                // --- الحالة المتوسعة (Timeline + الأزرار) ---
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _buildExpandedDetails(statusColor),
                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedHeader(Color statusColor) {
    return Row(
      children: [
        // صورة الراكب دائرية
        MyImageWidget(imageUrl: widget.ride.user?.image ?? "", height: 45, width: 45, radius: 25, isProfile: true),
        const SizedBox(width: Dimensions.space15),

        // معلومات الرحلة المختصرة
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.ride.user?.getFullName() ?? "عميل",
                style: boldDefault.copyWith(fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      MyUtils.getRideStatus(widget.ride.status ?? '9').tr,
                      style: regularSmall.copyWith(color: statusColor, fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${_formatDistance(widget.ride.distance).toArabicNumbers()} كم",
                    style: regularSmall.copyWith(color: MyColor.getGreyColor(), fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),

        // التكلفة
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${widget.currency}${StringConverter.formatNumber(widget.ride.amount.toString())}".toArabicNumbers(),
              style: boldDefault.copyWith(color: MyColor.getPrimaryColor(), fontSize: 17),
            ),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: MyColor.getGreyColor().withOpacity(0.5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedDetails(Color statusColor) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: Dimensions.space10),
          child: Divider(height: 1, thickness: 0.5),
        ),

        // تايم لاين المواقع
        CustomTimeLine(
          indicatorPosition: 0.1,
          dashColor: MyColor.neutral300,
          firstWidget: _buildLocationInfo(
            title: MyStrings.pickUpLocation.tr,
            address: widget.ride.pickupLocation ?? '',
            time: widget.ride.startTime,
            icon: Icons.location_on_rounded,
            accentColor: MyColor.colorGreen,
          ),
          secondWidget: _buildLocationInfo(
            title: MyStrings.destination.tr,
            address: widget.ride.destination ?? '',
            time: widget.ride.endTime,
            icon: Icons.flag_circle_rounded,
            accentColor: MyColor.colorRed,
          ),
        ),

        const SizedBox(height: Dimensions.space15),

        // نوع الخدمة وزر التفاصيل
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("نوع الخدمة", style: regularSmall.copyWith(fontSize: 10, color: MyColor.getGreyColor())),
                Text(widget.ride.service?.name ?? 'خدمة توصيل', style: boldDefault.copyWith(fontSize: 12)),
              ],
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(RouteHelper.driverRideDetailsScreen, arguments: widget.ride.id.toString())?.then((value) {
                  widget.controller.initialData(shouldLoading: false, tabID: widget.controller.selectedTab);
                });
              },
              child: Text("عرض المسار >", style: boldDefault.copyWith(color: MyColor.getPrimaryColor(), fontSize: 12)),
            ),
          ],
        ),

        const SizedBox(height: Dimensions.space15),
        _buildActionSection(),
      ],
    );
  }

  Widget _buildLocationInfo({
    required String title,
    required String address,
    required IconData icon,
    required Color accentColor,
    String? time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: regularSmall.copyWith(color: MyColor.getGreyColor(), fontSize: 10)),
          Text(address, style: boldDefault.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (time != null && widget.ride.status != AppStatus.RIDE_CANCELED)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                _getFormattedTime(time),
                style: regularSmall.copyWith(fontSize: 10, color: accentColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    if (widget.ride.status == AppStatus.RIDE_ACTIVE) {
      return Column(
        children: [
          _buildMessageAndCallWidget(),
          const SizedBox(height: 12),
          RoundedButton(
            text: MyStrings.pickupPassenger.tr,
            press: () {
              CustomBottomSheet(child: PickUpRiderFromActivityBottomSheet(ride: widget.ride)).customBottomSheet(context);
            },
          ),
        ],
      );
    }

    // في الحالات الأخرى (مثل الملغية أو المكتملة) نعرض وقت الطلب كمعلومات إضافية
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: MyColor.getPrimaryColor().withOpacity(0.05), borderRadius: BorderRadius.circular(Dimensions.mediumRadius)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("تاريخ الطلب", style: regularSmall.copyWith(color: MyColor.getGreyColor())),
          Text(
            _getFormattedTime(widget.ride.createdAt ?? ""),
            style: boldDefault.copyWith(fontSize: 11, color: MyColor.getPrimaryColor()),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageAndCallWidget() {
    return Row(
      children: [
        _smallActionCard(MyIcons.message, MyStrings.message, () {
          Get.toNamed(RouteHelper.rideMessageScreen, arguments: [widget.ride.id.toString(), widget.ride.user?.getFullName(), widget.ride.status.toString()]);
        }),
        const SizedBox(width: 10),
        _smallActionCard(MyIcons.callIcon, MyStrings.call, () {
          MyUtils.launchPhone('${widget.ride.user?.mobile}');
        }),
      ],
    );
  }

  Widget _smallActionCard(String icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: MyColor.getPrimaryColor().withOpacity(0.05),
            borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
            border: Border.all(color: MyColor.getPrimaryColor().withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyLocalImageWidget(imagePath: icon, width: 18, height: 18, imageOverlayColor: MyColor.getPrimaryColor()),
              const SizedBox(width: 8),
              Text(label.tr, style: boldDefault.copyWith(color: MyColor.getPrimaryColor(), fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // --- دالات مساعدة للتنسيق ---
  String _formatDistance(String? distance) {
    if (distance == null || distance.isEmpty) return "0";
    double d = double.tryParse(distance) ?? 0;
    return d.toStringAsFixed(1);
  }

  String _getFormattedTime(String isoDate) {
    try {
      DateTime dt = DateTime.parse(isoDate).toLocal();
      String period = dt.hour >= 12 ? "مساءاً" : "صباحاً";
      int hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      String minute = dt.minute.toString().padLeft(2, '0');
      String dateStr = "${dt.day}/${dt.month}/${dt.year}";
      return "$dateStr - $hour:$minute $period".toArabicNumbers();
    } catch (e) {
      return isoDate;
    }
  }
}

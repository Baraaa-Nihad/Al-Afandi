import 'package:ovoride/core/helper/date_converter.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/app_status.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_icons.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:ovoride/data/controller/rider/ride/all_ride_controller.dart';
import 'package:ovoride/data/model/global/app/ride_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/data/services/download_service.dart';
import 'package:ovoride/presentation/components/buttons/rounded_button.dart';
import 'package:ovoride/presentation/components/card/custom_app_card.dart';
import 'package:ovoride/presentation/components/image/my_local_image_widget.dart';
import 'package:ovoride/presentation/components/timeline/custom_time_line.dart';

// دالة مساعدة لتحويل الأرقام إلى العربية (بقية كما هي لضمان التوافق)
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

class RiderRideInfoCard extends StatefulWidget {
  final AllRideController controller;
  final RideModel ride;
  const RiderRideInfoCard({super.key, required this.controller, required this.ride});

  @override
  State<RiderRideInfoCard> createState() => _RiderRideInfoCardState();
}

class _RiderRideInfoCardState extends State<RiderRideInfoCard> with SingleTickerProviderStateMixin {
  bool isDownLoadLoading = false;
  bool isExpanded = false; // متغير للتحكم في توسيع البطاقة

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
          onTap: () => setState(() => isExpanded = !isExpanded), // التوسيع عند الضغط
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.space15),
            child: Column(
              children: [
                // --- الحالة المختصرة (دائماً ظاهرة) ---
                _buildCollapsedHeader(statusColor),

                // --- الحالة المتوسعة (تظهر بأنيميشن) ---
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _buildExpandedDetails(),
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

  // الجزء العلوي الذي يحتوي على السعر والحالة والوجهة
  Widget _buildCollapsedHeader(Color statusColor) {
    return Row(
      children: [
        // أيقونة الحالة الدائرية
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.directions_car_filled_rounded,
            color: statusColor,
          ),
        ),
        const SizedBox(width: Dimensions.space15),

        // معلومات الرحلة المختصرة
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.ride.destination ?? MyStrings.destination.tr,
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
                    () {
                      final date = _parseToLocalDate(widget.ride.startTime);

                      // تنسيق التاريخ: 2026/2/13
                      String formattedDate = "${date.year}/${date.month}/${date.day}";

                      // تنسيق الوقت: 11:30
                      int hour12 = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
                      String minute = date.minute.toString().padLeft(2, '0');
                      String period = date.hour >= 12 ? 'مساءاً' : 'صباحاً';

                      // الدمج النهائي
                      return "$formattedDate - $hour12:$minute $period".toArabicNumbers();
                    }(),
                    style: regularSmall.copyWith(
                      color: MyColor.getGreyColor(),
                      fontSize: 10, // تصغير بسيط ليناسب المساحة الجديدة
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // السعر
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${widget.controller.defaultCurrencySymbol}${StringConverter.formatNumber(widget.ride.offerAmount.toString())}".toArabicNumbers(),
              style: boldDefault.copyWith(color: MyColor.getPrimaryColor(), fontSize: 17),
            ),
            Icon(
              isExpanded ? Icons.visibility : Icons.visibility_outlined,
              size: 16,
              color: MyColor.getGreyColor().withOpacity(0.5),
            ),
          ],
        ),
      ],
    );
  }

  // تفاصيل الرحلة الكاملة (Timeline + Buttons)
  Widget _buildExpandedDetails() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: Dimensions.space10),
          child: Divider(height: 1, thickness: 0.5),
        ),

        // التايم لاين بتصميم أنحف
        CustomTimeLine(
          indicatorPosition: 0.1,
          dashColor: MyColor.neutral300,
          firstWidget: _buildLocationInfo(
            title: MyStrings.pickUpLocation.tr,
            address: widget.ride.pickupLocation ?? '',
            timePrefix: "وقت الركوب",
            time: widget.ride.startTime,
            icon: Icons.access_time_filled_rounded,
          ),
          secondWidget: _buildLocationInfo(
            title: MyStrings.destination.tr,
            address: widget.ride.destination ?? '',
            timePrefix: "وقت الوصول",
            time: widget.ride.endTime,
            icon: Icons.flag_circle_rounded,
          ),
        ),

        const SizedBox(height: Dimensions.space15),

        // الأزرار وتفاصيل الخدمة
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.ride.service?.name != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("نوع الخدمة", style: regularSmall.copyWith(fontSize: 10, color: MyColor.getGreyColor())),
                  Text(widget.ride.service?.name ?? '', style: boldDefault.copyWith(fontSize: 12)),
                ],
              ),

            // زر عرض التفاصيل الكاملة (الذي كان في CustomAppCard الأصلي)
            TextButton(
              onPressed: () {
                Get.toNamed(RouteHelper.riderRideDetailsScreen, arguments: widget.ride.id.toString())?.then((value) {
                  widget.controller.initialData(shouldLoading: false, tabID: widget.controller.selectedTab);
                });
              },
              child: Text("كل التفاصيل >", style: boldDefault.copyWith(color: MyColor.getPrimaryColor(), fontSize: 12)),
            ),
          ],
        ),

        const SizedBox(height: Dimensions.space10),
        _buildActionButtons(),
      ],
    );
  }

  // --- بقية الدوال المساعدة (بدون تغيير في المنطق لضمان عدم حدوث أخطاء) ---

  DateTime _parseToLocalDate(String? rawTime) {
    final parsed = DateTime.tryParse(rawTime ?? '');
    if (parsed == null) return DateTime.now();
    return parsed.isUtc ? parsed.add(const Duration(hours: 3)) : parsed;
  }

  Widget _buildLocationInfo({
    required String title,
    required String address,
    required String timePrefix,
    required IconData icon,
    String? time,
  }) {
    final DateTime localDate = _parseToLocalDate(time);
    final int hour24 = localDate.hour;
    final int minute = localDate.minute;
    final int hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final String period = hour24 >= 12 ? 'مساءاً' : 'صباحاً';
    final String timePart = '$hour12:${minute.toString().padLeft(2, '0')} $period'.toArabicNumbers();
    final String numericDate = '${localDate.day}-${localDate.month}-${localDate.year} م'.toArabicNumbers();

    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: regularSmall.copyWith(color: MyColor.getGreyColor(), fontSize: 10)),
          Text(address, style: boldDefault.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (time != null) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(icon, size: 12, color: MyColor.getPrimaryColor()),
                const SizedBox(width: 5),
                Text("$timePart | $numericDate", style: regularSmall.copyWith(fontSize: 10, color: MyColor.getPrimaryColor())),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.ride.status == AppStatus.RIDE_ACTIVE) {
      return buildMessageAndCallWidget();
    } else if (widget.ride.status == AppStatus.RIDE_PAYMENT_REQUESTED) {
      return RoundedButton(
        text: MyStrings.payNow.tr,
        press: () => Get.toNamed(RouteHelper.paymentScreen, arguments: [widget.ride, ""]),
      );
    } else if (widget.ride.status == AppStatus.RIDE_PENDING) {
      return RoundedButton(
        text: "${MyStrings.viewBids.tr} (${widget.ride.bidsCount ?? 0})".toArabicNumbers(),
        press: () => Get.toNamed(RouteHelper.rideBidScreen, arguments: widget.ride.id.toString()),
      );
    } else if (widget.ride.status == AppStatus.RIDE_COMPLETED) {
      return RoundedButton(
        isOutlined: true,
        text: MyStrings.receipt.tr,
        isLoading: isDownLoadLoading,
        press: _handleDownloadReceipt,
        textColor: MyColor.getPrimaryColor(),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _handleDownloadReceipt() async {
    setState(() => isDownLoadLoading = true);
    await DownloadService.downloadPDF(
      url: "${UrlContainer.riderRideReceipt}/${widget.ride.id}",
      fileName: "Receipt_Ride_${widget.ride.id}.pdf",
    );
    setState(() => isDownLoadLoading = false);
  }

  Widget buildMessageAndCallWidget() {
    return Row(
      children: [
        _smallActionCard(MyIcons.message, MyStrings.message, () {
          Get.toNamed(RouteHelper.rideMessageScreen, arguments: [widget.ride.id.toString(), widget.ride.driver?.getFullName(), widget.ride.status.toString()]);
        }),
        const SizedBox(width: 10),
        _smallActionCard(MyIcons.callIcon, MyStrings.call, () {
          MyUtils.launchPhone('${widget.ride.driver?.mobile}');
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
}

import 'package:ovoride/core/helper/date_converter.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/app_status.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_icons.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/data/controller/driver/ride/all_ride/all_ride_controller.dart';
import 'package:ovoride/data/model/global/ride/ride_model.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/data/services/download_service.dart';
import 'package:ovoride/environment.dart';
import 'package:ovoride/presentation/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:ovoride/presentation/components/buttons/rounded_button.dart';
import 'package:ovoride/presentation/components/card/custom_app_card.dart';
import 'package:ovoride/presentation/components/image/my_local_image_widget.dart';
import 'package:ovoride/presentation/components/image/my_network_image_widget.dart';
import 'package:ovoride/presentation/components/text/header_text.dart';
import 'package:ovoride/presentation/screens/driver/ride_history/widget/pick_up_from_activity_bottom_sheet.dart';
import 'package:ovoride/presentation/components/timeline/custom_time_line.dart';

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

class _RideInfoCardState extends State<RideInfoCard> {
  bool isDownLoadLoading = false;

  String _toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  Widget _buildDateTimeSection(String isoDate) {
    if (isoDate.isEmpty) return const SizedBox.shrink();
    try {
      DateTime dt = DateTime.parse(isoDate).toLocal();
      String period = dt.hour >= 12 ? "مساءاً" : "صباحاً";
      int hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      String minute = dt.minute.toString().padLeft(2, '0');
      String timeStr = _toArabicNumbers("$hour:$minute") + " $period";
      String dateStr = _toArabicNumbers("${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}");

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(timeStr, style: boldDefault.copyWith(color: const Color(0xFF6C5CE7), fontSize: 13)),
          Text("بتاريخ: $dateStr", style: regularSmall.copyWith(color: MyColor.colorGrey, fontSize: 10)),
        ],
      );
    } catch (e) {
      return Text(isoDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppCard(
      padding: const EdgeInsets.all(16),
      onPressed: () {
        Get.toNamed(RouteHelper.driverRideDetailsScreen, arguments: widget.ride.id.toString())?.then((value) {
          widget.controller.initialData(shouldLoading: false, tabID: widget.controller.selectedTab);
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MyImageWidget(imageUrl: widget.controller.userImagePath, height: 50, width: 50, radius: 25, isProfile: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم الراكب بخط عريض
                    HeaderText(text: widget.ride.user?.getFullName() ?? "", style: boldDefault.copyWith(fontSize: 16)),
                    const SizedBox(height: 4),
                    // توضيح المسافة ونوع الخدمة بشكل مقروء
                    Text(
                      _toArabicNumbers("${widget.ride.service?.name ?? ''} • المسافة: ${widget.ride.getDistance()} كيلومتر"),
                      style: regularDefault.copyWith(color: MyColor.colorGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // القسم الجديد: السعر وحالة الدفع تحت الاسم
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: MyColor.getPrimaryColor().withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("إجمالي التكلفة", style: regularSmall.copyWith(color: MyColor.colorGrey)),
                    Text(
                      _toArabicNumbers("${widget.currency}${StringConverter.formatNumber(widget.ride.amount.toString())}"),
                      style: boldLarge.copyWith(fontSize: 18, color: MyColor.getPrimaryColor()),
                    ),
                  ],
                ),
                _buildStatusBadge(),
              ],
            ),
          ),

          const Divider(height: 30, thickness: 0.5),

          CustomTimeLine(
            indicatorPosition: 0.1,
            dashColor: MyColor.neutral300,
            firstWidget: _buildLocationStep(
              title: MyStrings.pickUpLocation.tr,
              address: widget.ride.pickupLocation ?? '',
              time: widget.ride.startTime,
              isPickup: true,
            ),
            secondWidget: _buildLocationStep(
              title: MyStrings.destination.tr,
              address: widget.ride.destination ?? '',
              time: widget.ride.endTime,
              isPickup: false,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionSection(),
        ],
      ),
    );
  }

  Widget _buildLocationStep({required String title, required String address, String? time, required bool isPickup}) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: boldDefault.copyWith(color: isPickup ? MyColor.colorGreen : MyColor.colorRed, fontSize: 12)),
          const SizedBox(height: 4),
          Text(address, style: regularDefault.copyWith(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
          if (time != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_filled, size: 16, color: isPickup ? MyColor.colorGreen : MyColor.colorRed),
                      const SizedBox(width: 8),
                      Text(isPickup ? "وقت الركوب" : "وقت الوصول", style: regularDefault.copyWith(color: isPickup ? MyColor.colorGreen : MyColor.colorRed, fontSize: 12)),
                    ],
                  ),
                  _buildDateTimeSection(time),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor = MyUtils.getRideStatusColor(widget.ride.status ?? '9');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor.withOpacity(0.5))),
      child: Text(MyUtils.getRideStatus(widget.ride.status ?? '9').tr, style: boldDefault.copyWith(color: statusColor, fontSize: 12)),
    );
  }

  Widget _buildActionSection() {
    if (widget.ride.status == AppStatus.RIDE_ACTIVE) {
      return Column(
        children: [
          buildMessageAndCallWidget(),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("وقت الطلب", style: regularDefault.copyWith(color: MyColor.colorGrey)),
          _buildDateTimeSection(widget.ride.createdAt ?? ""),
        ],
      ),
    );
  }

  Widget buildMessageAndCallWidget() {
    return Row(
      children: [
        Expanded(
            child: _buildCircleAction(MyIcons.message, MyStrings.message, () {
          Get.toNamed(RouteHelper.rideMessageScreen, arguments: [widget.ride.id.toString(), widget.ride.user?.getFullName(), widget.ride.status.toString()]);
        })),
        const SizedBox(width: 12),
        Expanded(
            child: _buildCircleAction(MyIcons.callIcon, MyStrings.call, () {
          MyUtils.launchPhone('${widget.ride.user?.mobile}');
        })),
      ],
    );
  }

  Widget _buildCircleAction(String icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: MyColor.getPrimaryColor().withOpacity(0.3))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyLocalImageWidget(imagePath: icon, width: 20, height: 20, imageOverlayColor: MyColor.getPrimaryColor()),
            const SizedBox(width: 8),
            Text(label.tr, style: boldDefault.copyWith(color: MyColor.getPrimaryColor())),
          ],
        ),
      ),
    );
  }
}

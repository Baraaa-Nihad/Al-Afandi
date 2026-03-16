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

class RiderRideInfoCard extends StatefulWidget {
  final AllRideController controller;
  final RideModel ride;
  const RiderRideInfoCard({super.key, required this.controller, required this.ride});

  @override
  State<RiderRideInfoCard> createState() => _RiderRideInfoCardState();
}

class _RiderRideInfoCardState extends State<RiderRideInfoCard> {
  bool isDownLoadLoading = false;

  @override
  Widget build(BuildContext context) {
    return CustomAppCard(
      padding: const EdgeInsets.all(Dimensions.space15),
      onPressed: () {
        Get.toNamed(
          RouteHelper.riderRideDetailsScreen,
          arguments: widget.ride.id.toString(),
        )?.then((value) {
          widget.controller.initialData(shouldLoading: false, tabID: widget.controller.selectedTab);
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status and Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MyUtils.getRideStatusColor(widget.ride.status ?? '9').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: MyUtils.getRideStatusColor(widget.ride.status ?? '9').withOpacity(0.3)),
                ),
                child: Text(
                  MyUtils.getRideStatus(widget.ride.status ?? '9').tr,
                  style: boldDefault.copyWith(
                    fontSize: 12,
                    color: MyUtils.getRideStatusColor(widget.ride.status ?? '9'),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${widget.controller.defaultCurrencySymbol}${StringConverter.formatNumber(widget.ride.offerAmount.toString())}",
                    style: boldExtraLarge.copyWith(
                      color: MyColor.getPrimaryColor(),
                      fontSize: 18,
                    ),
                  ),
                  if (widget.ride.service?.name != null)
                    Text(
                      widget.ride.service?.name ?? '',
                      style: regularSmall.copyWith(color: MyColor.getGreyColor()),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: Dimensions.space20),

          // Timeline Section
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

          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildLocationInfo({required String title, required String address, required String timePrefix, required IconData icon, String? time}) {
    // 1. استخدام الدالة الأصلية لضمان بقاء الساعة 12
    String originalRawDate = DateConverter.estimatedDate(DateTime.tryParse(time ?? '') ?? DateTime.now());
    List<String> parts = originalRawDate.split(' ');

    // 2. تصحيح الوقت (صباحاً / مساءً)
    String timePart = "";
    if (parts.length >= 5) {
      timePart = "${parts[3]} ${parts[4]}";
      timePart = timePart.replaceAll("AM", "صباحاً").replaceAll("PM", "مساءً"); // التعديل المطلوب هنا
    }

    // 3. تنسيق التاريخ الرقمي (2026-3-11)
    DateTime parsedDate = DateTime.tryParse(time ?? '') ?? DateTime.now();
    String numericDate = "${parsedDate.year}-${parsedDate.month}-${parsedDate.day}";

    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: regularSmall.copyWith(color: MyColor.getGreyColor(), fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            address,
            style: boldDefault.copyWith(color: MyColor.getHeadingTextColor(), fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (time != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: MyColor.getPrimaryColor().withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: MyColor.getPrimaryColor().withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: MyColor.getPrimaryColor()),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "$timePrefix: ",
                            style: regularDefault.copyWith(fontSize: 10, color: MyColor.getGreyColor()),
                          ),
                          Text(
                            timePart,
                            style: boldDefault.copyWith(fontSize: 11, color: MyColor.getPrimaryColor()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            "بتاريخ: ",
                            style: regularDefault.copyWith(fontSize: 9, color: MyColor.getGreyColor().withOpacity(0.7)),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            numericDate,
                            style: regularDefault.copyWith(fontSize: 10, color: MyColor.getGreyColor()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
        text: "${MyStrings.viewBids.tr} (${widget.ride.bidsCount ?? 0})",
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

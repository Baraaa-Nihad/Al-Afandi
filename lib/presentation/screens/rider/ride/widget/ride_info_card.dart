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

// دالة مساعدة لتحويل الأرقام إلى العربية
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
  const RiderRideInfoCard({
    super.key,
    required this.controller,
    required this.ride,
  });

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
          widget.controller.initialData(
            shouldLoading: false,
            tabID: widget.controller.selectedTab,
          );
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: MyUtils.getRideStatusColor(
                    widget.ride.status ?? '9',
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: MyUtils.getRideStatusColor(
                      widget.ride.status ?? '9',
                    ).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  MyUtils.getRideStatus(widget.ride.status ?? '9').tr,
                  style: boldDefault.copyWith(
                    fontSize: 12,
                    color: MyUtils.getRideStatusColor(
                      widget.ride.status ?? '9',
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    // تحويل رقم السعر للعربي
                    "${widget.controller.defaultCurrencySymbol}${StringConverter.formatNumber(widget.ride.offerAmount.toString())}"
                        .toArabicNumbers(),
                    style: boldExtraLarge.copyWith(
                      color: MyColor.getPrimaryColor(),
                      fontSize: 18,
                    ),
                  ),
                  if (widget.ride.service?.name != null)
                    Text(
                      widget.ride.service?.name ?? '',
                      style: regularSmall.copyWith(
                        color: MyColor.getGreyColor(),
                      ),
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

  Widget _buildLocationInfo({
    required String title,
    required String address,
    required String timePrefix,
    required IconData icon,
    String? time,
  }) {
    String originalRawDate = DateConverter.estimatedDate(
      DateTime.tryParse(time ?? '') ?? DateTime.now(),
    );
    List<String> parts = originalRawDate.split(' ');

    String timePart = "";
    if (parts.length >= 5) {
      // إزالة الثواني: نأخذ الساعة والدقيقة فقط
      List<String> timeSplit = parts[3].split(':');
      String hourAndMinute = "${timeSplit[0]}:${timeSplit[1]}";

      timePart = "$hourAndMinute ${parts[4]}";
      timePart = timePart.replaceAll("AM", "صباحاً").replaceAll("PM", "مساءً");

      timePart = timePart.toArabicNumbers();
    }

    DateTime parsedDate = DateTime.tryParse(time ?? '') ?? DateTime.now();

    // إضافة حرف "م" بعد السنة وتحويل الكل للأرقام العربية
    // استخدمنا String interpolation لإضافة حرف الميم بعد الرقم مباشرة
    String numericDate =
        "${parsedDate.day}-${parsedDate.month}-${parsedDate.year} م"
            .toArabicNumbers();

    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان (نقطة الركوب / الوجهة)
          Text(
            title,
            style: regularSmall.copyWith(
              color: MyColor.getGreyColor(),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address,
            style: boldDefault.copyWith(
              color: MyColor.getHeadingTextColor(),
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (time != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: MyColor.getPrimaryColor().withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: MyColor.getPrimaryColor().withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: MyColor.getPrimaryColor()),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عرض وقت الركوب/الوصول بدون ثواني
                      Row(
                        children: [
                          Text(
                            "$timePrefix: ",
                            style: regularDefault.copyWith(
                              fontSize: 11,
                              color: MyColor.getGreyColor(),
                            ),
                          ),
                          Text(
                            timePart,
                            style: boldDefault.copyWith(
                              fontSize: 11,
                              color: MyColor.getPrimaryColor(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // عرض التاريخ مع حرف "م"
                      Row(
                        children: [
                          Text(
                            "بتاريخ: ",
                            style: regularDefault.copyWith(
                              fontSize: 11,
                              color: MyColor.getGreyColor(),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            numericDate,
                            style: regularDefault.copyWith(
                              fontSize: 11,
                              color: MyColor.getPrimaryColor(),
                            ),
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
        press: () => Get.toNamed(
          RouteHelper.paymentScreen,
          arguments: [widget.ride, ""],
        ),
      );
    } else if (widget.ride.status == AppStatus.RIDE_PENDING) {
      return RoundedButton(
        // تحويل عدد المزايدات للعربي
        text: "${MyStrings.viewBids.tr} (${widget.ride.bidsCount ?? 0})"
            .toArabicNumbers(),
        press: () => Get.toNamed(
          RouteHelper.rideBidScreen,
          arguments: widget.ride.id.toString(),
        ),
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
          Get.toNamed(
            RouteHelper.rideMessageScreen,
            arguments: [
              widget.ride.id.toString(),
              widget.ride.driver?.getFullName(),
              widget.ride.status.toString(),
            ],
          );
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
            color: MyColor.getPrimaryColor().withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
            border: Border.all(
              color: MyColor.getPrimaryColor().withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyLocalImageWidget(
                imagePath: icon,
                width: 18,
                height: 18,
                imageOverlayColor: MyColor.getPrimaryColor(),
              ),
              const SizedBox(width: 8),
              Text(
                label.tr,
                style: boldDefault.copyWith(
                  color: MyColor.getPrimaryColor(),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

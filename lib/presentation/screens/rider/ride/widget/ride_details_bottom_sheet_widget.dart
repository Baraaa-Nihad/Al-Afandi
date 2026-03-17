import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import 'package:ovoride/data/controller/rider/ride/ride_details/ride_details_controller.dart';
import 'package:ovoride/data/controller/rider/ride/ride_meassage/ride_meassage_controller.dart';
import 'package:ovoride/data/model/global/app/ride_model.dart';
import 'package:ovoride/data/services/download_service.dart';
import 'package:ovoride/presentation/components/bottom-sheet/bottom_sheet_bar.dart';
import 'package:ovoride/presentation/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:ovoride/presentation/components/buttons/rounded_button.dart';
import 'package:ovoride/presentation/components/column_widget/card_column.dart';
import 'package:ovoride/presentation/components/divider/custom_divider.dart';
import 'package:ovoride/presentation/components/image/my_local_image_widget.dart';
import 'package:ovoride/presentation/components/text/header_text.dart';
import 'package:ovoride/presentation/components/text/small_text.dart';
import 'package:ovoride/presentation/components/timeline/custom_time_line.dart';
import 'package:ovoride/presentation/packages/simple_ripple_animation.dart';
import 'package:ovoride/presentation/screens/rider/location/widgets/driver_profile_widget.dart';
import 'package:ovoride/presentation/screens/rider/location/widgets/ride_cancel_bottom_sheet_body.dart';
import 'package:ovoride/presentation/screens/rider/location/widgets/ride_details_review_bottom_sheet.dart';
import 'package:ovoride/presentation/screens/rider/location/widgets/ride_sos_bottom_sheet_body.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ovoride/presentation/screens/rider/payment/widget/ride_details_tips_bottom_sheet_body.dart';
import 'package:ovoride/presentation/screens/rider/ride/widget/searching_for_ride_aniamtion.dart';

class RiderRideDetailsBottomSheetWidget extends StatelessWidget {
  final ScrollController scrollController;
  final DraggableScrollableController draggableScrollableController;

  const RiderRideDetailsBottomSheetWidget({
    super.key,
    required this.scrollController,
    required this.draggableScrollableController,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideDetailsController>(
      tag: 'rider',
      builder: (controller) {
        final ride = controller.ride;
        final currency = controller.currency;

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: MyColor.getScreenBgColor(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.moreRadius),
                  topRight: Radius.circular(Dimensions.moreRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.space16),
              child: ListView(
                clipBehavior: Clip.none,
                controller: scrollController,
                children: [
                  const Center(child: BottomSheetBar()),
                  const CustomSpacer(height: Dimensions.space15),

                  // ---------------- STATUS: PENDING (Searching) ----------------
                  if (ride.status == AppStatus.RIDE_PENDING) ...[
                    _buildGlassContainer(
                      child: controller.totalBids == 0 ? _buildSearchingView() : _buildBidFoundHeader(controller, ride),
                    ),
                    const CustomSpacer(height: Dimensions.space20),
                    _buildInfoCard(buildRideCounterWidget(ride, currency)),
                    const CustomSpacer(height: Dimensions.space20),
                    _buildCancelButton(context),
                  ],

                  // ---------------- STATUS: ACTIVE (Driver Accepted) ----------------
                  if (ride.status == AppStatus.RIDE_ACTIVE) ...[
                    _buildArrivingHeader(),
                    const CustomSpacer(height: Dimensions.space20),
                    _buildSecurityCodeSection(ride),
                    const CustomSpacer(height: Dimensions.space15),
                    _buildInfoCard(buildRideCounterWidget(ride, currency)),
                    if (ride.driver != null) ...[
                      const CustomSpacer(height: Dimensions.space20),
                      _buildInfoCard(DriverProfileWidget(
                        driver: ride.driver,
                        driverImage: '${controller.driverImagePath}/${ride.driver?.avatar ?? ''}',
                        serviceImage: '${controller.serviceImagePath}/${ride.service?.image ?? ''}',
                        totalCompletedRide: controller.driverTotalCompletedRide,
                      )),
                    ],
                    const CustomSpacer(height: Dimensions.space25),
                    buildMessageOrCallWidget(ride),
                    const CustomSpacer(height: Dimensions.space20),
                    _buildCancelButton(context),
                  ],

                  // ---------------- STATUS: RUNNING (In Trip) ----------------
                  if (ride.status == AppStatus.RIDE_RUNNING) ...[
                    if (ride.driver != null) ...[
                      _buildInfoCard(DriverProfileWidget(
                        driver: ride.driver,
                        driverImage: '${controller.driverImagePath}/${ride.driver?.avatar ?? ''}',
                        serviceImage: '${controller.serviceImagePath}/${ride.service?.image ?? ''}',
                        totalCompletedRide: controller.driverTotalCompletedRide,
                      )),
                      const CustomSpacer(height: Dimensions.space15),
                      buildMessageOrCallWidget(ride),
                      const CustomSpacer(height: Dimensions.space20),
                    ],
                    _buildInfoCard(Column(
                      children: [
                        buildRideCounterWidget(ride, currency),
                        const CustomDivider(space: Dimensions.space15),
                        buildRideLocationAndDestinationWidget(ride),
                      ],
                    )),
                    const CustomSpacer(height: Dimensions.space20),
                    _buildSOSButton(context, controller, ride),
                  ],

                  // ---------------- STATUS: PAYMENT REQUESTED ----------------
                  if (ride.status == AppStatus.RIDE_PAYMENT_REQUESTED) ...[
                    const CustomSpacer(height: Dimensions.space40),
                    _buildInfoCard(buildRideCounterWidget(ride, currency)),
                    const CustomSpacer(height: Dimensions.space15),
                    _buildPaymentSummaryCard(controller, ride, context),
                    const CustomSpacer(height: Dimensions.space20),
                    if (ride.driver != null)
                      _buildInfoCard(DriverProfileWidget(
                        driver: ride.driver,
                        driverImage: '${controller.driverImagePath}/${ride.driver?.avatar ?? ''}',
                        serviceImage: '${controller.serviceImagePath}/${ride.service?.image ?? ''}',
                        totalCompletedRide: controller.driverTotalCompletedRide,
                      )),
                    const CustomSpacer(height: Dimensions.space30),
                    _buildActionOrWaitPayment(controller, ride),
                  ],

                  // ---------------- STATUS: COMPLETED ----------------
                  if (ride.status == AppStatus.RIDE_COMPLETED) ...[
                    const CustomSpacer(height: Dimensions.space40),
                    _buildInfoCard(Column(
                      children: [
                        buildRideCounterWidget(ride, currency),
                        const CustomDivider(space: Dimensions.space15),
                        buildRideLocationAndDestinationWidget(ride),
                      ],
                    )),
                    if (ride.driver != null) ...[
                      const CustomSpacer(height: Dimensions.space15),
                      _buildInfoCard(DriverProfileWidget(
                        driver: ride.driver,
                        driverImage: '${controller.driverImagePath}/${ride.driver?.avatar ?? ''}',
                        serviceImage: '${controller.serviceImagePath}/${ride.service?.image ?? ''}',
                        totalCompletedRide: controller.driverTotalCompletedRide,
                      )),
                    ],
                    const CustomSpacer(height: Dimensions.space25),
                    _buildCompletedActions(controller, ride, context),
                  ],

                  if (ride.status == AppStatus.RIDE_CANCELED) ...[
                    const CustomSpacer(height: Dimensions.space40),
                    _buildInfoCard(Column(
                      children: [
                        buildRideLocationAndDestinationWidget(ride),
                        const CustomDivider(space: Dimensions.space50),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.space5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("اتفركشت وما فيش نصيب", style: boldDefault.copyWith(color: MyColor.redCancelTextColor)),
                              const SizedBox(width: 8),
                              const Icon(Icons.cancel_outlined, color: MyColor.redCancelTextColor, size: 18),
                            ],
                          ),
                        ),
                      ],
                    )),
                  ],

                  const CustomSpacer(height: Dimensions.space30),
                ],
              ),
            ),
            if (_shouldShowTopOverlay(ride.status ?? "")) _buildTopStatusOverlay(ride),
          ],
        );
      },
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildGlassContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.getPrimaryColor().withOpacity(0.03),
        borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
        border: Border.all(color: MyColor.getPrimaryColor().withOpacity(0.1)),
      ),
      child: child,
    );
  }

  Widget _buildInfoCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.colorWhite,
        borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSearchingView() {
    return Column(
      children: [
        const SearchingForRideAnimation(),
        const CustomSpacer(height: Dimensions.space10),
        HeaderText(
          text: MyStrings.searchingForDriver.tr,
          style: boldMediumLarge.copyWith(color: MyColor.getHeadingTextColor()),
        ),
        SmallText(
          text: MyStrings.itMayTakeSomeTimes.tr,
          textStyle: regularDefault.copyWith(color: MyColor.getBodyTextColor()),
        ),
      ],
    );
  }

  Widget _buildBidFoundHeader(RideDetailsController controller, RideModel ride) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderText(
                text: MyStrings.bidFoundTitle.tr,
                style: boldMediumLarge.copyWith(color: MyColor.getHeadingTextColor()),
              ),
              SmallText(
                text: MyStrings.bidFoundSubTitle.tr,
                maxLine: 2,
                textStyle: regularDefault.copyWith(color: MyColor.getBodyTextColor()),
              ),
            ],
          ),
        ),
        _buildBidBadge(controller, ride),
      ],
    );
  }

  Widget _buildBidBadge(RideDetailsController controller, RideModel ride) {
    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.rideBidScreen, arguments: ride.id.toString()),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.space12),
            decoration: BoxDecoration(
              color: MyColor.primaryColor,
              borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
              boxShadow: [BoxShadow(color: MyColor.primaryColor.withOpacity(0.3), blurRadius: 8)],
            ),
            child: const MyLocalImageWidget(imagePath: MyIcons.driverIcon, height: 25, width: 25),
          ),
          Positioned(
            top: -5,
            right: -5,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: MyColor.greenSuccessColor,
              child: Text(controller.totalBids.toString(), style: boldDefault.copyWith(color: MyColor.colorWhite, fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCodeSection(RideModel ride) {
    return _buildInfoCard(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderText(text: MyStrings.securityCode.tr, style: regularDefault.copyWith(color: MyColor.getBodyTextColor())),
              const CustomSpacer(height: 5),
              Text("شارك الكود مع الكابتن", style: regularSmall.copyWith(color: MyColor.getPrimaryColor())),
            ],
          ),
          Row(
            children: ride.otp?.split('').map((e) => _buildOtpDigit(e)).toList() ?? [],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpDigit(String digit) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      width: 35,
      height: 45,
      decoration: BoxDecoration(
        color: MyColor.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MyColor.neutral200),
      ),
      child: Center(child: HeaderText(text: digit, style: boldMediumLarge)),
    );
  }

  Widget _buildPaymentSummaryCard(RideDetailsController controller, RideModel ride, BuildContext context) {
    return _buildInfoCard(
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmallText(text: MyStrings.billToPay.tr),
                const CustomSpacer(height: 5),
                Text(
                  "${controller.currencySym}${StringConverter.formatNumber(ride.amount.toString())}",
                  style: boldOverLarge.copyWith(fontSize: 24, color: MyColor.getHeadingTextColor()),
                ),
              ],
            ),
          ),
          _buildTipButton(controller, context),
        ],
      ),
    );
  }

  Widget _buildTipButton(RideDetailsController controller, BuildContext context) {
    bool hasTip = controller.tipsController.text.isNotEmpty;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: MyColor.getPrimaryColor()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.mediumRadius)),
        backgroundColor: MyColor.getPrimaryColor().withOpacity(0.05),
      ),
      onPressed: () => CustomBottomSheet(child: const RideDetailsTipsBottomSheet()).customBottomSheet(context),
      child: Row(
        children: [
          if (!hasTip) Icon(Icons.add, size: 18, color: MyColor.getPrimaryColor()),
          Text(
            hasTip ? "+${controller.currencySym}${controller.tipsController.text}" : MyStrings.addTip.tr,
            style: boldDefault.copyWith(color: MyColor.getPrimaryColor()),
          ),
        ],
      ),
    );
  }

  Widget _buildActionOrWaitPayment(RideDetailsController controller, RideModel ride) {
    if (ride.paymentStatus == '2' && !controller.isPaymentRequested) {
      return RoundedButton(
        text: MyStrings.payNow.tr,
        press: () => Get.toNamed(RouteHelper.paymentScreen, arguments: [ride, controller.tipsController.text]),
      ).animate().shimmer(duration: 1500.ms);
    }
    return Column(
      children: [
        const RippleAnimation(color: MyColor.primaryColor, minRadius: 20, child: SizedBox(height: 40, width: 40)),
        const CustomSpacer(height: 15),
        Text(MyStrings.waitForDriverResponse.tr, style: boldDefault.copyWith(color: MyColor.getPrimaryColor())),
      ],
    );
  }

  Widget _buildCompletedActions(RideDetailsController controller, RideModel ride, BuildContext context) {
    return Column(
      children: [
        if (ride.driverReview == null)
          RoundedButton(
            text: MyStrings.review.tr,
            press: () => CustomBottomSheet(child: RideDetailsReviewBottomSheet(ride: ride)).customBottomSheet(context),
          )
        else
          _buildReceiptButton(ride),
      ],
    );
  }

  Widget _buildReceiptButton(RideModel ride) {
    return RoundedButton(
      text: MyStrings.receipt.tr,
      isOutlined: true,
      press: () => DownloadService.downloadPDF(
        url: "${UrlContainer.riderRideReceipt}/${ride.id}",
        fileName: "Receipt_${ride.id}.pdf",
      ),
      bgColor: MyColor.getPrimaryColor().withOpacity(0.1),
      textColor: MyColor.getPrimaryColor(),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return RoundedButton(
      text: MyStrings.cancelRide.tr,
      bgColor: MyColor.redCancelTextColor,
      press: () => CustomBottomSheet(child: const RideCancelBottomSheetBody()).customBottomSheet(context),
    );
  }

  Widget _buildSOSButton(BuildContext context, RideDetailsController controller, RideModel ride) {
    return RoundedButton(
      text: MyStrings.sos.tr,
      bgColor: MyColor.redCancelTextColor,
      isLoading: controller.isSosLoading,
      press: () => CustomBottomSheet(
        child: RideDetailsSosBottomSheetBody(controller: controller, id: ride.id ?? '-1'),
      ).customBottomSheet(context),
    );
  }

  Widget _buildArrivingHeader() {
    return Center(
      child: Column(
        children: [
          const SearchingForRideAnimation(),
          const CustomSpacer(height: 10),
          SmallText(text: MyStrings.driverArriveMsg.tr, textStyle: regularDefault.copyWith(color: MyColor.getBodyTextColor())),
        ],
      ),
    );
  }

  bool _shouldShowTopOverlay(String status) {
    return status == AppStatus.RIDE_PAYMENT_REQUESTED || status == AppStatus.RIDE_COMPLETED || status == AppStatus.RIDE_CANCELED;
  }

  Widget _buildTopStatusOverlay(RideModel ride) {
    bool isCanceled = ride.status == AppStatus.RIDE_CANCELED;
    Color color = isCanceled ? MyColor.redCancelTextColor : MyColor.getPrimaryColor();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.space12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.moreRadius)),
        ),
        child: Center(
          child: HeaderText(
            text: isCanceled ? MyStrings.rideCanceled.tr : (ride.status == AppStatus.RIDE_COMPLETED ? MyStrings.rideCompleted.tr : MyStrings.arriveAtMsg.tr),
            style: boldLarge.copyWith(color: color),
          ),
        ),
      ),
    );
  }

  CustomTimeLine buildRideLocationAndDestinationWidget(RideModel ride) {
    return CustomTimeLine(
      firstIndicatorColor: MyColor.getPrimaryColor(),
      indicatorPosition: 0.1,
      dashColor: MyColor.getPrimaryColor(),
      firstWidget: _buildTimelineText(MyStrings.pickUpLocation.tr, ride.pickupLocation ?? ''),
      secondWidget: _buildTimelineText(MyStrings.destination.tr, ride.destination ?? ''),
    );
  }

  Widget _buildTimelineText(String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: boldDefault.copyWith(color: MyColor.rideTitle)),
          const SizedBox(height: 4),
          Text(sub, style: regularSmall.copyWith(color: MyColor.getBodyTextColor()), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Row buildMessageOrCallWidget(RideModel ride) {
    return Row(
      children: [
        Expanded(
          child: GetBuilder<RideMessageController>(
            tag: 'rider',
            builder: (msgController) => InkWell(
              onTap: () => Get.toNamed(RouteHelper.rideMessageScreen, arguments: [ride.id.toString(), ride.driver?.getFullName(), ride.status.toString()]),
              child: _buildInfoCard(Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message_rounded, color: MyColor.getPrimaryColor()),
                  const CustomSpacer(width: 10),
                  Text(MyStrings.message.tr, style: boldDefault),
                ],
              )),
            ),
          ),
        ),
        const CustomSpacer(width: 15),
        Expanded(
          child: InkWell(
            onTap: () => MyUtils.launchPhone(ride.driver?.mobile ?? ''),
            child: _buildInfoCard(Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.call, color: MyColor.greenSuccessColor),
                const CustomSpacer(width: 10),
                Text(MyStrings.call.tr, style: boldDefault),
              ],
            )),
          ),
        ),
      ],
    );
  }

  Widget buildRideCounterWidget(RideModel ride, String currency) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CardColumn(header: MyStrings.distance.tr, body: "${ride.distance ?? '0'} KM"),
        CardColumn(header: MyStrings.duration.tr, body: ride.duration ?? '0'),
        CardColumn(header: "الأجرة", body: "$currency${ride.amount ?? '0'}"),
      ],
    );
  }
}

class CustomSpacer extends StatelessWidget {
  final double? height;
  final double? width;
  const CustomSpacer({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 0,
      width: width ?? 0,
    );
  }
}

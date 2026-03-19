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

        return Container(
          decoration: BoxDecoration(
            color: MyColor.getScreenBgColor(),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.moreRadius)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 15, offset: const Offset(0, -5)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomSheetBar(),
              // حالة الرحلة في أعلى الشيت بشكل احترافي
              if (_shouldShowTopOverlay(ride.status ?? "")) _buildStatusBadge(ride),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(Dimensions.space16, 10, Dimensions.space16, Dimensions.space20),
                  children: [
                    // ---------------- STATUS: PENDING ----------------
                    if (ride.status == AppStatus.RIDE_PENDING) ...[
                      _buildSearchingHeader(controller, ride),
                      const SizedBox(height: Dimensions.space20),
                      _buildMainStatsCard(ride, currency),
                      const SizedBox(height: Dimensions.space20),
                      _buildCancelButton(context),
                    ],

                    // ---------------- STATUS: ACTIVE (ACCEPTED) ----------------
                    if (ride.status == AppStatus.RIDE_ACTIVE) ...[
                      _buildArrivingSection(),
                      const SizedBox(height: Dimensions.space15),
                      _buildSecurityCodeCard(ride),
                      const SizedBox(height: Dimensions.space15),
                      _buildMainStatsCard(ride, currency),
                      if (ride.driver != null) ...[
                        const SizedBox(height: Dimensions.space15),
                        _buildDriverCard(controller, ride),
                      ],
                      const SizedBox(height: Dimensions.space20),
                      _buildActionButtons(ride),
                      const SizedBox(height: Dimensions.space15),
                      _buildCancelButton(context),
                    ],

                    // ---------------- STATUS: RUNNING (In Trip) ----------------
                    if (ride.status == AppStatus.RIDE_RUNNING) ...[
                      if (ride.driver != null) _buildDriverCard(controller, ride),
                      const SizedBox(height: Dimensions.space15),
                      _buildActionButtons(ride),
                      const SizedBox(height: Dimensions.space15),
                      _buildTripDetailsCard(ride, currency),
                      const SizedBox(height: Dimensions.space20),
                      _buildSOSButton(context, controller, ride),
                    ],

                    // ---------------- STATUS: PAYMENT REQUESTED ----------------
                    if (ride.status == AppStatus.RIDE_PAYMENT_REQUESTED) ...[
                      _buildPaymentSummaryCard(controller, ride, context),
                      const SizedBox(height: Dimensions.space15),
                      if (ride.driver != null) _buildDriverCard(controller, ride),
                      const SizedBox(height: Dimensions.space25),
                      _buildActionOrWaitPayment(controller, ride),
                    ],

                    // ---------------- STATUS: COMPLETED ----------------
                    if (ride.status == AppStatus.RIDE_COMPLETED) ...[
                      _buildTripDetailsCard(ride, currency),
                      const SizedBox(height: Dimensions.space15),
                      if (ride.driver != null) _buildDriverCard(controller, ride),
                      const SizedBox(height: Dimensions.space25),
                      _buildCompletedActions(controller, ride, context),
                    ],

                    // ---------------- STATUS: CANCELED ----------------
                    if (ride.status == AppStatus.RIDE_CANCELED) _buildCanceledCard(ride),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- UI Components ---

  Widget _buildStatusBadge(RideModel ride) {
    bool isCanceled = ride.status == AppStatus.RIDE_CANCELED;
    Color color = isCanceled ? MyColor.redCancelTextColor : MyColor.primaryColor;
    String text = isCanceled ? MyStrings.rideCanceled.tr : (ride.status == AppStatus.RIDE_COMPLETED ? MyStrings.rideCompleted.tr : "الكابتن في الطريق إليك");

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.space16, vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
      ),
      child: Center(child: Text(text, style: boldDefault.copyWith(color: color))),
    ).animate().fadeIn().slideY(begin: -0.5);
  }

  Widget _buildMainStatsCard(RideModel ride, String currency) {
    return _buildContainerWrapper(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(MyStrings.distance.tr, "${ride.distance ?? '0'} KM", Icons.directions_car),
          _buildVerticalDivider(),
          _buildStatItem(MyStrings.duration.tr, ride.duration ?? '0', Icons.timer_outlined),
          _buildVerticalDivider(),
          _buildStatItem("الأجرة", "$currency${ride.amount ?? '0'}", Icons.payments_outlined),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: MyColor.getPrimaryColor().withOpacity(0.6)),
        const SizedBox(height: 5),
        Text(label, style: regularSmall.copyWith(color: MyColor.rideTitle)),
        Text(value, style: boldDefault.copyWith(color: MyColor.getHeadingTextColor())),
      ],
    );
  }

  Widget _buildSecurityCodeCard(RideModel ride) {
    return _buildContainerWrapper(
      color: MyColor.getPrimaryColor().withOpacity(0.02),
      child: Column(
        children: [
          Text("شارك كود الأمان مع الكابتن عند الركوب", style: regularSmall.copyWith(color: MyColor.getBodyTextColor())),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ride.otp?.split('').map((e) => _buildOtpBox(e)).toList() ?? [],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(String digit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: MyColor.colorWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MyColor.getPrimaryColor().withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
      ),
      child: Center(child: Text(digit, style: boldExtraLarge.copyWith(color: MyColor.getPrimaryColor()))),
    );
  }

  Widget _buildDriverCard(RideDetailsController controller, RideModel ride) {
    return _buildContainerWrapper(
      child: DriverProfileWidget(
        driver: ride.driver,
        driverImage: '${controller.driverImagePath}/${ride.driver?.avatar ?? ''}',
        serviceImage: '${controller.serviceImagePath}/${ride.service?.image ?? ''}',
        totalCompletedRide: controller.driverTotalCompletedRide,
      ),
    );
  }

  Widget _buildActionButtons(RideModel ride) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: MyStrings.message.tr,
            icon: Icons.chat_bubble_outline_rounded,
            color: MyColor.getPrimaryColor(),
            onTap: () => Get.toNamed(RouteHelper.rideMessageScreen, arguments: [ride.id.toString(), ride.driver?.getFullName(), ride.status.toString()]),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildActionButton(
            label: MyStrings.call.tr,
            icon: Icons.call_outlined,
            color: MyColor.greenSuccessColor,
            onTap: () => MyUtils.launchPhone(ride.driver?.mobile ?? ''),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(label, style: boldDefault.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  // --- Shared Layout Helpers ---

  Widget _buildContainerWrapper({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: color ?? MyColor.colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyColor.borderColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: MyColor.borderColor.withOpacity(0.5));
  }

  // الميثودات المساعدة الأخرى (نفس المنطق لكن بتنسيق Wrapper)
  Widget _buildTripDetailsCard(RideModel ride, String currency) {
    return _buildContainerWrapper(
      child: Column(
        children: [
          _buildMainStatsCardContent(ride, currency),
          const CustomDivider(space: Dimensions.space15),
          buildRideLocationAndDestinationWidget(ride),
        ],
      ),
    );
  }

  // تم نقل المحتوى ليكون متناسقاً
  Widget _buildMainStatsCardContent(RideModel ride, String currency) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CardColumn(header: MyStrings.distance.tr, body: "${ride.distance ?? '0'} KM"),
        CardColumn(header: MyStrings.duration.tr, body: ride.duration ?? '0'),
        CardColumn(header: "الأجرة", body: "$currency${ride.amount ?? '0'}"),
      ],
    );
  }

  // ... (بقية ميثودات الأزرار والـ Headers تبقى كما هي مع التأكد من وضعها داخل الأوعية الجديدة)

  Widget _buildSearchingHeader(RideDetailsController controller, RideModel ride) {
    return Column(
      children: [
        const SearchingForRideAnimation(),
        const SizedBox(height: 10),
        controller.totalBids == 0
            ? Column(
                children: [
                  HeaderText(text: MyStrings.searchingForDriver.tr, style: boldMediumLarge),
                  SmallText(text: MyStrings.itMayTakeSomeTimes.tr),
                ],
              )
            : _buildBidFoundHeader(controller, ride),
      ],
    );
  }

  Widget _buildArrivingSection() {
    return Column(
      children: [
        const SearchingForRideAnimation(),
        const SizedBox(height: 8),
        Text(MyStrings.driverArriveMsg.tr, style: regularDefault.copyWith(color: MyColor.getPrimaryColor())),
      ],
    );
  }

  Widget _buildCanceledCard(RideModel ride) {
    return _buildContainerWrapper(
      child: Column(
        children: [
          buildRideLocationAndDestinationWidget(ride),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: MyColor.redCancelTextColor),
              const SizedBox(width: 8),
              Text("تم إلغاء هذه الرحلة", style: boldDefault.copyWith(color: MyColor.redCancelTextColor)),
            ],
          ),
        ],
      ),
    );
  }

  // الميثودات الأصلية المطلوبة من الكود
  Widget _buildPaymentSummaryCard(RideDetailsController controller, RideModel ride, BuildContext context) {
    return _buildContainerWrapper(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallText(text: MyStrings.billToPay.tr),
              Text(
                "${controller.currencySym}${StringConverter.formatNumber(ride.amount.toString())}",
                style: boldExtraLarge.copyWith(fontSize: 28, color: MyColor.getHeadingTextColor()),
              ),
            ],
          ),
          _buildTipButton(controller, context),
        ],
      ),
    );
  }

  // الميثودات المساعدة (UI Logic)
  bool _shouldShowTopOverlay(String status) => status == AppStatus.RIDE_PAYMENT_REQUESTED || status == AppStatus.RIDE_COMPLETED || status == AppStatus.RIDE_CANCELED;

  // -- ميثودات الأزرار والوظائف (نفس المنطق الأصلي لكن مع تحسين التصميم)
  Widget _buildCancelButton(BuildContext context) {
    return RoundedButton(
      text: MyStrings.cancelRide.tr,
      bgColor: Colors.transparent,
      textColor: MyColor.redCancelTextColor,
      isOutlined: true,
      press: () => CustomBottomSheet(child: const RideCancelBottomSheetBody()).customBottomSheet(context),
    );
  }

  Widget _buildSOSButton(BuildContext context, RideDetailsController controller, RideModel ride) {
    return RoundedButton(
      text: MyStrings.sos.tr,
      bgColor: MyColor.redCancelTextColor,
      press: () => CustomBottomSheet(child: RideDetailsSosBottomSheetBody(controller: controller, id: ride.id ?? '-1')).customBottomSheet(context),
    );
  }

  // بقية الميثودات (buildRideLocationAndDestinationWidget, _buildTipButton, الخ) تبقى كما هي مع تغيير الستايلات لتناسب التصميم الجديد.

  Widget _buildBidFoundHeader(RideDetailsController controller, RideModel ride) {
    return _buildContainerWrapper(
      color: MyColor.getPrimaryColor().withOpacity(0.05),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderText(text: "وصلتك عروض جديدة!", style: boldMediumLarge),
                SmallText(text: "اضغط على الأيقونة لرؤية عروض السائقين"),
              ],
            ),
          ),
          _buildBidBadge(controller, ride),
        ],
      ),
    );
  }

  Widget _buildBidBadge(RideDetailsController controller, RideModel ride) {
    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.rideBidScreen, arguments: ride.id.toString()),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: MyColor.primaryColor, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.local_taxi, color: Colors.white),
          ),
          Positioned(
            top: -5,
            right: -5,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text(controller.totalBids.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
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
          Text(title, style: boldDefault.copyWith(color: MyColor.rideTitle, fontSize: 12)),
          Text(sub, style: regularDefault.copyWith(color: MyColor.getHeadingTextColor()), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTipButton(RideDetailsController controller, BuildContext context) {
    bool hasTip = controller.tipsController.text.isNotEmpty;
    return RoundedButton(
      text: hasTip ? "+${controller.currencySym}${controller.tipsController.text}" : MyStrings.addTip.tr,
      width: 100,
      press: () => CustomBottomSheet(child: const RideDetailsTipsBottomSheet()).customBottomSheet(context),
      bgColor: MyColor.getPrimaryColor().withOpacity(0.1),
      textColor: MyColor.getPrimaryColor(),
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
        const SizedBox(height: 15),
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
          RoundedButton(
            text: MyStrings.receipt.tr,
            isOutlined: true,
            press: () => DownloadService.downloadPDF(url: "${UrlContainer.riderRideReceipt}/${ride.id}", fileName: "Receipt_${ride.id}.pdf"),
          ),
      ],
    );
  }
}

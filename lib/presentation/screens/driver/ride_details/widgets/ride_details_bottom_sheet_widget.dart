import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/utils/app_status.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:ovoride/data/controller/driver/ride/ride_details/ride_details_controller.dart';
import 'package:ovoride/data/model/global/ride/ride_model.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/data/services/download_service.dart';
import 'package:ovoride/environment.dart';
import 'package:ovoride/presentation/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:ovoride/presentation/components/buttons/rounded_button.dart';
import 'package:ovoride/presentation/components/dialog/app_dialog.dart';
import 'package:ovoride/presentation/screens/driver/ride_details/section/ride_details_payment_section.dart';
import 'package:ovoride/presentation/screens/driver/ride_details/section/ride_details_review_section.dart';
import 'package:ovoride/presentation/screens/driver/ride_details/widgets/pick_up_rider_bottom_sheet.dart';
import 'package:ovoride/presentation/screens/driver/ride_details/widgets/ride_cancel_bottom_sheet.dart';
import 'package:ovoride/presentation/screens/driver/ride_details/widgets/user_details_widget.dart';

class RideDetailsBottomSheetWidget extends StatelessWidget {
  final ScrollController scrollController;
  final DraggableScrollableController draggableScrollableController;

  const RideDetailsBottomSheetWidget({
    super.key,
    required this.scrollController,
    required this.draggableScrollableController,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideDetailsController>(
      tag: 'driver',
      builder: (controller) {
        final ride = controller.ride;
        final currency = controller.currency;
        bool isCancelled = ride.status == AppStatus.RIDE_CANCELED;

        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: MyColor.colorWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.moreRadius),
                  topRight: Radius.circular(Dimensions.moreRadius),
                ),
              ),
              padding: const EdgeInsets.only(
                top: Dimensions.space10,
                left: Dimensions.space16,
                right: Dimensions.space16,
              ),
              child: ListView(
                clipBehavior: Clip.none,
                controller: scrollController,
                children: [
                  // Handle Bar
                  if (ride.status != AppStatus.RIDE_COMPLETED &&
                      !isCancelled &&
                      ride.status != AppStatus.RIDE_PAYMENT_REQUESTED) ...[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 5,
                        width: 45,
                        decoration: BoxDecoration(
                          color: MyColor.neutral300.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.space15),
                  ],

                  if (ride.status == AppStatus.RIDE_PAYMENT_REQUESTED ||
                      (ride.status == AppStatus.RIDE_COMPLETED) ||
                      isCancelled) ...[
                    const SizedBox(height: Dimensions.space70),
                  ],

                  if (ride.user != null) ...[
                    // تخصيص عرض المستخدم: إخفاء أزرار الاتصال إذا كان المشوار ملغياً
                    UserDetailsWidget(
                      ride: ride,
                      imageUrl: controller.userImageUrl,
                    ),
                    const SizedBox(height: Dimensions.space25),
                  ],

                  // بطاقة العداد: تختفي تماماً في حالة الإلغاء لزيادة الاحترافية
                  if (!isCancelled) ...[
                    buildRideCounterWidget(ride, currency),
                    const SizedBox(height: Dimensions.space25),
                  ],

                  // قسم العناوين (نقطة الركوب والوجهة)
                  buildLocationSection(ride),

                  const SizedBox(height: Dimensions.space25),

                  // منطقة الأزرار والتحكم بالرحلة
                  _buildActionButtons(context, controller, ride),

                  const SizedBox(height: Dimensions.space30),
                ],
              ),
            ),

            // هيدر الحالة الاحترافي (براند الأفندي)
            _buildStatusHeader(ride),
          ],
        );
      },
    );
  }

  // دالة بناء هيدر الحالة العلوي
  Widget _buildStatusHeader(RideModel ride) {
    bool isCompleted = ride.status == AppStatus.RIDE_COMPLETED;
    bool isCancelled = ride.status == AppStatus.RIDE_CANCELED;
    bool isPaymentReq = ride.status == AppStatus.RIDE_PAYMENT_REQUESTED;

    if (isCompleted || isCancelled || isPaymentReq) {
      return Positioned(
        top: 0,
        right: 0,
        left: 0,
        child: IgnorePointer(
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              // استخدام اللون البنفسجي للنجاح والأحمر الباهت للإلغاء
              color: isCancelled
                  ? Colors.redAccent.withValues(alpha: 0.9)
                  : MyColor.getPrimaryColor().withValues(alpha: 0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.moreRadius),
                topRight: Radius.circular(Dimensions.moreRadius),
              ),
            ),
            child: Center(
              child: Text(
                isCompleted
                    ? MyStrings.rideCompleted.tr
                    : isCancelled
                    ? "تم إلغاء هذا الطلب يا أفندي"
                    : MyStrings.arriveAtMsg.tr,
                style: boldExtraLarge.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // دالة عرض المواقع
  Widget buildLocationSection(RideModel ride) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const Icon(
                Icons.radio_button_checked,
                size: 20,
                color: MyColor.primaryColor,
              ),
              Container(width: 1, height: 50, color: MyColor.neutral300),
              const Icon(Icons.location_on, size: 20, color: Colors.redAccent),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationItem(
                  MyStrings.pickUpLocation.tr,
                  ride.pickupLocation ?? '',
                  MyColor.getPrimaryColor(),
                ),
                const SizedBox(height: 25),
                _buildLocationItem(
                  MyStrings.destination.tr,
                  ride.destination ?? '',
                  Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(String label, String address, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: regularSmall.copyWith(
            color: labelColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          address,
          style: boldDefault.copyWith(color: MyColor.titleColor),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // دالة بناء أزرار التحكم بناءً على الحالة
  Widget _buildActionButtons(
    BuildContext context,
    RideDetailsController controller,
    RideModel ride,
  ) {
    if (ride.status == AppStatus.RIDE_COMPLETED) {
      if (ride.userReview == null) {
        return RoundedButton(
          text: MyStrings.review.tr,
          press: () => CustomBottomSheet(
            child: RideDetailsReviewSection(),
          ).customBottomSheet(context),
        );
      } else {
        return buildReceiptButton(ride);
      }
    }

    if (ride.status == AppStatus.RIDE_ACTIVE) {
      return Column(
        children: [
          RoundedButton(
            text: MyStrings.pickupPassenger.tr,
            press: () => CustomBottomSheet(
              child: PickUpRiderBottomSheet(ride: ride),
            ).customBottomSheet(context),
            isLoading: controller.isStartBtnLoading,
          ),
          const SizedBox(height: 15),
          RoundedButton(
            text: MyStrings.cancelRide.tr,
            press: () => CustomBottomSheet(
              child: RideCancelBottomSheet(ride: ride),
            ).customBottomSheet(context),
            bgColor: Colors.transparent,
            textColor: MyColor.redCancelTextColor,
            isOutlined: true,
          ),
        ],
      );
    }

    if (ride.status == AppStatus.RIDE_RUNNING) {
      return RoundedButton(
        text: MyStrings.endRide.tr,
        press: () => AppDialog().showRideDetailsDialog(
          context,
          title: MyStrings.pleaseConfirm.tr,
          description: MyStrings.youWantToEndTheRide.tr,
          onTap: () async => await controller.endRide(ride.id ?? '-1'),
        ),
        isLoading: controller.isEndBtnLoading,
      );
    }

    if (ride.status == AppStatus.RIDE_PAYMENT_REQUESTED) {
      return RideDetailsPaymentSection();
    }

    return const SizedBox.shrink();
  }

  Widget buildRideCounterWidget(RideModel ride, String currency) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.space20),
      decoration: BoxDecoration(
        color: MyColor.neutral50,
        borderRadius: BorderRadius.circular(Dimensions.largeRadius),
      ),
      child: Row(
        children: [
          _buildInfoItem(
            '${ride.getDistance()} ${MyUtils.getDistanceLabel(distance: ride.distance, unit: Get.find<ApiClient>().getDistanceUnit())}',
            MyStrings.distance.tr,
          ),
          _buildDivider(),
          _buildInfoItem('${ride.duration}', MyStrings.estimatedTime.tr),
          _buildDivider(),
          _buildInfoItem(
            '${StringConverter.formatNumber(ride.amount.toString())} $currency',
            MyStrings.rideFare.tr,
            isAmount: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String value, String label, {bool isAmount = false}) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            child: Text(
              value,
              style: boldMediumLarge.copyWith(
                color: isAmount
                    ? MyColor.getPrimaryColor()
                    : MyColor.titleColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: regularSmall.copyWith(color: MyColor.getBodyTextColor()),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Container(height: 30, width: 1, color: MyColor.neutral200);

  Widget buildReceiptButton(RideModel ride) {
    return Builder(
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return RoundedButton(
              text: MyStrings.receipt.tr,
              isOutlined: true,
              isLoading: isLoading,
              press: () async {
                setState(() => isLoading = true);
                await DownloadService.downloadPDF(
                  url: "${UrlContainer.rideReceipt}/${ride.id}",
                  fileName: "${Environment.appName}_receipt_${ride.id}.pdf",
                );
                setState(() => isLoading = false);
              },
            );
          },
        );
      },
    );
  }
}

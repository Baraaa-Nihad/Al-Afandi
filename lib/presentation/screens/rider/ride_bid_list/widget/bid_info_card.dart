import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/controller/rider/ride/ride_bid_list/ride_bid_list_controller.dart';
import 'package:ovoride/data/model/global/bid/bid_model.dart';
import 'package:ovoride/data/model/global/app/ride_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/presentation/components/image/my_network_image_widget.dart';

class BidInfoCard extends StatelessWidget {
  final BidModel bid;
  final RideModel ride;
  final String currency;

  const BidInfoCard({
    super.key,
    required this.bid,
    required this.ride,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideBidListController>(
      builder: (controller) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MyColor.getCardBgColor(),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Driver Profile & Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed(
                      RouteHelper.driverReviewScreen,
                      arguments: bid.driver?.id,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: MyColor.primaryColor.withValues(
                                alpha: 0.2,
                              ),
                              width: 2,
                            ),
                          ),
                          child: MyImageWidget(
                            imageUrl:
                                '${controller.driverImagePath}${bid.driver?.avatar}',
                            isProfile: true,
                            height: 55,
                            width: 55,
                            radius: 30,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: MyColor.colorYellow,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 10,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  "${bid.driver?.avgRating}",
                                  style: boldDefault.copyWith(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${bid.driver?.getFullName()}",
                          style: boldDefault.copyWith(
                            fontSize: 18,
                            color: MyColor.rideTitle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "الكابتن قريب منك • ${ride.duration}",
                          style: regularDefault.copyWith(
                            color: MyColor.bodyTextColor.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "$currency${StringConverter.formatNumber(bid.bidAmount.toString())}",
                        style: boldDefault.copyWith(
                          fontSize: 20,
                          color: MyColor.primaryColor,
                        ),
                      ),
                      Text(
                        "عرض السائق",
                        style: regularDefault.copyWith(
                          fontSize: 11,
                          color: MyColor.bodyTextColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(height: 1, thickness: 0.5),
              ),

              // Ride Rules (Chips Style)
              if (bid.driver?.rules?.isNotEmpty ?? false) ...[
                Text(
                  MyStrings.rideRulse.tr,
                  style: boldDefault.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    bid.driver?.rules?.length ?? 0,
                    (index) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: MyColor.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        bid.driver?.rules?[index] ?? "",
                        style: regularDefault.copyWith(
                          fontSize: 12,
                          color: MyColor.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () => controller.rejectBid(bid.id.toString()),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child:
                            controller.isRejectLoading &&
                                controller.selectedId == bid.id.toString()
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                            : Text(
                                MyStrings.reject.tr,
                                style: boldDefault.copyWith(color: Colors.red),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () => controller.acceptBid(
                        bid.id.toString(),
                        ride.id.toString(),
                      ),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: MyColor.primaryColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: MyColor.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child:
                            controller.isAcceptLoading &&
                                controller.selectedId == bid.id.toString()
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                MyStrings.confirm.tr,
                                style: boldDefault.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

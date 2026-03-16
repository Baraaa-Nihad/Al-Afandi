import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:ovoride/data/controller/rider/home/home_controller.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/presentation/components/shimmer/ride_services_shimmer.dart';
import 'package:ovoride/presentation/screens/rider/home/widgets/service_card.dart';

class RideServiceSection extends StatelessWidget {
  const RideServiceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final services = controller.appServicesList;

        return Container(
          decoration: BoxDecoration(
            color: MyColor.getCardBgColor(),
            boxShadow: MyUtils.getCardShadow(),
            borderRadius: BorderRadius.circular(Dimensions.moreRadius),
          ),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.space16,
            vertical: Dimensions.space16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MyStrings.selectService.tr,
                style: boldLarge.copyWith(
                  color: MyColor.getRideTitleColor(),
                  fontWeight: FontWeight.w500,
                  fontSize: Dimensions.fontTitleLarge,
                ),
              ),
              spaceDown(Dimensions.space10),
              if (controller.isLoading) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: MyColor.colorWhite,
                  child: const RideServiceShimmer(),
                )
              ] else ...[
                if (services.isNotEmpty) ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 500,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.space10),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            await controller.selectService(services[index], shouldLoadFare: true);
                          },
                          child: ServiceCard(
                            service: services[index],
                            controller: controller,
                          ),
                        );
                      },
                    ),
                  )
                ] else
                  Container(
                    decoration: BoxDecoration(
                      color: MyColor.neutral50,
                      boxShadow: MyUtils.getCardShadow(),
                      borderRadius: BorderRadius.circular(Dimensions.moreRadius),
                    ),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.space16,
                      vertical: Dimensions.space16,
                    ),
                    child: Text(
                      MyStrings.noServiceAvailable.tr,
                      style: mediumSmall.copyWith(color: MyColor.redCancelTextColor),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

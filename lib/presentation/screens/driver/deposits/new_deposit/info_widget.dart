import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/presentation/components/card/custom_app_card.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';

import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/data/controller/driver/deposit/add_new_deposit_controller.dart';
import 'package:ovoride/presentation/components/row_widget/custom_row.dart';

class InfoWidget extends StatelessWidget {
  const InfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddNewDepositController>(
      builder: (controller) {
        bool showRate = controller.isShowRate();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            spaceDown(Dimensions.space16),
            CustomAppCard(
              child: Column(
                children: [
                  CustomRow(
                    firstText: MyStrings.depositLimit.tr,
                    lastText: controller.depositLimit,
                  ),
                  CustomRow(
                    firstText: MyStrings.depositCharge.tr,
                    lastText: controller.charge,
                  ),
                  CustomRow(
                    firstText: MyStrings.payable.tr,
                    lastText: controller.payableText,
                    showDivider: showRate,
                  ),
                  showRate
                      ? CustomRow(
                          firstText: MyStrings.conversionRate.tr,
                          lastText: controller.conversionRate,
                          showDivider: showRate,
                        )
                      : const SizedBox.shrink(),
                  showRate
                      ? CustomRow(
                          firstText: 'in ${controller.paymentMethod?.currency}'.tr,
                          lastText: controller.inLocal,
                          showDivider: false,
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

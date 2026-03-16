import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/data/controller/rider/payment/ride_payment_controller.dart';
import 'package:ovoride/presentation/components/annotated_region/annotated_region_widget.dart';

import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/presentation/components/bottom-sheet/bottom_sheet_header_row.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/presentation/components/text/header_text.dart';
import 'package:ovoride/presentation/screens/rider/payment/topup_screen/payment_method_card.dart';

class RiderPaymentMethodListBottomSheet extends StatelessWidget {
  const RiderPaymentMethodListBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RidePaymentController>(
      builder: (controller) {
        return AnnotatedRegionWidget(
          child: Container(
            height: context.height / 1.3,
            color: MyColor.colorWhite,
            child: Column(
              children: [
                const BottomSheetHeaderRow(),
                HeaderText(
                  text: MyStrings.selectPaymentMethod,
                  style: mediumOverLarge.copyWith(
                    fontSize: Dimensions.fontOverLarge,
                    fontWeight: FontWeight.normal,
                    color: MyColor.colorBlack,
                  ),
                ),
                spaceDown(Dimensions.space15),
                Flexible(
                  child: ListView.builder(
                    itemCount: controller.methodList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return PaymentMethodCard(
                        paymentMethod: controller.methodList[index],
                        assetPath: controller.imagePath,
                        selected: controller.methodList[index].id.toString() == controller.selectedMethod.id.toString(),
                        press: () {
                          controller.updateSelectedGateway(
                            controller.methodList[index],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/presentation/components/card/custom_app_card.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_images.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/data/controller/driver/ride/ride_details/ride_details_controller.dart';
import 'package:ovoride/presentation/components/buttons/rounded_button.dart';

class PaymentReceiveDialog extends StatelessWidget {
  const PaymentReceiveDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideDetailsController>(
      tag: 'driver',
      builder: (controller) => Dialog(
        backgroundColor: MyColor.transparentColor,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space40,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.moreRadius),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomAppCard(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Lottie.asset(MyImages.receivePayment, height: 250),
                    Column(
                      children: [
                        Text(
                          MyStrings.pleaseReceivePayment.tr,
                          style: semiBoldDefault.copyWith(
                            color: MyColor.getPrimaryColor(),
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          MyStrings.pleaseReceivePaymentSubtitle.tr,
                          style: lightDefault.copyWith(
                            color: MyColor.getBodyTextColor(),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    spaceDown(Dimensions.space15),
                    RoundedButton(
                      isLoading: controller.isAcceptPaymentBtnLoading,
                      text: MyStrings.confirmPayemnt.tr,
                      press: () {
                        controller.acceptPaymentRide(
                          controller.ride.id ?? '',
                          context,
                        );
                      },
                      textColor: MyColor.colorWhite,
                    ),
                    spaceDown(Dimensions.space10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

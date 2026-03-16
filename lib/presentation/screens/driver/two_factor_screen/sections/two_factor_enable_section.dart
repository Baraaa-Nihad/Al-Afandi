import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/presentation/components/card/custom_app_card.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/presentation/components/otp_field_widget/otp_field_widget.dart';

import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/controller/shared/auth/two_factor_controller.dart';
import 'package:ovoride/presentation/components/buttons/rounded_button.dart';
import 'package:ovoride/presentation/components/text/small_text.dart';
import '../widget/enable_qr_code_widget.dart';

class TwoFactorEnableSection extends StatelessWidget {
  const TwoFactorEnableSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TwoFactorController>(
      builder: (twoFactorController) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                CustomAppCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MyStrings.addYourAccount.tr,
                        style: boldExtraLarge.copyWith(
                          color: MyColor.colorBlack,
                        ),
                      ),
                      Text(
                        MyStrings.useQRCODETips.tr,
                        style: regularDefault.copyWith(
                          color: MyColor.getBodyTextColor(),
                        ),
                      ),
                      spaceDown(Dimensions.space20),
                      if (twoFactorController.twoFactorCodeModel.data?.qrCodeUrl != null) ...[
                        EnableQRCodeWidget(
                          qrImage: twoFactorController.twoFactorCodeModel.data?.qrCodeUrl ?? '',
                          secret: "${twoFactorController.twoFactorCodeModel.data?.secret}",
                        ),
                      ],
                    ],
                  ),
                ),
                spaceDown(Dimensions.space15),
                CustomAppCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MyStrings.enable2Fa.tr,
                        style: boldExtraLarge.copyWith(
                          color: MyColor.colorBlack,
                        ),
                      ),
                      spaceDown(Dimensions.space5),
                      SmallText(
                        text: MyStrings.twoFactorMsg.tr,
                        maxLine: 3,
                        textAlign: TextAlign.start,
                        textStyle: regularDefault.copyWith(
                          color: MyColor.getBodyTextColor(),
                        ),
                      ),
                      spaceDown(Dimensions.space30),
                      OTPFieldWidget(
                        onChanged: (value) {
                          twoFactorController.currentText = value;
                          twoFactorController.update();
                        },
                      ),
                      const SizedBox(height: Dimensions.space30),
                      RoundedButton(
                        isLoading: twoFactorController.submitLoading,
                        press: () {
                          twoFactorController.enable2fa(
                            twoFactorController.twoFactorCodeModel.data?.secret ?? '',
                            twoFactorController.currentText,
                          );
                        },
                        text: MyStrings.submit.tr,
                      ),
                      spaceDown(Dimensions.space30),
                    ],
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
